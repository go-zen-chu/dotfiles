package main

import (
	"os"

	"github.com/go-zen-chu/dotfiles/internal/di"
)

func main() {
	dic := di.NewContainer()
	p := di.NewContainer().Printer()
	ins := NewDotfilesInstaller(dic)
	cmd, err := ins.Startup()
	if err != nil {
		p.Error("failed to startup: %s", err)
		os.Exit(1)
	}
	err = ins.Install(cmd)
	if err != nil {
		p.Error("failed to install: %s", err)
		os.Exit(1)
	}
	p.Success("Finish setup")
	ins.WaitUserInput()
}
