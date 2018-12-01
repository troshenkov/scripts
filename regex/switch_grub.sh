#!/bin/bash
#
# Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# The bash script that change the grub default boot to the highest kernel (not necessary the first entry) version. 
# The OS is CentOS 6.x 
#
declare -a KVERS=(`egrep '^[[:space:]]*kernel' /boot/grub/grub.conf \
		| awk '{print $2}' \
		| sed "s/.el6.x86_64//g" \
		| sed -rn 's/[^[:digit:]]*([[:digit:]]+)[^[:digit:]]+([[:digit:]]+)[^[:digit:]]*/\1 \2/p' \
		| tr -d [:punct:] \
		| sed "s/ /\./g"`)

default=$(egrep '^default' /boot/grub/grub.conf | awk -F'=' '{print $2}')

for ((n=0; n < ${#KVERS[*]}; n++)) ; do 
 	if [ $(echo "${KVERS[$n]}>$MAX"|bc) -eq 1 ]; then
            MAX=${KVERS[$n]}
	    INDEX=$n
	fi
done

if [ $INDEX -ne $default ]; then
#switch to a kernel temporarily
#echo "savedefault --default=$INDEX --once" | grub --batch
sed -i "s/^\(default\s*=\s*\).*\$/\1$INDEX/" /boot/grub/grub.conf
echo "The highest kernel version detected"
fi

exit 0
