#!/usr/bin/env bash
set -ux

echo "[INFO] Setup brew"

if ! hash brew 2>/dev/null ; then
  # install homebrew without prompt
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
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
brew install qemu
# cloud tools
#brew install cloudfoundry/tap/cf-cli
#brew install bosh-cli
brew install kubectl
brew install ansible
brew install terraform

# install GUI tools via cask
#brew cask install adapter
brew cask install appcleaner
brew cask install alfred
echo "INFO: setup sync config with powerpack"
brew cask install amethyst
# setup keyboard custom setting
brew cask install karabiner-elements
if [ ! -d "${HOME}/.config/karabiner" ] ; then
  mkdir -p "${HOME}/.config"
  cp -R ./macos/karabiner ${HOME}/.config
fi
brew cask install google-chrome
brew cask install google-backup-and-sync # used to be google-drive
brew cask install google-japanese-ime
brew cask install slack
brew cask install zoomus
brew cask install kap
# dev
brew cask install iterm2
brew cask install visual-studio-code
brew cask install google-cloud-sdk
brew cask install wireshark
brew cask install docker
# brew cask install hex-fiend
# brew cask install virtualbox
# brew cask install balenaetcher # os image tool
# brew cask install jasper # github viewer

# echo tools that cannot be installed via cask
echo "need to install manually"
echo "> Install Pixelmator"
echo "> Install Bear"
echo "> Install LINE"
