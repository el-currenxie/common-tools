#!/bin/bash

#  param
# 1. frontend pivotal tracker url
# 2. backend pivotal tracker url
# 3. zapier url

source ./result/.story_ids
STORIES_INFO=[]
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            ZAPIER_URL)
              ZAPIER_URL=${VALUE}
              ;;
            *)
              STORY_IDS_VAR_NAME=${KEY}_STORY_IDS_STRING
              PROJECT_STORIES=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "$VALUE/stories/bulk?ids=${!STORY_IDS_VAR_NAME}")
              echo "> STORY_IDS_VAR_NAME: $STORY_IDS_VAR_NAME"
              echo "> PROJECT_STORIES: $PROJECT_STORIES"
              STORIES_INFO=$(jq -c --argjson arr1 "$STORIES_INFO" --argjson arr2 "$PROJECT_STORIES" -n '$arr2 + $arr1 | unique_by(.id)')
              ;;
    esac
done
curl -X POST -H "Content-Type: application/json" -H "X-cx-token: $ZAPIER_TOKEN" -d "$STORIES_INFO" $ZAPIER_URL
