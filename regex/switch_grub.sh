#!/bin/bash

# ===================================================================
# GRUB Default Kernel Setter for Rocky Linux
# ===================================================================
# Purpose:
#   - Set the default GRUB boot entry to the highest installed kernel version.
#   - Designed for Rocky Linux systems.
#
# Usage:
#   - ./set_default_kernel.sh
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Function to set the default GRUB kernel
set_default_grub_kernel() {
    local kernel_dir="/boot"
    local kernel_prefix="vmlinuz-"
    local highest_kernel=""
    local highest_version=""

    # Ensure the kernel directory exists
    if [[ ! -d "$kernel_dir" ]]; then
        echo "Kernel directory not found: $kernel_dir"
        exit 1
    fi

    # Iterate over kernel images to find the highest version
    for kernel in "$kernel_dir"/$kernel_prefix*; do
        # Extract the version number using regex
        if [[ $kernel =~ $kernel_prefix([0-9]+\.[0-9]+\.[0-9]+.*) ]]; then
            version=${BASH_REMATCH[1]}
            # Compare versions
            if [[ -z "$highest_version" || "$version" > "$highest_version" ]]; then
                highest_version=$version
                highest_kernel=$kernel
            fi
        fi
    done

    # Check if a kernel was found
    if [[ -z "$highest_kernel" ]]; then
        echo "No kernels found in $kernel_dir"
        exit 1
    fi

    # Set the highest kernel as the default using grubby
    grubby --set-default="$highest_kernel"

    # Verify the change
    if [[ $? -eq 0 ]]; then
        echo "GRUB default kernel set to: $highest_version"
    else
        echo "Failed to set the default kernel."
        exit 1
    fi
}

# Main script execution
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

set_default_grub_kernel
exit 0
