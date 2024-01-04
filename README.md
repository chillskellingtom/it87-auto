# Gigabyte z790 Sensor Setup - it87-auto
Installation script for it87 drivers compatible with Gigabyte Motherboards on Linux. 

After countless re-installs of a Proxmox node running a Gigabyte Aorus z790 Xtreme DDR4 motherboard, the below script automates the addition of the patched Linux drivers thanks to [frankcrawford](https://github.com/frankcrawford/it87), [hannesha](https://github.com/hannesha/it87), and original repo from [a1wong](https://github.com/a1wong/it87).

## Aim
The script `setup_sensors.sh` automates the installation of sensor monitoring tools and drivers, specifically targeting the Gigabyte Z790 motherboard. It performs the following tasks:
1. Installs the `lm-sensors` package for hardware sensor monitoring.
2. Automatically detects available sensors on the motherboard.
3. Clones and installs a custom `it87` driver from a GitHub repository, which is necessary for certain Gigabyte motherboards that are not supported out-of-the-box by `lm-sensors`.
4. Executes `sudo modprobe it87 ignore_resource_conflict=1 force_id=0x8622` to load the `it87` driver with specific parameters to avoid resource conflicts and to force the driver to recognize the motherboard's sensor chip.
5. Loads the `it87` driver and configures it to start on boot.

#### Force + Ignore Conflict Parameters

- The `sudo modprobe it87 ignore_resource_conflict=1 force_id=0x8622` command loads the `it87` kernel module with specific settings to handle potential I/O conflicts and to recognise the motherboard's sensor chip correctly.
- This approach is sometimes required when configuring Linux kernel modules to accommodate various hardware configurations, especially when dealing with newer or non-standard components.

## Running the Script
1. The script must be run as the root user. Ensure you have the necessary privileges before executing it.
2. Make sure your Proxmox node has an internet connection as the script needs to clone a repository and install packages.

## Script Execution
1. Download or create the script `setup_sensors.sh` on your Proxmox node.

2. Make the script executable:

sudo chmod +x ./setup_sensors.sh

3. Execute the script:

sudo ./setup_sensors.sh
