package main

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"

	"github.com/databricks/databricks-sdk-go/config"
	"github.com/databricks/databricks-sdk-go/config/credentials"
	"github.com/databricks/databricks-sdk-go/logger"
)

func TestMain(m *testing.M) {
	logger.DefaultLogger = &logger.SimpleLogger{Level: logger.LevelError + 1}
	os.Exit(m.Run())
}

func isolatedConfig(t *testing.T) *config.Config {
	t.Helper()
	for _, attribute := range config.ConfigAttributes {
		for _, variable := range attribute.EnvVars {
			t.Setenv(variable, "")
		}
	}
	t.Setenv("HOME", t.TempDir())
	return &config.Config{
		Credentials: forbiddenCredentials{t},
		HTTPTransport: transportFunc(func(*http.Request) (*http.Response, error) {
			t.Fatal("configuration resolution attempted an HTTP request")
			return nil, errors.New("forbidden HTTP request")
		}),
	}
}

type forbiddenCredentials struct{ t *testing.T }

func (forbiddenCredentials) Name() string { return "forbidden" }

func (c forbiddenCredentials) Configure(context.Context, *config.Config) (credentials.CredentialsProvider, error) {
	c.t.Fatal("configuration resolution attempted authentication")
	return nil, errors.New("forbidden authentication")
}

type transportFunc func(*http.Request) (*http.Response, error)

func (f transportFunc) RoundTrip(request *http.Request) (*http.Response, error) {
	return f(request)
}

func TestSDKResolution(t *testing.T) {
	const profiles = "[DEFAULT]\nhost = https://default.example\ntoken = SECRET_SENTINEL\n[staging]\nhost = https://staging.example\n[production]\nhost = https://production.example\n"
	cases := []struct {
		name string
		file string
		env  map[string]string
		want string
	}{
		{name: "legacy default", file: profiles, want: "DEFAULT (https://default.example)"},
		{name: "saved default", file: "[__settings__]\ndefault_profile = staging\n" + profiles, want: "staging (https://staging.example)"},
		{name: "explicit profile", file: profiles, env: map[string]string{"DATABRICKS_CONFIG_PROFILE": "production"}, want: "production (https://production.example)"},
		{name: "host overrides file", file: profiles, env: map[string]string{"DATABRICKS_HOST": "https://override.example/"}, want: "(https://override.example)"},
		{name: "host overrides selected profile", file: profiles, env: map[string]string{"DATABRICKS_CONFIG_PROFILE": "staging", "DATABRICKS_HOST": "https://override.example"}, want: "staging (https://override.example)"},
		{name: "SDK auth environment skips default", file: profiles, env: map[string]string{"DATABRICKS_TOKEN": "SECRET_SENTINEL"}},
		{name: "host only", env: map[string]string{"DATABRICKS_HOST": "https://workspace.example"}, want: "(https://workspace.example)"},
		{name: "missing configuration"},
		{name: "missing requested profile", file: profiles, env: map[string]string{"DATABRICKS_CONFIG_PROFILE": "missing"}},
		{name: "malformed configuration", file: "[broken\n"},
		{name: "custom configuration file", env: map[string]string{"DATABRICKS_CONFIG_FILE": "custom"}, file: profiles, want: "DEFAULT (https://default.example)"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			cfg := isolatedConfig(t)
			configPath := filepath.Join(os.Getenv("HOME"), ".databrickscfg")
			if tc.env["DATABRICKS_CONFIG_FILE"] != "" {
				configPath = filepath.Join(t.TempDir(), "custom.ini")
				t.Setenv("DATABRICKS_CONFIG_FILE", configPath)
			}
			if tc.file != "" {
				if err := os.WriteFile(configPath, []byte(tc.file), 0600); err != nil {
					t.Fatal(err)
				}
			}
			for key, value := range tc.env {
				if key != "DATABRICKS_CONFIG_FILE" {
					t.Setenv(key, value)
				}
			}
			if got := contextText(cfg, true); got != tc.want {
				t.Fatalf("contextText() = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestDisplaySafety(t *testing.T) {
	cases := []struct {
		name, profile, host, want string
	}{
		{"bare host", "staging", "workspace.example", "staging (https://workspace.example)"},
		{"port", "", "http://localhost:1234/", "(http://localhost:1234)"},
		{"IPv6", "", "http://[::1]:1234/", "(http://[::1]:1234)"},
		{"SDK removes URL extras", "", "https://user:SECRET_SENTINEL@workspace.example/path?token=SECRET_SENTINEL#fragment", "(https://workspace.example)"},
		{"printable punctuation", "dev '$()`[]%F{red}\\", "https://workspace.example", "dev '$()`[]%F{red}\\ (https://workspace.example)"},
		{"newline profile", "staging\n", "https://workspace.example", ""},
		{"escape profile", "staging\x1b[31m", "https://workspace.example", ""},
		{"DEL profile", "staging\x7f", "https://workspace.example", ""},
		{"invalid host", "", "https://SECRET_SENTINEL%zz", ""},
		{"newline host", "", "https://workspace.example\nSECRET_SENTINEL", ""},
		{"unsupported scheme", "", "ftp://workspace.example", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			cfg := isolatedConfig(t)
			cfg.Profile, cfg.Host = tc.profile, tc.host
			if got := contextText(cfg, true); got != tc.want {
				t.Fatalf("contextText() = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestLayout(t *testing.T) {
	cases := []struct {
		name    string
		profile string
		showURL bool
		want    string
	}{
		{name: "profile only", profile: "staging", want: "staging"},
		{name: "profile and URL", profile: "staging", showURL: true, want: "staging (https://workspace.example)"},
		{name: "host only stays hidden by default"},
		{name: "host only with URL enabled", showURL: true, want: "(https://workspace.example)"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			cfg := isolatedConfig(t)
			cfg.Profile, cfg.Host = tc.profile, "https://workspace.example"
			if got := contextText(cfg, tc.showURL); got != tc.want {
				t.Fatalf("contextText() = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestNoMetadataOrCredentialHelper(t *testing.T) {
	var requests atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		requests.Add(1)
	}))
	defer server.Close()
	cfg := isolatedConfig(t)
	cfg.Host = server.URL
	bin := t.TempDir()
	sentinel := filepath.Join(bin, "helper-was-run")
	if err := os.WriteFile(filepath.Join(bin, "az"), []byte("#!/bin/sh\ntouch '"+sentinel+"'\n"), 0755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", bin+":"+os.Getenv("PATH"))
	t.Setenv("DATABRICKS_AUTH_TYPE", "azure-cli")
	if got := contextText(cfg, true); got != "("+server.URL+")" {
		t.Fatalf("unexpected context %q", got)
	}
	if requests.Load() != 0 {
		t.Fatal("metadata endpoint received requests")
	}
	if _, err := os.Stat(sentinel); !os.IsNotExist(err) {
		t.Fatal("credential helper was executed")
	}
}
