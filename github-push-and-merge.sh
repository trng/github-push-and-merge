#!/bin/bash

symlinkdir="/usr/local/bin/"

# absolute path to this script
rl=`readlink -f $0`

# this script directory
rd=`dirname $rl`

if [ ! -f "$(realpath $0).conf" ]; then
  # No config file
  echo "" > $(realpath $0).conf
  echo -e "\n\n\n${YEL}FIRST RUN!!!${NC}\n"
  if [[ ! -h "${symlinkdir}/$(basename $0)" ]]; then
    printf "    ${CYA}Create symlink in ${symlinkdir}? (Y/N)${NC} "
    while read -N 1 -n 1 -s userchoice ; do
      if [[ 'YyNn' == *"$userchoice"* ]]; then
        [[ 'Yy' == *"$userchoice"* ]] && ln -s $(realpath $0) ${symlinkdir}/$(basename $0)
        break
      fi
    done
    echo -e "\n"
  fi
fi


# Token from github crypted by ccencrypt
tokenfile=${rd}/gh.secret.cpt

# Temporary branch name
tempbranchname=rptemp${RANDOM}

#ddd=` date +"%y%m%d%H%M%S"`

# escape ansi sequences for coloring
YEL='\033[1;33m' # Yellow
CYA='\033[1;36m' # Cyan
NC='\033[0m'     # No Color



for cmdneeded in ccdecrypt gh git ; do
  command -v ${cmdneeded} >/dev/null 2>&1 || { echo >&2 "${cmdneeded} not found.  Aborting..."; exit 1; }
done



gh auth status
if [ $? -ne 0 ]; then
  if [[ ! -f $tokenfile ]] ; then
    echo -e "GitHub token not found in file ${CYA}$tokenfile${NC}"
    exit
  fi
  echo "Opening a token file..."
  GH_TOKEN=`ccdecrypt -c ${tokenfile}`
  if [[ $? -ne 0 ]] ; then
    echo "GitHub token is not decrypted. Aborting..."
    exit 1
  fi
  echo $GH_TOKEN | gh auth login --with-token
  gh auth status
  echo -e "${YEL}\n\n\nGitHub authentication is not preserved between script runs."
  echo -e "If you need multiple pull requests/merges - login from bash with this command:\n"
  echo -e "${CYA}echo ${GH_TOKEN} | gh auth login --with-token ; history -d -1 ${NC}\n"
fi



#####################################################################################################################
#
# Check for mandatory git's settings before run git
#
#####################################################################################################################

user_email=`git config --global user.email`
if [ -z "${user_email}" ]; then
    echo -e "\n${YEL}user_email is empty but mandatory for github. Use follwing command for set user_email:${NC}"
    echo -e "\n     ${CYA}git config --global user.email \"username@mail.server\"  ${NC}\n"
    exit
fi

user_name=`git config --global user.name`
if [ -z "${user_name}" ]; then
    echo -e "\n${YEL}user.name${NC} is empty but mandatory for github. Use follwing command for set user_name:"
    echo -e "\n     ${CYA}git config --global user.name \"username\"  ${NC}\n"
    exit
fi

#####################################################################################################################
#####################################################################################################################



# git fetch
# git rev-list HEAD...origin/main --count
#if ! git diff --quiet remotes/origin/HEAD  ; then
#  echo -e "\n${CYA}There are newer files in the remote repo.\nPlease do a ${YEL}git pull${CYA} before commiting.${NC}\n"
#fi



#
# The check for remote changes and their potential conflicts with local changes.
# Remote changes without conflicts will just merged.
#
git pull
if [ $? -ne 0 ]; then
    echo -e "${MAG}Conflict with remote repo!!! Exiting...{NC}"
    exit
fi


# git switch -C ${tempbranchname} origin/main
git add -A
git diff --cached --exit-code > /dev/null
if [[ $? -eq 0 ]] ; then
  echo -e "\nNothing to commit. Exiting...\n"
  # git switch main
  # git branch --delete ${tempbranchname}
  exit 1
fi

git commit
git push

#gh pr create -f
#gh pr merge

