# bash_profile is loaded when user logging into shell (only once)
# write only "export" things here and put others into .bashrc

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# change console color with git branch
export PS1="\[\e[1;32m\]\u \w\[\e[00m\] \$(parse_git_branch): "

# OS別に管理
if [ "$(uname)" = 'Darwin' ]; then
	#  mac ports
	#PATH=$PATH:/opt/local/bin/

	#  set color of ls
	export LSCOLORS=xbfxcxdxbxegedabagacad
    alias ls='ls -a -G'
	# setting for bash_completion. check brew install bash_completion
	if [ -f $(brew --prefix)/etc/bash_completion ]; then
		. $(brew --prefix)/etc/bash_completion
	fi
else
	#  set color of ls
    eval 'dircolors ~/.colorrc'
    alias ls='ls -a --color=auto'
fi

# ============== PATH ================
# PATHは : でつないで登録する

#  python related
#PATH=$PATH:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/
#export PATH

#  add to PYTHON PATH
#PYTHONPATH=$PYTHONPATH:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages
#export PYTHONPATH


