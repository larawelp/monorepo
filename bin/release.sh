#!/usr/bin/env bash

set -e

VERSION=0
REPO_PATH=0
IGNORE_DIRTY=0
IS_MINOR=0

while getopts ":r:t:i:m" option; do
   case $option in
      r) # set REPO_PATH
          REPO_PATH=$OPTARG
          ;;
      t) # set ALSO_TAG
          VERSION=$OPTARG
          ;;
      i) # set IGNORE_DIRTY
          IGNORE_DIRTY=1
          ;;
      m) # set IS_MINOR
          IS_MINOR=1
          ;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

# get absolute path to this script's directory
ABS_PATH_TO_THIS_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# if VERSION is 0, exit with error
if [ $VERSION == 0 ]; then
  echo "Error: No version specified"
  exit 1
fi

echo "Releasing a minor version ?: $IS_MINOR"

#echo $VERSION;
#echo $REPO_PATH;
#echo $IGNORE_DIRTY;
#echo $ABS_PATH_TO_THIS_SCRIPT;
#exit 0;

RELEASE_BRANCH="0.x"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Make sure current branch and release branch match.
if [[ "$RELEASE_BRANCH" != "$CURRENT_BRANCH" ]]
then
    if [[ $IGNORE_DIRTY == 0 ]]; then
      echo "Release branch ($RELEASE_BRANCH) does not match the current active branch ($CURRENT_BRANCH)."

      exit 1;
    fi
fi

# Make sure the working directory is clear.
if [[ ! -z "$(git status --porcelain)" ]]
then
    if [[ $IGNORE_DIRTY == 0 ]]; then
      echo "Your working directory is dirty. Did you forget to commit your changes?"

      exit 1;
    fi
fi

# Make sure latest changes are fetched first.
git fetch origin

# Make sure that release branch is in sync with origin.
if [[ $(git rev-parse HEAD) != $(git rev-parse origin/$RELEASE_BRANCH) ]]
then
    echo "Your branch is out of date with its upstream. Did you forget to pull or push any changes before releasing?"

    exit 1
fi

# Always prepend with "v"
if [[ $VERSION != v*  ]]
then
    VERSION="v$VERSION"
fi

UPDATE_FRAMEWORK=0

#echo $VERSION;
#exit 0;

# Tag Framework
tagExists=$(git tag --list | grep $VERSION | wc -l | xargs)
echo "Tag exists: $tagExists"
if [[ $tagExists == 1 ]]; then
  echo "Tag $VERSION exists, checking if it is the same"
  numberOfChanges=$(git diff $RELEASE_BRANCH..refs/tags/$VERSION | wc -l | xargs)
  echo "Number of changes: $numberOfChanges"
  if [[ $numberOfChanges == 0 ]]; then
    echo -e "\e[32mTag $VERSION already exists and there are no changes in current branch VS remote tag. Skipping...\e[0m"
  fi
  if [[ $numberOfChanges != 0 ]]; then
    git push --delete origin $VERSION || echo "Tag does not exist on origin."
    # delete tag locally
    git tag -d $VERSION || echo "Tag does not exist locally."
    git tag $VERSION
    git push origin --tags
  fi
fi

# for now always tag the framework
if [[ $tagExists == 0 ]]; then
  git tag $VERSION
  git push origin --tags
fi

#if [[ $tagExists == 0 ]]; then
#  # if tag exists and IS_MINOR is 1, compare working directory with latest tag and if there are no changes, skip tagging
#  if [[ $IS_MINOR == 1 ]]; then
#    echo "Tag $VERSION does not exist, checking if it is the same as latest tag"
#    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
#    echo "Latest tag: $latestTag"
#    numberOfChanges=$(git diff $latestTag | wc -l | xargs)
#    echo "Number of changes: $numberOfChanges"
#    if [[ $numberOfChanges == 0 ]]; then
#      echo "Tag $VERSION already exists and there are no changes in current branch VS remote tag. Skipping..."
#    fi
#    if [[ $numberOfChanges != 0 ]]; then
#      git tag $VERSION
#      git push origin --tags
#    fi
#  fi
#fi

# Tag Components
for REMOTE in Contracts Foundation Options Pagination Support
do
    lowercaseRemote=$(echo "$REMOTE" | tr '[:upper:]' '[:lower:]')
    echo ""
    echo ""
    echo "Releasing $REMOTE";

    TMP_DIR="/tmp/larawelp-split"
    REMOTE_URL="git@github.com:larawelp/$lowercaseRemote.git"

    rm -rf $TMP_DIR;
    mkdir $TMP_DIR;

    (
        cd $TMP_DIR;

        git clone $REMOTE_URL .
        git checkout "$RELEASE_BRANCH";

        latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

        tagExists=$(git tag --list | grep $VERSION | wc -l | xargs)
        echo "Tag exists: $tagExists"
        # if there are no changes in current branch VS remote branch, skip re-doing the tag to save time
        if [[ $tagExists == 1 ]]; then
          echo "Tag $VERSION exists, checking if it is the same"
          numberOfChanges=$(git diff $RELEASE_BRANCH..refs/tags/$VERSION | wc -l | xargs)
          echo "Number of changes: $numberOfChanges"
          if [[ $numberOfChanges == 0 ]]; then
            echo "Tag $VERSION already exists on $REMOTE_URL and there are no changes in current branch VS remote tag. Skipping..."
            continue
          fi
        fi

        if [[ $tagExists == 0 ]]; then
          # if tag exists and IS_MINOR is 1, compare working directory with latest tag and if there are no changes, skip tagging
          if [[ $IS_MINOR == 1 ]]; then
            echo "Tag $VERSION does not exist, checking if it is the same as latest tag"
            echo "Latest tag: $latestTag"
            numberOfChanges=$(git diff $latestTag | wc -l | xargs)
            echo "Number of changes: $numberOfChanges"
            if [[ $numberOfChanges == 0 ]]; then
              # with green text, show latestTag
              echo -e "\e[32mTag Skipping useless minor tag, latest released tag is $latestTag...\e[0m"
              continue
            fi
          fi
        fi

        # if the tag already exists on origin, delete it first
        git push --delete origin $VERSION || echo "Tag does not exist on origin."
        # delete tag locally
        git tag -d $VERSION || echo "Tag does not exist locally."

        git tag $VERSION
        git push origin --tags
    )
done