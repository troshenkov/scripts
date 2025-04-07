#!/bin/sh
# ------------------------------------------------------------------------------
# Image Optimizer for Web
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Description:
#   This script optimizes JPEG and PNG images for web use by reducing file size
#   while maintaining quality. It automatically detects and installs missing tools.
#
# Usage:
#   1. Place this script in the root directory where images are stored.
#   2. Grant execution permissions: chmod +x image_optimizer.sh
#   3. Run the script: ./image_optimizer.sh
#
# Features:
#   - Uses jpegoptim to compress JPEG images.
#   - Uses optipng to compress PNG images.
#   - Logs before-and-after storage sizes.
#   - Installs missing dependencies automatically.
#
# Dependencies:
#   - jpegoptim (for JPEG compression)
#   - optipng (for PNG compression)
#
# Configuration:
#   - Modify `_PATH` to set the root directory for image optimization.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./image_optimizer.sh
#
# ------------------------------------------------------------------------------

# Set root directory for optimization
_PATH="/home/"

# Log file
LOG_FILE="$(basename "$0").log"

# Function to install jpegoptim
install_jpegoptim() {
    echo "Installing jpegoptim..."
    wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.2.tar.gz
    tar -xzf jpegoptim-1.4.2.tar.gz
    cd jpegoptim-1.4.2 || exit
    ./configure && make && make install
    cd .. && rm -rf jpegoptim-1.4.2 jpegoptim-1.4.2.tar.gz
}

# Function to install optipng
install_optipng() {
    echo "Installing optipng..."
    wget http://prdownloads.sourceforge.net/optipng/optipng-0.7.5.tar.gz
    tar -xzf optipng-0.7.5.tar.gz
    cd optipng-0.7.5 || exit
    make && make install
    cd .. && rm -rf optipng-0.7.5 optipng-0.7.5.tar.gz
}

# Validate path
if [ ! -d "${_PATH}" ]; then
    echo "Error: Directory ${_PATH} does not exist."
    exit 1
fi

# Check and install jpegoptim
if ! command -v jpegoptim >/dev/null 2>&1; then
    install_jpegoptim || { echo "jpegoptim installation failed"; exit 1; }
fi

# Check and install optipng
if ! command -v optipng >/dev/null 2>&1; then
    install_optipng || { echo "optipng installation failed"; exit 1; }
fi

# Log initial disk usage
echo "Before size: $(du -sh "${_PATH}")" >> "${LOG_FILE}"

# Optimize JPEG images
find "${_PATH}" -type f -iname "*.jpg" -o -iname "*.jpeg" | while read -r file; do
    jpegoptim --max=80 --strip-all "$file" >> "${LOG_FILE}" 2>/dev/null
done

# Optimize PNG images
find "${_PATH}" -type f -iname "*.png" | while read -r file; do
    optipng "$file" >> "${LOG_FILE}" 2>/dev/null
done

# Log final disk usage
echo "After size: $(du -sh "${_PATH}")" >> "${LOG_FILE}"

echo "Image optimization completed."

exit 0
