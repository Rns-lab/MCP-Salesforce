FROM node:20-bookworm

# Python per mcp-proxy (bridge SSE/HTTP)
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && rm -rf /var/lib/apt/lists/*

# Salesforce CLI
RUN npm install -g @salesforce/cli

# Crea virtualenv per Python e installa mcp-proxy
RUN python3 -m venv /venv \
  && /venv/bin/pip install --no-cache-dir --upgrade pip \
  && /venv/bin/pip install --no-cache-dir mcp-proxy

# Aggiungi la venv al PATH
ENV PATH="/venv/bin:$PATH"

WORKDIR /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8080
CMD ["/app/start.sh"]


