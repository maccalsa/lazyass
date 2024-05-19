#!/bin/bash

# Function to check and install missing dependencies
ensure_dependencies() {
    local missing_deps=0

    # Check for tar and install if missing
    if ! command -v tar &> /dev/null; then
        echo "tar is not installed. Attempting to install..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y tar
        elif [[ -f /etc/fedora-release ]]; then
            sudo dnf install -y tar
        elif [[ -f /etc/arch-release ]]; then
            sudo pacman -Sy tar
        else
            echo "Unsupported distribution for automatic installation of tar."
            missing_deps=1
        fi
    fi

    # Check for ssh and install if missing
    if ! command -v ssh &> /dev/null; then
        echo "ssh is not installed. Attempting to install..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y openssh-client
        elif [[ -f /etc/fedora-release ]]; then
            sudo dnf install -y openssh-clients
        elif [[ -f /etc/arch-release ]]; then
            sudo pacman -Sy openssh
        else
            echo "Unsupported distribution for automatic installation of SSH."
            missing_deps=1
        fi
    fi

    return $missing_deps
}

# Function to perform local backup
local_backup() {
    if tar -czf "${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz" -C "${SOURCE_DIR}" .; then
        echo "Local backup completed successfully."
    else
        echo "Error: Failed to create local backup."
        exit 1
    fi
}

# Function to perform SSH backup
ssh_backup() {
    read -p "Enter SSH destination (e.g., user@host:/path): " SSH_DEST
    if tar -czf - -C "${SOURCE_DIR}" . | ssh "${SSH_DEST}" "cat > '${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz'"; then
        echo "SSH backup completed successfully."
    else
        echo "Error: Failed to create SSH backup."
        exit 1
    fi
}

# Ensure all dependencies are installed
if ! ensure_dependencies; then
    echo "Failed to install required dependencies."
    exit 1
fi

# Prompt for the source and backup directories
read -p "Enter the source directory: " SOURCE_DIR
read -p "Enter the backup directory: " BACKUP_DIR

# Validate directories
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Create a timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Ask user for backup method
echo "Choose the backup method:"
select method in "Local" "SSH"
do
    case $method in
        "Local")
            local_backup
            break
            ;;
        "SSH")
            ssh_backup
            break
            ;;
        *)
            echo "Invalid option. Please choose 'Local' or 'SSH'."
            ;;
    esac
done
