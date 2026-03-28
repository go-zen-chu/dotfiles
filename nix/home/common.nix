{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.home-manager.enable = true;

  xdg.enable = true;

  home.packages = with pkgs; [
    atuin
    bat
    direnv
    fzf
    gh
    git
    gitleaks
    jq
    jsonnet
    k9s
    kind
    kubectl
    kubecolor
    kustomize
    rsync
    shellcheck
    starship
    tree
    wget
    yq-go
    zellij
  ];

  home.file = {
    ".config/atuin/config.toml".source = ../../terminal-tools/atuin/config.toml;
    ".config/git/ignore".source = ../../terminal-tools/git/global-ignore;
    ".config/starship.toml".source = ../../terminal-tools/starship/starship.toml;
    ".config/zellij/config.kdl".source = ../../terminal-tools/zellij/config.kdl;
  };

  home.sessionVariables = {
    ATUIN_CONFIG_DIR = "$HOME/.config/atuin";
    LANG = "en_US.UTF-8";
    PNPM_HOME = "$HOME/.local/share/pnpm";
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
  } // lib.optionalAttrs isDarwin {
    LSCOLORS = "bxfxcxdxgxegedabagacad";
  };

  home.sessionPath = [
    "$HOME/.krew/bin"
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
    "/snap/bin"
    "${homeDir}/.anyenv/bin"
  ] ++ lib.optionals isDarwin [
    "/opt/homebrew/bin"
  ] ++ lib.optionals (!isDarwin) [
    "/home/linuxbrew/.linuxbrew/bin"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh.enable = true;

  programs.git = {
    enable = true;
    extraConfig = {
      core.excludesfile = "${homeDir}/.config/git/ignore";
      pull.rebase = false;
      push.default = "current";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cat = "bat --paging=never";
      cpdir = "cp -R";
      echopath = "echo \"$PATH\" | tr \":\" \"\\n\"";
      history = "history -E 1 | less";
      kubectl = "kubecolor";
      less = "bat";
      ll = "ls -l";
      ls =
        if isDarwin
        then "ls -a -G -F"
        else "ls -a --color=auto -F";
      relogin = "exec $SHELL -l";
      rmdir = "rm -rf";
    } // lib.optionalAttrs (!isDarwin) {
      xclip = "xclip -selection clipboard";
    };

    shellGlobalAliases = {
      G = "| grep --color=auto";
      L = "| less -iMRS";
      LY = "| less -l yaml";
      P =
        if isDarwin
        then "| pbcopy"
        else "| xclip -selection clipboard";
      k = "kubectl";
    };

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      path = "${homeDir}/.zsh_history";
      save = 100000;
      share = true;
      size = 100000;
    };

    initExtraBeforeCompInit = ''
      fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
    '';

    completionInit = ''
      autoload -Uz compinit
      local zcompdump="${homeDir}/.zcompdump"

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors di=31 ln=35 ex=36
      zstyle ':completion:*' menu select=2

      if [ -f "$zcompdump" ] && [ "$(date +%Y%m%d)" = "$(date -r "$zcompdump" +%Y%m%d 2>/dev/null)" ]; then
        compinit -d "$zcompdump" -C
      else
        compinit -d "$zcompdump"
      fi
    '';

    initExtraFirst = ''
      export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
    '';

    initExtra = ''
      setopt auto_pushd
      setopt hist_expire_dups_first
      setopt hist_ignore_all_dups
      setopt hist_ignore_dups
      setopt hist_reduce_blanks
      setopt hist_save_no_dups
      setopt ignore_eof
      setopt inc_append_history
      setopt interactive_comments
      setopt no_beep
      setopt no_flow_control
      setopt print_eight_bit
      setopt pushd_ignore_dups
      setopt share_history

      bindkey -e
      if [[ "$(uname -s)" == "Darwin" ]]; then
        bindkey "^[[3~" delete-char
        bindkey "^[^[[D" backward-word
        bindkey "^[^[[C" forward-word
      else
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      fi

      mkdir_touch() {
        mkdir -p "$(dirname "''${argv[-1]}")"
        touch "$@"
        echo "runned: mkdir -p $(dirname "''${argv[-1]}"); touch $*"
      }
      alias touch='mkdir_touch'

      gq() {
        local comment="$1"
        git add --all
        git commit -a -m "$comment"
        git push
      }

      gprnb() {
        git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
      }

      if hash ghq 2>/dev/null; then
        alias codeghq='code $(ghq list --full-path | fzf)'
        alias cdghq='cd $(ghq list --full-path | fzf)'
      fi

      alias gitlog='git log --graph --color --oneline'
      alias cdgr='cd $(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)'

      if hash gh 2>/dev/null; then
        alias ghprsw='gh pr checkout $(gh pr list | fzf | awk "{print \$1;}")'
        alias ghprcrw='gh pr create | open'
      fi

      if hash powershell.exe 2>/dev/null; then
        alias open='powershell.exe -c start'
        export BROWSER='powershell.exe -NoProfile -Command Start-Process'
      fi

      if hash kubectl 2>/dev/null; then
        compdef kubecolor=kubectl

        kgall() {
          kubectl get -A "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"
        }

        kgalln() {
          local ns="$1"
          kubectl get -n "$ns" "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"
        }

        kdelcrd() {
          local domain="$1"
          kubectl get crd | grep "$domain" | awk '{ print $1 }' | xargs kubectl delete crd
        }
      fi

      if hash fzf 2>/dev/null; then
        fzf-history-widget() {
          local selected num
          setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
          selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
            FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=''${(qqq)LBUFFER} +m" fzf) )
          local ret=$?
          if [ -n "$selected" ]; then
            num=$selected[1]
            if [ -n "$num" ]; then
              zle vi-fetch-history -n "$num"
            fi
          fi
          zle reset-prompt
          return $ret
        }
        zle -N fzf-history-widget
        bindkey '^r' fzf-history-widget
      fi

      if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init --disable-up-arrow zsh)"
      fi

      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi

      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi

      if command -v anyenv >/dev/null 2>&1; then
        anyenv() {
          unfunction "$0"
          eval "$(command anyenv init -)"
          "$0" "$@"
        }
        pyenv() {
          if [[ -n "''${PYENV_SHELL}" ]]; then
            command pyenv "$@"
            return
          fi
          unfunction "$0"
          anyenv -v
          eval "$(command pyenv init -)"
          "$0" "$@"
        }
        python() {
          unfunction "$0"
          pyenv versions
          "$0" "$@"
        }
        goenv() {
          unfunction "$0"
          anyenv -v
          eval "$(command goenv init -)"
          "$0" "$@"
        }
        rbenv() {
          unfunction "$0"
          anyenv -v
          eval "$(command rbenv init -)"
          "$0" "$@"
        }
      fi

      if command -v wtp >/dev/null 2>&1; then
        eval "$(wtp hook zsh)"
      fi

      if [ -d "${homeDir}/go" ]; then
        path=("${homeDir}/go/bin" "$HOME/.anyenv/envs/goenv/shims" "$(go env GOPATH 2>/dev/null)/bin" $path)
      fi

      nodejs_install_path="$(brew --prefix node@22 2>/dev/null || true)"
      if [ -n "$nodejs_install_path" ] && [ -d "$nodejs_install_path" ]; then
        path=("''${nodejs_install_path}/bin" $path)
      fi

      if ! ssh-add -l >/dev/null 2>&1; then
        if [[ "$(uname -s)" == "Linux" ]] && command -v keychain >/dev/null 2>&1; then
          keys=()
          [ -f "${homeDir}/.ssh/id_rsa" ] && keys+=("${homeDir}/.ssh/id_rsa")
          [ -f "${homeDir}/.ssh/id_ed25519" ] && keys+=("${homeDir}/.ssh/id_ed25519")
          [ -f "${homeDir}/.ssh/github/id_rsa" ] && keys+=("${homeDir}/.ssh/github/id_rsa")
          if [ "''${#keys[@]}" -gt 0 ]; then
            eval "$(keychain --eval "''${keys[@]}")"
          fi
        else
          SSH_ENV="${homeDir}/.ssh/agent-env"
          if [ -f "$SSH_ENV" ]; then
            source "$SSH_ENV" >/dev/null
          fi
          if ! ssh-add -l >/dev/null 2>&1; then
            eval "$(ssh-agent -s)"
            echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$SSH_ENV"
            echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "$SSH_ENV"
            [ -f "${homeDir}/.ssh/id_rsa" ] && ssh-add "${homeDir}/.ssh/id_rsa"
            [ -f "${homeDir}/.ssh/id_ed25519" ] && ssh-add "${homeDir}/.ssh/id_ed25519"
            [ -f "${homeDir}/.ssh/github/id_rsa" ] && ssh-add "${homeDir}/.ssh/github/id_rsa"
          fi
        fi
      fi

      if [ -f "$HOME/local.zsh" ]; then
        source "$HOME/local.zsh"
      fi
    '';
  };
}
