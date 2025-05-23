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
alias -g L='| \less -iMRS' # less is aliased to bat
alias -g LY='| less -l yaml'
alias -g G='| grep --color=auto'
if hash pbcopy 2>/dev/null; then
	alias -g P='| pbcopy'
fi
if hash xclip 2>/dev/null; then
	alias -g P='| xclip -selection clipboard'
	alias xclip='xclip -selection clipboard'
fi

# utilities
# refresh current shell without creating a child process
alias relogin='exec $SHELL -l'
alias history='history -E 1 | less'
alias ll='ls -l'
alias rmdir='rm -rf'
alias cpdir='cp -R'
alias echopath='echo "$PATH" | tr ":" "\n"'
mkdir_touch() {
	mkdir -p "$(dirname ${argv[-1]})"
	touch $@
	echo "runned: mkdir -p $(dirname ${argv[-1]}); touch $@"
}
alias touch='mkdir_touch'

# git
alias gitlog='git log --graph --color --oneline'
alias cdgr='cd $(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)'
if hash ghq 2>/dev/null; then
	alias codeghq='code $(ghq list --full-path | fzf)'
	alias cdghq='cd $(ghq list --full-path | fzf)'
fi
gq() {
	# git add, commit, push in 1 command
	comment=$1
	git add --all
	git commit -a -m "${comment}"
	git push
}
gprnb() {
	# clean up merged branches
	git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# gh
if hash gh 2>/dev/null; then
	alias ghprsw='gh pr checkout $(gh pr list | fzf | awk "{print $1;}")'
	alias ghprcrw='gh pr create | open'
fi

# kubectl
if hash kubectl 2>/dev/null; then
	if hash kubecolor 2>/dev/null; then
		alias kubectl='kubecolor'
		# by default kubecolor fail to complete kubectl commands so this can make it work
		compdef kubecolor=kubectl
	fi
	alias -g k="kubectl"
	# get all resources except events
	alias kgall='kubectl get -A "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"'
	# get all resource in specific namespace
	kgalln() {
		ns=$1
		kubectl get -n "${ns}" "$(kubectl api-resources --namespaced=true --verbs=list --output=name | grep -v "events" | tr "\n" "," | sed -e 's/,$//')"
	}

	# delete crd related to the domain
	kdelcrd() {
		domain=$1
		kubectl get crd | grep "${domain}" | awk '{ print $1}' | xargs kubectl delete crd
	}
fi

# bat
if hash bat 2>/dev/null; then
	alias cat='bat --paging=never'
	alias less='bat'
fi

# doggo
if hash doggo 2>/dev/null; then
	alias dig='doggo'
fi
