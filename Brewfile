# Packages installed with `brew bundle` on macOS / Ubuntu (termux uses pkg, see os-termux/setup.sh).
# install.sh (through the chezmoi script home/.chezmoiscripts) runs `brew bundle install` with this file.
#
#   brew bundle check --file ~/dotfiles/Brewfile    # missing packages
#   brew bundle cleanup --file ~/dotfiles/Brewfile  # packages not listed here (add --force to uninstall them)

# personal mode is chosen with `./install.sh -p` and kept in the chezmoi config.
# TIPS: brew drops environment variables without the HOMEBREW_ prefix
personal = ENV.fetch("HOMEBREW_DOTFILES_PERSONAL") do
  `chezmoi execute-template '{{ .personal }}' 2>/dev/null`.strip
end == "true"
# TIPS: installing some tools takes a long time in CI so skip them there
ci = ENV.key?("CI")

# language runtimes / toolchains
brew "uv" # python version / virtualenv manager
brew "go" # toolchain of each project is fetched by GOTOOLCHAIN=auto
brew "node@24" # LTS, terminal-tools/zsh/path.zsh adds it to PATH as it is keg-only

# terminal tools
brew "git"
brew "gh"
brew "direnv"
brew "atuin"
brew "gitleaks"
brew "zsh"
brew "vim"
brew "wget"
brew "rsync"
brew "fzf"
brew "jq"
brew "yq"
brew "bat" # cat, less alternatives
brew "doggo" # dig alternatives
brew "tree"
brew "starship"
brew "chezmoi" # deploys the dotfiles in home/
brew "openssl@3" unless ci
if OS.mac?
  brew "watch" unless ci
else
  brew "xclip"
end

# development tools
# TIPS: Homebrew refuses formulae of third party taps unless they are trusted
brew "microsoft/apm/apm", trusted: true # agent package manager for claude code
cask "claude-code"
brew "gibo"
brew "ghq"
brew "shellcheck"
brew "golangci-lint"
brew "pnpm"

# kubernetes tools
brew "kubernetes-cli"
brew "kustomize"
brew "kubecolor"
brew "kind"
brew "krew"

# cloud tools
brew "opentofu" unless ci # terraform alternative (command tofu)

if OS.mac?
  cask "karabiner-elements"
  unless ci
    cask "appcleaner"
    # alacritty is not listed: its cask is disabled because it does not pass the Gatekeeper check
    cask "google-chrome"
    cask "licecap"
    cask "raycast"
    cask "visual-studio-code"
    cask "wireshark-app"
  end
end

# personal machine tools
if personal && !ci
  brew "hugo"
  brew "sass/sass/sass", trusted: true
  if OS.mac?
    cask "slack"
    cask "zoom"
    cask "tailscale-app"
    cask "gcloud-cli"
  end
end

# go install
go "github.com/cweill/gotests/gotests" # generate test code
go "github.com/rakyll/gotest" # colorize test output
go "golang.org/x/tools/gopls"

# kubectl krew install
krew "ctx"
krew "ns"
krew "access-matrix" unless OS.linux? && Hardware::CPU.arm? # not provided for linux/arm64
krew "tree"
krew "neat"
krew "resource-capacity"
krew "view-allocations"
krew "iexec"
krew "stern"
