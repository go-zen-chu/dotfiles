#!/bin/bash

set -eu

macos_check_developer_tool() {
    echo_blue "Checking developer tools..."

    if ! xcode-select -p; then
        log "$LOG_LEVEL_INFO" "[ ] developer tool not installed. Installing..."
        xcode-select --install
    else
        log "$LOG_LEVEL_INFO" "[✓] developer tool is already installed"
    fi
}

macos_setup_basic_tools() {
    echo_blue "Setup macos specific tools..."

    setup_karabiner
    # TIPS: installing tools with Homebrew takes a long time in CI so skip for these tools
    if [ "${is_ci}" = "false" ]; then
        brew_install watch
        brew install --cask appcleaner
        brew install --cask microsoft-edge
        brew install --cask hiddenbar
        brew install --cask licecap
        brew install --cask raycast
        # development tools
        brew install --cask google-cloud-sdk
        brew install --cask visual-studio-code
        brew install --cask wireshark
    fi
}

setup_karabiner() {
    brew install --cask karabiner-elements
    if [[ -n ${config_dir} && ! -d "${config_dir}/karabiner" ]]; then
        mkdir -p "${config_dir}"
        cp -R ./os-macos/karabiner "${config_dir}"
    fi
}

macos_setup_personal_machine_tools() {
    echo_blue "Setup macos personal machine tools..."

    # TIPS: installing tools with Homebrew takes a long time in CI so skip for these tools
    if [ "${is_ci}" = "false" ]; then
        brew_install mas # tool that install app from app store
        # you cannot run mas install on CI because you need to be once installed in AppStore
        # https://github.com/mas-cli/mas?tab=readme-ov-file#mas-install
        mas install 539883307 # LINE

        brew install --cask slack
        brew install --cask zoom
        # development tools
        brew install --cask tailscale
        brew install --cask google-cloud-sdk
        brew install --cask hex-fiend
        brew install --cask balenaetcher
    fi
}

macos_setup_defaults() {
    echo_blue "Setup macos defaults..."

    # screenshot setting
    defaults write com.apple.screencapture name "screenshot"
    # disable system ui sound (includes screenshot sound)
    defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0

    #========================== Keyboard Settings ==========================
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
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

    # disable next input source (for spotlight)
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><false/></dict>"
    # change spotlight key binding to ctrl + space
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"

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

    # Enable other multi-finger gestures
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2

    # three finger mission control & expose
    defaults write com.apple.dock showMissionControlGestureEnabled -bool true
    defaults write com.apple.dock showAppExposeGestureEnabled -bool true
    defaults write com.apple.dock showDesktopGestureEnabled -bool true
    defaults write com.apple.dock showLaunchpadGestureEnabled -bool true

    #========================== Menu bar Settings ==========================
    defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
    defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6

    #========================== Dock and Finder Settings ==========================
    # show hidden files in finder
    defaults write com.apple.finder AppleShowAllFiles YES
    # Automatically hide or show the Dock
    defaults write com.apple.dock autohide -bool true
    # Wipe all app icons from the Dock
    defaults write com.apple.dock persistent-apps -array
    # Magnificate the Dock
    defaults write com.apple.dock magnification -bool true

    # restart to enable configs
    killall Finder
    killall Dock

    #========================== Safari Settings ==========================
    # Enable the `Develop` menu and the `Web Inspector`
    #defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    #defaults write com.apple.Safari IncludeDevelopMenu -bool true
    #defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

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
    # Disable automatically rearrange Spaces based on recent use
    defaults write com.apple.dock mru-spaces -bool false
}
