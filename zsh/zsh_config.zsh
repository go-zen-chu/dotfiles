# language setting
export LANG=en_US.UTF-8

# case insensitivce
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# colorize directory, link, executive
zstyle ':completion:*' list-colors di=31 ln=35 ex=36
# menu select by tab & arrow
zstyle ':completion:*' menu select=2

# history setting
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt share_history # share history with other windows
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_expire_dups_first
setopt hist_save_no_dups

# pushd automatically when cd
setopt auto_pushd
setopt pushd_ignore_dups
# show japanese file name
setopt print_eight_bit
setopt no_beep
# ignore ctrl+s, ctrl+q lock
setopt no_flow_control
# don't stop zsh with ctrl+d
setopt ignore_eof
# recognize # as comment in commandline
setopt interactive_comments
