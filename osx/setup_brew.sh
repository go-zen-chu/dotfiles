#!/usr/bin/env bash
set -ux

# you can extend time via sudo visudo https://www.tecmint.com/set-sudo-password-timeout-session-longer-linux/
sudo -v # sudoing first

hash brew 2>/dev/null
if [[ $? != 0 ]] ;then
  # install homebrew without prompt
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
fi

function echo_green() {
  echo "\e[32m$1\e[m"
}

function echo_yellow() {
  echo "\e[33m$1\e[m"
}

brew install git
brew install openssl # not supported from El Capitan
brew install wget
brew install rsync
brew install nmap # for checking network
brew install gibo # for creating .gitignore
brew install direnv
brew install watch # periodical command execution
brew install jq
brew install bat
brew install tree
brew install gsed
brew install less
brew install shellcheck

sudo -v

# install GUI tools via cask
brew cask install appcleaner
brew cask install alfred
echo_yellow "set setting sync with powerpack"
# brew cask install vivaldi
brew cask install google-chrome
brew cask install google-backup-and-sync # used to be google-drive
brew cask install google-japanese-ime
brew cask install google-cloud-sdk
brew cask install dropbox
brew cask install slack
echo_yellow "set slack channels"
brew cask install iterm2
brew cask install kap
brew cask install lastpass
brew cask install cmd-eikana # japanese input tool
echo_yellow "change : -> ;"

# cloud tools
brew install cloudfoundry/tap/cf-cli
brew install bosh-cli
# install ruby then install uaac
echo_yellow "gem install cf-uaac"

# echo tools that cannot be installed via cask
echo_green "Install LINE"
echo_green "Install Pixelmator"
echo_green "Install Bear"
echo_green "Install Gitify"
