#!/usr/bin/env python3

"""
File Cleanup Script

This script deletes files older than a specified number of days and removes empty directories.
It is useful for managing disk space and cleaning up old files automatically.

Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
Date Created: <Creation Date>
Last Updated: <Last Update Date>

Configuration:
- DAYS: Defines how many days old a file should be before deletion.
- FOLDERS: List of directories to clean.

Functionality:
- Deletes files older than the specified number of days.
- Removes empty directories.
- Provides summary logs of deleted files and space freed.

Usage:
- Modify `DAYS` and `FOLDERS` as needed.
- Run the script as a cron job for automated cleanup.
"""

import os
import time

# Configuration
DAYS = 5  # Max age of file to stay, older will be deleted
FOLDERS = ["/path/to/folder/"]  # List of folders to clean

# Counters
TOTAL_DELETED_SIZE = 0  # Total deleted size of all files in bytes
TOTAL_DELETED_FILE = 0  # Total deleted files
TOTAL_DELETED_DIRS = 0  # Total deleted empty folders

now_time = time.time()  # Get current time in seconds
age_time = now_time - (60 * 60 * 24 * DAYS)  # Calculate threshold time


def delete_old_files(folder):
    """Delete files older than X days."""
    global TOTAL_DELETED_SIZE, TOTAL_DELETED_FILE

    for path, _, files in os.walk(folder):
        for file in files:
            file_path = os.path.join(path, file)
            try:
                if os.path.getmtime(file_path) < age_time:
                    file_size = os.path.getsize(file_path)
                    TOTAL_DELETED_SIZE += file_size
                    TOTAL_DELETED_FILE += 1
                    print(f"Deleting file: {file_path} ({file_size/1024/1024:.2f} MB)")
                    os.remove(file_path)
            except Exception as e:
                print(f"Error deleting file {file_path}: {e}")


def delete_empty_dirs(folder):
    """Delete empty directories."""
    global TOTAL_DELETED_DIRS

    for path, dirs, files in os.walk(folder, topdown=False):
        if not dirs and not files:
            try:
                os.removedirs(path)
                TOTAL_DELETED_DIRS += 1
                print(f"Deleting empty directory: {path}")
            except Exception as e:
                print(f"Error deleting directory {path}: {e}")


# Execution
start_time = time.asctime()

for folder in FOLDERS:
    delete_old_files(folder)  # Delete old files
    delete_empty_dirs(folder)  # Delete empty folders

finish_time = time.asctime()

# Summary
print("\n----------------------------")
print(f"Start time: {start_time}")
print(f"Total deleted size: {TOTAL_DELETED_SIZE / 1024 / 1024:.2f} MB")
print(f"Total deleted files: {TOTAL_DELETED_FILE}")
print(f"Total deleted directories: {TOTAL_DELETED_DIRS}")
print(f"Finish time: {finish_time}")

