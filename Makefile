.PHONY: setup-mac is-mac mac-prepare setup-defaults setup-brew setup-centos centos-setup-yum centos-setup-docker setup-bash setup-zsh setup-vim setup-tmux setup-anyenv

# check what os it is
UNAME_S := $(shell uname -s)
IS_MACOS := false
IS_CENTOS := false

ifeq ($(UNAME_S),Darwin)
  IS_MACOS := true
else ifneq (,$(wildcard /etc/redhat-release))
  IS_CENTOS := true
else
  @echo "Not supported OS. Aborting..."
	exit 1
endif

CURDIR := $(shell pwd)
$(info "Start make for $(UNAME_S) at $(CURDIR)")

setup-mac: is-mac mac-prepare setup-defaults setup-brew setup-vim setup-plantuml setup-tmux setup-zsh setup-anyenv

setup-centos: is-centos centos-setup-yum centos-setup-docker setup-vim setup-tmux setup-zsh setup-anyenv

#========================== OSX ==========================
is-mac:
ifeq ($(IS_MACOS), false)
	@echo "Not OS X. Aborting..."
	exit 1
endif
	@echo "Is OS X. Continue."

mac-prepare:
	$(shell ./osx/check_developer_tool.sh)

setup-defaults: osx/setup_defaults.sh
	@echo "Setup Defaults"
	$(shell ./osx/setup_defaults.sh)

setup-brew: osx/setup_brew.sh
	@echo "Setup Brew"
	$(shell ./osx/setup_brew.sh)

#========================== CentOS ==========================
is-centos:
ifeq ($(IS_CENTOS), false)
	@echo "Not CentOS. Aborting..."
	exit 1
endif
	@echo "Is CentOS. Continue."

centos-setup-yum:
	@echo "Setup yum"
	sudo yum update ; \
	sudo yum install -y git ; \
	sudo yum install -y wget ; \
	sudo yum install -y jq

centos-setup-docker:
	@echo "Setup docker"
	# https://docs.docker.com/install/linux/docker-ce/centos/
	sudo yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine ; \
	sudo yum install -y yum-utils \
	  device-mapper-persistent-data \
	  lvm2 ; \
	sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo ; \
	sudo yum install docker-ce docker-ce-cli containerd.io

#========================== OS Common ==========================
setup-bash: bash/setup_bash.sh
	$(shell ./bash/setup_bash.sh)

setup-zsh: zsh/setup_zsh.sh
	$(shell ./zsh/setup_zsh.sh)

setup-vim:
	$(shell ./vim/setup_vim.sh)

setup-plantuml:
	$(shell ./plantuml/setup_plantuml.sh)

setup-anyenv:
	$(shell ./anyenv/setup_anyenv.sh)

setup-tmux:
	$(shell ./tmux/setup_tmux.sh)
