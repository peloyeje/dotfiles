package main

import (
	"bytes"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"
)

var ansi = regexp.MustCompile(`\x1b\[[0-9;]*m`)

func runCommand(t *testing.T, command *exec.Cmd) string {
	t.Helper()
	var stderr bytes.Buffer
	command.Stderr = &stderr
	output, err := command.Output()
	if err != nil {
		t.Fatalf("%s: %v\n%s", command.Path, err, stderr.String())
	}
	if stderr.Len() != 0 {
		t.Fatalf("%s emitted stderr: %s", command.Path, stderr.String())
	}
	return string(output)
}

func TestInstallationAndPrompt(t *testing.T) {
	root, err := filepath.Abs("../..")
	if err != nil {
		t.Fatal(err)
	}
	home := t.TempDir()
	chezmoi, err := exec.LookPath("chezmoi")
	if err != nil {
		t.Fatal(err)
	}
	starship, err := exec.LookPath("starship")
	if err != nil {
		t.Fatal(err)
	}
	configFile := filepath.Join(t.TempDir(), "chezmoi.toml")
	if err := os.WriteFile(configFile, nil, 0600); err != nil {
		t.Fatal(err)
	}
	args := []string{"--source", root, "--destination", home, "--config", configFile, "execute-template"}
	template, err := os.ReadFile(filepath.Join(root, "run_onchange_after_starship-databricks.sh.tmpl"))
	if err != nil {
		t.Fatal(err)
	}
	render := exec.Command(chezmoi, args...)
	render.Stdin = bytes.NewReader(template)
	script := runCommand(t, render)
	install := exec.Command("sh", "-s")
	install.Stdin = strings.NewReader(script)
	install.Env = append(os.Environ(), "GOTOOLCHAIN=local", "GOPROXY=off", "GOSUMDB=off")
	runCommand(t, install)
	binary := filepath.Join(home, ".local/bin/starship-databricks")
	before, err := os.ReadFile(binary)
	if err != nil {
		t.Fatal(err)
	}

	t.Run("failed rebuild preserves installation", func(t *testing.T) {
		bin := t.TempDir()
		if err := os.WriteFile(filepath.Join(bin, "go"), []byte("#!/bin/sh\nexit 1\n"), 0755); err != nil {
			t.Fatal(err)
		}
		failed := exec.Command("sh", "-s")
		failed.Stdin = strings.NewReader(script)
		failed.Env = append(os.Environ(), "PATH="+bin+":"+os.Getenv("PATH"))
		if err := failed.Run(); err == nil {
			t.Fatal("expected failed build")
		}
		after, err := os.ReadFile(binary)
		if err != nil || !bytes.Equal(before, after) {
			t.Fatal("failed build changed the installed executable")
		}
		files, err := filepath.Glob(binary + ".*")
		if err != nil || len(files) != 0 {
			t.Fatalf("temporary files remain: %v, %v", files, err)
		}
	})

	t.Run("source directory is not managed", func(t *testing.T) {
		managedArgs := append(append([]string{}, args[:len(args)-1]...), "managed")
		output := runCommand(t, exec.Command(chezmoi, managedArgs...))
		if strings.Contains(output, "tools/starship-databricks") {
			t.Fatal("Go sources would be installed into the home directory")
		}
	})

	profileFile := filepath.Join(home, ".databrickscfg")
	if err := os.WriteFile(profileFile, []byte("[__settings__]\ndefault_profile = trial\n[trial]\nhost = https://workspace.example\ntoken = SECRET_SENTINEL\n"), 0600); err != nil {
		t.Fatal(err)
	}
	env := []string{
		"HOME=" + home,
		"PATH=" + filepath.Dir(binary) + ":" + os.Getenv("PATH"),
		"TERM=xterm-256color",
		"STARSHIP_CONFIG=" + filepath.Join(root, "private_dot_config/starship.toml"),
		"STARSHIP_CACHE=" + filepath.Join(home, "cache"),
	}
	invoke := func(program string, arguments []string, extra ...string) string {
		command := exec.Command(program, arguments...)
		command.Dir = home
		command.Env = append(append([]string{}, env...), extra...)
		return runCommand(t, command)
	}

	t.Run("installed resolver is quiet", func(t *testing.T) {
		for _, tc := range []struct {
			args []string
			want string
		}{
			{nil, "trial"},
			{[]string{"--show-url"}, "trial (https://workspace.example)"},
			{[]string{"--show-url=false"}, "trial"},
		} {
			if got := invoke(binary, tc.args); got != tc.want {
				t.Fatalf("arguments %v produced %q, want %q", tc.args, got, tc.want)
			}
		}
		for _, host := range []string{"https://SECRET_SENTINEL%zz", "https://workspace.example\nSECRET_SENTINEL"} {
			if got := invoke(binary, nil, "DATABRICKS_HOST="+host); got != "" {
				t.Fatalf("unsafe host produced %q", got)
			}
		}
	})

	t.Run("full prompt and AWS countdown", func(t *testing.T) {
		awsEnv := []string{"AWS_PROFILE=aws-trial", "AWS_REGION=eu-west-1", "AWS_SESSION_EXPIRATION=" + time.Now().Add(2*time.Hour).UTC().Format(time.RFC3339)}
		baseline := filepath.Join(home, "aws-baseline.toml")
		if err := os.WriteFile(baseline, []byte("[aws]\nforce_display = true\n"), 0600); err != nil {
			t.Fatal(err)
		}
		previous := invoke(starship, []string{"module", "aws"}, append(awsEnv, "STARSHIP_CONFIG="+baseline)...)
		countdown := regexp.MustCompile(`\[[0-9]+[hms]`)
		if !countdown.MatchString(ansi.ReplaceAllString(previous, "")) {
			t.Fatalf("baseline did not show a countdown: %q", previous)
		}
		prompt := invoke(starship, []string{"prompt", "--path", home, "--terminal-width", "240"}, awsEnv...)
		plain := ansi.ReplaceAllString(prompt, "")
		if strings.Count(plain, "on 󰽙 trial") != 1 || strings.Contains(plain, "workspace.example") || strings.Count(plain, "\n") != 1 {
			t.Fatalf("unexpected prompt %q", plain)
		}
		module := invoke(starship, []string{"module", "custom.databricks"})
		if !strings.HasPrefix(module, "on \x1b[1;31m󰽙 ") || !strings.Contains(plain, "aws-trial") || !strings.Contains(plain, "eu-west-1") || countdown.MatchString(plain) || strings.Contains(plain, "SECRET_SENTINEL") {
			t.Fatalf("incorrect style, AWS context, or secret handling: %q", prompt)
		}
		if hidden := invoke(starship, []string{"prompt", "--path", home}, "DATABRICKS_HOST=https://invalid%zz"); strings.Contains(hidden, "󰽙") || strings.Contains(hidden, "on ") {
			t.Fatalf("empty resolver output did not hide the prefix: %q", hidden)
		}
		if hidden := invoke(starship, []string{"prompt", "--path", home}, "PATH=/usr/bin:/bin"); strings.Contains(hidden, "󰽙") || strings.Contains(hidden, "on ") {
			t.Fatalf("missing resolver did not hide the module: %q", hidden)
		}
	})

	t.Run("optional URL in the full prompt", func(t *testing.T) {
		configuration, err := os.ReadFile(filepath.Join(root, "private_dot_config/starship.toml"))
		if err != nil {
			t.Fatal(err)
		}
		enabled := strings.Replace(string(configuration), "command = 'starship-databricks'", "command = 'starship-databricks --show-url'", 1)
		enabledPath := filepath.Join(home, "show-url.toml")
		if err := os.WriteFile(enabledPath, []byte(enabled), 0600); err != nil {
			t.Fatal(err)
		}
		prompt := invoke(starship, []string{"prompt", "--path", home}, "STARSHIP_CONFIG="+enabledPath)
		plain := ansi.ReplaceAllString(prompt, "")
		if strings.Count(plain, "on 󰽙 trial (https://workspace.example)") != 1 || strings.Count(plain, "\n") != 1 {
			t.Fatalf("unexpected URL-enabled prompt %q", plain)
		}
	})

	t.Run("zsh treats profile as literal data", func(t *testing.T) {
		sentinel := filepath.Join(home, "executed")
		profile := "dev $(touch " + sentinel + ") `touch " + sentinel + "` %F{blue} ' \\ $HOME"
		if err := os.WriteFile(profileFile, []byte("["+profile+"]\nhost = https://workspace.example\n"), 0600); err != nil {
			t.Fatal(err)
		}
		output := invoke("zsh", []string{"-f", "-c", `setopt PROMPT_SUBST; PROMPT='$("$1" prompt --path "$HOME" --terminal-width 240)'; print -rP -- "$PROMPT"`, "test", starship}, "DATABRICKS_CONFIG_PROFILE="+profile, "STARSHIP_SHELL=zsh")
		if !strings.Contains(ansi.ReplaceAllString(output, ""), "on 󰽙 "+profile) {
			t.Fatalf("profile did not survive prompt expansion: %q", output)
		}
		if _, err := os.Stat(sentinel); !os.IsNotExist(err) {
			t.Fatal("profile executed code through prompt expansion")
		}
	})
}
