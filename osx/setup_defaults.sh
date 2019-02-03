#!/usr/bin/env bash
set -ux

#========================== Keyboard Settings ==========================
# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
#
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

# 3本指でmission control & expose
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
