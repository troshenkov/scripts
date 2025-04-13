#!/bin/bash

# Script: fizzbuzz.sh
#
# Description:
#   This script prints the numbers from 1 to 100 with the classic FizzBuzz logic:
#   - For multiples of 3, it prints "Fizz".
#   - For multiples of 5, it prints "Buzz".
#   - For numbers divisible by both 3 and 5, it prints "FizzBuzz".
#   - Otherwise, it simply prints the number.
#
# Requirements:
#   - Bash shell
#
# Usage:
#   Run the script directly:
#       ./fizzbuzz.sh
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date: April 13, 2025
#
# -----------------------------------------------------------------------------
# Notes:
#   - This is a standard coding exercise to test basic control flow and arithmetic.
#   - Output includes the number followed by its FizzBuzz result, if applicable.
# -----------------------------------------------------------------------------

COUNTER=1

while [ $COUNTER -le 100 ]; do
    if (( COUNTER % 15 == 0 )); then
        echo "$COUNTER: FizzBuzz"
    elif (( COUNTER % 3 == 0 )); then
        echo "$COUNTER: Fizz"
    elif (( COUNTER % 5 == 0 )); then
        echo "$COUNTER: Buzz"
    fi
    (( COUNTER++ ))
done