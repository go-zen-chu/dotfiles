# setting prompt
PROMPT='%F{green} %n %~%f$ '

# kube-ps1
PROMPT='$(kube_ps1)'$PROMPT

# show git branch
# http://stackoverflow.com/questions/1128496/to-get-a-prompt-which-indicates-git-branch-in-zsh
setopt prompt_subst
autoload -Uz vcs_info
# Format when action is in progress (e.g., rebase): (VCS type)-[branch|action]
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
# Normal format: (VCS type)-[branch]
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
# Branch format for svn/bzr
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
# Enable these version control systems
zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
	vcs_info
	local worktree_info=""
	# Check if in a git worktree
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		local git_dir=$(git rev-parse --git-common-dir 2>/dev/null)
		local toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
		# If .git is a file (not a directory), it's a worktree
		if [[ -f "$toplevel/.git" ]]; then
			local worktree_name=$(basename "$toplevel")
			worktree_info="%{$fg[cyan]%}[wt:$worktree_name]%{$reset_color%} "
		fi
	fi
	if [[ -n "$vcs_info_msg_0_" ]]; then
		echo "${worktree_info}%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
	elif [[ -n "$worktree_info" ]]; then
		echo "$worktree_info"
	fi
}
RPROMPT=$RPROMPT$'$(vcs_info_wrapper)'
