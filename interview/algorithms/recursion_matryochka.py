#!/usr/bin/env python3



def matryoshka(n):
    if n == 1:
        print(">Smallest Matryoshka")
    else:
        print("Top    n=", n)
        matryoshka(n-1)
        print("Bottom n=", n)

matryoshka(5)
