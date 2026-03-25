# Agent Observability Dashboard

## Action Center: Urgent & Today

```dataview
TASK
WHERE contains(tags, "#urgent") OR due = date(today) OR contains(text, "📅")
```

## All Open Tasks (Foreman Sweep)
![[Foreman-Tasks]]

## Agent Queue Status

```dataviewjs
// Fetch all files from the queues directory
const queuesDir = "Meta/queues";
let outboxFiles = [];
try {
    const files = await app.vault.adapter.list(queuesDir);
    outboxFiles = files.files.filter(f => f.endsWith("-outbox.jsonl"));
} catch (e) {
    // Directory might not exist yet
}

let allMessages = [];

for (const file of outboxFiles) {
    const rawData = await app.vault.adapter.read(file);
    const messages = rawData.split('\n')
        .filter(line => line.trim().length > 0)
        .map(line => JSON.parse(line));
    allMessages.push(...messages);
}

// Find all resolved IDs
const resolvedIds = new Set(
    allMessages
        .filter(m => m.resolves_id)
        .map(m => m.resolves_id)
);

// Filter for pending messages that haven't been resolved
const pendingMessages = allMessages.filter(m => 
    m.status === "pending" && 
    m.message_id && 
    !resolvedIds.has(m.message_id)
);

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