#!/bin/bash
set -e

echo "[0/3] Starting Salesforce MCP container..."

# Check env vars
if [ -z "$SF_USERNAME" ] || [ -z "$SFDX_CLIENT_ID" ] || [ -z 
"$JWT_KEY_PATH" ] || [ -z "$SF_LOGIN_URL" ]; then
  echo "❌ Missing one or more required environment variables:"
  echo "   SF_USERNAME, SFDX_CLIENT_ID, JWT_KEY_PATH, SF_LOGIN_URL"
  exit 1
fi

echo "[1/3] JWT auth against ${SF_LOGIN_URL} as ${SF_USERNAME} ..."
sf org login jwt \
  --username "${SF_USERNAME}" \
  --jwt-key-file "${JWT_KEY_PATH}" \
  --client-id "${SFDX_CLIENT_ID}" \
  --instance-url "${SF_LOGIN_URL}" \
  --alias salesforceMCP

echo "[2/3] Setting default org..."
sf config set target-org=salesforceMCP

echo "[3/3] Starting MCP proxy..."
/venv/bin/mcp-proxy --port 3000
