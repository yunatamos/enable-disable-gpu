#!/bin/bash

# Script to enable/disable GPU on Ubuntu
# Must be run with sudo privileges

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Function to show usage
show_usage() {
    echo "Usage: $0 [enable|disable]"
    echo "Examples:"
    echo "  $0 enable   - Enable the GPU"
    echo "  $0 disable  - Disable the GPU"
    exit 1
}

# Function to check if nvidia drivers are installed
check_nvidia() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA drivers not found. Script may not be necessary."
        exit 0
    fi
}

# Function to disable GPU
disable_gpu() {
    echo "Disabling GPU..."
    
    # Create blacklist file for nvidia modules
    cat > /etc/modprobe.d/blacklist-nvidia.conf << EOF
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_uvm
blacklist nvidia_modeset
EOF
    
    # Update initramfs
    update-initramfs -u
    
    # Remove nvidia modules from current session
    modprobe -r nvidia_drm
    modprobe -r nvidia_uvm
    modprobe -r nvidia_modeset
    modprobe -r nvidia
    
    # Disable nvidia-persistence service if it exists
    if systemctl is-active --quiet nvidia-persistence; then
        systemctl stop nvidia-persistence
        systemctl disable nvidia-persistence
    fi
    
    # Set system to use integrated graphics if available
    if command -v prime-select &> /dev/null; then
        prime-select intel
    fi
    
    echo "GPU has been disabled. Please reboot your system for changes to take effect."
}

# Function to enable GPU
enable_gpu() {
    echo "Enabling GPU..."
    
    # Remove blacklist file if it exists
    if [ -f /etc/modprobe.d/blacklist-nvidia.conf ]; then
        rm /etc/modprobe.d/blacklist-nvidia.conf
    fi
    
    # Update initramfs
    update-initramfs -u
    
    # Load nvidia modules
    modprobe nvidia
    modprobe nvidia_drm
    modprobe nvidia_uvm
    modprobe nvidia_modeset
    
    # Enable and start nvidia-persistence service if it exists
    if systemctl list-unit-files | grep -q nvidia-persistence; then
        systemctl enable nvidia-persistence
        systemctl start nvidia-persistence
    fi
    
    # Set system to use NVIDIA graphics if available
    if command -v prime-select &> /dev/null; then
        prime-select nvidia
    fi
    
    echo "GPU has been enabled. Please reboot your system for changes to take effect."
}

# Check command line arguments
if [ $# -ne 1 ]; then
    show_usage
fi

# Main execution
echo "GPU Management Script"
echo "===================="

# Check for NVIDIA drivers
check_nvidia

# Process command line argument
case "$1" in
    enable)
        read -p "This will enable the GPU. Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            enable_gpu
        else
            echo "Operation cancelled"
            exit 1
        fi
        ;;
    disable)
        read -p "This will disable the GPU. Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            disable_gpu
        else
            echo "Operation cancelled"
            exit 1
        fi
        ;;
    *)
        show_usage
        ;;
esac
