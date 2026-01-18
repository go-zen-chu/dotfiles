# for git
if [ -z "${SSH_AUTH_SOCK}" ]; then
    echo "Starting ssh-agent and ssh-add..."
    os=$(uname -s)

    if [[ "${os}" == "Linux" && type keychain >/dev/null 2>&1 ]]; then
        # Use keychain to manage SSH keys
        keys=()
        [ -f "${HOME}/.ssh/id_rsa" ] && keys+="${HOME}/.ssh/id_rsa"
        [ -f "${HOME}/.ssh/id_ed25519" ] && keys+="${HOME}/.ssh/id_ed25519"
        [ -f "${HOME}/.ssh/github/id_rsa" ] && keys+="${HOME}/.ssh/github/id_rsa"
        
        if [ ${#keys[@]} -gt 0 ]; then
            eval $(keychain --agents ssh --eval "${keys[@]}")
        fi
    else
        eval $(ssh-agent -s)
        if [ -f "${HOME}/.ssh/id_rsa" ]; then
            ssh-add "${HOME}/.ssh/id_rsa"
        fi
        if [ -f "${HOME}/.ssh/id_ed25519" ]; then
            ssh-add "${HOME}/.ssh/id_ed25519"
        fi
        if [ -f "${HOME}/.ssh/github/id_rsa" ]; then
            ssh-add "${HOME}/.ssh/github/id_rsa"
        fi 
    fi
fi
