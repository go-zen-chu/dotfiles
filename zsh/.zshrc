#!/usr/bin/env zsh

# TIPS: To profile zsh, uncomment below
#zmodload zsh/zprof && zprof

source $HOME/dotfiles/zsh/plugins.zsh
source $HOME/dotfiles/zsh/fzf.zsh
# make settings below overwrite plugin settings (if exists)
source $HOME/dotfiles/zsh/zsh_config.zsh
source $HOME/dotfiles/zsh/ssh.zsh
source $HOME/dotfiles/zsh/prompt.zsh
source $HOME/dotfiles/zsh/alias.zsh
source $HOME/dotfiles/zsh/key.zsh
source $HOME/dotfiles/zsh/path.zsh
source $HOME/dotfiles/zsh/atuin.zsh
source $HOME/dotfiles/zsh/later_config.zsh
# import env independent settings. Should be located in $HOME and be customized
source $HOME/local.zsh

# end of zsh profiling
if type "zprof" >/dev/null; then
    zprof
fi
