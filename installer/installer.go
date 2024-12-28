package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"slices"
	"strings"
	"time"

	ios "github.com/go-zen-chu/dotfiles/installer/os"

	"github.com/go-zen-chu/dotfiles/internal/printer"
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
	d.ShowWelcomeMessage()

	if err := d.CheckOS(); err != nil {
		return "", fmt.Errorf("while checking os: %w", err)
	}

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

func (d *dotfilesInstaller) ShowWelcomeMessage() {
	d.printer.Emphasize("[welcome to dotfiles installer, let's start setup]")
}

func (d *dotfilesInstaller) CheckOS() error {
	d.printer.Info("Checking OS...")
	os, err := ios.GetOS()
	if err != nil {
		return fmt.Errorf("get OS: %w", err)
	}
	d.os = os
	d.printer.Info("OS: %s", os)
	return nil
}

func (d *dotfilesInstaller) Install(cmd string) error {
	d.printer.Emphasize("Installing dotfiles")

	// setup package manager and install tools
	err := d.SetupPackageManager()
	if err != nil {
		return fmt.Errorf("setup package manager: %w", err)
	}
	// install and setup git
	// install and setup zsh
	// install and setup tmux
	// install and setup vim
	// install and setup anyenv
	// install and setup golang

	// gbt.RunLongRunningCmdWithLog()
	d.WaitUserInput()
	return nil
}

const (
	installHomebrewCommand = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
)

func (d *dotfilesInstaller) SetupPackageManager() error {
	switch d.os {
	case "darwin":
	case "ubuntu":
		// stdout, stderr, err := gbt.RunLongRunningCmdWithLog(installHomebrewCommand)
		// if err != nil {
		// 	return fmt.Errorf("fail install homebrew stdout: %s, stderr: %s, error: %w", stdout, stderr, err)
		// }
		// d.printer.Stdout(stdout)
		// d.printer.Stderr(stderr)
		cmd1 := exec.Command("/bin/bash", "-c", "\"#!/bin/bash\necho hello\"")
		out, err := cmd1.CombinedOutput()
		if err != nil {
			return fmt.Errorf("fail install homebrew stdout/err: %s, error: %w", out, err)
		}
		d.printer.Stdout(string(out))
	case "windows":
		d.printer.Info("no setup for windows")
	}
	d.printer.Info("setup package manager done")
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
