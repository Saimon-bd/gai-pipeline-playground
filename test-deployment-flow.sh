#!/bin/bash

# Enhanced Workflow Tester with Deployment Flow Simulation
# Usage: ./test-deployment-flow.sh <event-file>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

EVENT_FILE="${1:-.github/test-event-all.json}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Complete Deployment Flow Test${NC}"
echo -e "${GREEN}========================================${NC}"

# Step 1: Run path detection
echo -e "\n${CYAN}🔍 Step 1: Path Detection & Environment Parsing${NC}"
result=$(./test-workflow-local.sh "$EVENT_FILE" | tail -10)
echo "$result"

# Extract environments and services from the output
full_output=$(./test-workflow-local.sh "$EVENT_FILE")
envs=$(echo "$full_output" | grep "envs:" | cut -d' ' -f4)
services=$(echo "$full_output" | grep "services:" | cut -d' ' -f4)

if [[ -z "$envs" ]]; then
    echo -e "${RED}❌ No environments detected. Exiting.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}📊 Detected Configuration:${NC}"
echo -e "   Environments: ${CYAN}$envs${NC}"
echo -e "   Services: ${CYAN}$services${NC}"

# Step 2: Simulate Terraform CD Pipeline
echo -e "\n${YELLOW}🚀 Step 2: Terraform CD Pipeline Simulation${NC}"

IFS=',' read -ra ENV_ARRAY <<< "$envs"
total_deployments=${#ENV_ARRAY[@]}

echo -e "   Matrix Strategy: ${total_deployments} parallel jobs"

# Step 3: Simulate each environment deployment
for env in "${ENV_ARRAY[@]}"; do
    echo -e "\n${MAGENTA}🌍 Environment: $env${NC}"
    echo -e "${YELLOW}   ├── 📢 Slack Alert: Approval Required${NC}"
    
    # Simulate Slack notification
    cat << EOF | sed 's/^/   │   /'
🔄 Infrastructure Deployment Pending

Environment: $env
Repository: gai-pipeline-playground  
Branch: aauto-trigger
Triggered by: test-user

⚠️ Waiting for manual approval to proceed
EOF
    
    echo -e "${YELLOW}   ├── ⏸️  Waiting for approval...${NC}"
    sleep 1
    
    echo -e "${YELLOW}   ├── ✅ Approval received!${NC}"
    echo -e "${YELLOW}   ├── 🔧 Terraform Plan...${NC}"
    sleep 0.5
    
    echo -e "${YELLOW}   ├── 🚀 Terraform Apply...${NC}"
    sleep 0.5
    
    # Simulate deployment success
    echo -e "${GREEN}   ├── ✅ Deployment Success!${NC}"
    echo -e "${YELLOW}   └── 📢 Slack Alert: Deployment Complete${NC}"
    
    # Simulate success notification
    cat << EOF | sed 's/^/       /'
✅ Deployment Success

Environment: $env
Repository: gai-pipeline-playground
Branch: aauto-trigger  
Workflow: Deploy Infrastructure
EOF
done

# Step 4: Summary
echo -e "\n${GREEN}🎉 Step 3: Deployment Summary${NC}"
echo -e "   ✅ Total Environments: ${total_deployments}"
echo -e "   ✅ Total Notifications: $((total_deployments * 2))"
echo -e "   ✅ All deployments completed successfully!"

# Step 5: Real workflow commands
echo -e "\n${BLUE}💡 To run actual GitHub Actions:${NC}"
echo -e "   1. Push to repository"
echo -e "   2. Create PR with changes to:"

IFS=',' read -ra SERVICE_ARRAY <<< "$services"
for service in "${SERVICE_ARRAY[@]}"; do
    for env in "${ENV_ARRAY[@]}"; do
        echo -e "      - environments/$env/$service/apim-config/"
    done
done

echo -e "   3. Merge PR to trigger deployment"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN} Test Complete! 🚀${NC}"
echo -e "${GREEN}========================================${NC}"