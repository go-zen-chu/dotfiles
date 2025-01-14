# OS independent setting
declare os
os=$(uname -s)
if [[ ${os} == 'Darwin' ]]; then
	export LSCOLORS=bxfxcxdxgxegedabagacad
	alias ls='ls -a -G -F'
elif [[ ${os} == 'Linux' ]]; then
	alias ls='ls -a --color=auto -F'
fi

# set global alias
alias -g L='| less -iMRS'
alias -g G='| grep --color=auto'
if hash pbcopy 2>/dev/null; then
	alias -g P='| pbcopy'
fi
if hash xclip 2>/dev/null; then
	alias -g P='| xclip -selection clipboard'
	alias xclip='xclip -selection clipboard'
fi
alias -g X='| xargs'

# relogin current shell
alias relogin='exec $SHELL -l'
alias history='history -E 1 | less'
alias ll='ls -l'
alias rmdir='rm -rf'
alias cpdir='cp -R'
alias gitlog='git log --graph --color --oneline'
alias cdgr='cd $(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)'
alias ecpath="tr ':' '\n' <<< $PATH"

if hash ghq 2>/dev/null; then
	alias codeghq='code $(ghq list --full-path | fzf)'
	alias cdghq='cd $(ghq list --full-path | fzf)'
fi
if hash gh 2>/dev/null; then
	alias ghprsw='gh pr checkout $(gh pr list | fzf | awk "{print $1;}")'
	alias ghprcrw='gh pr create | open'
fi
if hash kubectl 2>/dev/null; then
	alias -g k="kubectl"
	# get all resources except events
	alias kgall='kubectl get -A "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"'
	# get all resource in specific namespace
	kgalln() {
		ns=$1
		kubectl get -n "${ns}" "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"
	}
fi
if hash bat 2>/dev/null; then
	alias cat='bat --paging=never'
	alias less='bat'
fi
if hash doggo 2>/dev/null; then
	alias dig='doggo'
fi
