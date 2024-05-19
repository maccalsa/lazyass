#!/bin/bash

# Function to check and install zip and unzip
install_zip_utils() {
    # Checking for 'zip' and 'unzip' installation
    if ! command -v zip &> /dev/null || ! command -v unzip &> /dev/null; then
        echo "zip and/or unzip not found. Installing them now..."

        # Identify the distribution and install tools
        if [[ -f /etc/arch-release ]]; then
            sudo pacman -Sy --noconfirm zip unzip
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y zip unzip
        elif [[ -f /etc/fedora-release ]]; then
            sudo dnf install -y zip unzip
        else
            echo "Unsupported Linux distribution. Please install zip and unzip manually."
            exit 1
        fi
    else
        echo "zip and unzip are already installed."
    fi
}

# Function to zip and encrypt SSH keys
zip_encrypt_keys() {
    echo "Available SSH keys:"
    ls ~/.ssh/id_* | grep -v '\.pub$'
    read -p "Enter the keys you want to include in the zip (space-separated): " keys_input
    read -p "Enter filename for the encrypted zip (e.g., ssh_keys.zip): " zip_name

    # Create array of keys and ensure public keys are also included
    keys=($keys_input)
    for key in "${keys[@]}"; do
        keys+=("${key}.pub")  # Include public key counterparts
    done

    # Zip and encrypt the files
    zip -e --password "$(read -s -p "Enter a passkey for zip encryption: "; echo $REPLY)" "$zip_name" ${keys[@]}
    echo "Keys are zipped and encrypted into $zip_name"
}

# Function to unzip and install keys
unzip_install_keys() {
    read -p "Enter the zip filename to unzip (e.g., ssh_keys.zip): " zip_name
    unzip -d ~/.ssh/ "$zip_name"
    chmod 600 ~/.ssh/id_*  # Set correct permissions
    echo "Keys are unzipped and installed to ~/.ssh/"
}

# Function to register keys with ssh-agent
register_keys() {
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        eval "$(ssh-agent -s)"
    fi

    echo "Available keys to add to ssh-agent:"
    ls ~/.ssh/id_*
    read -p "Enter the keys you want to add to the agent (space-separated): " keys_input

    for key in $keys_input; do
        ssh-add ~/.ssh/"$key"
    done
}

# Main execution
install_zip_utils

# Main menu
while true; do
    echo "Select an operation:"
    echo "1) Zip and Encrypt SSH Keys"
    echo "2) Unzip and Install SSH Keys"
    echo "3) Register SSH Keys with ssh-agent"
    echo "4) Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            zip_encrypt_keys
            ;;
        2)
            unzip_install_keys
            read -p "Do you want to delete the zip file after installation? (y/n): " del_choice
            if [[ "$del_choice" == "y" ]]; then
                rm -f "$zip_name"
                echo "Zip file deleted."
            fi
            ;;
        3)
            register_keys
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done

