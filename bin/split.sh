#!/usr/bin/env bash

set -e
set -x

CURRENT_BRANCH="0.x"
REPOS="Contracts Foundation Options Pagination Support Theme"

CWD=$(pwd)

function remote()
{
    git remote add $1 $2 || true
}

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
#  git checkout -b $CURRENT_BRANCH
  git checkout -b $RANDOM_BRANCH
  remote $lowercaseApp git@github.com:larawelp/$lowercaseApp.git
  git filter-repo --subdirectory-filter=$app --force
  git push  $lowercaseApp $CURRENT_BRANCH --force

#  git checkout -b $RANDOM_BRANCH
#  git filter-repo --subdirectory-filter=$app --force
#  git push  $lowercaseApp $RANDOM_BRANCH:$CURRENT_BRANCH --force
#  git checkout $CURRENT_BRANCH
}

# allow overwriting REPOS from command line
if [ -n "$1" ]; then
  REPOS=$1
fi



#git pull origin $CURRENT_BRANCH

for app in $REPOS; do
  lowercaseApp=$(echo "$app" | tr '[:upper:]' '[:lower:]')
  echo "Releasing $app git@github.com:larawelp/$lowercaseApp.git"
  echo "Splitting $app"
  split $app $lowercaseApp
done

#remote contracts git@github.com:larawelp/contracts.git
#remote framework git@github.com:larawelp/framework.git
#remote options git@github.com:larawelp/options.git
#remote pagination git@github.com:larawelp/pagination.git
#remote support git@github.com:larawelp/support.git
#remote theme git@github.com:larawelp/theme.git
#
#split 'contracts' contracts
#split 'framework' framework
#split 'options' options
#split 'pagination' pagination
#split 'support' support
#split 'theme' theme
