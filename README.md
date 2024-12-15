# GPU Manager Script

A bash script for Ubuntu systems to easily enable or disable NVIDIA GPUs. This tool is particularly useful for:
- Conserving power on laptops
- Troubleshooting graphics issues
- Switching between integrated and dedicated graphics
- System maintenance

## Prerequisites

- Ubuntu or Ubuntu-based Linux distribution
- NVIDIA GPU and drivers installed
- Root/sudo privileges
- Basic command line knowledge

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/yunatamos/gpu-manager/main/gpu-manager.sh
```

2. Make the script executable:
```bash
chmod +x gpu-manager.sh
```

## Usage

The script requires sudo privileges and accepts one of two commands: `enable` or `disable`.

### Disable GPU
```bash
sudo ./gpu-manager.sh disable
```

### Enable GPU
```bash
sudo ./gpu-manager.sh enable
```

### Important Notes
- A system reboot is required after running either command
- The script will prompt for confirmation before making changes
- If no NVIDIA drivers are detected, the script will exit safely

## How It Works

### Disable Operation
- Creates a blacklist for NVIDIA kernel modules
- Unloads NVIDIA modules from the current session
- Stops and disables the NVIDIA persistence daemon
- Switches to integrated graphics (if available)
- Updates initramfs

### Enable Operation
- Removes the NVIDIA module blacklist
- Loads NVIDIA kernel modules
- Enables and starts the NVIDIA persistence daemon
- Switches to NVIDIA graphics (if available)
- Updates initramfs

## Troubleshooting

1. **"Please run as root" error**
   - Make sure to run the script with sudo

2. **"NVIDIA drivers not found" message**
   - Verify NVIDIA drivers are installed: `nvidia-smi`
   - Install drivers if needed: `sudo ubuntu-drivers autoinstall`

3. **Black screen after disable/enable**
   - Boot into recovery mode
   - Remove blacklist file: `rm /etc/modprobe.d/blacklist-nvidia.conf`
   - Update initramfs: `update-initramfs -u`
   - Reboot

## Safety Features

- Checks for root privileges
- Verifies NVIDIA driver presence
- Confirms actions with user
- Provides status messages
- Includes rollback instructions

## Limitations

- Currently supports NVIDIA GPUs only
- Requires system reboot to apply changes
- May not work with all GPU configurations
- Designed for Ubuntu and similar distributions

## Contributing

Feel free to submit issues and enhancement requests!

## License

This script is released under the MIT License. See the LICENSE file for details.

## Author

YUnatamoS
