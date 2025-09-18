FROM node:20-bookworm

# Python per mcp-proxy (bridge SSE/HTTP)
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Salesforce CLI
RUN npm install -g @salesforce/cli

# MCP proxy (stdio <-> SSE/HTTP)
RUN pip3 install --no-cache-dir mcp-proxy

WORKDIR /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8080
CMD ["/app/start.sh"]

