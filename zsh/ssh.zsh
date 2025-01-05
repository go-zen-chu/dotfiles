# for git
if [ -z "${SSH_AUTH_SOCK}" ]; then
    echo "Starting ssh-agent and ssh-add..."
    eval $(ssh-agent -s)
    if [ -f "${HOME}/.ssh/id_rsa" ]; then
        ssh-add "${HOME}/.ssh/id_rsa"
    fi
    if [ -f "${HOME}/.ssh/id_ed25519" ]; then
        ssh-add "${HOME}/.ssh/id_ed25519"
    fi
fi
