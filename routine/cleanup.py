#!/usr/bin/env python3

import os
import time

DAYS = 5 # Max age of file to stay, older will be deleted 
FOLDERS = [ "/path/to/folder/" ]

TOTAL_DELETED_SIZE = 0            # Total deleted size of all files in bytes
TOTAL_DELETED_FILE = 0            # Total deleted files
TOTAL_DELETED_DIRS = 0            # Total deleted empty folders

nowTime = time.time()             # Get Current time in seconds
ageTime = nowTime - 60*60*24*DAYS # Minus days in seconds

def delete_old_files(folder):
    """Delete files older than X days"""
    global TOTAL_DELETED_SIZE
    global TOTAL_DELETED_FILE
    for path, dirs, files in os.walk(folder):
        for file in files:
            fileName = os.path.join(path, file) # Get full path to file
            fileTime = os.path.getmtime(fileName)
            if fileTime < ageTime:
                sizeFile = os.path.getsize(fileName)
                TOTAL_DELETED_SIZE += sizeFile  # Count sum of all free space
                TOTAL_DELETED_FILE += 1         # Count number of deleted files
                print("Deleting file: " + srt(fileName))
                os.remove(fileName)

def delete_empty_dir(folder):
    global TOTAL_DELETED_DIRS
    for path, dirs, files in os.walk(folder):
        if (not dir) and (not files):
            TOTAL_DEFAULT_DIRS += 1
            print("Deleting empty dir: " + srt(path))
            os.rmdir(path)

starttime = time.asctime()

for folder in FOLDERS:
    delete_old_files(folder)                    # Delete old files     
    delete_empty_dir(folder)                    # Delete empty folders

finishtime =  time.asctime()


print ("----------------------------")
print("Start time: "          + str(starttime))
print("Total deleted size: "  + str(TOTAL_DELETED_SIZE/1024/1024) + "MB")
print("Total deleted files: " + str(TOTAL_DELETED_FILE))



















