FROM node:20-bookworm

# Python per mcp-proxy (in venv per evitare PEP 668)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Salesforce CLI moderno
RUN npm install -g @salesforce/cli

# Venv Python + mcp-proxy
RUN python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip && \
    /venv/bin/pip install --no-cache-dir mcp-proxy

WORKDIR /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8080
CMD ["/app/start.sh"]

