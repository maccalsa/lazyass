#!/bin/bash

# Function to install missing dependencies
install_dependencies() {
    echo "Checking and installing necessary dependencies..."
    local install_cmd=""
    
    # Determine the package manager
    if [[ -f /etc/arch-release ]]; then
        install_cmd="sudo pacman -Sy --noconfirm"
    elif [[ -f /etc/fedora-release ]]; then
        install_cmd="sudo dnf install -y"
    elif [[ -f /etc/debian_version ]]; then
        install_cmd="sudo apt-get update && sudo apt-get install -y"
    else
        echo "Unsupported distribution. Please manually install required packages."
        return 1
    fi

    # Check for 'ss' utility, part of 'iproute2'
    if ! command -v ss &> /dev/null; then
        echo "Installing 'iproute2'..."
        $install_cmd iproute2
    fi

    # Check for 'tcpdump'
    if ! command -v tcpdump &> /dev/null; then
        echo "Installing 'tcpdump'..."
        $install_cmd tcpdump
    fi

    echo "All necessary dependencies are installed."
    return 0
}

# Ensure dependencies are installed before continuing
if ! install_dependencies; then
    exit 1
fi

# Default to the current logged-in user
CURRENT_USER=$(whoami)
read -p "Enter username to check ports for (default: $CURRENT_USER): " USER
USER=${USER:-$CURRENT_USER}

# Function to list open ports
list_ports() {
    echo "Open ports and associated programs for user: $USER"
    ss -ltnp | grep "$(ps -u $USER -o pid= | tr '\n' '|')" | awk '{print $1, $5, $6}'
}

# Function to query specific port
query_port() {
    read -p "Enter the port number to query: " PORT
    echo "Details for port $PORT for user $USER:"
    ss -ltnp | grep ":$PORT " | grep "$(ps -u $USER -o pid= | tr '\n' '|')"
}

# Function to kill process on a specific port
kill_process_on_port() {
    read -p "Enter the port number to kill the process on: " PORT
    local pid=$(ss -ltnp | grep ":$PORT " | grep "$(ps -u $USER -o pid= | tr '\n' '|')" | awk '{print $7}' | sed 's/.*pid=\([0-9]*\),.*/\1/')
    if [ -z "$pid" ]; then
        echo "No process found running on port $PORT for user $USER."
        return
    fi
    echo "Killing process with PID $pid on port $PORT..."
    kill $pid
    echo "Process killed."
}

# Function to monitor traffic on a specific port
monitor_traffic_on_port() {
    read -p "Enter the port number to monitor: " PORT
    echo "Monitoring traffic on port $PORT. Press Ctrl+C to stop."
    sudo tcpdump -i any port $PORT
}

# Display options to the user
echo "Select an operation:"
echo "1) List all open ports for $USER"
echo "2) Query a specific port for $USER"
echo "3) Kill a process on a specific port for $USER"
echo "4) Monitor traffic on a specific port"
read -p "Choose an option (1-4): " OPTION

case $OPTION in
    1) 
        list_ports
        ;;
    2) 
        query_port
        ;;
    3) 
        kill_process_on_port
        ;;
    4) 
        monitor_traffic_on_port
        ;;
    *) 
        echo "Invalid option selected."
        ;;
esac
