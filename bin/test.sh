echo "Deleting remote tags not existing locally"
  git ls-remote --tags $lowercaseApp | while read tag; do
    tag=$(echo $tag | awk '{print $2}' | sed 's/refs\/tags\///g')
    echo "Checking if tag $tag exists locally"
    if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
      echo "Tag $tag exists locally"
    else
      echo "Tag $tag does not exist locally, deleting from remote"
      git push --delete origin $tag
    fi
  done