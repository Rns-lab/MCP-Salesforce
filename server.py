from flask import Flask, Response, request
from simple_salesforce import Salesforce
import os, json

app = Flask(__name__)

# Connessione a Salesforce
def connect_salesforce():
    sf = Salesforce(
        username=os.environ["SALESFORCE_USERNAME"],
        password=os.environ["SALESFORCE_PASSWORD"],
        security_token=os.environ["SALESFORCE_SECURITY_TOKEN"]
    )
    return sf

@app.route("/")
def health():
    return {"status": "ok", "message": "Salesforce MCP server running"}

# Endpoint SSE minimale
@app.route("/sse/", methods=["GET"])
def sse():
    def event_stream():
        yield "event: message\n"
        yield 'data: {"status": "connected", "msg": "SSE ready"}\n\n'
    return Response(event_stream(), mimetype="text/event-stream")

# Endpoint MCP minimale: accetta query SOQL
@app.route("/mcp", methods=["POST"])
def mcp():
    try:
        data = request.get_json()
        query = data.get("query", "SELECT Id, Name FROM Account LIMIT 5")
        sf = connect_salesforce()
        result = sf.query(query)
        return {"status": "ok", "records": result["records"]}
    except Exception as e:
        return {"status": "error", "error": str(e)}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

