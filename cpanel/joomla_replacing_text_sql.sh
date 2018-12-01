#!/bin/sh

# Dmitry Troshenkov (troshenkov.d@gmail.com)
# Text replacing in DB SQL of Joomla of different versions

declare -a _dbprefix=(`cat $(find /home -maxdepth 3  -name "configuration.php") | grep '$dbprefix' | tr -d \'\'\; | awk '{ print $4 }'`)
declare -a _user=(`cat $(find /home -maxdepth 3  -name "configuration.php") | grep '$user' | tr -d \'\'\; | awk '{ print $4 }'`)
declare -a _db=(`cat $(find /home -maxdepth 3  -name "configuration.php") | grep '$db' | grep -v '$dbtype' | grep -v '$dbprefix' | tr -d \'\'\; | awk '{ print $4 }'`)
declare -a _password=(`cat $(find /home -maxdepth 3  -name "configuration.php") | grep '$password' | tr -d \'\'\; | awk '{ print $4 }'`)

ToSmth=artmebius.com

for ((n=0; n < ${#_dbprefix[*]}; n++)) ; do

 for Smth in 'artmebius.ru' 'artmebius.su' 'артмёбиус.рф' 'xn--80acvotjdl7j.xn--p1ai' 'артмебиус.рф' 'xn--80aclnrxldn.xn--p1ai' ; do
        #echo  PREFIX: ${_dbprefix[$n]} USER: ${_user[$n]} DATEBASE: ${_db[$n]} PASS: ${_password[$n]} ;
        mysql -u${_user[$n]} -p${_password[$n]} ${_db[$n]} <<-EOF
        UPDATE ${_dbprefix[$n]}modules SET content = replace(content, "$Smth", "$ToSmth");
        UPDATE ${_dbprefix[$n]}content SET introtext = replace(introtext, "$Smth", "$ToSmth"), \`fulltext\` = replace(\`fulltext\`, "$Smth", "$ToSmth");
        UPDATE ${_dbprefix[$n]}menu SET title = replace(title, "$Smth", "$ToSmth"), \`link\` = replace(\`link\`, "$Smth", "$ToSmth");
        EOF
  done

done

exit 0

