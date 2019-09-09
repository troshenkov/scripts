#!/usr/bin/env python3

# Recursion #4
# Fibonacci number 
# 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ... 17811 ...

def fibon(x):
   if x == 0:
       return 0
   elif x == 1:
       return 1
   else:
       return fibon(x-1) + fibon(x-2)

print(fibon(10))

    
    
