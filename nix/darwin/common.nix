{ homeDirectory, pkgs, username, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.zsh.enable = true;

  users.users.${username}.home = homeDirectory;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    casks = [
      "karabiner-elements"
    ];
  };

  system = {
    primaryUser = username;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.uiaudio.enabled" = 0;
      };
      dock = {
        autohide = true;
        magnification = true;
        mru-spaces = false;
        persistent-apps = [ ];
      };
      finder = {
        AppleShowAllFiles = true;
      };
      screencapture = {
        name = "screenshot";
      };
      CustomUserPreferences = {
        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          Clicking = true;
          TrackpadFiveFingerPinchGesture = 2;
          TrackpadFourFingerHorizSwipeGesture = 2;
          TrackpadFourFingerPinchGesture = 2;
          TrackpadFourFingerVertSwipeGesture = 2;
          TrackpadThreeFingerTapGesture = 2;
          TrackpadThreeFingerVertSwipeGesture = 2;
        };
        "com.apple.Terminal" = {
          "Startup Window Settings" = "Pro";
        };
        "com.apple.TextEdit" = {
          RichText = 0;
        };
        "com.apple.iCal" = {
          "Default duration in minutes for new event" = 15;
          "number of hours displayed" = 24;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "61" = {
              enabled = false;
            };
            "64" = {
              enabled = true;
              value = {
                parameters = [ 32 49 262144 ];
                type = "standard";
              };
            };
          };
        };
        "com.apple.dock" = {
          showAppExposeGestureEnabled = true;
          showDesktopGestureEnabled = true;
          showLaunchpadGestureEnabled = true;
          showMissionControlGestureEnabled = true;
        };
      };
    };
    activationScripts.postUserDefaults.text = ''
      /usr/bin/defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
      /usr/bin/defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6
      /usr/bin/defaults write -g com.apple.mouse.scaling 5
    '';
    stateVersion = 6;
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
