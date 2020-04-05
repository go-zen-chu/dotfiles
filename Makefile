.PHONY: help
## print all available commands
help:
	@./make/help.sh

.PHONY: setup-mac
## setup mac from scratch 
setup-mac: macos zsh vim tmux git

.PHONY: setup-centos
## setup centos from scratch 
setup-centos: centos zsh vim tmux git

.PHONY: macos
## setup macos
macos:
	@./macos/check_developer_tool.sh
	@./macos/setup_defaults.sh
	@./macos/setup_brew.sh

.PHONY: centos
## setup centos
centos:
	@./centos/setup.sh

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