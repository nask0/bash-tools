#!/bin/env bash
# Simple script for processing sql updates from database-changes.txt file.
set +x
set -o pipefail
shopt -s nullglob
FUNC_FILES=();
DUMP_FILES=();
CHANGES_FILE=database-changes.txt
dumpsImported=0;
funcsImported=0;

read -p "MySQL user : " sqlUser
read -s -p "MySQL password : " sqlPass
printf "\n"
read -p "MySQL Database : " sqlDb

for sqlFile in `grep -o '\<application\/resources\/sql\/.*sql\>' ${CHANGES_FILE}`; 
do 
    if `echo ${sqlFile} | grep "func" 1>/dev/null 2>&1`
    then
        FUNC_FILES=("${FUNC_FILES[@]}" ${sqlFile});
    else
        DUMP_FILES=("${DUMP_FILES[@]}" ${sqlFile});
    fi
done

printf "Processing ${#FUNC_FILES[@]} sql files with function declarations :\n" 
for funcFile in ${FUNC_FILES[@]};
do 
    mysql -u ${sqlUser} -p${sqlPass} ${sqlDb} < ${funcFile}
    if [ $? -gt 0 ];
    then
        printf "Importing ${funcFile}.....\e[1;31m[ERROR]\033[0m\n"
    else
        printf "Importing ${funcFile}.....\e[1;32m[OK]\033[0m\n"
        funcsImported=$[funcsImported + 1]; 
    fi
done

printf "\n\nProcessing ${#DUMP_FILES[@]} sql dump files :\n" 
for funcFile in ${DUMP_FILES[@]};
do 
    mysql -u ${sqlUser} -p${sqlPass} ${sqlDb} < ${funcFile}
    if [ $? -gt 0 ]; 
    then
        printf "Importing ${funcFile}.....\e[1;31m[ERROR]\033[0m\n"
    else 
        printf "Importing ${funcFile}.....\e[1;32m[OK]\033[0m\n"
        dumpsImported=$[funcsImported + 1]; 
    fi
done

printf "\n"
printf "Summary :\n\e[1;32m${funcsImported}\033[0m funcions imported of ${#FUNC_FILES[@]}\n\e[1;32m${dumpsImported}\033[0m dumps imported of ${#DUMP_FILES[@]}\ndone.\n"