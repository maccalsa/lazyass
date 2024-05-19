#!/bin/bash

after() {
    echo -e "\e[34m==========================================\e[0m"
    echo -e "\e[36mAfter a Reboot\e[0m\n"
    
    echo -e "\e[33mFull screen\e[0m"
    echo -e "\e[34m-----------\e[0m"
    echo -e "\e[32m1. Run KVM Virtual Machines Manager\e[0m"
    echo -e "\e[32m2. In the guest machine try this to get full screen\e[0m"
    echo -e "\e[32m3. Make sure host is running virtio\e[0m"
    echo -e "\e[32m4. If still not working, try \e[35mxrandr --output HDMI1 --primary\e[0m in guest"
    echo -e "\e[32m5. Make sure guest is running virtio\e[0m"
    
    echo -e "\n\e[33mMount a drive\e[0m"
    echo -e "\e[34m-------------\e[0m"
    echo -e "\e[32m1. Run KVM Virtual Machines Manager\e[0m"
    echo -e "\e[32m2. Enable shared memory\e[0m"
    echo -e "\e[32m3. Add hardware > Filesystem\e[0m"
    echo -e "\e[35m   a. virtiofs, source=<sharedFolder>  target=<sharedFolderGuestName>\e[0m"
    echo -e "\e[32m4. Inside guest, mount shared folder onto /mnt/<folder>\e[0m"
    echo -e "\e[35m   a. sudo mkdir /mnt/<folder>\e[0m"
    echo -e "\e[35m   b. sudo mount -t virtiofs <sharedFolderGuestName> /mnt/<folder>\e[0m"
    echo -e "\e[34m==========================================\e[0m"
}

# Update and Upgrade Ubuntu 22.04
echo "Updating and Upgrading Ubuntu..."
sudo apt update && sudo apt upgrade -y

# Check if Virtualization is enabled
if ! egrep -c '(vmx|svm)' /proc/cpuinfo; then
    echo "KVM virtualization is not enabled. Please enable it from BIOS settings."
    exit 1
fi

# Install the cpu-checker package
echo "Installing cpu-checker..."
sudo apt install -y cpu-checker

# Install KVM and related tools
echo "Installing KVM and related tools..."
sudo apt install -y qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils

# Enable and start the virtualization daemon
echo "Enabling and starting libvirtd..."
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd

# Check if the virtualization daemon is running
echo "Checking status of libvirtd..."
sudo systemctl status libvirtd

# Add current user to the KVM and Libvirt group
echo "Adding current user to KVM and Libvirt groups..."
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER

after

# Ask the user if they want to reboot now
read -p "Do you want to reboot now? (yes/no) " reboot_choice

case $reboot_choice in
    [Yy]* ) 
        echo "Rebooting..."
        sudo reboot
        ;;
    [Nn]* ) 
        echo "You've chosen not to reboot now. Please remember to reboot later for changes to take effect."
        ;;
    * ) 
        echo "Invalid choice. Assuming 'no'. Remember to reboot later."
        ;;
esac
