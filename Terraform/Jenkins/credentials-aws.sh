#!/bin/bash

FILE="$HOME/.ssh/credentials.csv"
USER="terraform"

export AWS_ACCESS_KEY_ID=$(grep "$USER" "$FILE" | awk -F "," '{ print $3}')
export AWS_SECRET_ACCESS_KEY=$(grep "$USER" "$FILE" | awk -F "," '{ print $4}')

#export AWS_ACCESS_KEY_ID=$(awk -F "," '{ print $3}' "$FILE" | awk 'NR==2')
#export AWS_SECRET_ACCESS_KEY=$(awk -F "," '{ print $4}' "$FILE" | awk 'NR==2')
#env | grep AWS
