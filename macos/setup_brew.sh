#!/usr/bin/env bash
set -u

source ./make/util.sh

echo_green "[INFO] Setup brew"

if ! hash brew 2>/dev/null ; then
  # install homebrew without prompt
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
fi

# sometime it gets checksum error if not updated
brew update 

# put set +e because other setup script may set -e
set +e
brew install git || true # || true for some CI fails
brew install openssl # not supported from El Capitan
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
# personal dev
brew install hugo
brew install sass/sass/sass
# brew install qemu
# cloud tools
#brew install cloudfoundry/tap/cf-cli
#brew install bosh-cli
brew install kubectl
brew install ansible
brew install terraform
brew install anyenv

# install GUI tools 
#brew install --cask adapter
brew install --cask appcleaner
brew install --cask lfred
echo "INFO: setup sync config with powerpack"
brew install --cask amethyst
# setup keyboard custom setting
brew install --cask karabiner-elements
if [ ! -d "${HOME}/.config/karabiner" ] ; then
  mkdir -p "${HOME}/.config"
  cp -R ./macos/karabiner ${HOME}/.config
fi
brew install --cask google-chrome
brew install --cask google-backup-and-sync # used to be google-drive
brew install --cask google-japanese-ime
brew install --cask slack
brew install --cask zoomus
brew install --cask kap

# dev
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask google-cloud-sdk
brew install --cask wireshark
brew install --cask docker
# brew install --cask hex-fiend
# brew install --cask virtualbox
# brew install --cask balenaetcher # os image tool
brew install --cask jasper # github viewer

# echo tools that cannot be installed via cask
echo_green "need to install manually"
echo_yellow "> Install Pixelmator"
echo_yellow "> Install Bear"
echo_yellow "> Install LINE"
