#!/bin/bash

# Function to update the PATH in various shell configuration files
update_shell_path() {
    local neovim_path='export PATH="$HOME/neovim/bin:$PATH"'

    # Update .bashrc for Bash
    if [ -f "$HOME/.bashrc" ]; then
        echo "$neovim_path" >> $HOME/.bashrc
        echo "Updated PATH in .bashrc"
    fi

    # Update .zshrc for Zsh
    if [ -f "$HOME/.zshrc" ]; then
        echo "$neovim_path" >> $HOME/.zshrc
        echo "Updated PATH in .zshrc"
    fi

    # Update config.fish for Fish, using Fish syntax
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        echo "set -gx PATH $HOME/neovim/bin \$PATH" >> $HOME/.config/fish/config.fish
        echo "Updated PATH in config.fish"
    fi
}

# Function to build and install Neovim
build_and_install_neovim() {
    # Specify the log file
    local log_file="$HOME/neovim_install.log"

    # Remove existing build directory to clear the CMake cache
    echo "Removing existing build directory to clear the CMake cache..."
    rm -rf build/ | tee -a $log_file

    # Create a fresh build and specify the install prefix
    echo "Starting build with specified CMake install prefix..."
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim" | tee -a $log_file

    # Install Neovim to the specified directory
    echo "Installing Neovim..."
    make install | tee -a $log_file

    # Update the PATH in shell configurations
    echo "Updating shell configuration files to include Neovim in PATH..."
    update_shell_path | tee -a $log_file

    echo "Neovim has been installed and PATH updated in your shell configurations."
}

# Function to clone Neovim repository
clone_neovim() {
    local neovim_dir="$HOME/.sources/github/neovim"

    # Ensure the target directory exists
    mkdir -p "$neovim_dir"
    cd "$neovim_dir"

    # Ask for the branch
    read -p "Enter the Neovim branch you want to build (press enter for stable): " branch
    branch=${branch:-stable}

    # Clone the repository if it doesn't exist
    if [ ! -d "neovim/.git" ]; then
        git clone --branch $branch --single-branch git@github.com:neovim/neovim.git
        echo "Neovim repository ($branch branch) cloned successfully."
    else
        echo "Neovim repository already exists. Updating to the latest of the $branch branch..."
        cd neovim
        git fetch origin
        git checkout $branch
        git pull origin $branch
    fi
}

# Function to change to the Neovim directory
change_to_neovim_dir() {
    # Define the path to the Neovim directory
    local neovim_dir="$HOME/.sources/github/neovim/neovim"

    # Check if the directory exists and change to it
    if [ -d "$neovim_dir" ]; then
        cd "$neovim_dir"
        echo "Changed directory to Neovim repository."
    else
        echo "Neovim directory does not exist. Please check the cloning process."
        exit 1
    fi
}


# Function to install prerequisites for Debian-based distributions
install_debian() {
    sudo apt-get update
    sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
}

# Function to install prerequisites for Fedora-based distributions
install_fedora() {
    sudo dnf -y install ninja-build cmake gcc make unzip gettext curl glibc-gconv-extra
}

# Function to install prerequisites for Arch Linux
install_arch() {
    sudo pacman -Sy --needed base-devel cmake unzip ninja curl
}

# Detecting the Linux distribution and installing the prerequisites
if grep -qEi "(debian|ubuntu|mint)" /etc/*release; then
    install_debian
elif grep -qEi "(fedora|centos|red hat)" /etc/*release; then
    install_fedora
elif grep -qEi "arch" /etc/*release; then
    install_arch
else
    echo "Unsupported Linux distribution"
    exit 1
fi

echo "Prerequisites installed successfully."

# Call the function to clone Neovim
clone_neovim

# Call the function to change directory
change_to_neovim_dir

# Install neovim
build_and_install_neovim
