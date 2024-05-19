#!/bin/bash

# Function to ensure SSH agent is running
ensure_ssh_agent_running() {
    if [ -z "$SSH_AGENT_PID" ]; then
        eval $(ssh-agent -s)
    fi
}

# Function to validate email format
is_valid_email() {
    [[ $1 =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]
}

# Function to install xclip if not installed
install_xclip() {
    if ! command -v xclip &> /dev/null; then
        echo "xclip is not installed. Attempting to install xclip."
        if [[ -f /etc/arch-release ]]; then
            sudo pacman -Sy xclip --noconfirm
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y xclip
        elif [[ -f /etc/fedora-release ]]; then
            sudo dnf install -y xclip
        else
            echo "Unsupported distribution. Please install xclip manually."
            return 1
        fi
    fi
    return 0
}

# Start SSH agent as needed
ensure_ssh_agent_running

# Collect user information
read -p "Enter the email associated with your account: " email
while ! is_valid_email "$email"; do
    echo "Invalid email format. Please enter a valid email:"
    read email
done

read -p "Enter the service name (e.g., GitHub, GitLab, press Enter to use 'GitHub'): " service_name
service_name=${service_name:-GitHub}

encryption=""
while [[ ! "$encryption" =~ ^(ed25519|rsa)$ ]]; do
    read -p "Choose an encryption mechanism (ed25519 or rsa): " encryption
    if [[ ! "$encryption" =~ ^(ed25519|rsa)$ ]]; then
        echo "Invalid choice. Please choose either 'ed25519' or 'rsa'."
    fi
done

# Generate and add SSH key
service_filename=$(echo "$service_name" | tr '[:upper:]' '[:lower:]')
ssh_key_path="${HOME}/.ssh/id_${encryption}_${service_filename}"
ssh-keygen -t $encryption -f "$ssh_key_path" -C "$email" || { echo "Failed to generate SSH key."; exit 1; }
ssh-add "$ssh_key_path" || { echo "Failed to add SSH key to agent."; exit 1; }

# Display public key
echo "======================"
echo "Your public SSH key for $service_name is:"
cat "${ssh_key_path}.pub"
echo "======================"

read -p "Copy the above public key and add it to your $service_name account. Once done, press [Enter] to continue."

# Update or create SSH config file
config_file="${HOME}/.ssh/config"
touch "$config_file"

read -p "Enter the service URL (e.g., github.com, gitlab.com, press Enter to use 'github.com'): " service_url
service_url=${service_url:-"github.com"}

read -p "Enter the SSH username for $service_name (press Enter to use 'git'): " ssh_user
ssh_user=${ssh_user:-git}

if ! grep -q "Host $service_url" "$config_file"; then
    cat >> "$config_file" <<EOL

Host $service_url
  HostName $service_url
  User $ssh_user
  IdentityFile $ssh_key_path
  IdentitiesOnly yes

EOL
    echo "SSH config updated for $service_name."
else
    echo "An SSH config entry for $service_name already exists. Skipping modification."
fi

echo "Setup complete!"

# Install xclip if not present
install_xclip && {
    read -p "Do you want to copy the SSH public key to the clipboard? (y/n): " copy_clip
    if [[ "$copy_clip" == [Yy]* ]]; then
        xclip -selection clipboard < "${ssh_key_path}.pub"
        echo "SSH public key copied to clipboard."
    fi
}
``
