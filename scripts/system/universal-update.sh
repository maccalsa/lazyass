#!/bin/bash

# Detecting the Linux distribution
if [[ -f /etc/arch-release ]]; then
    # Arch Linux
    echo "Detected Arch Linux. Updating the system..."
    sudo pacman -Syu --noconfirm

elif [[ -f /etc/fedora-release ]]; then
    # Fedora
    echo "Detected Fedora. Updating the system..."
    sudo dnf upgrade --refresh -y
    sudo dnf autoremove -y

elif [[ -f /etc/debian_version ]]; then
    # Debian-based systems (Debian, Ubuntu, etc.)
    echo "Detected Debian-based system. Updating the system..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get autoremove -y

else
    echo "Unsupported distribution. Exiting."
    exit 1
fi

echo "System updated successfully."
