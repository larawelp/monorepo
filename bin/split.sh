#!/usr/bin/env bash

set -e
#set -x

CURRENT_BRANCH="0.x"
REPOS="Contracts Foundation Options Pagination Support Theme"

ALSO_TAG=0

CWD=$(pwd)

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "h     Print this Help."
   echo "r     Repos to split."
   echo "t     Also tag the split repos."
   echo
}

while getopts ":h:r:t:" option; do
   case $option in
      h) # display Help
         Help
         exit 0;;
      r) # display Help
          REPOS=$OPTARG
          ;;
      t) # set ALSO_TAG
          ALSO_TAG=$OPTARG
          if [[ $ALSO_TAG != v*  ]]
          then
              ALSO_TAG="v$ALSO_TAG"
          fi
          ;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

function remote()
{
    git remote add $1 $2 || true
}

ABS_PATH_TO_THIS_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";

function split()
{
#  Logic for split:
# Checkout to a new random 16 character branch name
# Run git filter-repo --subdirectory-filter=$app --force
# Force Push the branch ref to remote called $lowercaseApp and branch name $CURRENT_BRANCH
# Checkout to $CURRENT_BRANCH again

  app=$1
  lowercaseApp=$2
  RANDOM_BRANCH=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)
  echo "Random branch name: $RANDOM_BRANCH"

  # if /tmp/split/$lowercaseApp does not exist, create it, if exists delete first
  if [ -d "/tmp/split/$lowercaseApp" ]; then
    rm -rf "/tmp/split/$lowercaseApp"
  fi
  mkdir -p "/tmp/split/$lowercaseApp"

  git clone "$CWD" "/tmp/split/$lowercaseApp"
  cd "/tmp/split/$lowercaseApp"
  git checkout -b $CURRENT_BRANCH || true
  git checkout -b $RANDOM_BRANCH
  remote $lowercaseApp git@github.com:larawelp/$lowercaseApp.git
  git filter-repo --subdirectory-filter=$app --force
  git push  $lowercaseApp $CURRENT_BRANCH --force

  # if $ALSO_TAG is not, tag the repo with $ALSO_TAG
    echo "ALSO TAG $ALSO_TAG"
  if [ $ALSO_TAG != 0 ]; then
    # get absolute path to this script's directory
#    git checkout -b $CURRENT_BRANCH
    echo "$ABS_PATH_TO_THIS_SCRIPT/release.sh -t $ALSO_TAG -r "/tmp/split/$lowercaseApp" -i"
    bash $ABS_PATH_TO_THIS_SCRIPT/release.sh -t $ALSO_TAG -r "/tmp/split/$lowercaseApp" -i
  fi

  return 0

#  git checkout -b $RANDOM_BRANCH
#  git filter-repo --subdirectory-filter=$app --force
#  git push  $lowercaseApp $RANDOM_BRANCH:$CURRENT_BRANCH --force
#  git checkout $CURRENT_BRANCH
}

echo "Releasing $REPOS"
if [ $ALSO_TAG != 0 ]; then
  echo "Also tagging with $ALSO_TAG"
fi


#git pull origin $CURRENT_BRANCH
echo "REPOS: $REPOS"
for app in $REPOS; do
  lowercaseApp=$(echo "$app" | tr '[:upper:]' '[:lower:]')
  echo "Releasing $app git@github.com:larawelp/$lowercaseApp.git"
  echo "Splitting $app"
  split $app $lowercaseApp || true
done