#!/bin/bash
###############################################################################
# Script Name - compare.sh
description() {
    echo "                                                              "
    echo "This script reads host names from the LSF farms and           "
    echo "from the OPT license files and compares them.                 "
    echo "The script also checks the entries in the OPT files.          "
    echo "                                                              "
}
# Synopsis
usage() {
    echo "Usage: $0 [OPTION]                                            "
    echo "          -a, --all      Check and clean                      "
    echo "          -k, --check    Check                                "
    echo "          -c, --clean    Clean                                "
    echo "          -s, --status   Status                               "
    echo "          -h, --help     Display this help and exit           "
    echo "          -v, --version  Output version information and exit  "
    echo "          -d, --debug    Debug                                "
    echo "          or      export COMPARE_DEBUG=[Yes/No]               "
    exit 0
}
# Options
    export PATH=$PATH:/auto/edatools/bin/
    CFG='/auto/edatools/cae/scripts/crontab/eda-sjc-01/COMPARE_CFG'
    LOG='/auto/eda_depot/cae_log/chk_lsf_host/chk_host_out'
#   export COMPARE_DEBUG=[Yes/No]
implementation () {
    echo "                                                                "
    echo "compare.sh v1.04  7/18/2019                                     "
    echo "EDA Tools - Dmitry Troshenkov (dtroshen@cisco.com)              "
    echo "<https://gitlab-sjc.cisco.com/dtroshen/eda-tools/>              "
    echo "                                                                "
    exit 0
}
###############################################################################

FILE_1="$LOG"-$(head -1 /dev/urandom | od -N 2 | awk '{ print $2 }')
FILE_2="$LOG"-$(head -1 /dev/urandom | od -N 2 | awk '{ print $2 }')
WORK_DIR=$(dirname "$LOG")
CONF_DIR=$(dirname "$CFG")
_NAME_="$CONF_DIR"/$(basename "$0")

if [ $# != 0 ]; then
    while true; do
        case "$1" in
            -a|--all)
                CHECK_MODE=1
                CLEAN_MODE=1
                _RUN="Checking and Cleaning..."
                break
                ;;
            -k|--check)
                CHECK_MODE=1
                CLEAN_MODE=0
                _RUN="Checking..."
                break
                ;;
            -c|--clean)
                CHECK_MODE=0
                CLEAN_MODE=1
                _RUN="Cleaning..."
                break
                ;;
            -s|--status)
                STATUS_MODE=1
                _RUN="Status..."
                break
                ;;
            -d|--debug)
                DEBUG_MODE=1
                CHECK_MODE=1
                CLEAN_MODE=1
                _RUN="Debug..."
                break
                ;;
            -h|--help)
                description
                usage
                ;;
            -v|--version)
                implementation
                ;;
            *)
                usage
                ;;
        esac
    done
else
    usage
fi

# Delimiter
delim () { for i in $(seq 1 80); do echo -n =; done; echo; }

logger () {
    _DATA=$(date +%D-%T)
    if [ "$DEBUG" ]; then
        echo "$_DATA - $_RUN $_RESAULT $_WARNING - OPT:$FILE_1 LSF:$FILE_2" >> "$LOG"
    else
        echo "$_DATA - $_RUN $_RESAULT $_WARNING" >> "$LOG"
        rm -rf "$FILE_1" "$FILE_2"
    fi
    # Clean a log file and keep last 30 lines
    n=$(( $(wc -l < "$LOG") - 16 ))
    [[ $n -gt 0 ]] && sed -i 1,${n}d "$LOG"
    # Delete the diff files which older 30 days
    find "$LOG"-* -type f -mtime +30 &>/dev/null  -exec rm {} \;
}

if [[ "$DEBUG_MODE" -eq 1 ]] || [[ $COMPARE_DEBUG =~ ^([yY][eE][sS]|[yY])$ ]]; then
    DEBUG="True"
else
    DEBUG=""
fi

# Check a config file
if [ "$DEBUG" ]; then
    delim
    echo Debug mode: "$_NAME_"
    echo $(basename "$0") " - Perm: " $(stat -c "%a" "$_NAME_") ", Owner: " \
         $(stat -c "%U" "$_NAME_") ", Group: " $(stat -c "%G" "$_NAME_")
    delim
fi

if [ ! -d "$CONF_DIR" ]; then
    _RESAULT="$CONF_DIR does not exist. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [ ! -f "$CFG" ]; then
    _RESAULT="$CFG does not exist. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [ ! -r "$CFG" ]; then
    _RESAULT="$CFG has not read permission. Exit..."
    logger
    exit 1
fi

if [ "$DEBUG" ]; then
    echo "Config file - " $(echo "$CFG"|awk -F'/' '{print $NF }')
    echo "Perm: " $(stat -c "%a" "$CFG") ", Owner: " $(stat -c "%U" "$CFG") \
        ", Group: " $(stat -c "%G" "$CFG")
    echo "$CFG" - Ok
    delim
fi

# Get data from config file
_FARM=$(sed -e '/\[LSF_FARMS\]/d'   -e '/\[/,$d' "$CFG" | grep -v '^#' | sort -u | sed '/^$/d')
_OPTS=$(sed -e '1,/\[OPT_FILES\]/d' -e '/\[/,$d' "$CFG" | grep -v '^#' | sort -u | sed '/^$/d')
_INCL=$(sed -e '1,/\[INCLUDE\]/d'   -e '/\[/,$d' "$CFG" | grep -v '^#' | sort -u | sed '/^$/d')
_XCLD=$(sed -e '1,/\[EXCLUDE\]/d'                "$CFG" | grep -v '^#' | sort -u | sed '/^$/d')

# Check entries in the config file
if [ ! "$_FARM" ]; then
    _RESAULT="No Farms entries in the config file. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [ ! "$_OPTS" ]; then
    _RESAULT="No OPTs entries in the config file. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [[ "$STATUS_MODE" -eq 1  ]] || [[ "$DEBUG_MODE" -eq 1 ]]; then
    #echo -e "LSF FARMS:\n$_FARM"
    echo -e "\nOPT Files:\n$_OPTS"
    echo -e "\nHost Groups:\n$_INCL"
    echo -e "\nExclude Hosts:\n$_XCLD"
    delim
    if [ ! "$DEBUG_MODE" ]; then
        echo "Log File:"
        cat "$LOG"
        logger
        exit 0
    fi
fi

# Check OPT file exists and not empty. And loading hosts
for i in $_OPTS; do
    if [ ! -f "$i" ]; then
        _WARNING="Warning: $i - File does not exist."
        echo "$_WARNING"
    elif [ ! -s "$i" ]; then
        _WARNING="Warning: $i - File is empty."
        echo "$_WARNING"
    elif [ ! -r "$i" ]; then
        _WARNING="Warning: $i - File has not read permission."
        echo "$_WARNING"
    elif  [[ $(grep "$_INCL" "$i" | sed -e 's/[A-Z_]//g' | tr -d '\n\r' ) ]]; then
        _HOSTS_OPTS+=($(grep "$_INCL" "$i" | sed -e 's/[A-Z_]//g' | tr -d '\n\r' ))
        if [ "$DEBUG" ]; then
            echo "$i - Hosts: $(grep "$_INCL" "$i" | sed -e 's/[A-Z_]//g' \
                                            | tr -d '\n\r' | uniq | wc -w )"
        fi
    else
        if [ "$DEBUG" ]; then
            echo "$i - Hosts: 0"
        fi
    fi
done

# Check LSF Farms
for i in $_FARM; do
    lsid --farm "$i" >/dev/null
    if [ $? -eq 0 ]; then
        _HOSTS_FARMS+=($(lshosts --farm "$i" -w | grep -v 'HOST_NAME' | awk '{ print $1 }'))
        if [ "$DEBUG" ]; then
            echo "Connection to $i - Hosts: $(lshosts --farm "$i" -w | grep -v 'HOST_NAME' \
                | awk '{ print $1 }' | wc -w )"
        fi
    else
        _WARNING="Warning: Connection to $i - False"
        echo "$_WARNING"
    fi
done

if [ "$DEBUG" -a -d "$WORK_DIR" -a -w "$WORK_DIR" ]; then
    delim
    echo "Log Dir: ""$WORK_DIR"
    echo -n "Perm: "$(stat -c "%a" "$WORK_DIR")", Owner: "
    echo $(stat -c "%U" "$WORK_DIR")", Group: "$(stat -c "%G" "$WORK_DIR")
fi

if [ ! -d "$WORK_DIR" ]; then
    _RESAULT="$WORK_DIR does not exist. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [ ! -w "$WORK_DIR" ]; then
    _RESAULT="$WORK_DIR has not write permission. Exit..."
    echo "$_RESAULT"
    logger
    exit 1
fi

if [[ "${_HOSTS_OPTS[@]}" ]] && [[ "${_HOSTS_FARMS[@]}" ]]; then
    printf "%s\n" "${_HOSTS_OPTS[@]}"  | grep -Ev "${_XCLD:-"#"}" | sort -u > "$FILE_1"
    printf "%s\n" "${_HOSTS_FARMS[@]}" | grep -Ev "${_XCLD:-"#"}" | sort -u > "$FILE_2"
    if [[ "$CHECK_MODE" -eq 1 ]]; then
        DIFF_B=$(diff -yd  --suppress-common-lines "$FILE_1" "$FILE_2" \
            | awk '{ print $2 $3 }' | tr -d "\>\<\|" | sed '/^$/d')
    fi
    if [[ "$CLEAN_MODE" -eq 1 ]]; then
        DIFF_A=$(diff -yd  --suppress-common-lines "$FILE_1" "$FILE_2" \
            | awk '{ print $1 }' | tr -d "\>\<\|" | sed '/^$/d')
    fi
    if [ "$DEBUG"  ]; then
        delim
        echo "LSF side:" "$DIFF_B" | tr '\n' ' '
        echo -e "\n"
        echo "OPT side:" "$DIFF_A" | tr '\n' ' '
        echo -e "\n"
    fi
else
    _RESAULT="Epic Failure! \nNo data coming to compare!"
    echo "$_RESAULT"
    logger
    exit 1
fi

if [[ "$DIFF_A" ]] || [[ "$DIFF_B" ]]; then
    delim
    if [ "$DIFF_B" ]; then
        prev=""
        _TMP=""
        echo "The following hosts are in the farms, but not in the OPT files:"
        _RESAULT="$_RESAILT The hosts in the farms, but not in the OPT files found."
        for i in $DIFF_B; do
            _regex="${i%-*}"
            if [[ ! $(echo "$_OPTS" | xargs grep -n "${i}" | awk -F':' '{ print $1 }' | uniq) ]] \
                                                             && [[ ! "$prev" =~ "$_regex" ]]; then
                for y in $DIFF_B; do
                    if [[ "$y" =~ "$_regex" ]]; then
                        echo -n "$y "
                        prev="$y"
                    fi
                done

                files=$(echo "$_OPTS" | xargs grep -n "${i%-*}" | awk -F':' '{ print $1 }' | uniq)
                if [ "$files" ]; then
                    echo -e "\n\nThe files associated with ${i%-*} hosts:"
                    printf "%s \n" "$files"
                else
                    echo -e "\n\nNo files associated with ${i%-*} hosts."
                fi
            fi
            if [[ $(echo "$_OPTS" | xargs grep -n "${i}" | awk -F':' '{ print $1 }' | uniq) ]] \
                                                           && [[ ! "$prev" =~ "$_regex" ]]; then
                GROUP_NAME=$(echo "$_OPTS" | xargs grep -h "${i}" | awk '{ print $2 }' | uniq)
                echo -e "\nThis hosts here because the HOST_GROUP $GROUP_NAME is not mentioned in the config file"
                RESAULT="$_RESAULT The $GROUP_NAME is not mentioned in the config file found."
                for y in $DIFF_B; do
                    if [[ "$y" =~ "$_regex" ]]; then
                        echo -n "$y "
                        prev="$y"
                        _TMP+=$(echo "$_OPTS" | xargs grep -no "${y}" | awk -F':' '{ print $1 ":" $2 " " }')
                    fi
                done
                echo "$_TMP" | tr " " "\n" | sort -u
                echo
            fi
        done
        echo
        delim
    fi

    if [ "$DIFF_A" ]; then
        prev=""
        _TMP=""
        echo  "The following hosts are not in the farm, but in the OPT files:"
        _RESAULT="$_RESAULT The hosts with not in the farm, but in the OPT files found."
        for i in $DIFF_A; do
            _regex="${i%-*}"
            if [[ ! "$prev" =~ "$_regex" ]]; then
                echo
                for y in $DIFF_A; do
                    if [[ "$y" =~ "$_regex" ]]; then
                        echo -n "$y "
                        prev="$y"
                        _TMP+=$(echo "$_OPTS" | xargs grep -no "${y}" | awk -F':' '{ print $1 ":" $2 " " }')
                    fi
                done
                echo "$_TMP" | tr " " "\n" | sort -u
                _TMP=""
            fi
        done
    fi
else
    _RESAULT="$_RESAULT No difference found!"
    if [ "$DEBUG" ]; then
        delim
        echo "No difference found!"
    fi
fi

## checking the hosts into the opts files
if [[ -s "$FILE_2" ]] && [[ "$CLEAN_MODE" -eq 1 ]];  then
    prev=""
    _TMP=""
    LSF=""
    for i in $(cat "$FILE_2"); do
        _REGX+=( $(printf "%s " ${i%-*} ) )
    done
    for x in $(printf "%s\n" "${_REGX[@]}" | uniq); do
        for y in $(echo "$_OPTS" | xargs grep -n "$x" | awk -F':' '{ print $1 }' | sort -u); do
            for z in $(cat "$FILE_2"); do
                if [[ "$z" =~ "$x" ]] && [[ ! $(grep -o "$z" "$y") ]]; then
                    _TMP+=$(echo -n "$z ")
                fi
            done
            if [[ "$_TMP" ]]; then
                z=$(echo "$_TMP" | cut -f 1 -d " ")
                if [[ ! "$prev" ]] || [[ ! "$y" =~ "$prev" ]]; then
                    for i in $_FARM; do
                        lsid --farm "$i" >/dev/null
                        if [[ $? -eq 0 ]] && [[ $(lshosts --farm "$i" -w | grep -o "$z") ]]; then
                            LSF=$(echo ${i%-*} | tr a-z A-Z)
                        fi
                    done
                    echo -e "\nThe following hosts are in the ${LSF:-"[undetermined]"} Farm but not in the $y:"
                fi
                echo "$_TMP"
                _TMP=""
                LSF=""
                prev="$y"
            fi
        done
    done
    if [ "$prev" ]; then
        _RESAULT="$_RESAULT Some issue with the OPT files."
        echo
        delim
    fi
fi

if [ "$DEBUG" ]; then
    delim
    echo -e "OPT file: " "$FILE_1" "\nLSF file: " "$FILE_2" "\nLog file: " "$LOG"
    delim
fi

logger

exit 0
