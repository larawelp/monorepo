#!/usr/bin/env bash

set -e
#set -x

CURRENT_BRANCH="0.x"
REPOS="Contracts Foundation Options Pagination Support Theme"

# if we have GITHUB_REF_NAME env variable, use that as the current branch
if [ -n "$GITHUB_REF_NAME" ]; then
#  CURRENT_BRANCH=$GITHUB_REF_NAME
  echo "GITHUB_REF_NAME: $GITHUB_REF_NAME"
fi

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

ENABLE_CHECK=0

if [ $ENABLE_CHECK == 1 ]; then
  # if we have GITHUB_REF_NAME env variable and GITHUB_EVENT_NAME is not "delete"
  if [ -n "$GITHUB_REF_NAME" ] && [ "$GITHUB_EVENT_NAME" != "delete" ]; then
    # loop through all the repos, check if any file in that folder has been changed, if not remove if from the list
    for app in $REPOS; do
      lowercaseApp=$(echo "$app" | tr '[:upper:]' '[:lower:]')
      echo "Checking if $app has changed"
      changes=$(git diff-tree --no-commit-id --name-only -r HEAD | grep $app | wc -l | xargs)
      if [ $changes == 0 ]; then
        echo "$app has not changed, removing from list"
        REPOS=$(echo "$REPOS" | sed "s/$app//g")
      fi
    done

    # if no repos have changed (trimmed list is empty), exit
    trimmedRepos=$(echo "$REPOS" | xargs)
    if [ -z "$trimmedRepos" ]; then
      echo "No repos have changed, exiting"
      exit 0
    fi
  fi
fi


function remote()
{
    git remote add $1 $2 || true
}

ABS_PATH_TO_THIS_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";

#python variable can be python3 or just python3, first check if python3 exists, if not, check if python exists
if command -v python3 &>/dev/null; then
    echo "python3 exists"
    python=python3
elif command -v python &>/dev/null; then
    echo "python exists"
    python=python
else
    echo "python does not exist"
    exit 1
fi

function split()
{
#  Logic for split:
# Checkout to a new random 16 character branch name
# Run git filter-repo --subdirectory-filter=$app --force
# Force Push the branch ref to remote called $lowercaseApp and branch name $CURRENT_BRANCH
# Checkout to $CURRENT_BRANCH again

  app=$1
  lowercaseApp=$2
#  RANDOM_BRANCH=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)
#  echo "Random branch name: $RANDOM_BRANCH"

  # if /tmp/split/$lowercaseApp does not exist, create it, if exists delete first
  if [ -d "/tmp/split/$lowercaseApp" ]; then
    rm -rf "/tmp/split/$lowercaseApp"
  fi
  mkdir -p "/tmp/split/$lowercaseApp"

  git clone "$CWD" "/tmp/split/$lowercaseApp"
  cd "/tmp/split/$lowercaseApp"

  git checkout -b $CURRENT_BRANCH || true
#  git checkout -b $RANDOM_BRANCH
  if [ -n "$GITHUB_REF_NAME" ]; then
    remote $lowercaseApp https://$DEPLOY_TOKEN_SPLIT@github.com/larawelp/$lowercaseApp.git
  else
    remote $lowercaseApp git@github.com:larawelp/$lowercaseApp.git
  fi



  pathToFilterRepoPythonScript=$ABS_PATH_TO_THIS_SCRIPT/git-filter-repo.py
  $python $pathToFilterRepoPythonScript --subdirectory-filter=$app --force

#  GIT_TRACE=1 GIT_TRANSFER_TRACE=1 GIT_CURL_VERBOSE=1 git \
#  -c "http.https://github.com/.extraheader=AUTHORIZATION: token $DEPLOY_TOKEN_SPLIT" \
#  push $lowercaseApp $CURRENT_BRANCH --force -vvv

  git push --tags --force --set-upstream $lowercaseApp $CURRENT_BRANCH
  # push all tags
#  echo "Pushing tags"
#  git push $lowercaseApp --tags --force

  #delete remote tags not existing locally
  echo "Deleting remote tags not existing locally"
  git ls-remote --tags $lowercaseApp | while read tag; do
    tag=$(echo $tag | awk '{print $2}' | sed 's/refs\/tags\///g')
    echo "Checking if tag $tag exists locally"
    if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
      echo "Tag $tag exists locally"
    else
      echo "Tag $tag does not exist locally, deleting from remote"
      git push --delete $lowercaseApp $tag
    fi
  done

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