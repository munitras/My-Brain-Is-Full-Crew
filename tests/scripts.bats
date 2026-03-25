#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    # Create a temporary directory for the mock vault and repo
    export TEST_DIR="$(mktemp -d)"
    export PROJECT_ROOT="$(pwd)"
    export MOCK_REPO="$TEST_DIR/repo"
    
    mkdir -p "$MOCK_REPO/Meta"
    mkdir -p "$MOCK_REPO/.opencode/agents"
    mkdir -p "$MOCK_REPO/.opencode/references"
    mkdir -p "$MOCK_REPO/scripts"
    
    # Copy scripts to mock repo for testing
    cp "$PROJECT_ROOT/scripts/generate-manifest.sh" "$MOCK_REPO/scripts/"
    
    # Create some mock agent files
    echo "architect content" > "$MOCK_REPO/.opencode/agents/architect.md"
    echo "scribe content" > "$MOCK_REPO/.opencode/agents/scribe.md"
    echo "AGENTS content" > "$MOCK_REPO/AGENTS.md"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "generate-manifest.sh creates Meta/agent-manifest.json" {
    cd "$MOCK_REPO"
    run bash scripts/generate-manifest.sh
    assert_success
    assert [ -f "Meta/agent-manifest.json" ]
}

@test "generate-manifest.sh includes all agent files in manifest" {
    cd "$MOCK_REPO"
    run bash scripts/generate-manifest.sh
    assert_success
    
    # Check if files are in the manifest
    run jq -r '.files | keys[]' Meta/agent-manifest.json
    assert_success
    assert_line ".opencode/agents/architect.md"
    assert_line ".opencode/agents/scribe.md"
    assert_line "AGENTS.md"
}

@test "verify-integrity.sh fails if file is tampered" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/verify-integrity.sh" "scripts/"
    run bash scripts/generate-manifest.sh
    assert_success
    
    # Tamper with a file
    echo "tampered" >> ".opencode/agents/architect.md"
    
    run bash scripts/verify-integrity.sh
    assert_failure
    assert_line --partial "MISMATCH: .opencode/agents/architect.md"
}

@test "verify-integrity.sh passes if files match manifest" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/verify-integrity.sh" "scripts/"
    run bash scripts/generate-manifest.sh
    assert_success
    
    run bash scripts/verify-integrity.sh
    assert_success
}

@test "install-opencode.sh should generate manifest if missing" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/install-opencode.sh" "scripts/"
    
    # Remove existing manifest
    rm -f Meta/agent-manifest.json
    
    # Mocking read -r -p "   > " CONFIRM
    # Actually, we just want it to generate the manifest before asking confirm.
    # We can use "timeout" to stop after it generates manifest but before it blocks on read.
    # Or just echo 'n' | bash scripts/install-opencode.sh
    echo "n" | timeout 5s bash scripts/install-opencode.sh || true
    
    [ -f "Meta/agent-manifest.json" ]
}

@test "validate-paths.sh rejects path with .." {
    mkdir -p "$TEST_DIR/vault"
    VAULT="$(cd "$TEST_DIR/vault" && pwd)"
    run bash scripts/validate-paths.sh "$VAULT" "00-Inbox/../../etc/passwd"
    assert_failure
    assert_output --partial "ERROR: Path contains '..'"
}

@test "validate-paths.sh rejects path escaping vault" {
    mkdir -p "$TEST_DIR/vault"
    VAULT="$(cd "$TEST_DIR/vault" && pwd)"
    run bash scripts/validate-paths.sh "$VAULT" "/etc/passwd"
    assert_failure
    assert_output --partial "ERROR: Path escapes vault boundary"
}

@test "validate-paths.sh accepts valid relative path" {
    mkdir -p "$TEST_DIR/vault"
    VAULT="$(cd "$TEST_DIR/vault" && pwd)"
    run bash scripts/validate-paths.sh "$VAULT" "00-Inbox/note.md"
    assert_success
    assert_output --partial "Path OK"
}

@test "context-switch.sh switches focus and creates profile if missing" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/context-switch.sh" "scripts/"
    run bash scripts/context-switch.sh --switch "Deep Work" "$MOCK_REPO"
    assert_success
    assert_output --partial "Switched focus to: Deep Work"
    
    run grep 'current_focus: "Deep Work"' "$MOCK_REPO/Meta/user-profile.md"
    assert_success
    run grep 'focus_status: "active"' "$MOCK_REPO/Meta/user-profile.md"
    assert_success
}

@test "context-switch.sh pauses and resumes focus" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/context-switch.sh" "scripts/"
    
    # Create initial state
    mkdir -p "$MOCK_REPO/Meta"
    cat << 'EOF' > "$MOCK_REPO/Meta/user-profile.md"
---
current_focus: "Writing Tests"
focus_status: "active"
---
# User Profile
EOF

    run bash scripts/context-switch.sh --pause "$MOCK_REPO"
    assert_success
    assert_output --partial "Paused current focus"
    run grep 'focus_status: "paused"' "$MOCK_REPO/Meta/user-profile.md"
    assert_success
    
    run bash scripts/context-switch.sh --resume "$MOCK_REPO"
    assert_success
    assert_output --partial "Resumed current focus"
    run grep 'focus_status: "active"' "$MOCK_REPO/Meta/user-profile.md"
    assert_success
}

@test "context-switch.sh writes to chronos-ledger.jsonl" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/context-switch.sh" "scripts/"
    
    run bash scripts/context-switch.sh --switch "Deep Work" "$MOCK_REPO"
    assert_success
    
    # Check that ledger file was created and contains the correct JSON
    assert [ -f "$MOCK_REPO/07-Daily/chronos-ledger.jsonl" ]
    
    run grep '"action": "switch"' "$MOCK_REPO/07-Daily/chronos-ledger.jsonl"
    assert_success
    run grep '"task": "Deep Work"' "$MOCK_REPO/07-Daily/chronos-ledger.jsonl"
    assert_success
    
    run bash scripts/context-switch.sh --pause "$MOCK_REPO"
    assert_success
    
    run grep '"action": "pause"' "$MOCK_REPO/07-Daily/chronos-ledger.jsonl"
    assert_success
    run grep '"task": "Deep Work"' "$MOCK_REPO/07-Daily/chronos-ledger.jsonl"
    assert_success
}

@test "foreman-sweep.sh extracts open tasks correctly" {
    cd "$MOCK_REPO"
    cp "$PROJECT_ROOT/scripts/foreman-sweep.sh" "scripts/"
    
    mkdir -p 00-Inbox 01-Projects/Alpha
    echo "- [ ] Inbox task" > 00-Inbox/note.md
    echo "  - [ ] Project task" > 01-Projects/Alpha/plan.md
    echo "- [x] Done task" >> 01-Projects/Alpha/plan.md
    
    run bash scripts/foreman-sweep.sh "$MOCK_REPO"
    assert_success
    assert_line --partial "- [ ] Inbox task [[00-Inbox/note]]"
    assert_line --partial "- [ ] Project task [[01-Projects/Alpha/plan]]"
    refute_output --partial "Done task"
}

@test "poll-queue.sh filters pending messages for specific agent" {
    mkdir -p "$TEST_DIR/Meta/queues"
    QUEUE_DIR="$TEST_DIR/Meta/queues"
    echo '{"resolves_id": "msg-001", "status": "resolved"}' > "$QUEUE_DIR/architect-outbox.jsonl"
    echo '{"message_id": "msg-001", "timestamp": "2026-03-25T08:05:00Z", "from": "architect", "to": "sorter", "status": "pending", "intent": "file_note", "payload": {"note": "test.md"}}' > "$QUEUE_DIR/sorter-outbox.jsonl"
    echo '{"message_id": "msg-002", "timestamp": "2026-03-25T08:10:00Z", "from": "architect", "to": "sorter", "status": "pending", "intent": "file_note", "payload": {"note": "test2.md"}}' >> "$QUEUE_DIR/sorter-outbox.jsonl"

    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh "sorter"
    assert_success
    assert_output '{"message_id":"msg-002","timestamp":"2026-03-25T08:10:00Z","from":"architect","to":"sorter","status":"pending","intent":"file_note","payload":{"note":"test2.md"}}'
}

@test "poll-queue.sh fails gracefully when queue file is missing" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh "sorter"
    assert_success
    assert_output ""
}

@test "poll-queue.sh requires agent name parameter" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh
    assert_failure
    assert_output '{"error": "Agent name parameter required (e.g., ./poll-queue.sh architect)"}'
}

@test "Meta/vault-structure.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/Meta/vault-structure.json"
    assert_success
}

@test "Meta/tag-taxonomy.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/Meta/tag-taxonomy.json"
    assert_success
}

@test "generate-golden-dataset.py creates 50 notes" {
    # Run the script in the test environment
    mkdir -p "$TEST_DIR/tests/fixtures"
    # Ensure script writes to the test directory by overriding the VAULT_DIR or just running it in a tmp folder
    # Wait, the script hardcodes VAULT_DIR = "tests/fixtures/golden-vault" relative to CWD.
    cd "$TEST_DIR"
    mkdir -p "tests/fixtures"
    cp "$PROJECT_ROOT/scripts/generate-golden-dataset.py" .
    
    run python3 generate-golden-dataset.py
    assert_success
    assert_output --partial "Golden dataset vault generated with 50 notes."
    
    # Check that 50 notes were created in 00-Inbox
    run bash -c "ls -1 tests/fixtures/golden-vault/00-Inbox/*.md | wc -l"
    assert_output "50"
    
    # Check that answer-key.json was created
    assert [ -f "tests/fixtures/golden-vault/answer-key.json" ]
}

@test "benchmark-sorter.py calculates accuracy correctly" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/benchmark-sorter.py" .
    
    echo '{"note1.md": "01-Projects/Alpha", "note2.md": "00-Inbox"}' > answer-key.json
    echo '{"note1.md": "01-Projects/Alpha", "note2.md": "01-Projects/Beta"}' > predictions.json
    
    run python3 benchmark-sorter.py answer-key.json predictions.json
    assert_success
    assert_output --partial "Baseline Accuracy     : 50.00% (1/2)"
}

@test "benchmark-transcriber.py calculates precision and recall correctly" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/benchmark-transcriber.py" .

    echo '{"explicit_tasks": ["Buy groceries", "Fix the car"], "implicit_tasks": ["Call mom"]}' > transcriber-answer.json
    echo '{"extracted_tasks": ["Buy groceries", "Call mom", "Random thought"]}' > transcriber-preds.json

    run python3 benchmark-transcriber.py transcriber-answer.json transcriber-preds.json
    assert_success
    assert_output --partial "Explicit Tasks Captured: 1/2 (50.00%)"
    assert_output --partial "Hallucinated Tasks     : 1/3 (33.33%)"
}

@test "benchmark-connector.py calculates wikilink connections correctly" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/benchmark-connector.py" .

    mkdir -p dummy-vault
    echo "This is a note linking to [[ValidNote]] and [[DeadNote]]." > dummy-vault/Note1.md
    echo "Another link [[ValidNote#Section]] here." > dummy-vault/ValidNote.md

    run python3 benchmark-connector.py dummy-vault
    assert_success
    assert_output --partial "Total Wikilinks Found: 3"
    assert_output --partial "Valid Semantic Connections: 2"
    assert_output --partial "Dead Links: 1"
    assert_output --partial "Dead Link Rate: 33.33%"
}

@test "Dashboard.md contains Dataview query for urgent and today tasks" {
    cd "$PROJECT_ROOT"
    run grep -A 3 '```dataview' Meta/Dashboard.md
    assert_success
    assert_output --partial "TASK"
    assert_output --partial 'WHERE contains(tags, "#urgent") OR due = date(today) OR contains(text, "📅")'
}

@test "Dashboard.md contains Foreman-Tasks embed" {
    cd "$PROJECT_ROOT"
    run grep '!\[\[Foreman-Tasks\]\]' Meta/Dashboard.md
    assert_success
}

@test "ON_START.md triggers Foreman sweep and advises user to check HUD" {
    cd "$PROJECT_ROOT"
    run grep 'bash scripts/foreman-sweep.sh . > Meta/Foreman-Tasks.md' .opencode/ON_START.md
    assert_success
    
    run grep 'Please check the Dashboard HUD for your tasks today' .opencode/ON_START.md
    assert_success
}

@test "AGENTS.md routes 'Read this link' to reader subagent" {
    cd "$PROJECT_ROOT"
    run grep '| "Read this link" | Reader (subagent) | Task tool with prompt |' AGENTS.md
    assert_success
}

@test ".opencode/agents/reader.md exists and is configured as a subagent" {
    cd "$PROJECT_ROOT"
    assert [ -f ".opencode/agents/reader.md" ]
    run grep 'mode: subagent' .opencode/agents/reader.md
    assert_success
    run grep 'webfetch: allow' .opencode/agents/reader.md
    assert_success
}

@test ".opencode/agents/scribe.md is configured to allow bash and handle @now interrupts" {
    cd "$PROJECT_ROOT"
    assert [ -f ".opencode/agents/scribe.md" ]
    run grep 'bash: allow' .opencode/agents/scribe.md
    assert_success
    run grep 'System Interrupts: `@now`' .opencode/agents/scribe.md
    assert_success
    run grep 'context-switch.sh' .opencode/agents/scribe.md
    assert_success
}

@test ".opencode/agents/synthesizer.md exists and is configured as a subagent" {
    cd "$PROJECT_ROOT"
    assert [ -f ".opencode/agents/synthesizer.md" ]
    run grep 'mode: subagent' .opencode/agents/synthesizer.md
    assert_success
}

@test "Meta/vault-structure.json contains Drafts folder in 01-Projects" {
    cd "$PROJECT_ROOT"
    run jq -e '.["01-Projects"].subfolders | index("Drafts")' Meta/vault-structure.json
    assert_success
}

@test "AGENTS.md routes 'Draft a document' to synthesizer subagent" {
    cd "$PROJECT_ROOT"
    run grep '| "Draft a document" | Synthesizer (subagent) | Task tool with prompt |' AGENTS.md
    assert_success
}

@test "ON_CLOSE.md triggers Sorter and Librarian, and asks for reflection" {
    cd "$PROJECT_ROOT"
    assert [ -f ".opencode/ON_CLOSE.md" ]
    run grep 'Sorter' .opencode/ON_CLOSE.md
    assert_success
    run grep 'Librarian' .opencode/ON_CLOSE.md
    assert_success
    run grep 'Any final thoughts to park for tomorrow?' .opencode/ON_CLOSE.md
    assert_success
}

@test "README.md contains brainsleep alias" {
    cd "$PROJECT_ROOT"
    run grep 'alias brainsleep="opencode --prompt '"'Execute ON_CLOSE.md...'\"" README.md
    assert_success
}