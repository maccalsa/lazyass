#!/bin/bash

# Function to install fd-find based on the Linux distribution
install_fd() {
    if grep -qEi "(debian|ubuntu)" /etc/*release; then
        echo "Installing fd-find on Debian/Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y fd-find
        create_link "/usr/bin/fdfind"
    elif grep -qEi "(fedora|centos|red hat)" /etc/*release; then
        echo "Installing fd-find on Fedora/CentOS/Red Hat..."
        sudo dnf install -y fd-find
        create_link "/usr/bin/fdfind"
    elif grep -qEi "arch" /etc/*release; then
        echo "Installing fd on Arch Linux..."
        sudo pacman -S --noconfirm fd
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
}


# Function to create a symbolic link from fd to fdfind if it does not already exist
create_link() {
    local target_path="$1"  # Path to the fdfind executable

    # Check if the link already exists; if not, create it
    if [ ! -L "$HOME/bin/fd" ]; then
        mkdir -p "$HOME/bin"
        ln -s "$target_path" "$HOME/bin/fd"
        echo "Created symbolic link from 'fd' to 'fdfind' in $HOME/bin"
        export PATH="$HOME/bin:$PATH"
        echo 'export PATH="$HOME/bin:$PATH"' >> $HOME/.bashrc
        echo 'export PATH="$HOME/bin:$PATH"' >> $HOME/.zshrc
        [ -d "$HOME/.config/fish" ] && echo 'set -gx PATH $HOME/bin $PATH' >> "$HOME/.config/fish/config.fish"
    else
        echo "Symbolic link 'fd' already exists."
    fi
}

# Install fd and configure aliases as necessary
install_fd
