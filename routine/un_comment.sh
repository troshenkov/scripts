#!/bin/sh
target_file=''
start_commented_area=''
end_commented_area=''

start_line=$(cat -n ${target_file} | egrep '${start_commented_area}' | awk '{print $1}' | head -1);
end_line=$(cat -n ${target_file} | egrep '${end_commented_area}' | awk 'END{print $1}');

if [${start_line} && ${end_line} ]; then
#comment
#sed -i "${start_line},${end_line}s/^/#/" ${target_file}
#uncomment
#sed -i "${start_line},${end_line}s/^#//" ${target_file}
fi

#start_num_line=0
#end_num_line=0

##comment
#sed -i "${start_num_line},${end_num_line}s/^/#/" ${target_file}
##uncomment
#sed -i "${start_num_line},${end_num_line}s/^#//" ${target_file}
