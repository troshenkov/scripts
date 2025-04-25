#!/bin/bash

# Script Name: media_converter.sh (HEIC to JPG and HEVC to MP4)
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Version: 1.1
# Date: 2023-10-01
#
# Description:
# This script converts `.heic` files to `.jpg` format and `.hevc` files to `.mp4` format in the current directory.
# It uses `heif-convert` for `.heic` to `.jpg` conversion and `ffmpeg` for `.hevc` to `.mp4` conversion.
# The script skips conversion if the corresponding output file already exists.
#
# Dependencies:
# - `heif-convert`: For converting `.heic` files to `.jpg`.
# - `ffmpeg`: For converting `.hevc` files to `.mp4`.
#
# Installation:
# On Ubuntu/Debian:
#   - Install `heif-convert`:
#     sudo apt update
#     sudo apt install libheif-examples
#   - Install `ffmpeg`:
#     sudo apt install ffmpeg
#
# On RHEL/Rocky Linux/AlmaLinux:
#   - Install `heif-convert`:
#     sudo yum install libheif-tools
#   - Install `ffmpeg`:
#     sudo yum install epel-release
#     sudo yum install ffmpeg
#
# Usage:
# 1. Place the script in the directory containing `.heic` and `.hevc` files.
# 2. Make the script executable:
#    chmod +x media_converter.sh
# 3. Run the script:
#    ./media_converter.sh
#
# Notes:
# - Ensure that `heif-convert` and `ffmpeg` are installed before running the script.
# - The script will skip files if the corresponding output file already exists.
#
# Disclaimer:
# This script is provided "as is" without any warranty. Use it at your own risk.

# Check if required tools are installed
if ! command -v heif-convert &>/dev/null; then
  echo "Error: heif-convert is not installed. Please install it and try again."
  exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
  echo "Error: ffmpeg is not installed. Please install it and try again."
  exit 1
fi

# Function to convert HEIC to JPG
convert_heic_to_jpg() {
  for file in *.heic; do
    if [[ -f "$file" ]]; then
      output_file="${file%.heic}.jpg"
      if [[ ! -f "$output_file" ]]; then
        echo "Converting $file to $output_file..."
        if heif-convert "$file" "$output_file"; then
          echo "Successfully converted $file to $output_file."
        else
          echo "Error: Failed to convert $file."
        fi
      else
        echo "Skipping $file: $output_file already exists."
      fi
    fi
  done
}

# Function to convert HEVC to MP4
convert_hevc_to_mp4() {
  for file in *.hevc; do
    if [[ -f "$file" ]]; then
      output_file="${file%.hevc}.mp4"
      if [[ ! -f "$output_file" ]]; then
        echo "Converting $file to $output_file..."
        if ffmpeg -i "$file" -c:v libx264 -preset fast -crf 23 -c:a aac "$output_file"; then
          echo "Successfully converted $file to $output_file."
        else
          echo "Error: Failed to convert $file."
        fi
      else
        echo "Skipping $file: $output_file already exists."
      fi
    fi
  done
}

# Main script execution
echo "Starting media conversion..."
convert_heic_to_jpg
convert_hevc_to_mp4
echo "Media conversion completed."

