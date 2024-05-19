#!/bin/bash

# Prompt for the paths to the public and private keys
read -p "Enter the path to the private key: " private_key_path
read -p "Enter the path to the public key: " public_key_path

# Prompt for the service details with default values
read -p "Enter the service name (default: GitHub): " service_name
service_name=${service_name:-GitHub}

read -p "Enter the service URL (default: github.com): " service_url
service_url=${service_url:-github.com}

read -p "Enter the SSH username (default: git): " ssh_user
ssh_user=${ssh_user:-git}

# Default SSH directory
SSH_DIR="${HOME}/.ssh"

# Destination paths for the keys
DEST_PRIVATE_KEY="${SSH_DIR}/id_${service_name}"
DEST_PUBLIC_KEY="${DEST_PRIVATE_KEY}.pub"

# Create the .ssh directory if it doesn't exist
mkdir -p $SSH_DIR

# Copy the keys to the designated location
cp "$private_key_path" "$DEST_PRIVATE_KEY"
cp "$public_key_path" "$DEST_PUBLIC_KEY"

# Set the correct permissions for the private key
chmod 600 "$DEST_PRIVATE_KEY"

# Update/Create SSH config
config_file="${SSH_DIR}/config"
# Check if an entry for the service already exists in SSH config
if grep -q "Host $service_url" $config_file; then
    echo "An SSH config entry for $service_name already exists. Skipping modification."
else
    cat >> $config_file <<EOL

Host $service_url
  HostName $service_url
  User $ssh_user
  IdentityFile $DEST_PRIVATE_KEY
  IdentitiesOnly yes

EOL
    echo "SSH config updated for $service_name."
fi

# Inform the user and provide instruction to test
echo "SSH keys and config have been set up."
echo "To test the connection, you can use: ssh -T ${ssh_user}@${service_url}"
