#!/bin/bash

email=troshenkov.d@gmail.com

pattern='^[[:alnum:]._%+-]+@[[:alnum:]._+-]+.[[:alpha:]]{2,4}$'

if [[ $email =~ $pattern ]]; then

    echo good

else

    echo bad
fi
