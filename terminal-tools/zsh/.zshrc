#!/usr/bin/env zsh

# TIPS: To profile zsh, uncomment below
#zmodload zsh/zprof && zprof

# path should be loaded first for vscode terminal which has different path loading
source $HOME/dotfiles/terminal-tools/zsh/path.zsh
source $HOME/dotfiles/terminal-tools/zsh/plugins.zsh
source $HOME/dotfiles/terminal-tools/zsh/fzf.zsh
# make settings below overwrite plugin settings (if exists)
source $HOME/dotfiles/terminal-tools/zsh/zsh_config.zsh
source $HOME/dotfiles/terminal-tools/zsh/ssh.zsh
source $HOME/dotfiles/terminal-tools/zsh/alias.zsh
source $HOME/dotfiles/terminal-tools/zsh/key.zsh
source $HOME/dotfiles/terminal-tools/zsh/atuin.zsh
source $HOME/dotfiles/terminal-tools/zsh/later_config.zsh
# import env independent settings. Should be located in $HOME and be customized
if [ -f $HOME/local.zsh ]; then
    source $HOME/local.zsh
fi

# end of zsh profiling
if type "zprof" >/dev/null; then
    zprof
fi
