#!/bin/sh

#
# Dmitry Troshenkov (troshenkov.d@gmail.com)
# Manually deployment with Git to the WHM/cPanel account/username
#

ACC=Cpanel_Account_Name
GITS_REPOS=/home/git/repositories
WORK_DIR=/home/${ACC}/public_html

#test -d ${WORK_DIR} || mkdir -p ${WORK_DIR}

if [ ! -d ${GITS_REPOS} ]; then echo Directory ${GITS_REPOS} does not exists; exit 0; fi
if [ ! -d ${WORK_DIR} ]; then echo Directory ${WORK_DIR} does not exists; exit 0; fi

git --work-tree=${WORK_DIR} --git-dir=${GITS_REPOS}/${ACC}.git checkout -f

#find ${WORK_DIR} -type d -exec chmod 755 {} \;
#find ${WORK_DIR} -type f -exec chmod 644 {} \;

chown -R ${ACC}.${ACC} ${WORK_DIR}/.[*\^.]*

echo Done

exit 0


