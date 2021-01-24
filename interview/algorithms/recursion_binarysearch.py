#!/usr/bin/env python3

# Recursion #4
# Binary search works on sorted arrays

def binarysearch(mylist, target, start, stop):
    if start > stop:
        return False
    else:
        mid = (start + stop) // 2
        if target == mylist[mid]:
            return mid
        elif target < mylist[mid]:
            return binarysearch(mylist, target, start, mid - 1)
        else:
            return binarysearch(mylist, target, mid + 1, stop)

mylist = [10, 12, 15, 19, 20, 23, 24, 35, 39, 44, 51, 66 , 77, 84]
target = 24
start = 0
stop = len(mylist)

x = binarysearch(mylist, target, start, stop)

if x == False:
    print("Item ", target, "Not Found!")
else:
    print("Item ", target, "Found at Index ", x)
