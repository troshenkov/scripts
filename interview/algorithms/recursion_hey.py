#!/usr/bin/env python3

# Recrusion #1

def hey(x):
    if x == 0:
        return
    else:
        print("Hello World!")
        hey(x-1)


hey(4)
