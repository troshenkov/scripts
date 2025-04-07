#!/bin/bash

# ------------------------------------------------------------------------------
# VBox Kernel Module Signing Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script addresses issues related to VirtualBox kernel module loading 
#   such as errors related to "/dev/vboxnetctl" or "vboxdrv". The script signs 
#   kernel modules using the Machine Owner Key (MOK) and imports it for secure 
#   loading.
#
# Usage:
#   ./vbox_kernel_module_signing.sh
#
# Prerequisites:
#   - VirtualBox installed
#   - Kernel headers installed
#   - mokutil installed
#
# Steps:
#   1. Generate MOK (Machine Owner Key) for signing.
#   2. Sign VirtualBox kernel modules.
#   3. Import the MOK into the system's keyring using `mokutil`.
#   4. Reboot the system for changes to take effect.
#
# Dependencies:
#   - openssl
#   - mokutil
#   - linux kernel headers
#   - VirtualBox kernel modules
#
# Note:
#   Ensure that you have the correct kernel headers installed for your running kernel.
# ------------------------------------------------------------------------------
# Script Start

set -e  # Exit on error

# Step 1: Generate the MOK (Machine Owner Key) for signing modules
echo "Generating MOK for signing..."
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=MOK Signing/"

# Step 2: Sign VirtualBox kernel modules
echo "Signing VirtualBox kernel modules..."
for modfile in $(dirname $(modinfo -n vboxdrv))/*.ko; do
  echo "Signing $modfile..."
  /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der "$modfile"
done

# Step 3: Import the MOK into the system keyring
echo "Importing MOK..."
sudo mokutil --import MOK.der && echo "Reboot your system for changes to take effect..."

exit 0
