package main

import (
	"context"
	"fmt"
	"net/url"
	"strings"
	"unicode"

	"github.com/databricks/databricks-sdk-go/config"
	"github.com/databricks/databricks-sdk-go/logger"
)

func main() {
	logger.DefaultLogger = &logger.SimpleLogger{Level: logger.LevelError + 1}
	fmt.Print(contextText(&config.Config{}))
}

func contextText(cfg *config.Config) string {
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
	if cfg.Profile == "" {
		return host.Host
	}
	return cfg.Profile + " @ " + host.Host
}
