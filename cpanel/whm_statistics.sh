#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)
#

if [[ ! -s /etc/userdatadomains || ! -s /etc/userdatadomains || ! -s /etc/userdatadomains || ! -d /var/cpanel/suspended ]]; then
        echo 'Condition not met, maybe WHM/cPanel was not installed. Program will now close!'
        exit 0
fi

EMAIL=host@yourdomain.tld
_F='F.csv'
:> $_F
_IDENT=0
:> MESSAGE

declare -a EXCLUDE=('corp' 'somename')

declare -a _dname=(`cat /etc/userdatadomains | awk -F: '{ print $1 }'`)
declare -a _duser=(`cat /etc/userdatadomains | awk -F= '{ print $1 } ' | awk ' { print $2} '`)
declare -a _user_data=(`cat /etc/userdatadomains | awk -F== '{ print $3 ";" $4 ";" $5 ";" $6 } '`)
declare -a _susd=(`ls /var/cpanel/suspended/`)

_Bitrix_ID='bitrix/php_interface/dbconn.php'
_Joomla_ID='configuration.php'
_Drupal_ID='sites/default/settings.php'
_GetSimple_ID='gsconfig.php'

# The legend of data                                                                                                                                                            
echo -e "DomainName;PunyCode;ResponseIP;AccountName;TypeDomain;OwnerDomain;DocumentRoot;HostIP;Registrar;PaidTill;Nameserver1;Nameserver2;PHP_Ver;CMS;ReleaseVER;MaintenanceVER; \                                                                                                                                                                              
License_Key;URL_Admin;AdminUser;Password;UserDB;NameDB;PassDB;rsFirewallStatus;rs_Password;URL_Cpanel;PASSWORD;HostFTP;FTP_USER;URL_FTP;Plan;MX;EXCLUDED;Status" >> $_F         
                                                                                                                                                                                
# Enumerate all the domains in the main loop                                                                                                                                    
for ((n=0; n < ${#_dname[*]}; n++)) ; do                                                                                                                                        
                                                                                                                                                                                
_EXCLUDED=0                                                                                                                                                                     
                                                                                                                                                                                
# Get the DomainName                                                                                                                                                            
        echo -n ${_dname[$n]} >> $_F                                                                                                                                            
        echo -n ';' >> $_F                                                                                                                                                      
                                                                                                                                                                                
                # If domain is not pingable add it to the log file and make domain status offline.                                                                              
                # Else make good domain name which punycode correctly returned IDN. Return domain IP from ping and make status online.                                          
                if [[ -z `ping -c 1 ${_dname[$n]} | grep PING` ]]; then                                                                                                         
                        echo No ping to ${_dname[$n]} >> MESSAGE
                        echo -n ';' >> $_F
                        # Set a domain status - Offline
                        _STATUS=0

                        else
                                # Get a PunyCode
                                echo -n `idn --quiet -u ${_dname[$n]}` >> $_F
                                echo -n ';' >> $_F
                                # Get a ResponseIP
                                echo -n `ping -c 1 ${_dname[$n]} | grep PING | tr -d \(\) | awk '{ print $3 }'` >> $_F
                                # Set a domain status - Online
                                _STATUS=1
                fi

        echo -n ';' >> $_F

        # Get an AccountName
        echo -n ${_duser[$n]} >> $_F
        echo -n ';' >> $_F

        # Get a TypeDomain, OwnerDomain, DocumentRoot and HostIP
        echo -n ${_user_data[$n]} >> $_F
        echo -n ';' >> $_F

        # Set the domain document root
        _DocumentRoot=`echo ${_user_data[$n]} | awk -F ";" '{ print $3 }'`

        # Set the domain type (sub, addon, main)
        _TypeDomain=`echo ${_user_data[$n]} | awk -F ";" '{ print $1 }'`

        # Get from whois a registrar and paid-till data for the domain
        _WHOIS=`echo $(whois -h whois.tcinet.ru ${_dname[$n]} | grep 'registrar\|paid-till' | awk '{ print $2 }' | tr '\n' ';')`

                if [ $_WHOIS ] ; then
                                echo -n $_WHOIS >> $_F

                        else
                                echo -n ";;" >> $_F
                fi

                # If the domain type is main
                if [ $_TypeDomain == main ]; then

                        # Read the list of suspended domains. If the domain is suspended to change the status of domain as - Suspended
                        for ((i=0; i < ${#_susd[*]}; i++)) ; do
                                if [ ${_duser[$n]} == ${_susd[$i]} ] ; then
                                        # Suspended account
                                        _STATUS=2
                                fi
                        done


                        # Read an array of excluded accounts
                        for ((i=0; i < ${#EXCLUDE[*]}; i++)) ; do
                                if [ ${_duser[$n]} == ${EXCLUDE[$i]} ] ; then
                                        # Excluded
                                        _EXCLUDED=1
                                fi
                        done

                        # Get two nameservers for the domain
                        echo -n $(dig +short ${_dname[$n]} ns | sed -n 1p) >> $_F
                        echo -n ";" >> $_F
                        echo -n $(dig +short ${_dname[$n]} ns | sed -n 2p) >> $_F
                        echo -n ";" >> $_F

                        # If will detected CloudLinux, get php version from CageFS. Otherwise uses standart PHP out.
                        if [ -f /home/${_duser[$n]}/.cl.selector/defaults.cfg ] ; then
                                echo -n $(cat /home/${_duser[$n]}/.cl.selector/defaults.cfg | grep 'php=' | tr -d \php= ) >> $_F

                                else
                                        echo -n $(php -i | grep 'PHP Version' | uniq | awk '{ print $4 }') >> $_F
                        fi

                        echo -n ";" >> $_F

                        # PMA
                        # Adminer

# Site administrator
_ADMIN=''; _PASS='';
# MySQL database
_user=''; _db=''; _password='';
# RS Firewall for Joomla
_RS_STATUS=''; _RS_PASS='';

                                # Joomla CMS
                                #
                                if [ -s $_DocumentRoot/$_Joomla_ID ]; then
                                        _IDENT=1
                                        echo -n 'Joomla' >> $_F
                                        echo -n ';' >> $_F

                                        # Get Joomla version and release
                                        # 1.5.x 1.6.x
                                        F=$_DocumentRoot/libraries/joomla/version.php
                                        # 2.x.x 3.x.x1
                                        F2=$_DocumentRoot/libraries/cms/version/version.php
                                        # 1.0.x
                                        F3=$_DocumentRoot/includes/version.php

                                        if [[ -e "$F" || -e "$F2" || -e "$F3" ]] ; then
                                                        if [[ -e "$F" ]] ; then
                                                                echo -n $(cat $F | grep '$RELEASE' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                                echo -n ';' >> $_F
                                                                echo -n $(cat $F | grep '$DEV_LEVEL' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                        elif [[ -e "$F2" ]] ; then
                                                                echo -n $(cat $F2 | grep '$RELEASE' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                                echo -n ';' >> $_F
                                                                echo -n $(cat $F2 | grep '$DEV_LEVEL' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                        elif [[ -e "$F3" ]] ; then
                                                                echo -n $(cat $F3 | grep '$CMS_ver' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                                echo -n ';' >> $_F
                                                                echo -n $(cat $F3 | grep '$DEV_LEVEL' | tr -d \'\; | awk '{ print $4 }') >> $_F
                                                        fi

                                                else
                                                        echo -n 'N/A;N/A' >> $_F
                                        fi

                                        echo -n ';;' >> $_F
                                        echo -n 'http://'${_dname[$n]}'/administrator/' >> $_F


                                # If the domain status is not suspended or account is not from exclude list, then connect to database
                                if [[ ${_STATUS} -ne 2 ]] && [[ ${_EXCLUDED} -ne 1 ]] ; then

                                        _dbprefix=`echo $(cat $_DocumentRoot/$_Joomla_ID | grep '$dbprefix' | tr -d \'\; | awk '{ print $4 }')`
                                        _user=`echo $(cat $_DocumentRoot/$_Joomla_ID | grep '$user' | tr -d \'\; | awk '{ print $4 }')`
                                        _db=`echo $(cat $_DocumentRoot/$_Joomla_ID | grep '$db' | grep -v '$dbtype' | grep -v '$dbprefix' | tr -d \'\; | awk '{ print $4 }')`
                                        _password=`echo $(cat $_DocumentRoot/$_Joomla_ID | grep '$password' | tr -d \'\; | awk '{ print $4 }')`

                                        # Test connection to MySQL database
                                        RES_EXIST=$(mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                        SELECT count(*) FROM information_schema.TABLES WHERE ( TABLE_SCHEMA = '${_db}' ) AND ( TABLE_NAME = '${_dbprefix}users' );
                                        EOF
                                        )
                                                _RES_EXIST=$(echo cat $RES_EXIST | awk '{ print $3 }')

                                                # If had connection
                                                if [[ $_RES_EXIST == '1' ]] ; then

                                                        # Try to detect an admin user
                                                        _RES=$(mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                                        SELECT username FROM ${_dbprefix}users WHERE name = 'Super User' OR name = 'Administrator' OR name = 'Temporary Administrator'  'position_id' = "00000000" LIMIT 1 ;
                                                        EOF
                                                        )

                                                        #If an admin user is found
                                                        if [[ $_RES ]] ; then
                                                                _ADMIN=$(echo cat ${_RES} | awk '{ print $3 }')
                                                                _PASS=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c12; echo "")
                                                                        mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                                                        UPDATE ${_db}.${_dbprefix}users SET password = MD5('$_PASS') WHERE ${_dbprefix}users.username = '$_ADMIN' ;
                                                                        EOF

                                                                else
                                                                        _ADMIN=''
                                                                        _PASS=''
                                                                        echo 'The DB' ${_dname[$n]} 'does not have a Administrator entries in the' ${_dbprefix}users.username 'field' >> MESSAGE
                                                        fi

                                                                # Try to connect a rsFirewall table
                                                                RS_EXIST=$(mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                                                SELECT count(*) FROM information_schema.TABLES WHERE ( TABLE_SCHEMA = '${_db}' ) AND ( TABLE_NAME = '${_dbprefix}rsfirewall_configuration' );
                                                                EOF
                                                                )

                                                                _RS_EXIST=$(echo cat $RS_EXIST | awk '{ print $3 }')

                                                                # If rsFirewall exists
                                                                if [[ $_RS_EXIST == '1' ]] ; then
                                                                        _RS=$(mysql --user=${_user} --password=${_password} ${_db} -s <<-EOF
                                                                        SELECT * FROM ${_dbprefix}rsfirewall_configuration WHERE name = 'backend_password_enabled' ;
                                                                        EOF
                                                                        )

                                                                        # Check for rsFirewall Off = 0 / On = 1  / no install = 2
                                                                        _RS_STATUS=$(echo cat ${_RS} | awk '{ print $3}')

                                                                                if [[ $_RS_STATUS == '1' ]] ; then
                                                                                        _RS_PASS=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c12; echo "")
                                                                                        mysql --user=$_user --password=${_password} $_db <<-EOF
                                                                                        UPDATE ${_dbprefix}rsfirewall_configuration SET value = MD5('$_RS_PASS') WHERE  name = 'backend_password' LIMIT 1;
                                                                                        EOF
                                                                                fi

                                                                                if [[ $_RS_STATUS == '0' ]] ; then
                                                                                        _RS_PASS=''
                                                                                fi

                                                                        else
                                                                                _RS_STATUS=2
                                                                                _RS_PASS=''
                                                                fi

                                                        else
                                                                _ADMIN=''
                                                                _PASS=''
                                                                echo 'No connection to the database' ${_dname[$n]} 'which account' ${_duser[$n]} ${_user} ${_password} ${_db} >> MESSAGE
                                                fi

                                        echo -n ';'$_ADMIN';'$_PASS';'$_user';'$_db';'$_password';'$_RS_STATUS';'$_RS_PASS';' >> $_F

                                        else
                                                echo -n ';;;;;;;;' >> $_F
                                fi
                                fi

                                # Bitrix CMS
                                #
                                if [ -s $_DocumentRoot/$_Bitrix_ID ]; then
                                        _IDENT=1
                                        echo -n 'Bitrix' >> $_F
                                        echo -n ';' >> $_F

                                        F=$_DocumentRoot/bitrix/modules/main/admin/update_system.php
                                        if [[ -e "$F" ]] ; then
                                                echo -n $(cat $F | grep UPDATE_SYSTEM_VERSION | grep -v '!define' | tr -d \'\"\)\; | awk '{ print $2 }') >> $_F
                                                echo -n ';' >> $_F

                                                else
                                                        echo -n 'N/A;N/A' >> $_F
                                        fi

                                        echo -n ';' >> $_F
                                        echo -n $( cat $_DocumentRoot/bitrix/license_key.php | sed -e 's|<?| |g' | awk '{ print $3 }' | tr -d \"\;\?\> ) >> $_F
                                        echo -n ';' >> $_F
                                        echo -n 'http://'${_dname[$n]}'/bitrix/admin/' >> $_F

                                # If the domain status is not suspended or account is not from exclude list, then connect to database
                                if [[ ${_STATUS} -ne 2 ]] && [[ ${_EXCLUDED} -ne 1 ]] ; then

                                        _user=`echo $(cat $_DocumentRoot/$_Bitrix_ID | grep '$DBLogin' | tr -d \"\; | awk '{ print $3 }')`
                                        _db=`echo $(cat $_DocumentRoot/$_Bitrix_ID | grep '$DBName' | tr -d \"\; | awk '{ print $3 }')`
                                        _password=`echo $(cat $_DocumentRoot/$_Bitrix_ID | grep '$DBPassword' | tr -d \"\; | awk '{ print $3 }')`

                                        RES_EXIST=$(mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                        SELECT count(*) FROM information_schema.TABLES WHERE ( TABLE_SCHEMA = '${_db}' ) AND ( TABLE_NAME = 'b_user' );
                                        EOF
                                        )

                                        _RES_EXIST=$(echo cat $RES_EXIST | awk '{ print $3 }')

                                                if [[ $_RES_EXIST == '1' ]] ; then

                                                        _RES=$(mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                                        SELECT LOGIN FROM b_user WHERE ID = "1" ;
                                                        EOF
                                                        )

                                                        _ADMIN=$(echo cat ${_RES} | awk '{ print $3 }')

                                                                if [[ $_ADMIN ]] ; then
                                                                        _PASS=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c12; echo "")

                                                                        mysql --user=${_user} --password=${_password} ${_db} <<-EOF
                                                                        UPDATE ${_db}.b_user SET PASSWORD = MD5('$_PASS') WHERE b_user.ID = 1 AND b_user.LOGIN = '$_ADMIN' ;
                                                                        EOF

                                                                        else
                                                                                echo ' Does not admin detected in the ' ${_db} >> MESSAGE
                                                                fi

                                                        else
                                                                #_ADMIN=''
                                                                #_PASS=''
                                                                echo 'No connection to the database' ${_dname[$n]} 'which account' ${_duser[$n]} >> MESSAGE
                                                fi

                                        echo -n ';'$_ADMIN';'$_PASS';'$_user';'$_db';'$_password';;;' >> $_F

                                        else
                                                echo -n ';;;;;;;;' >> $_F
                                fi
                                fi

                                # Drupal CMS
                                #
                                if [ -s $_DocumentRoot/$_Drupal_ID ]; then
                                        _IDENT=1
                                        echo -n 'Drupal' >> $_F
                                        echo -n ';' >> $_F

                                        F=$_DocumentRoot/CHANGELOG.txt
                                        if [[ -e "$F" ]] ; then
                                                echo -n $(cat $F | grep Drupal | head -1 | tr -d \, | awk '{ print $2 }') >> $_F
                                                echo -n ';' >> $_F

                                                else
                                                        echo -n 'N/A;N/A' >> $_F
                                        fi

                                        echo -n ';;' >> $_F
                                        echo -n 'http://'${_dname[$n]}'/user/' >> $_F
                                        echo -n ';;;' >> $_F
                                        echo -n `cat $_DocumentRoot/$_Drupal_ID | grep -v '*' | grep "$db_url = 'mysql://" | tr -d \'\; | sed -e 's|/| |g' | sed -e 's|@localhost| |g'| sed -e 's|:| |g' | awk '{ print $4 }'` >> $_F
                                        echo -n ';' >> $_F
                                        echo -n `cat $_DocumentRoot/$_Drupal_ID | grep -v '*' | grep "$db_url = 'mysql://" | tr -d \'\; | sed -e 's|/| |g' | sed -e 's|@localhost| |g'| sed -e 's|:| |g' | awk '{ print $6 }'` >> $_F
                                        echo -n ';' >> $_F
                                        echo -n `cat $_DocumentRoot/$_Drupal_ID | grep -v '*' | grep "$db_url = 'mysql://" | tr -d \'\; | sed -e 's|/| |g' | sed -e 's|@localhost| |g'| sed -e 's|:| |g' | awk '{ print $5 }'` >> $_F
                                        echo -n ';;;' >> $_F
                                fi

                                # GetSimple CMS
                                #
                                if [ -s $_DocumentRoot/$_GetSimple_ID ]; then
                                        _IDENT=1
                                        echo -n 'GetSimple' >> $_F
                                        echo -n ';' >> $_F

                                        F=$_DocumentRoot/admin/inc/configuration.php
                                        if [[ -e "$F" ]] ; then
                                                echo -n $(cat $_F | grep '$site_version_no' | head -1 | tr -d \'\; | awk '{ print $3 }') >> $_F
                                                echo -n ';' >> $_F

                                                else
                                                        echo -n 'N/A;N/A' >> $_F
                                        fi
                                        echo -n ';;;;;;;;;;' >> $_F
                                fi

                                # WordPress

                                # If no CMS detected
                                #
                                if [[ $_IDENT -eq 0 ]]; then
                                        echo -n 'Unknown;;;;;;;;;;;;' >> $_F

                                        else
                                                _IDENT=0
                                fi

                        # Get cPanel url for domain
                        echo -n 'https://'${_dname[$n]}':2083/' >> $_F
                        echo -n ';' >> $_F

                        # If the domain status is not suspended, change account password
                        if [[ ${_STATUS} -ne 2 ]] && [[ ${_EXCLUDED} -ne 1 ]] ; then

                                # Generated a password
                                _PASS=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c12; echo "")

                                # Change cPanel password for account
                                export ALLOW_PASSWORD_CHANGE=1
                                /usr/local/cpanel/scripts/realchpass ${_duser[$n]} $_PASS >/dev/null  2>&1
                                /usr/local/cpanel/scripts/ftpupdate >/dev/null  2>&1

                                # cPanel account password
                                echo -n $_PASS >> $_F

                        echo -n ';' >> $_F

                        # Ftp url
                        echo -n 'ftp://'${_dname[$n]} >> $_F
                        echo -n ';' >> $_F
                        # Ftp user
                        echo -n ${_duser[$n]} >> $_F
                        echo -n ';' >> $_F
                        # Full string for the ftp access to the domain
                        echo -n 'ftp://'${_duser[$n]}':'$_PASS'@'${_dname[$n]} >> $_F
                        echo -n ';' >> $_F

                                else
                                        echo -n ';;;;' >> $_F
                        fi

                        # Get a hosting plan for a user
                        echo -n `cat /etc/userplans | grep ${_duser[$n]}: | awk '{ print $2 }'` >> $_F
                        echo -n ';' >> $_F

                        # Get a MX for the domain
                        echo -n `dig +short ${_dname[$n]} mx | awk '{ print $2 }'` >> $_F
                        echo -n ';' >> $_F

                                # If domain type is not a main

                        else
                                echo -n ';;;;;;;;;;;;;;;;;;;;;;' >> $_F
                fi

                # Write excluded status to the file
                echo -n ${_EXCLUDED} >> $_F
                echo -n ';' >> $_F

        # Write a domain status
        case "$_STATUS" in
                "0")
                        echo -e 'Offline' >> $_F
                        ;;
                "1")
                        echo -e 'Online' >> $_F
                        ;;
                "2")
                        echo -e 'Suspended' >> $_F
                        ;;
                *)
                        echo -e 'Unknown' >> $_F
                        ;;
        esac

        # Remove MS-DOS end of string characters from the data file
        sed -i -e 's/\r//g' $_F

done

# Check entirely for the data file
_consist=$(echo $( awk -F\; '{print NF-1}' $_F | uniq -c | wc -l) )

# If a data file is well
if [[ $_consist == '1' ]]; then

        CORP_EXIST=$(mysql --host='corp.yourdomain.tld' --user='corpartm_db' --password='********' 'corpartm_db' <<-EOF
        SELECT count(*) FROM information_schema.TABLES WHERE ( TABLE_SCHEMA = 'corpartm_db' ) AND ( TABLE_NAME = 'data_store_items' ) ;
        EOF
        )

        _CORP_EXIST=$(echo cat $CORP_EXIST | awk '{ print $3 }')

                if [[ $_CORP_EXIST == '1' ]] ; then
         
                        TMP=`echo $(cat $_F | base64)`

                        # Get a server ip
                        SERVER_IP=$(ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

                                mysql --host='corp.yourdomain.tld' --user='corpartm_db' --password='********' 'corpartm_db' <<-EOF
                                        INSERT INTO corpartm_db.data_store_items ( ProviderId  ,Type  ,Active  ,Data ) VALUES ( '$SERVER_IP'  ,0   ,1  ,'$TMP' ) ;
                                EOF

                        else
                                echo "=======================================================================" >> MESSAGE
                                echo "Can't connect to corp.yourdomain.tld MySQL server or tabel corpartm_db.data_store_items not exist" >> MESSAGE
                fi

        else
                echo "=======================================================================" >> MESSAGE
                echo "a CSV file corrupted" >> MESSAGE
fi

# Sent log to the e-mail
if [ -s MESSAGE ]; then
        sed -i -e 's/\r//g' MESSAGE
        cat MESSAGE | mailx -s "The hostnames is not pingable - `hostname`" ${EMAIL}
fi

rm MESSAGE
#rm $_F

# For counting separators # awk -F\; '{print NF-1}' F.csv  | nl

exit 0


