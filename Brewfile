# Homebrew packages installed by install.sh in one `brew bundle` run.
# brew bundle batches the formulae into a single `brew install`, so bottles are downloaded in parallel
# instead of one tool at a time. Configuration of each tool stays in install.sh.
#
# Homebrew filters the environment except HOMEBREW_*, so install.sh passes its flags as HOMEBREW_DOTFILES_*.
ci = ENV["HOMEBREW_DOTFILES_CI"] == "true"
personal = ENV["HOMEBREW_DOTFILES_PERSONAL"] == "true"

tap "microsoft/apm"

# basic tools
brew "git"
brew "gh"
brew "direnv"
brew "uv"
brew "node@24" # keep in sync with nodejs_version in install.sh
brew "atuin"
brew "gitleaks"
cask "claude-code"
brew "microsoft/apm/apm", trusted: true
brew "zsh"
brew "vim"

# golang related tools (prebuilt bottles are much faster than `go install`)
brew "go"
brew "gopls"
brew "gotests"
brew "golangci-lint"

# terminal tools
brew "wget"
brew "rsync"
brew "fzf"
brew "jq"
brew "yq"
brew "bat"   # cat, less alternatives
brew "doggo" # dig alternatives
brew "tree"
brew "starship"

# development tools
brew "gibo"
brew "ghq"
brew "shellcheck"

# kubernetes tools
brew "kubectl"
brew "kustomize"
brew "kubecolor"
brew "kind"
brew "krew"

# TIPS: installing these takes a long time in CI so skip there
unless ci
  brew "openssl"
  brew "opentofu" # terraform alternative (command: tofu)
end

if OS.linux?
  brew "xclip"
  brew "keychain"
end

if OS.mac?
  cask "karabiner-elements"
  unless ci
    brew "watch"
    cask "appcleaner"
    cask "alacritty"
    cask "google-chrome"
    cask "licecap"
    cask "raycast"
    # development tools
    cask "visual-studio-code"
    cask "wireshark"
  end
end

# personal machine tools
if personal && !ci
  brew "hugo"
  tap "sass/sass"
  brew "sass/sass/sass", trusted: true

  if OS.mac?
    cask "slack"
    cask "zoom"
    # development tools
    cask "tailscale"
    cask "google-cloud-sdk"
  end
end
