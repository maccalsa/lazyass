#!/bin/bash

# Function to install fzf
install_fzf() {
    # Define the fzf installation directory
    local fzf_dir="$HOME/.fzf"

    # Clone the fzf repository if it hasn't been cloned already
    if [ ! -d "$fzf_dir" ]; then
        echo "Cloning fzf repository into $fzf_dir..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    else
        echo "fzf repository already exists in $fzf_dir. Updating repository..."
        cd "$fzf_dir"
        git pull
    fi

    # Run the install script
    echo "Running fzf installation script..."
    "$fzf_dir/install"
}

# Call the function to install fzf
install_fzf
