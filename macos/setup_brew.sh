#!/usr/bin/env bash
set -ux

echo "[INFO] Setup brew"

hash brew 2>/dev/null
if [[ $? != 0 ]] ;then
  # install homebrew without prompt
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
fi

brew install git
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
brew install fzf

brew install shellcheck
# personal dev
brew install hugo
brew install qemu
brew install less
# cloud tools
brew install cloudfoundry/tap/cf-cli
brew install bosh-cli

# install GUI tools via cask
brew cask install adaptor
brew cask install appcleaner
brew cask install alfred
echo "set setting sync with powerpack"
brew cask install spectacle
brew cask install cmd-eikana # japanese input tool
brew cask install google-chrome
brew cask install google-backup-and-sync # used to be google-drive
brew cask install google-japanese-ime
brew cask install slack
brew cask install kap
brew cask install dropbox
brew cask install lastpass
# dev
brew cask install iterm2
brew cask install visual-studio-code
brew cask install google-cloud-sdk
brew cask install wireshark

# echo tools that cannot be installed via cask
echo "need to install manually"
echo "> Install Pixelmator"
echo "> Install Bear"
echo "> Install Gitify"
echo "> Install LINE"
