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

@test "poll-queue.sh filters pending messages for specific agent" {
    mkdir -p "$TEST_DIR/Meta"
    QUEUE_FILE="$TEST_DIR/Meta/agent-messages.jsonl"
    echo '{"timestamp": "2026-03-25T08:00:00Z", "from": "system", "to": "architect", "status": "resolved", "intent": "initialize_bus", "payload": {"status": "online"}}' > "$QUEUE_FILE"
    echo '{"timestamp": "2026-03-25T08:05:00Z", "from": "architect", "to": "sorter", "status": "pending", "intent": "file_note", "payload": {"note": "test.md"}}' >> "$QUEUE_FILE"
    echo '{"timestamp": "2026-03-25T08:10:00Z", "from": "architect", "to": "sorter", "status": "resolved", "intent": "file_note", "payload": {"note": "test2.md"}}' >> "$QUEUE_FILE"

    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh "sorter"
    assert_success
    assert_output '{"timestamp":"2026-03-25T08:05:00Z","from":"architect","to":"sorter","status":"pending","intent":"file_note","payload":{"note":"test.md"}}'
}

@test "poll-queue.sh fails gracefully when queue file is missing" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh "sorter"
    assert_failure
    assert_output --partial "Queue file not found"
}

@test "poll-queue.sh requires agent name parameter" {
    cd "$TEST_DIR"
    cp "$PROJECT_ROOT/scripts/poll-queue.sh" "poll-queue.sh"
    chmod +x poll-queue.sh

    run ./poll-queue.sh
    assert_failure
    assert_output '{"error": "Agent name parameter is required."}'
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