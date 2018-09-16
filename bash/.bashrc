# .bashrc is loaded every startup (.bash_profile is every login)

# alias
alias gitlog='git log --graph --color --oneline'
alias rmdir='rm -rf'
# tmux の色設定を変えて、vimのcolorschemaを適用できるようにする
alias tmux="TERM=screen-256color-bce tmux"

# functions
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
