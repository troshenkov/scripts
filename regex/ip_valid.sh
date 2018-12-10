#!/bin/bash

# Ip validator
# Dmitry Troshenkov (troshenkov.d@gmail.com)

if [[ "$?" ]] ; then

ip=("$@")

for ((n=0; n < ${#ip[*]}; n++)) ; do

    if [[ ${ip[$n]} =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

    OIFS=$IFS
    IFS='.'
    _ip=("${ip[$n]}")
    IFS=$OIFS
              # Error avoid: "value too great for base (error token is "09" - %%[!0]*
        if [[ ${_ip[3]%%[!0]*} -le 255 && ${_ip[3]%%[!0]*} -le 255 && \
              ${_ip[3]%%[!0]*} -le 255 && ${_ip[3]%%[!0]*} -le 255 ]]; then

            echo IP is valid.

            else

                echo IP is no valid.

        fi

     else
            echo IP is no valid.

    fi

done

fi
