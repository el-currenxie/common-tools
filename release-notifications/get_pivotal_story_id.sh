#!/bin/bash

#  param
# 1. project_name
# 2. project_url
# 3. environment

git remote update
# new
CURRENT_LOC=$(git rev-parse HEAD)
# old
TARGET_LOC=$(git tag --list "v*" --sort=-version:refname | head -n 1)
echo
case $3 in
"master")
  CURRENT_LOC=$(git tag --list "v*" --sort=-version:refname | head -n 1)
  TARGET_LOC=$(git tag --list "v*" --sort=-version:refname | head -n 2 | tail -1)
  ;;
"testing")
  CURRENT_LOC=$(git tag --list "test*" --sort=-version:refname | head -n 1)
  TARGET_LOC=$(git tag --list "test*" --sort=-version:refname | head -n 2 | tail -1)
  ;;
esac
if [ -z "$TARGET_LOC" ];
then
  # get master commit id if no release tag
  TARGET_LOC=$(git rev-parse HEAD)
fi
if [ -z "$CURRENT_LOC" ] || [ -z "$TARGET_LOC" ];
then
  exit 1
fi
echo "> project_name: $1"
echo "> environment: $3"
echo "> CURRENT_LOC: $CURRENT_LOC, TARGET_LOC: $TARGET_LOC ($(git rev-parse $TARGET_LOC))"
git config --global core.pager cat
ALL_STORY_IDS=($(git log $TARGET_LOC..$CURRENT_LOC | grep -E "\\[.*\\]" | grep -oE "\\[.*\\]" | grep -oE "([0-9]+)"))
PROJECT_STORY_IDS=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "$2/stories/bulk?ids='$(IFS=,; echo "${ALL_STORY_IDS[*]}")'" | jq -c -r 'map(.id|tostring)  | join(",")')
echo "> ALL_STORY_IDS: ${ALL_STORY_IDS[*]}"
echo "> PROJECT_STORY_IDS: $PROJECT_STORY_IDS"
mkdir -p ./result
if  [[ ! -z "${PROJECT_STORY_IDS}" ]];
then
  echo "export $1_STORY_IDS_STRING=\"$PROJECT_STORY_IDS\"" >> ./result/.story_ids
else
  echo "export $1_STORY_IDS_STRING=" >> ./result/.story_ids
fi
git config --global core.pager less
