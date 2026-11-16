package main

import (
	"context"
	"flag"
	"fmt"
	"net/url"
	"strings"
	"unicode"

	"github.com/databricks/databricks-sdk-go/config"
	"github.com/databricks/databricks-sdk-go/logger"
)

func main() {
	showURL := flag.Bool("show-url", false, "Show the workspace URL after the profile.")
	flag.Parse()
	logger.DefaultLogger = &logger.SimpleLogger{Level: logger.LevelError + 1}
	fmt.Print(contextText(&config.Config{}, *showURL))
}

func contextText(cfg *config.Config, showURL bool) string {
	// Config resolution otherwise fetches host metadata before authentication.
	cfg.HostMetadataResolver = func(context.Context, string) (*config.HostMetadata, error) {
		return nil, nil
	}
	if err := cfg.EnsureResolved(); err != nil {
		return ""
	}
	if strings.ContainsFunc(cfg.Profile, unicode.IsControl) || strings.ContainsFunc(cfg.Host, func(r rune) bool {
		return unicode.IsControl(r) || unicode.IsSpace(r)
	}) {
		return ""
	}
	host, err := url.Parse(cfg.Host)
	if err != nil || (host.Scheme != "https" && host.Scheme != "http") || host.Hostname() == "" ||
		host.User != nil || host.Path != "" || host.RawQuery != "" || host.ForceQuery || host.Fragment != "" {
		return ""
	}
	if !showURL {
		return cfg.Profile
	}
	if cfg.Profile == "" {
		return "(" + cfg.Host + ")"
	}
	return cfg.Profile + " (" + cfg.Host + ")"
}
