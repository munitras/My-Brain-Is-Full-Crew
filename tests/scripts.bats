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
