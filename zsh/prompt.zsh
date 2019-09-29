# setting prompt
PROMPT='%F{green}z> %n %~%f %F{yellow}$(get_cf_info)%f$ '

# CF info in prompt. requires jq >= 1.5
get_cf_info() {
if [[ -f "manifest.yml" ]]; then
    echo "$(less ~/.cf/config.json | jq -r '(.Target | gsub("https://api.run.|.io";"")), .OrganizationFields.Name, .SpaceFields.Name' | tr '\n' ' ')"
fi
}

# show git branch
# http://stackoverflow.com/questions/1128496/to-get-a-prompt-which-indicates-git-branch-in-zsh
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
'%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
'%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn
# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [[ -n "$vcs_info_msg_0_" ]]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$RPROMPT$'$(vcs_info_wrapper)'
