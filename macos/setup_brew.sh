#!/usr/bin/env bash
set -u

source ./make/util.sh
echo_green "[INFO] Setup brew"
setup_type="$1"

if [[ "$setup_type" == "minimum" || "$setup_type" == "personal" ]]; then
	echo_green "setup with $setup_type mode"
else
	echo_red "invalid setup type: $1. valid option [minimum, personal]"
	exit 1
fi

if ! hash brew 2>/dev/null; then
	# install homebrew without prompt
	# https://brew.sh/
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
fi

# sometime it gets checksum error if not updated
brew update

# put set +e because other setup script may set -e
set +e
brew install git || true # || true for some CI fails
brew install openssl     # not supported from El Capitan
brew install wget
brew install rsync
brew install nmap # for checking network
brew install gibo # for creating .gitignore
brew install direnv
brew install watch # periodical command execution
brew install jq
brew install tree
brew install gnu-sed
brew install tig
brew install shellcheck
brew install anyenv
brew install fzf
# cloud tools
brew install kubectl
brew install ansible
brew install terraform

if [[ "$setup_type" == "personal" ]]; then
	# blog tools
	brew install hugo
	brew install sass/sass/sass
	# os tools
	brew install qemu
fi

# install GUI tools
#brew install --cask adapter
brew install --cask appcleaner
brew install --cask alfred
echo "INFO: setup sync config with powerpack"
brew install --cask amethyst
# setup keyboard custom setting
brew install --cask karabiner-elements
if [ ! -d "${HOME}/.config/karabiner" ]; then
	mkdir -p "${HOME}/.config"
	cp -R ./macos/karabiner ${HOME}/.config
fi

brew install --cask google-chrome
brew install --cask google-backup-and-sync # used to be google-drive
brew install --cask google-japanese-ime
brew install --cask kap
# dev
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask wireshark
brew install --cask docker
brew install --cask jasper # github viewer

if [[ "$setup_type" == "personal" ]]; then
	brew install --cask slack
	brew install --cask zoomus
	# dev
	brew install --cask google-cloud-sdk
	brew install --cask hex-fiend
	brew install --cask balenaetcher # os image tool
	# echo tools that cannot be installed via cask
	echo_yellow "need to install manually via AppStore"
	echo_yellow "> Pixelmator"
	echo_yellow "> Bear"
	echo_yellow "> LINE"
fi
