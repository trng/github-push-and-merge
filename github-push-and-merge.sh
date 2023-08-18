#!/bin/bash
SCRIPT_VERSION="0.1.1"

# ANSI escape-sequences for coloring
CYA='\033[1;36m' # Cyan
MAG='\033[1;35m' # Magenta
YEL='\033[1;33m' # Yellow
NC='\033[0m'     # No Color

echo ""
printf "###################################################\n"
printf "#                                                 #\n"
printf "#  ${CYA}GitHub push and merge v.%-12s${NC}           #\n" ${SCRIPT_VERSION}
printf "#                                                 #\n"
printf "###################################################\n"
echo ""




# Folder for symlink
SYMLINK_DIR="/usr/local/bin/"


# Encrypted token option name (for .git/config file)
ENCRYPTED_TOKEN_OPTION_NAME="remote.origin.encryptedtoken"


#
# Prerequirements
#
for cmdneeded in openssl git ; do
  command -v ${cmdneeded} >/dev/null 2>&1 || { echo -e >&2 "${MAG}${cmdneeded}${NC} not found."; external_tool_missing="true"; }
done
[ -z ${external_tool_missing} ] || { echo -e "\nCannot continue without mandatory external tools. Exiting...\n" ; exit 1; }




################################################################################
#
#  Variables
#
################################################################################


# absolute path to this script
#RL=`readlink -f $0`
#FULL_PATH_WITHOUT_EXTENTION=${RL%.*}

# this script directory
#RD=`dirname $RL`

#REPO_NAME=$(basename ${RL})
#REPO_NAME=${REPO_NAME%.*}


# Temporary branch name
#tempbranchname=${REPO_NAME}${RANDOM}


################################################################################
################################################################################




#
# First run?
#
if [ ! -f "$(realpath $0).conf" ]; then
  # No config file
  echo "" > $(realpath $0).conf
  echo -e "\n\n\n${YEL}FIRST RUN!!!${NC}"
  echo "    Config file created"
  if [[ ! -h "${SYMLINK_DIR}/$(basename $0)" ]]; then
    printf "    ${CYA}Create symlink in ${SYMLINK_DIR}? (Y/N)${NC} "
    while read -N 1 -n 1 -s userchoice ; do
      if [[ 'YyNn' == *"$userchoice"* ]]; then
        if [[ 'Yy' == *"$userchoice"* ]] ; then
          ln -s $(realpath $0) ${SYMLINK_DIR}/$(basename $0)
          echo -e "\n    Symlink created in ${SYMLINK_DIR}\n\n\n"
        else
          echo -e "\n    Symlink not created\n\n\n"
        fi
        break
      fi
    done
    echo -e "\n"
  else
    echo -e "    Symlink exists in ${SYMLINK_DIR}\n\n\n"
  fi
fi


#
# Check is current folder "gitted" (.git subfolder exist?)
#
if [ ! -d "$(pwd)/.git" ]; then
  # No .git folder
  echo "No .git subfolder within the current dir. Exiting..."
  exit 1
fi


#
# Check for mandatory git parameters
#
for option_needed in remote.origin.url remote.origin.fetch branch.main.merge branch.main.remote ; do
  git config --get ${option_needed} > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "${MAG}No ${option_needed} in .git/config${NC}"
    badconfig="true"
  fi
done

for option_needed in user.email user.name ; do
  git config --global --get ${option_needed} > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "${MAG}No ${option_needed} in ~/.gitconfig.${NC} Use follwing command to define it:"
    echo -e "     ${CYA}git config --global ${option_needed} \"<value>\"${NC}\n"
    badconfig="true"
  fi
done

[ -z ${badconfig} ] || { echo "        Cannot continue without mandatory parameters. Exiting..." ; exit 1; }



#
# Check for GitHub's fine-grained personal access token
#
echo -e "${CYA}Get GitHub's fine-grained personal access token${NC}"
TOKEN_FROM_CONFIG_ENCRYPTED=`git config --get ${ENCRYPTED_TOKEN_OPTION_NAME}`
if [[ $? -ne 0 ]] ; then
    echo -e "GitHub's ${YEL}fine-grained personal access token${NC} is absent in .git/config"
    echo -e "Paste it here (or press Ctrl-C to stop script):"

    read token_pasted
    [ -z ${token_pasted} ] && { echo -e "Empty token. Exiting...\n"; exit 1; }

    echo -e "\nOk. Now it will be encrypted with AES-256 and stored in .git/config\n"

    # Encrypt and convert to base64 string (-A mean one line without linebreaks)
    TOKEN_PASTED_ENCRYPTED=$(echo "${token_pasted}" | openssl enc -e -aes-256-cbc -pbkdf2 -base64 -A)

    [[ $? -ne 0 ]] && { echo -e "${MAG}Something wrong with password entered (blank or do not match). Exiting...${NC}" ; exit 1; }

    git config ${ENCRYPTED_TOKEN_OPTION_NAME} "${TOKEN_PASTED_ENCRYPTED}"
fi

TOKEN_DECRYPTED=$(echo "${TOKEN_FROM_CONFIG_ENCRYPTED}" | openssl base64 -d | openssl enc -d -aes-256-cbc -pbkdf2)
echo -e "${CYA}Ok${NC}"




#
# Get remote origin url and inject decrypted token to it
#
remote_origin_url=`git config --get remote.origin.url`
repo_url_for_git_push=${remote_origin_url/\:\/\//\:\/\/${TOKEN_DECRYPTED}\@}.git



#gh auth status
#if [ $? -ne 0 ]; then
#  if [[ ! -f $tokenfile ]] ; then
#    echo -e "GitHub token not found in file ${CYA}$tokenfile${NC}"
#    exit
#  fi
#  echo "Opening a token file..."
#  GH_TOKEN=`ccdecrypt -c ${tokenfile}`
#  if [[ $? -ne 0 ]] ; then
#    echo "GitHub token is not decrypted. Aborting..."
#    exit 1
#  fi
#  echo $GH_TOKEN | gh auth login --with-token
#  gh auth status
#  echo -e "${YEL}\n\n\nGitHub authentication is not preserved between script runs."
#  echo -e "If you need multiple pull requests/merges - login from bash with this command:\n"
#  echo -e "${CYA}echo ${GH_TOKEN} | gh auth login --with-token ; history -d -1 ${NC}\n"
#fi



# git fetch
# git rev-list HEAD...origin/main --count
#if ! git diff --quiet remotes/origin/HEAD  ; then
#  echo -e "\n${CYA}There are newer files in the remote repo.\nPlease do a ${YEL}git pull${CYA} before commiting.${NC}\n"
#fi



#
# The check for remote changes and their potential conflicts with local changes.
# Remote changes without conflicts will just merged.
#
echo -e "\n${CYA}Check for remote changes...${NC}"
git pull
if [ $? -ne 0 ]; then
    echo -e "${MAG}Conflict with remote repo!!! Exiting...${NC}"
    exit
fi
echo -e "${CYA}Ok${NC}"

# git switch -C ${tempbranchname} origin/main
echo -e "\n${CYA}Adding all to new commit...${NC}"
git add -A
git diff --cached --exit-code > /dev/null
if [[ $? -eq 0 ]] ; then
  echo -e "\nNothing to commit. Exiting...\n"
  # git switch main
  # git branch --delete ${tempbranchname}
  exit 1
fi
echo -e "${CYA}Ok${NC}"

echo -e "\n${CYA}Commit...${NC}"
git commit
echo -e "${CYA}Ok${NC}"

echo -e "\n${CYA}Push directly to the master branch...${NC}"
git push ${repo_url_for_git_push}
echo -e "${CYA}Ok${NC}\n\n"
#gh pr create -f
#gh pr merge

