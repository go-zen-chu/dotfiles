package os

import (
	"errors"
	"fmt"
	"os"
	"regexp"
	"runtime"
	"strings"
)

const (
	osReleasePath = "/etc/os-release"
)

var (
	// (?m) matches every line
	osDistroRegex  = regexp.MustCompile(`(?m)^NAME="(.*)"`)
	osVersionRegex = regexp.MustCompile(`(?m)^VERSION_ID="(.*)"`)
)

// GetOS returns the current OS and returns an error when os is not supported
func GetOS() (string, error) {
	goos := runtime.GOOS
	switch goos {
	case "darwin":
		return goos, nil
	case "windows":
		return goos, nil
	case "linux":
		distro, version, err := GetLinuxDistroAndVersion()
		if err != nil {
			return "", fmt.Errorf("could not get linux distro and version: %w", err)
		}
		if distro == "ubuntu" {
			return "ubuntu", nil
		}
		return "", fmt.Errorf("unsupported linux distro, version: %s, %s", distro, version)

	}
	return "", fmt.Errorf("unsupported os: %s", goos)
}

func GetLinuxDistroAndVersion() (string, string, error) {
	if _, err := os.Stat(osReleasePath); err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return "", "", fmt.Errorf("could not find %s", osReleasePath)
		}
		return "", "", fmt.Errorf("could not stat %s: %w", osReleasePath, err)
	}
	cnt, err := os.ReadFile(osReleasePath)
	if err != nil {
		return "", "", fmt.Errorf("could not read %s: %w", osReleasePath, err)
	}
	distroMatch := osDistroRegex.FindStringSubmatch(string(cnt))
	if len(distroMatch) != 2 {
		return "", "", fmt.Errorf("could not find os distro in %s (match: %d)", osReleasePath, len(distroMatch))
	}
	versionMatch := osVersionRegex.FindStringSubmatch(string(cnt))
	if len(versionMatch) != 2 {
		return "", "", fmt.Errorf("could not find os version in %s (match: %d)", osReleasePath, len(versionMatch))
	}
	return strings.ToLower(distroMatch[1]), versionMatch[1], nil
}
