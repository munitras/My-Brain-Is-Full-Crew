# Agent Observability Dashboard

```dataviewjs
// Fetch the raw JSONL file
const rawData = await app.vault.adapter.read("Meta/agent-messages.jsonl");

// Split by line, filter out empty lines, and parse JSON
const messages = rawData.split('\n')
    .filter(line => line.trim().length > 0)
    .map(line => JSON.parse(line));

// Filter for pending messages to keep the dashboard clean
const pendingMessages = messages.filter(m => m.status === "pending");

// Render the table
dv.table(
    ["Time", "From", "To", "Intent", "Payload"],
    pendingMessages.map(m => [
        moment(m.timestamp).format("YYYY-MM-DD HH:mm"),
        m.from,
        m.to,
        m.intent,
        JSON.stringify(m.payload)
    ])
);
```