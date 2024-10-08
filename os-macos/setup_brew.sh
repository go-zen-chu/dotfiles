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
brew install nmap  # for checking network
brew install gibo  # for creating .gitignore
brew install watch # periodical command execution
brew install tree
brew install tig
brew install anyenv
brwe install node@20
# cloud tools
brew install ansible
brew install kubernetes-cli
brew install kustomize
# Automate App-Store installation
brew install mas

# install GUI tools
#brew install --cask adapter
brew install --cask appcleaner
brew install --cask alfred
echo_green "INFO: [Alfred] setup sync config with powerpack"
# setup keyboard custom setting
brew install --cask karabiner-elements
if [[ ! -d "${HOME}/.config/karabiner" ]]; then
	mkdir -p "${HOME}/.config"
	cp -R ./os-macos/karabiner "${HOME}/.config"
fi
brew install --cask google-chrome
brew install --cask google-backup-and-sync # used to be google-drive
brew install --cask google-japanese-ime
brew install --cask licecap
brew install --cask raycast
brew install --cask hiddenbar
# dev
brew install --cask iterm2
echo_green "INFO: [iTerm2] set iterm config path to ${HOME}/dotfiles/macos/iterm/com.googlecode.iterm2.plist"
brew install --cask visual-studio-code
brew install --cask wireshark

if [[ "$setup_type" == "personal" ]]; then
	# blog tools
	brew install hugo
	brew install sass/sass/sass
	# os tools
	brew install qemu

	brew install --cask slack
	brew install --cask zoomus
	# dev
	brew install --cask google-cloud-sdk
	brew install --cask hex-fiend
	brew install --cask balenaetcher # os image tool
	mas install 539883307            # LINE
	mas install 585829637            # Todoist
fi
