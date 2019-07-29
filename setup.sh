#!/bin/bash

set -u

# check os
declare os=$(uname -s)
case "${os}" in
"Darwin") ;;
"Linux")
    if [[ -f /etc/redhat-release ]] ; then
        os="CentOS"
    else
        echo "not supported linux (yet)"
        exit 1
    fi
    ;;
*)
    echo "not supported os (yet)"
    exit 1 
    ;;
esac

# show usage
function usage() {
    cat <<EOF
usage:  ./setup.sh
description: setup dotfiles
option:
  -h : show this help
  -u : uninstall and erase files
EOF
    exit 0
}

# returns 0 if file should be written
function confirm_overwrite() {
    declare file=$1
    if [[ -f "${file}" ]] ; then
        read -r -p "${file} exists. overwrite? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort overwrite"; return 1 ;;
        esac
    fi
    return 0
}

# returns 0 if cmd should be uninstalled
function confirm_uninstall() {
    declare cmd=$1
    command -v "${cmd}" >/dev/null 2>&1
    if [[ $? = 0 ]] ; then
        read -r -p "Do you uninstall ${cmd}? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort uninstall"; return 1 ;;
        esac
    fi
    return 1
}

#=============================== tmux ===============================
declare TMUX_VERSION="2.8"
function setup_tmux() {
    echo "> setup tmux"
    command -v tmux >/dev/null 2>&1
    if [[ $? = 1 ]] ; then
        case "${os}" in
        "Darwin")
            brew install tmux
            ;;
        "CentOS")
            pushd "${PWD}"
            yum install -y gcc make libevent-devel ncurses-devel
            cd /usr/local/src
            curl -o tmux-${TMUX_VERSION}.tar.gz -L https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
            tar -xvf tmux-${TMUX_VERSION}.tar.gz
            cd tmux-${TMUX_VERSION}
            ./configure && make
            make install > /dev/null
            popd
            ;;
        esac
        tmux -V
    else
        echo "tmux installed"
    fi
    # set tpm
    if [[ ! -d  "${HOME}/.tmux" ]] ; then
        git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    fi
    # set tmux config
    confirm_overwrite "${HOME}/.tmux.conf"
    if [[ $? = 0 ]] ; then
        cp ./tmux/.tmux.conf ${HOME}
    fi
}
function uninstall_tmux() {
    echo "> uninstall tmux"
    if [[ -f "${HOME}/.tmux.conf" ]] ; then
        rm ${HOME}/.tmux.conf
    fi
    if [[ -d "${HOME}/.tmux" ]] ; then
        rm -r "${HOME}/.tmux"
    fi
    confirm_uninstall "tmux"
    if [[ $? = 0 ]] ; then
        case "${os}" in
        "Darwin")
            brew uninstall tmux
            ;;
        "CentOS")
            pushd "${PWD}"
            yum remove -y libevent-devel ncurses-devel
            cd /usr/local/src/tmux-${TMUX_VERSION}
            make uninstall
            popd
            ;;
        esac
    fi
    echo "uninstall tmux finished"
}

#=============================== setup for mac ===============================
function check_developer_tool() {
    xcode-select -p
    # if installed returns 0 else install
    if [[ $? != 0 ]] ; then
        xcode-select --install
    else
        echo "developer tool is already installed"
    fi
}


function setup_defaults() {
    #========================== Keyboard Settings ==========================
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    # Set a shorter Delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    # ignore correction
    defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
    # change caps lock to control
    # get string like : 1452-630-0 for keyboard_id (ref: http://freewing.starfree.jp/software/macos_keyboard_setting_terminal_commandline)
    keyboard_id="$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-\n' -)-0"
    defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboard_id} -array-add "
    <dict>
    <key>HIDKeyboardModifierMappingDst</key>\
    <integer>30064771300</integer>\
    <key>HIDKeyboardModifierMappingSrc</key>\
    <integer>30064771129</integer>\
    </dict>
    "

    #========================== Trackpad Settings ==========================
    # make it click when tap trackpad
    defaults write -g com.apple.mouse.tapBehavior -int 1
    # mouse faster
    defaults write -g com.apple.mouse.scaling 5
    # Enable `Tap to click`
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    # Enable three finger tap (look up)
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    # Enable other multi-finger gestures
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2
    # mission control & expose weith 3 fingers
    defaults write com.apple.dock showMissionControlGestureEnabled -bool true
    defaults write com.apple.dock showAppExposeGestureEnabled -bool true
    defaults write com.apple.dock showDesktopGestureEnabled -bool true
    defaults write com.apple.dock showLaunchpadGestureEnabled -bool true

    #========================== Dock and Finder Settings ==========================
    # show hidden files in finder
    defaults write com.apple.finder AppleShowAllFiles YES
    # Automatically hide or show the Dock
    defaults write com.apple.dock autohide -bool true
    # Wipe all app icons from the Dock
    defaults write com.apple.dock persistent-apps -array
    # Magnificate the Dock （Dock の拡大機能を入にする）
    defaults write com.apple.dock magnification -bool true
    # restart to enable configs
    killall Finder
    killall Dock

    #========================== Safari Settings ==========================
    # Enable the `Develop` menu and the `Web Inspector`
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

    #========================== iCal Settings ==========================
    # default duration to 15m
    defaults write com.apple.iCal "Default duration in minutes for new event" 15
    # 24 hour view
    defaults write com.apple.iCal "number of hours displayed" 24

    #========================== Terminal Settings ==========================
    # Set startup terminal theme
    defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

    #========================== TextEdit Settings ==========================
    # make default to plain text
    defaults write com.apple.TextEdit RichText -int 0

    #========================== Mission Control Settings ==========================
    defaults write com.apple.dock mru-spaces -bool false
}

function setup_brew() {
    command -v brew >/dev/null 2>&1
    if [[ $? = 1 ]] ; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

function install_brew_pkgs() {
    brew install git openssl wget rsync nmap gibo direnv watch jq bat tree gsed less shellcheck
    brew install cloudfoundry/tap/cf-cli bosh-cli
    brew cask install google-japanese-ime cmd-eikana
    brew cask install alfred google-chrome google-backup-and-sync google-cloud-sdk
    brew cask install slack iterm2 spectacle
    brew cask install appcleaner kap lastpass
}

function output_mac_manual_install() {
    echo "need to install manually"
    echo "Install LINE"
    echo "Install Pixelmator"
    echo "Install Bear"
    echo "Install Gitify"
}

function setup_mac() {
    check_developer_tool
    setup_defaults
    setup_brew
    install_brew_pkgs
    setup_tmux
    output_mac_manual_install
}

#=============================== setup for centos ===============================
function setup_centos() {
    setup_tmux
}

#=============================== commands ===============================
function setup() {
    echo "setup"
    case "${os}" in
    "Darwin") setup_mac ;;
    "CentOS") setup_centos ;;
    *) echo "not supported: ${os}" ;;
    esac
}

function uninstall() {
    echo "uninstall"
    uninstall_tmux
    uninstall_spectacle
}

# handle args
uninstall_flg="false"
while getopts hu OPT; do
    case $OPT in
    "h" ) usage ;;
    "u" ) uninstall_flg="true" ;;
    * ) usage ;;
    esac
done
shift $((OPTIND - 1))

if [[ "${uninstall_flg}" = "true" ]]; then
    uninstall
else
    setup
fi

exit 0