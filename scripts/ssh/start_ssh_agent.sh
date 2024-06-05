#!/bin/bash

# Start the SSH agent and add keys passed as arguments

start_ssh_agent() {
    # Check if SSH_AGENT_PID is set and is a running process
    if [[ -z "$SSH_AGENT_PID" ]] || ! kill -0 "$SSH_AGENT_PID" &>/dev/null; then
        echo "Starting SSH agent..."
        eval "$(ssh-agent -s)"  # Start the ssh-agent
    else
        echo "SSH agent already running with PID $SSH_AGENT_PID"
    fi
}

add_keys() {
     if [ "$#" -eq 0 ]; then
        echo "No SSH keys provided. Exiting."
        exit 0
    fi
    
    for key in "$@"; do
        if [ -f "$key" ]; then
            ssh-add "$key"
        else
            echo "Warning: SSH key '$key' not found."
        fi
    done
}

# Main execution
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <path_to_ssh_key> [path_to_another_ssh_key] ..."
    exit 1
fi

start_ssh_agent
add_keys "$@"
