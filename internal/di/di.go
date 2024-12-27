package di

import (
	"log/slog"
	"os"

	"github.com/go-zen-chu/dotfiles/internal/printer"
)

type Container struct {
	cache map[string]any
}

func NewContainer() *Container {
	return &Container{
		cache: map[string]any{},
	}
}

func initOnce[T any](c *Container, component string, fn func() (T, error)) T {
	if v, ok := c.cache[component]; ok {
		return v.(T)
	}
	var err error
	v, err := fn()
	if err != nil {
		slog.Error("failed to set up "+component, "error", err)
		os.Exit(1)
	}
	c.cache[component] = v
	return v
}

func (c *Container) Printer() printer.Printer {
	return initOnce(c, "Printer", func() (printer.Printer, error) {
		return printer.NewPrinter(), nil
	})
}
