#!/bin/env bash
# Simple script for updateing
set +x
set -o pipefail
shopt -s nullglob

$ shopt -s extglob
# ?(list): Matches zero or one occurrence of the given patterns.
# *(list): Matches zero or more occurrences of the given patterns.
# +(list): Matches one or more occurrences of the given patterns.
# !(list): Matches anything except one of the given patterns.
# @(list): Matches one of the given patterns.

GIT_SRC=/src/git/
SVN_SRC=/var/www/html/projects/svn/

GIT_SRC_PATH=$HOME$GIT_SRC
SVN_SRC_PATH=$SVN_SRC

for gitFolder in `ls ${GIT_SRC_PATH}`
do
    printf "Updating from git : \e[1;34m${gitFolder}...: \033[0m"

    folder=${GIT_SRC_PATH}${gitFolder}"/"
    cd ${folder}
    out=`git pull`


    if [[ $out = *up-to-date* ]];
    then
        printf "\e[1;31m[up-to-date]\033[0m\n"
    else
        printf ${out}"\n"
    fi
done

for svnFolder in `ls ${SVN_SRC_PATH}`
do

    #printf "Preparing to update from git : "
    printf "Updating from svn : \e[1;34m${svnFolder}...: \033[0m\n"
    folder=${SVN_SRC_PATH}${svnFolder}"/"
    cd ${folder}
    svn up
    cd ../
done