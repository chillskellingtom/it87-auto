#!/bin/bash

# Function to print in green for success
print_success() {
    echo -e "\e[32m$1\e[0m"
}

# Function to print in red for failure
print_failure() {
    echo -e "\e[31m$1\e[0m" >&2
}

# Function to display progress
progress_bar() {
    local PROGRESS_BAR_SIZE=50
    local CURRENT_PROGRESS=$1
    local MAX_PROGRESS=$2
    local BAR_FILLED=$((CURRENT_PROGRESS * PROGRESS_BAR_SIZE / MAX_PROGRESS))
    local BAR_EMPTY=$((PROGRESS_BAR_SIZE - BAR_FILLED))
    printf "\r["
    printf "%${BAR_FILLED}s" | tr ' ' '='
    printf "%${BAR_EMPTY}s" | tr ' ' ' '
    printf "]"
}

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Starting sensor setup for Gigabyte Z790 Motherboard..."

# Install lm-sensors
print_success "Installing lm-sensors package..."
apt-get update && apt-get install -y lm-sensors
progress_bar 1 4

# Detect sensors
print_success "Detecting sensors (automated)..."
yes "" | sensors-detect --auto
progress_bar 2 4

# Install custom it87 driver
print_success "Installing custom it87 driver for Gigabyte motherboard..."
if [ -d "it87" ]; then
    print_success "it87 directory already exists. Skipping git clone."
else
    git clone https://github.com/frankcrawford/it87 || print_failure "Failed to clone it87 repository."
fi

cd it87
sudo make clean
sudo make
sudo make install
sudo modprobe it87 ignore_resource_conflict=1 force_id=0x8622
progress_bar 3 4

# Configure it87 driver to load at boot
print_success "Configuring it87 driver to load at boot..."
echo "options it87 ignore_resource_conflict=1 force_id=0x8622" > /etc/modprobe.d/it87.conf

# Check if 'it87' is already in /etc/modules and add if not
if ! grep -q "^it87$" /etc/modules; then
    echo "it87" >> /etc/modules
fi

# Execute sensors command to verify sensor output
print_success "Executing sensors command to verify sensor output..."
sensors_output=$(sensors)
echo "$sensors_output"

# Check for known IT87 chips
print_success "Checking for known IT87 chips..."
prefixes="it8603 it8613 it8620 it8622 it8625 it8628 it8705 it8712 it8716 it8718 it8720 it8721 it8728 it8732 it8771 it8772 it8781 it8782 it8783 it8786 it8790 sis950"
for prefix in $prefixes; do
    if [[ $sensors_output == *"$prefix"* ]]; then
        print_success "Detected chip with prefix: $prefix"
    fi
done

print_success "Sensor setup complete. Please check the above output for detected sensors."
progress_bar 4 4
echo ""
