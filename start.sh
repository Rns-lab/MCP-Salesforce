#!/usr/bin/env bash
set -euo pipefail

# Env richieste (impostale in Render → Environment):
#   SF_USERNAME     -> username Salesforce della tua org
#   SFDX_CLIENT_ID  -> Consumer Key della Connected App JWT
#   SF_LOGIN_URL    -> (opzionale) login host; default 
login.salesforce.com
#   ORG_ALIAS       -> (opzionale) alias org; default mcpOrg
# Secret file (Render → Secret Files):
#   /etc/secrets/jwt.key -> chiave privata RSA abbinata al certificato 
caricato nella Connected App

: "${SF_USERNAME:?Missing SF_USERNAME}"
: "${SFDX_CLIENT_ID:?Missing SFDX_CLIENT_ID}"
: "${JWT_KEY_PATH:=/etc/secrets/jwt.key}"
: "${SF_LOGIN_URL:=https://login.salesforce.com}"
: "${ORG_ALIAS:=mcpOrg}"

echo "[0/3] Setup CLI (telemetry off)"
sf config set disable-telemetry true --global || true
sf --version || true

echo "[1/3] JWT auth -> ${SF_USERNAME} @ ${SF_LOGIN_URL}"
sf org login jwt \
  --username "${SF_USERNAME}" \
  --client-id "${SFDX_CLIENT_ID}" \
  --jwt-key-file "${JWT_KEY_PATH}" \
  --instance-url "${SF_LOGIN_URL}" \
  --alias "${ORG_ALIAS}" \
  --set-default

echo "[2/3] Verifica connessione"
sf org display --target-org "${ORG_ALIAS}"

echo "[3/3] Avvio MCP proxy su :8080 (SSE=/sse/ , HTTP=/mcp)"
exec /venv/bin/mcp-proxy \
  --allow-origin "*" \
  --host 0.0.0.0 \
  --port 8080 \
  -- npx -y @salesforce/mcp --orgs "${ORG_ALIAS}" --toolsets all

