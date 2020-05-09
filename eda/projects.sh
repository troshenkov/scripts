#!/bin/bash
# Script Name - projects.sh
description () {
    echo "                                                              "
    echo " The script prints the names of the projects that             "
    echo "do not have any use in the last 6 months.                     "
    echo "                                                              "
}

# Options
declare -a _FARMS=(sjc-hw csi-hw blr-hw imt nsb crdc)
_OS='CEL5_5|CEL6_6|RHEL|RHEL7'
_DAYS='180'
_CPUs=$(grep -c "processor" /proc/cpuinfo)

# Synopsis
usage () {
    echo "                                                              "
    echo "Usage: $0 [PARAM]                                             "
    echo "          -f, --farm ["${_FARMS[@]}"] or [all]                "
    echo "          -v, --version                                       "
    echo "          -h, --help                                          "
    echo "                                                              "
    exit 0
}

implementation () {
    echo "                                                              "
    echo "projects.sh v0.14 6/06/2019                                   "
    echo "EDA Tools - Dmitry Troshenkov (dtroshen@cisco.com)            "
    echo "<https://gitlab-sjc.cisco.com/dtroshen/eda-tools/>            "
    echo "                                                              "
    exit 0
}

if [ $# != 0 ]; then
    case "$1" in
        -f|--farm   )
            if [ "$2" ]; then
                for ((n=0; n < "${#_FARMS[*]}"; n++)); do
                    if [[ "${_FARMS["$n"]}" == "$2" ]]; then
                        _FARMS=("${_FARMS["$n"]}")
                    fi
                done
                if [[ "${#_FARMS[*]}" -ne 1 ]] && [[ "all" != "$2" ]]; then
                    usage
                fi
            else
                usage
            fi
            ;;
        -h|--help   )
            description
            usage
            ;;
        -v|--version)
            implementation
            ;;
        *           )
            usage
            ;;
    esac
else
    usage
fi

for ((n=0; n < ${#_FARMS[*]}; n++)) ; do
    FILE_1=/tmp/$USER-$(head -1 /dev/urandom | od -N 2 | awk '{ print $2 }')
    FILE_2=/tmp/$USER-$(head -1 /dev/urandom | od -N 2 | awk '{ print $2 }')
    LSF_LOG_DIR=/auto/edatools/platform/lsf/"${_FARMS["$n"]}"/work/"${_FARMS["$n"]}"/logdir/

    /auto/edatools/bin/lsid --farm "${_FARMS["$n"]}" >/dev/null

    if [ $? -eq 0 ]; then
    /auto/edatools/bin/bugroup --farm "${_FARMS["$n"]}" -w | awk '{ print $1 }' | grep -v 'GROUP_NAME' | sort -u > "$FILE_1"
    else
        echo ""${_FARMS["$n"]}": Fail connection to the farm."
    fi

    if [ ! -s "$FILE_1" ]; then
        echo ""${_FARMS["$n"]}": Empty data from the farm."
    fi

    if [ ! -d "$LSF_LOG_DIR" ]; then
         echo ""${_FARMS["$n"]}": Log directory (""$LSF_LOG_DIR"") is not found!"
    fi

    if [ -d "$LSF_LOG_DIR" ] && [ -s "$FILE_1" ]; then
        _LOGS=$(find "$LSF_LOG_DIR" -type f -name 'lsb.events*' -mtime -"$_DAYS" 2>/dev/null)
        echo "$_LOGS" | xargs -P "$_CPUs" grep -E "^\"JOB_NEW\"" | awk -F "$_OS" '{ print $NF }' | cut -d\" -f7 | sed '/^$/d' | sort -u > "$FILE_2"
    fi

    if [ ! -s "$FILE_2" ]; then
        echo ""${_FARMS["$n"]}": Empty data from the log files (""$LSF_LOG_DIR"")."
    fi

    if [ -s "$FILE_1" ] && [ -s "$FILE_2" ]; then
        DIFF=$(diff -yd  --suppress-common-lines "$FILE_1" "$FILE_2" | awk '{ print $1 }' | tr -d "\>\<\|" | sed '/^$/d')
        if [ "$DIFF" ]; then
            echo -e "\n"
            echo -e "The names of the projects that DO NOT have any use in the last $(($_DAYS/30)) months on the "${_FARMS["$n"]}" farm:\n"
            echo "$DIFF" | tr "\n" " "
            echo -e "\n"
        fi
    fi

    rm -rf "$FILE_1" "$FILE_2"

done #| pv-1.6.6 -t

exit 0
