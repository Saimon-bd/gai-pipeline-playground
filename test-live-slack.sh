#!/bin/bash

# Live Slack Alert Test
# This sends actual notifications to your configured Slack channels

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Live Slack Alert Test${NC}"
echo -e "${GREEN}========================================${NC}"

# Test environment (change this to test different environments)
TEST_ENV="${1:-dev}"

echo -e "\n${CYAN}🧪 Testing Slack notification for environment: ${YELLOW}$TEST_ENV${NC}"

# Get webhook URL from environment variables or use placeholder
case "$TEST_ENV" in
    "dev")
        WEBHOOK_VAR="SLACK_WEBHOOK_URL_DEV"
        ;;
    "stg")
        WEBHOOK_VAR="SLACK_WEBHOOK_URL_STG"
        ;;
    "prd")
        WEBHOOK_VAR="SLACK_WEBHOOK_URL_PRD"
        ;;
    *)
        echo -e "${RED}❌ Invalid environment. Use: dev, stg, or prd${NC}"
        exit 1
        ;;
esac

# Note: In actual GitHub Actions, this would be available as secrets
# For local testing, we'll create a test payload
echo -e "\n${YELLOW}📝 Creating test notification payload...${NC}"

# Create the JSON payload
PAYLOAD=$(cat << EOF
{
  "text": "⏳ *Approval Required*",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "🔄 *Infrastructure Deployment Pending*\n\n*Environment:* \`$TEST_ENV\`\n*Repository:* gai-pipeline-playground\n*Branch:* aauto-trigger\n*Triggered by:* $(whoami)\n*Services:* charging-service, customer-service, public-api\n\n⚠️ *Waiting for manual approval to proceed with deployment*"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View Workflow"
          },
          "url": "https://github.com/Saimon-bd/gai-pipeline-playground/actions"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "🧪 *TEST ALERT* - This is a test notification from local development"
        }
      ]
    }
  ]
}
EOF
)

echo -e "${BLUE}📤 Payload created:${NC}"
echo "$PAYLOAD" | jq '.'

echo -e "\n${YELLOW}🔐 Note: This test requires actual webhook URL${NC}"
echo -e "   To send live notification:"
echo -e "   1. Get webhook URL from GitHub Secrets"
echo -e "   2. Set as environment variable:"
echo -e "   ${CYAN}export $WEBHOOK_VAR=\"https://hooks.slack.com/services/...\"${NC}"
echo -e "   3. Run this script again"

# Check if webhook URL is available
if [ ! -z "${!WEBHOOK_VAR}" ]; then
    echo -e "\n${GREEN}✅ Webhook URL found! Sending live notification...${NC}"
    
    response=$(curl -s -X POST \
        -H 'Content-type: application/json' \
        -d "$PAYLOAD" \
        "${!WEBHOOK_VAR}")
    
    if [ "$response" == "ok" ]; then
        echo -e "${GREEN}🎉 SUCCESS! Notification sent to #alerts-$TEST_ENV${NC}"
        echo -e "   Check your Slack channel for the test message"
    else
        echo -e "${RED}❌ FAILED! Response: $response${NC}"
    fi
else
    echo -e "\n${YELLOW}💡 Alternative: Manual webhook test${NC}"
    echo -e "   Copy this curl command and replace YOUR_WEBHOOK_URL:"
    echo -e "${CYAN}"
    echo "curl -X POST -H 'Content-type: application/json' \\"
    echo "  -d '$PAYLOAD' \\"
    echo "  'YOUR_WEBHOOK_URL'"
    echo -e "${NC}"
fi

echo -e "\n${BLUE}📋 Test environments available:${NC}"
echo -e "   ./test-live-slack.sh dev    # Test DEV channel"
echo -e "   ./test-live-slack.sh stg    # Test STG channel"  
echo -e "   ./test-live-slack.sh prd    # Test PRD channel"

echo -e "\n${GREEN}========================================${NC}"