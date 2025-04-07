#!/bin/bash
# ------------------------------------------------------------------------------
# Recursive File Encoding Converter (Windows-1251 to UTF-8)
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Description:
#   This script converts text files from Windows-1251 encoding to UTF-8.
#   It processes specified file types recursively within a directory.
#
# Usage:
#   1. Place this script in the root directory of your project.
#   2. Grant execution permissions: chmod +x convert_encoding.sh
#   3. Run the script: ./convert_encoding.sh
#
# Features:
#   - Converts .php, .html, .css, .js, .xml, and .txt files.
#   - Preserves the original file structure.
#   - Displays progress for each processed file.
#
# Dependencies:
#   - iconv (for encoding conversion)
#
# Configuration:
#   - Modify the find command to include additional file extensions if needed.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./convert_encoding.sh
#
# ------------------------------------------------------------------------------

# Start processing files
find ./ -type f \( -name "*.php" -o -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.xml" -o -name "*.txt" \) | while read -r file; do
    echo "Converting: $file"
    mv "$file" "$file.bak"
    iconv -f WINDOWS-1251 -t UTF-8 "$file.bak" > "$file"
    rm -f "$file.bak"
done

echo "Conversion completed successfully."

exit 0
