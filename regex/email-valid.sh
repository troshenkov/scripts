#!/bin/bash

email='troshenkov.d@gmail..com'

_RFC822="\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"

if [[ $email =~ $_RFC822 ]]; then

#if [[ $email =~ ^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:].]{2,4}$ ]]; then

echo good

else

    echo bad
fi
