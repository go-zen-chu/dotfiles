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

.PHONY: setup-arch
## setup archlinux from scratch 
setup-arch: setup-common
	@echo "setup ArchLinux finish"

.PHONY: setup-windows
## setup windows from scratch 
setup-windows:
	cat ./windows/README.md
	@echo "setup Windows finish"

.PHONY: setup-ubuntu
### setup ubuntu from scratch
setup-ubuntu: setup-ubuntu-config setup-common
	@echo "setup Ubuntu finish"

.PHONY: setup-ubuntu-config
### set config for ubuntu from scratch
setup-ubuntu-config:
	sudo dpkg-reconfigure locales

.PHONY: setup-common
## setup common packages
setup-common: aqua zsh vim tmux git

.PHONY: aqua
## setup aqua and install tools
aqua:
	@./aqua/setup.sh

.PHONY: zsh
## setup zsh
zsh:
	@./zsh/setup.sh

.PHONY: vim
## setup vim
vim:
	@./vim/setup.sh

.PHONY: tmux
## setup tmux
tmux:
	@./tmux/setup.sh

.PHONY: git
## setup git
git:
	@./git/setup.sh

.PHONY: backup
## backup files
backup:
	@./make/backup.sh
