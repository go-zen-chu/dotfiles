.PHONY: setup-mac is-mac setup-linux setup-defaults setup-brew setup-atom setup-zsh setup-vim setup-anyenv

# check what os it is
UNAME_S := $(shell uname -s)
IS_OS_X := false
IS_LINUX := false
ifeq ($(UNAME_S),Linux)
    IS_LINUX := true
endif
ifeq ($(UNAME_S),Darwin)
    IS_OS_X := true
endif

CURDIR := $(shell pwd)
$(info "Start make for $(UNAME_S) at $(CURDIR)")

setup-mac: is-mac mac-prepare setup-defaults setup-brew setup-vim setup-atom setup-tmux setup-zsh setup-anyenv

setup-linux: is-linux linux-prepare setup-vim setup-tmux setup-anyenv setup-zsh

#========================== OSX ==========================

is-mac:
ifeq ($(IS_OS_X), false)
	@echo "Not OS X. Aborting..."
	exit 1
endif
	@echo "Is OS X. Continue."

mac-prepare:
	# install developer tool
	xcode-select --install

setup-defaults: osx/setup_defaults.sh
	@echo "Setup Defaults"
	$(shell ./osx/setup_defaults.sh)

setup-brew: osx/setup_brew.sh
	@echo "Setup Brew"
	$(shell ./osx/setup_brew.sh)

#========================== LINUX ==========================
is-linux:
ifeq ($(IS_LINUX), false)
	@echo "Not Linux. Aborting..."
	exit 1
endif
	@echo "Is Linux. Continue."

linux-prepare:
	# -y for yes to all
	yum -y install git
	# cp all outer repos
	sudo cp yum/.* /etc/yum.repos.d/
	yum update

#========================== OS Common ==========================
setup-bash: bash/setup_bash.sh
	$(shell ./bash/setup_bash.sh)

setup-zsh: zsh/setup_zsh.sh
	$(shell ./zsh/setup_zsh.sh)

setup-vim:
	$(shell ./vim/setup_vim.sh)

setup-atom:
	$(shell ./atom/setup_atom.sh)

setup-anyenv:
	$(shell ./anyenv/setup_anyenv.sh)

setup-tmux:
	$(shell ./tmux/setup_tmux.sh)
