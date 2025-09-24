# Live Slack Test Commands
# Replace YOUR_WEBHOOK_URL with actual webhook from GitHub Secrets

# Test DEV Channel
curl -X POST -H 'Content-type: application/json' \
  -d '{
  "text": "⏳ *Approval Required*",
  "blocks": [
    {
      "type": "section", 
      "text": {
        "type": "mrkdwn",
        "text": "🔄 *Infrastructure Deployment Pending*\n\n*Environment:* `dev`\n*Repository:* gai-pipeline-playground\n*Branch:* aauto-trigger\n*Triggered by:* test-user\n*Services:* charging-service, customer-service, public-api\n\n⚠️ *Waiting for manual approval to proceed with deployment*"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View Workflow"},
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
}' \
'YOUR_DEV_WEBHOOK_URL'

# Test STG Channel  
curl -X POST -H 'Content-type: application/json' \
  -d '{"text": "⏳ *STG Approval Required* - Test from local development", "blocks": [{"type": "section", "text": {"type": "mrkdwn", "text": "🧪 Testing STG webhook integration"}}]}' \
'YOUR_STG_WEBHOOK_URL'

# Test PRD Channel
curl -X POST -H 'Content-type: application/json' \
  -d '{"text": "⏳ *PRD Approval Required* - Test from local development", "blocks": [{"type": "section", "text": {"type": "mrkdwn", "text": "🧪 Testing PRD webhook integration"}}]}' \
'YOUR_PRD_WEBHOOK_URL'