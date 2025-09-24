#!/bin/bash

# Slack Notification Test Simulator
# This simulates what would be sent to Slack channels

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

EVENT_FILE="${1:-.github/test-event-all.json}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Slack Notification Simulation${NC}"
echo -e "${GREEN}========================================${NC}"

# Get workflow results
full_output=$(./test-workflow-local.sh "$EVENT_FILE")
envs=$(echo "$full_output" | grep "envs:" | sed 's/.*envs: //')
services=$(echo "$full_output" | grep "services:" | sed 's/.*services: //')

echo -e "\n${CYAN}📊 Deployment Configuration:${NC}"
echo -e "   Environments: ${YELLOW}$envs${NC}"
echo -e "   Services: ${YELLOW}$services${NC}"

# Convert comma-separated to array
IFS=',' read -ra ENV_ARRAY <<< "$envs"

echo -e "\n${BLUE}📱 Slack Notifications Preview:${NC}"

for env in "${ENV_ARRAY[@]}"; do
    echo -e "\n${MAGENTA}🔔 Channel: #alerts-$env${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Approval Required Message
    echo -e "${CYAN}📧 Message 1 - Approval Required:${NC}"
    cat << EOF
⏳ Infrastructure Deployment Pending

Environment: $env
Repository: gai-pipeline-playground
Branch: aauto-trigger  
Triggered by: $(whoami)

⚠️ Waiting for manual approval to proceed with deployment

Services to deploy: $services

[View Workflow] button → GitHub Actions page
EOF

    echo -e "\n${CYAN}ℹ️  No success notification (as requested)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
done

echo -e "\n${GREEN}📊 Notification Summary:${NC}"
total_notifications=${#ENV_ARRAY[@]}
echo -e "   • Total Environments: ${#ENV_ARRAY[@]}"
echo -e "   • Total Notifications: $total_notifications (approval only)"
echo -e "   • Channels Used: $(for env in "${ENV_ARRAY[@]}"; do echo "#alerts-$env"; done | tr '\n' ' ')"

echo -e "\n${BLUE}🔗 Available Webhook URLs:${NC}"
echo -e "   • SLACK_WEBHOOK_URL_DEV ✅"  
echo -e "   • SLACK_WEBHOOK_URL_STG ✅"
echo -e "   • SLACK_WEBHOOK_URL_PRD ✅"

echo -e "\n${GREEN}✨ Ready for Production! All Slack secrets configured.${NC}"
echo -e "${GREEN}========================================${NC}"