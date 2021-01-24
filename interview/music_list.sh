#!/bin/bash

#--- Apple ---

# Write a program (In your preferred programming language) to generate a Sorted List of 
# Artists from “Billboard Hot 100” based on the total number of letters in their track title.
# You can find Billboard Hot 100 list at : https://www.billboard.com/charts/hot-100

URL='https://www.billboard.com/charts/hot-100'
SONG_PTN='chart-element__information__song'
ARTIST_PTN='chart-element__information__artist'

declare -a LIST=($(curl -s "$URL" | grep 'span' | grep "$SONG_PTN\|$ARTIST_PTN" | sed  's/<[^>]*>//g' | sed 's/^ *//g' | tr ' ' '\*' | tr ',' '\*' ))

declare -a SONGS
declare -a ARTISTS
declare -a COUNT

for ((n=0; n < ${#LIST[*]}; n++)) ; do
	SONGS+=(${LIST[$n]})
	n="$n"+1
	ARTISTS+=(${LIST[$n]})
done

for ((n=0; n < ${#SONGS[*]}; n++)) ; do
        COUNT+=($(echo ${SONGS[$n]} | wc -c))
done

for ((i = 0; i<=${#COUNT[@]}; i++)); do
   for((j = 0; j<=${#COUNT[@]}; j++)); do
	if [[ ${COUNT[$i]} -gt ${COUNT[$j]} ]] ; then

	    # swap the total number of letters in their track title. 
            temp=${COUNT[$i]} 
            COUNT[$i]=${COUNT[$j]}   
            COUNT[$j]=$temp

            # swap the name of songs
	    temp=${SONGS[$i]}
	    SONGS[$i]=${SONGS[$j]}
            SONGS[$j]=$temp
	    
            # swap the name of artists
            temp=${ARTISTS[$i]}
            ARTISTS[$i]=${ARTISTS[$j]}
            ARTISTS[$j]=$temp
        fi
   done
done

for ((i = 0; i<=${#COUNT[@]}; i++)); do
	echo "${SONGS[$i]}, ${ARTISTS[$i]}"
done
