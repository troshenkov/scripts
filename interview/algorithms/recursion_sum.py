#!/usr/bin/env python3

# Recursion #2
# sum 0+1+2+3+4+5

def sum(x):
    if x == 0:
        return 0
    elif x == 1:
        return 1
    else:
        return x + sum(x-1)


z = sum(5)
print(z)
