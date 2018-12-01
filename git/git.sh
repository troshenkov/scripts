#!/bin/sh

# Dmitry Troshenkov (troshenkov.d@gmail.com)
#
#  This special script for making the git for a web projects on the Cloudinux when used CageFS and WHM/cPanel as a web hosting platform.
#
################################
# sudo yum install git
#
# OR
#
# sudo yum groupinstall "Development Tools"
# sudo yum install zlib-devel perl-ExtUtils-MakeMaker asciidoc xmlto openssl-devel
#
# cd ~ && wget -O git.zip https://github.com/git/git/archive/master.zip
# unzip git.zip && cd git-master
#
# make configure
# ./configure --prefix=/usr/local/cpanel/3rdparty/ # ./configure --prefix=/usr/local
# make all doc
# sudo make install install-doc install-html
###################################
#
GIT_USER=git
GIT_SERVER=git.artmebius.com
GIT_IGNORE='.gitignore_global'

# Checking for the Git instalation
ck_git() { if hash git 2>/dev/null; then git --version; else echo 'The Git should be installed'; exit 0; fi }

# Checking for the GCC compiller instalation
ck_gcc() { if hash gcc 2>/dev/null; then echo gcc: $(gcc -dumpversion)'  '$(gcc -dumpmachine)
						else echo 'The gcc compiler should be installed' exit 0; fi }

# Checking for the Git user existing
if id -u ${GIT_USER} >/dev/null 2>&1 ; then
	echo The Git user ${GIT_USER} exists
  else
	echo The Git user ${GIT_USER} does not exist!
	exit 0
fi

# Checking for input argument as a cPanel account name
if [ $# -lt 1 ]; then echo Requires account name as an argument; exit 0; fi

ACC=$1

# Checking for running as root this script
if [ "$(id -u)" != "0" ]; then echo "This script must be run as root" 1>&2 ; exit 0 ; fi

# Checking for an account name existing
if [ ! -d /home/${ACC} ]; then echo Account ${ACC} not exists; exit 0; fi

# Checking for the git existing in the account http folder
if [ -d /home/${ACC}/public_html/.git ]; then echo The Git folder in the ${ACC} account already exists; exit 0; fi

# Checking for the GitoLite existing
if [ -d /home/${GIT_USER}/repositories/gitolite-admin.git/ ]; then 
	GIT_REPOS=/home/${GIT_USER}/repositories
	_GitoLite=1
	if [ ! -d ${GIT_REPOS}/${ACC}.git ]; then echo The bare Git for ${ACC} does not exists. Create it from Gitolite first; exit 0;
		else
# If bare Git for account exists, check for size and detecting an empty or not empty it
			if [ `du --max-depth=0 ${GIT_REPOS}/${ACC}.git | awk '{ print $1 }'` -ge 100 ] ; then
				echo Git Bare ${GIT_REPOS}/${ACC}.git is not empty
				exit 0
			  # else echo ${GIT_REPOS}/${ACC}.git ok!
			fi
	fi
	echo GitoLite detected.
	echo Directory for Git repositories ${GIT_REPOS}
 else
# If GitoLite is not exists
	GIT_REPOS=/home/${GIT_USER}
	_GitoLite=0
	if [ ! -d ${GIT_REPOS} ]; then echo ${GIT_REPOS} directory not exists; exit 0; fi
	if [ -d ${GIT_REPOS}/${ACC}.git ]; then echo The Git repository ${ACC}.git already exists; exit 0; fi
	echo Directory for Git repositories ${GIT_REPOS}
fi

# Checking for the CloudLinux
if [ -f /etc/cagefs/cagefs.mp ] ; then
echo -e '++++++++++++++++++++++
When using the Cloudinux and CageFS checkout this settings or run:
which git >> /etc/cagefs/cagefs.mp
cagefsctl --remount-all
cagefsctl --disable ${GIT_USER}
++++++++++++++++++++++'
fi

ck_git && ck_gcc

# Add Git ignore file to configuration
if [ -f /home/${GIT_USER}/${GIT_IGNORE} ] ; then 
		git config --global core.excludesfile /home/${GIT_USER}/${GIT_IGNORE};
		echo Using git ignore file /home/${GIT_USER}/${GIT_IGNORE}
	else
		echo The ${GIT_IGNORE} file no exist in the /home/${GIT_USER}
		exit 0
fi

# If you have a punycode domain name, you get readable name for project
_PING=$(echo ping -c 1 `ls -1 /home/${ACC}/access-logs/ | grep ^[^\.]` | grep PING | tr -d \(\) | awk '{ print $2 }')

# Git initialisation
cd /home/${ACC}/public_html
git init
git add .
git commit -m "Initial Commit" -q
#git status

# A project name put to description in the account
if [ $_PING ] ; then 
	echo ${_PING} > .git/description
	else echo Unknown > .git/description
fi

# Creating .htaccess file
echo -e "Order Deny,Allow\nDeny from all" > .git/.htaccess

# if GitoLite does not exist, do create bare
if [ ${_GitoLite} -eq 0 ] ; then
	mkdir -p ${GIT_REPOS}/${ACC}.git
	cd ${GIT_REPOS}/${ACC}.git
	git init --bare
 else
	cd ${GIT_REPOS}/${ACC}.git
fi

# A project name put to description in the bare
if [ $_PING ] ; then
	echo ${_PING} > description
 else
	echo Unknown > description
fi

chown -R ${GIT_USER}.${GIT_USER} ../${ACC}.git/.[*\^.]*

cd /home/${ACC}/public_html/
if [ ${_GitoLite} -eq 0 ] ; then
	git remote add hub ${GIT_REPOS}/${ACC}.git
 else
	git remote add hub ${GIT_USER}@${GIT_SERVER}:${ACC}
fi

git remote show hub
git push hub master

chown -R ${ACC}.${ACC} .git/.[*\^.]*

PC=post-commit
PU=post-update
PR=pre-receive


echo Creating post-update hook in the ${GIT_REPOS}/${ACC}.git/hooks
#
cd ${GIT_REPOS}/${ACC}.git/hooks
cat << EOF > ${PU}.sh
#!/bin/sh
echo "******************************"
echo "*** Deploying Website LIVE ***"
echo "******************************"
cd /home/$ACC/public_html || exit
unset GIT_DIR
git pull hub master
git submodule init
git submodule update
git update-server-info
git gc
chown -R ${ACC}.${ACC} .[*\^.]*
chown root.root .git/hooks/${PC}
chmod 4777 .git/hooks/${PC}
EOF

cat << EOF >  $PU.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
int main(){ setuid(0); system("sh hooks/${PU}.sh"); return 0; }
EOF

gcc ${PU}.c -o ${PU} && chown root.root ${PU} && chmod 4777 ${PU}
chown ${GIT_USER}.${GIT_USER} ${PU}.sh
rm ${PU}.c


echo Creating post-commit hook in the /home/${ACC}/public_html/.git/hooks/
#
cd /home/${ACC}/public_html/.git/hooks/ || exit
cat << EOF > ${PC}.sh
#!/bin/sh
echo "******************************"
echo "*** Pushing changes to Hub ***"
echo "***   [Lives ${PC} hook]   ***"
echo "******************************"
git push --set-upstream hub master
git push hub
git gc
chown -R git.git ${GIT_REPOS}/${ACC}.git/.[*\^.]*
chown root.root ${GIT_REPOS}/${ACC}.git/hooks/${PU}
chown root.root ${GIT_REPOS}/${ACC}.git/hooks/${PP}
chown root.root ${GIT_REPOS}/${ACC}.git/hooks/${PR}
chmod 4777  ${GIT_REPOS}/${ACC}.git/hooks/${PU}
chmod 4777  ${GIT_REPOS}/${ACC}.git/hooks/${PP}
chmod 4777  ${GIT_REPOS}/${ACC}.git/hooks/${PR}
EOF

cat << EOF > ${PC}.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
int main(){ setuid(0); system("sh .git/hooks/${PC}.sh"); return 0; }
EOF

gcc ${PC}.c -o ${PC} && chown root.root ${PC} && chmod 4777 ${PC}
chown ${ACC}.${ACC} ${PC}.sh
rm ${PC}.c


echo Creating pre-push hook in the ${GIT_REPOS}/$ACC.git/hooks
#
cd ${GIT_REPOS}/$ACC.git/hooks

cat << EOF > ${PR}.sh
#!/bin/sh
echo "********************************************"
echo "*** Pre-recive before pushing to the Hub ***"
echo "********************************************"

cd /home/$ACC/public_html/ || exit
unset GIT_DIR
#git push -u hub master
#git pull --set-upstream hub master
#git pull hub master
#git submodule init
#git submodule update
#git update-server-info
git add .
git commit -m "Commiting a Live changes before push to the Hub" -q
git gc

LOCAL=\$(git rev-parse @)
REMOTE=\$(git rev-parse @{u})
BASE=\$(git merge-base @ @{u})

echo L - \$LOCAL
echo R - \$REMOTE
echo B - \$BASE

if [[ \$LOCAL = \$REMOTE ]]; then
		echo "Up-to-date"
	elif [[ \$LOCAL = \$BASE ]]; then
		echo "Need to pull"
	elif [[ \$REMOTE = \$BASE ]]; then
		echo "Need to push"
	else
		echo "Diverged"
fi
EOF

cat << EOF >  $PR.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
int main(){ setuid(0); system("sh hooks/${PR}.sh"); return 0; }
EOF

gcc ${PR}.c -o ${PR} && chown root.root ${PR} && chmod 4777 ${PR}
chown ${GIT_USER}.${GIT_USER} ${PR}.sh
rm ${PR}.c

echo Done

exit 0

