#!/usr/bin/env python3

import os
import sys
import shutil

# logrotate.py

if(len(sys.argv) < 4):
    print("Missing arguments! Usage: logrotate.py <file.log> <size> <limit>")
    exit(1)

file_name  = sys.argv[1]
limitsize  = int(sys.argv[2])
logsnumber = int(sys.argv[3])

if(os.path.isfile(file_name) == True):               # Chech if MAIN logfile exist
    logfile_size = os.stat(file_name).st_size / 1024 # Get Filesize in kilobytes

    if(logfile_size >= limitsize):
        if(logsnumber > 0):
            for currentFileNum in range(logsnumber, 1, -1):
                src = file_name + "_" + str(currentFileNum - 1)
                dst = file_name + "_" + str(currentFileNum)
                if(os.path.isfile(src) == True):
                    shutil.copyfile(src, dst)
                    print("Copied: " + src + " to " + dst)

            shutil.copyfile(file_name, file_name + "_1") 
            print("Copied: " + " to " + file_name + "_1")
    myfile = open(file_name, 'w')
    myfile.close()
    
