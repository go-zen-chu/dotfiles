.PHONY: help
## print all available commands
help:
	@./make/help.sh

.PHONY: setup-mac
## setup for macOS (minimum setup)
setup-mac: macos setup-common
	@echo "setup MacOS finish"

.PHONY: setup-mac-personal
## setup for macOS with personal development tools	
setup-mac-personal: macos-personal setup-common

.PHONY: setup-centos
## setup centos from scratch 
setup-centos: centos setup-common
	@echo "setup CentOS finish"

.PHONY: setup-arch
## setup centos from scratch 
setup-arch: setup-common
	@echo "setup ArchLinux finish"

.PHONY: macos
## setup macos with minimum setup
macos:
	@./macos/check_developer_tool.sh
	@./macos/setup_defaults.sh
	@./macos/setup_brew.sh minimum

.PHONY: macos-personal
## setup macos with personal dev tools
macos-personal:
	@./macos/check_developer_tool.sh
	@./macos/setup_defaults.sh
	@./macos/setup_brew.sh personal

.PHONY: centos
## setup centos
centos:
	@./centos/setup.sh

.PHONY: setup-common
## setup common packages
setup-common: zsh vim tmux git

.PHONY: vim
## setup vim
vim:
	@./vim/setup.sh

.PHONY: zsh
## setup zsh
zsh:
	@./zsh/setup.sh

.PHONY: tmux
## setup tmux
tmux:
	@./tmux/setup.sh

.PHONY: git
## setup git
git:
	@./git/setup.sh
