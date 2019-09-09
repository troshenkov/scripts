#!/usr/bin/env python3

# Recursion #3
# Factorial 5! = 1*2*3*4*5 = 120

def factorial(x):
    if x == 0:
        return 1 
    else:
        return x * factorial(x-1)


print(factorial(5))
