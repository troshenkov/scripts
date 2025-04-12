#!/bin/bash
# ---------------------------------------------------------------------------
# Script: imagen.sh
# Description: Generates an image using the Google Gemini API (Imagen model)
#              based on a given text prompt and saves it as a PNG file.
#
# Requirements:
#   - A valid Google Gemini API key stored in the GEMINI_API_KEY environment variable.
#   - Dependencies: curl, jq, base64
#
# Dependencies Installation:
#   For Debian/Ubuntu:
#     sudo apt update
#     sudo apt install -y curl jq coreutils
#
#   For RHEL/Rocky:
#     sudo yum install -y curl jq coreutils
#   For Gentoo:
#     sudo emerge --ask net-misc/curl sys-apps/coreutils app-misc/jq
#
# Usage:
#   1. Export your Google Gemini API key:
#      export GEMINI_API_KEY="your_api_key_here"
#
#   2. Run the script with a text prompt and output file name:
#      ./imagen.sh <prompt> <output_file_without_extension>
#
#      Example:
#      ./imagen.sh "A futuristic cityscape at sunset" cityscape
#      # This will generate an image based on the prompt and save it as cityscape.png
#
# Error Handling:
#   - Ensures the API key is set.
#   - Validates input arguments.
#   - Handles API errors and malformed responses.
#   - Provides clear error messages for common issues.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date: April 12, 2025
# ---------------------------------------------------------------------------

imagen () {
    # Check if GEMINI_API_KEY is set
    if [[ -z "$GEMINI_API_KEY" ]]; then
        echo "Error: GEMINI_API_KEY is not set. Please export your API key." >&2
        return 1
    fi

    # Validate input arguments
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: imagen <prompt> <output_file_without_extension>" >&2
        return 1
    fi

    local prompt="$1"
    local output_file="$2.png"

    # Make the API request
    local response
    response=$(curl -s https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key="$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -X POST \
        -d '{"instances": [{"prompt": "'"$prompt"'"}],"parameters": {"sampleCount": 1, "aspectRatio": "16:9"}}')

    # Check if the API response is empty
    if [[ -z "$response" ]]; then
        echo "Error: No response from the API. Please check your network connection or API key." >&2
        return 1
    fi

    # Extract the Base64-encoded image data
    local image_data
    image_data=$(echo "$response" | jq -r '.predictions[0].bytesBase64Encoded' 2>/dev/null)

    # Check if the image data was successfully extracted
    if [[ -z "$image_data" || "$image_data" == "null" ]]; then
        echo "Error: Failed to extract image data from the API response." >&2
        echo "Response: $response" >&2
        return 1
    fi

    # Decode the Base64 image data and save it to a file
    echo "$image_data" | base64 -d > "$output_file" || {
        echo "Error: Failed to save the image to $output_file." >&2
        return 1
    }

    # Confirm success
    echo "Image successfully saved as $output_file"
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ensure the script is run directly, not sourced
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <prompt> <output_file_without_extension>" >&2
        exit 1
    fi

    # Call the imagen function with the provided arguments
    imagen "$1" "$2"
fi