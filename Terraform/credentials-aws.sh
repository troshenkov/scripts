#!/bin/bash -       
#title           :credentials-aws.sh
#description     :This script will make credentials for AWS.
#author		 :Dmitry Troshenkov (troshenkov.d@gmail.com)
#date            :05182020
#version         :0.2    
#usage		 :bash credentials-aws.sh
#notes           :This script has variables: FILE - The credential csv file with imported from AWS IAM
#					     USER - IAM username

FILE="$HOME/.ssh/credentials.csv"
USER="terraform"

[ ! -f "$FILE" ] && { echo "File $FILE does not exist "; exit 1; }
[ ! -r "$FILE" ] && { echo "File $FILE is not readable"; exit 1; }


# First implementation 
export AWS_ACCESS_KEY_ID=$(grep "$USER" "$FILE" | awk -F "," '{ print $3}')
export AWS_SECRET_ACCESS_KEY=$(grep "$USER" "$FILE" | awk -F "," '{ print $4}')

# Second implementation
#export AWS_ACCESS_KEY_ID=$(awk -F "," '{ print $3}' "$FILE" | awk 'NR==2')
#export AWS_SECRET_ACCESS_KEY=$(awk -F "," '{ print $4}' "$FILE" | awk 'NR==2')

# Print credentials from environment
env | grep AWS

exit 0

