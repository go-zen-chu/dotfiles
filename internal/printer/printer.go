package printer

import "github.com/fatih/color"

type Printer interface {
	Info(format string, args ...any)
	Emphasize(format string, args ...any)
	Stdout(format string, args ...any)
	Stderr(format string, args ...any)
	Error(format string, args ...any)
	Success(format string, args ...any)
	Warn(format string, args ...any)
}

type printer struct {
}

func NewPrinter() Printer {
	return &printer{}
}

func (p *printer) Info(format string, args ...any) {
	color.White(format, args...)
}

func (p *printer) Emphasize(format string, args ...any) {
	color.HiGreen(format, args...)
}

func (p *printer) Stdout(format string, args ...any) {
	// sky blue
	color.RGB(135, 206, 235).Printf(format, args...)
}

func (p *printer) Stderr(format string, args ...any) {
	// indian red
	color.RGB(205, 92, 92).Printf(format, args...)
}

func (p *printer) Error(format string, args ...any) {
	color.HiRed(format, args...)
}

func (p *printer) Success(format string, args ...any) {
	color.Blue(format, args...)
}

func (p *printer) Warn(format string, args ...any) {
	color.Yellow(format, args...)
}
