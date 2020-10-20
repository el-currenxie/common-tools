#!/bin/bash

#  param
# 1. project_name
# 2. project_url
# 3. integrations_uuid

source ./result/.story_ids
LATEST_GIT_SHA=$(git rev-parse HEAD)
ENV_VAR_NAME="$1_STORY_IDS_STRING"

echo "$LATEST_GIT_SHA"
echo "ENV_VAR_NAME"

if  [[ ! -z "${!ENV_VAR_NAME}" ]]; then
  curl -X POST \
  -H "X-TrackerToken: $TRACKER_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"passed", "url":"'$CIRCLE_BUILD_URL'", "uuid":"'$3'", "story_ids":['${!ENV_VAR_NAME}'], "latest_git_sha":"'$LATEST_GIT_SHA'", "version":1}' \
  "$2/cicd"
fi
