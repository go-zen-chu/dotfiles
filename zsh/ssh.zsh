# for git
# Check if ssh-agent is running and has keys
if ! ssh-add -l >/dev/null 2>&1; then
    # No agent running or no keys loaded
    echo "Starting ssh-agent and ssh-add..."
    os=$(uname -s)
    if [[ "${os}" == "Linux" ]] && type "keychain" >/dev/null 2>&1 ; then
        # Use keychain to manage SSH keys (reuses existing agent)
        keys=()
        [ -f "${HOME}/.ssh/id_rsa" ] && keys+="${HOME}/.ssh/id_rsa"
        [ -f "${HOME}/.ssh/id_ed25519" ] && keys+="${HOME}/.ssh/id_ed25519"
        [ -f "${HOME}/.ssh/github/id_rsa" ] && keys+="${HOME}/.ssh/github/id_rsa"
        
        if [ ${#keys[@]} -gt 0 ]; then
            eval $(keychain --eval "${keys[@]}")
        fi
    else
        # Try to reuse existing agent
        SSH_ENV="${HOME}/.ssh/agent-env"
        
        if [ -f "${SSH_ENV}" ]; then
            source "${SSH_ENV}" > /dev/null
        fi
        
        # Check if the loaded agent is still valid
        if ! ssh-add -l >/dev/null 2>&1; then
            # Start new agent and save its info
            eval $(ssh-agent -s)
            echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" > "${SSH_ENV}"
            echo "export SSH_AGENT_PID=${SSH_AGENT_PID}" >> "${SSH_ENV}"
            
            # Add keys only when starting new agent
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
fi
