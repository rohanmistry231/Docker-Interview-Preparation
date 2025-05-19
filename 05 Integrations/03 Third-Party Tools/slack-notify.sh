#!/bin/bash

SLACK_WEBHOOK_URL="$1"
APP_NAME="third-party-tools-demo"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Send notification to Slack
curl -X POST -H 'Content-type: application/json' --data "{
    \"text\": \"Deployment completed for *${APP_NAME}* at ${TIMESTAMP}\"
}" $SLACK_WEBHOOK_URL