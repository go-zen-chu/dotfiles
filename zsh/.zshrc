#!/usr/bin/env zsh

source $HOME/dotfiles/zsh/plugins.zsh
source $HOME/dotfiles/zsh/fzf.zsh
# make settings below overwrite plugin settings (if exists)
source $HOME/dotfiles/zsh/alias.zsh
source $HOME/dotfiles/zsh/prompt.zsh
source $HOME/dotfiles/zsh/key.zsh
source $HOME/dotfiles/zsh/settings.zsh
source $HOME/dotfiles/zsh/path.zsh
# import env independent settings. Should be located in $HOME and be customized
source $HOME/local.zsh

# for profiling zsh (requires zmodload zsh/zprof && zprof in .zshenv)
if type "zprof" > /dev/null; then
    zprof
fi
