#!/bin/bash

COUNTER=1

while [  $COUNTER -lt 101 ]; do
    if [ $(( $COUNTER % 15 )) -eq 0 ]; then
        echo "$COUNTER: FizzBizz"
    elif [ $(( $COUNTER % 3 )) -eq 0 ]; then
        echo "$COUNTER: Fizz"
    elif [ $(( $COUNTER % 5 )) -eq 0 ]; then
        echo "$COUNTER: Buzz"
    fi
    COUNTER=$(( $COUNTER + 1 ))
done
