#!/bin/sh
# ------------------------------------------------------------------------------
# Script to comment or uncomment lines in a file based on start and end patterns.
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script searches for the start and end patterns within a file and 
#   comments or uncomments the lines between them.
#
# Usage:
#   ./un_comment.sh
#
# Configuration:
#   - Set `target_file` to the file you want to process.
#   - Set `start_commented_area` and `end_commented_area` to the patterns 
#     that define the start and end of the lines to be commented or uncommented.
#
# Exit Codes:
#   0 - Script executed successfully.
#   1 - Error in finding start or end patterns in the file.
#
# Example:
#   ./un_comment.sh
# ------------------------------------------------------------------------------

# Target file to process
target_file='/path/to/your/file'

# Define the start and end commented areas (patterns to find in the file)
start_commented_area='START_PATTERN'
end_commented_area='END_PATTERN'

# Get the start and end line numbers where the patterns are found
start_line=$(awk "/${start_commented_area}/ {print NR; exit}" ${target_file})
end_line=$(awk "/${end_commented_area}/ {print NR; exit}" ${target_file})

# Check if both start and end lines are found
if [ -n "${start_line}" ] && [ -n "${end_line}" ]; then
    # Comment out lines between start and end lines
    # sed -i "${start_line},${end_line}s/^/#/" ${target_file}
    
    # Uncomment lines between start and end lines
    sed -i "${start_line},${end_line}s/^#//" ${target_file}
else
    echo "Error: Could not find both start and end patterns in the file."
    exit 1
fi

exit 0
