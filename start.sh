#!/usr/bin/env bash
set -euo pipefail

# Env richieste in Render:
#   SF_USERNAME    -> il tuo username Salesforce
#   SFDX_CLIENT_ID -> Consumer Key della Connected App JWT
#   SF_LOGIN_URL   -> https://login.salesforce.com (o il tuo MyDomain login URL)
# Secret file:
#   /etc/secrets/jwt.key -> private key generata (server.key)

: "${SF_USERNAME:?Missing SF_USERNAME}"
: "${SFDX_CLIENT_ID:?Missing SFDX_CLIENT_ID}"
: "${SF_LOGIN_URL:=https://login.salesforce.com}"
: "${JWT_KEY_PATH:=/etc/secrets/jwt.key}"

echo "[1/3] JWT auth against ${SF_LOGIN_URL} as ${SF_USERNAME} ..."
sf org login jwt \
  --username "${SF_USERNAME}" \
  --jwt-key-file "${JWT_KEY_PATH}" \
  --client-id "${SFDX_CLIENT_ID}" \
  --login-url "${SF_LOGIN_URL}" \
  --alias playfulUnicorn

echo "[2/3] Verifying connection ..."
sf org display -o playfulUnicorn || { echo "SF login failed"; exit 1; }

echo "[3/3] Starting MCP proxy on :8080 (SSE /sse/ ; HTTP /mcp) ..."
exec mcp-proxy --allow-origin "*" --host 0.0.0.0 --port 8080 -- \
  npx -y @salesforce/mcp --orgs playfulUnicorn --toolsets all

