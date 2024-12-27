package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strings"
	"time"

	ios "github.com/go-zen-chu/dotfiles/installer/os"

	"github.com/go-zen-chu/dotfiles/internal/printer"
	// gbt "github.com/go-zen-chu/go-build-tools"
)

var (
	commandList = []string{
		"all",
	}
)

type DotfilesInstallerRequirements interface {
	Printer() printer.Printer
}

type DotfilesInstaller interface {
	Startup() (string, error)
	Install(cmd string) error
	WaitUserInput()
}

type dotfilesInstaller struct {
	printer     printer.Printer
	stdinReader *bufio.Reader
	os          string
}

func NewDotfilesInstaller(req DotfilesInstallerRequirements) DotfilesInstaller {
	return &dotfilesInstaller{
		printer:     req.Printer(),
		stdinReader: bufio.NewReader(os.Stdin),
	}
}

func (d *dotfilesInstaller) Startup() (string, error) {
	d.printer.Emphasize("[welcome to dotfiles installer, let's start setup]")

	d.printer.Info("Checking OS...")
	os, err := ios.GetOS()
	if err != nil {
		return "", fmt.Errorf("while checking OS info: %w", err)
	}
	d.os = os
	d.printer.Info("OS: %s", os)

	d.printer.Info("Choose command to execute: [%s]\n> ", strings.Join(commandList, ", "))
	input, err := d.stdinReader.ReadString('\n')
	if err != nil {
		return "", fmt.Errorf("error reading input: %w", err)
	}
	input = strings.TrimSpace(input)
	if input == "" {
		return "", fmt.Errorf("input is empty (avilable commands: [%s])", strings.Join(commandList, ", "))
	}
	if !slices.Contains[[]string](commandList, input) {
		return "", fmt.Errorf("invalid command: %s (avilable commands: [%s])", input, strings.Join(commandList, ", "))
	}
	return input, nil
}

func (d *dotfilesInstaller) Install(cmd string) error {
	d.printer.Emphasize("Installing dotfiles")

	// gbt.RunLongRunningCmdWithLog()
	return nil
}

func (d *dotfilesInstaller) WaitUserInput() {
	d.printer.Info("Press enter to continue...")
	_, err := d.stdinReader.ReadString('\n')
	if err != nil {
		d.printer.Error("error reading input on WaitUserInput", "error", err)
		time.Sleep(30 * time.Second)
	}
}

func (d *dotfilesInstaller) errorExit(errMsg string, err error) {
	d.printer.Error(errMsg, "error", err)
	d.WaitUserInput()
	os.Exit(1)
}
