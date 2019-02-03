#!/usr/bin/env bash

IS_BREW_INSTALLED=$(hash brew 2>/dev/null)
if [ ! $IS_BREW_INSTALLED ] ;then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
brew install plantuml 
brew install less
brew install shellcheck

# install GUI tools
brew install appcleaner
brew install alfred
brew install vivaldi
brew install google-backup-and-sync # used to be google-drive
brew install google-japanese-ime
brew install dropbox
brew install slack
brew install iterm2
brew install kap 
brew install boostnote 
brew install lastpass
brew install cmd-eikana # japanese input tool
echo_yellow "change : -> ; and L_CMD -> ei, R_CMD -> kana"

# echo tools that cannot be installed
echo_green "Install LINE"
echo_green "Install Pixelmator"
