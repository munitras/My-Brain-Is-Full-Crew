# =============================================================================
# My Brain Is Full - Crew :: Makefile
# =============================================================================
# High-quality SDLC automation for the OpenCode Edition.
# =============================================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash

# --- Variables ---
REPO_DIR := $(shell pwd)
SCRIPTS_DIR := $(REPO_DIR)/scripts
TESTS_DIR := $(REPO_DIR)/tests
META_DIR := $(REPO_DIR)/Meta
MANIFEST := $(META_DIR)/agent-manifest.json

# Colors for output
BLUE   := \033[0;34m
GREEN  := \033[0;32m
CYAN   := \033[0;36m
YELLOW := \033[1;33m
RED    := \033[0;31m
BOLD   := \033[1m
NC     := \033[0m

# --- SDLC Targets ---

.PHONY: help
help: ## Show this help message
	@echo -e "$(BOLD)My Brain Is Full - Crew :: Development & Lifecycle$(NC)"
	@echo -e "Usage: make $(CYAN)<target>$(NC)"
	@echo ""
	@echo -e "$(BOLD)SDLC Targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(BOLD)Installation & Upgrade:$(NC)"
	@echo -e "  $(CYAN)install$(NC)         Run the interactive installer into an Obsidian vault"
	@echo -e "  $(CYAN)update$(NC)          Update an existing installation in your vault"
	@echo ""
	@echo -e "$(BOLD)Project Utilities:$(NC)"
	@echo -e "  $(CYAN)context$(NC)         Generate project long-context.txt for review"
	@echo ""
	@echo -e "$(BOLD)Examples:$(NC)"
	@echo -e "  make test             Run all integrity and script tests"
	@echo -e "  make manifest         Regenerate the agent manifest (after code changes)"
	@echo -e "  make verify           Verify file integrity against the manifest"

.PHONY: init
init: ## Initialize development environment (check dependencies)
	@echo -e "$(BLUE)==> Checking dependencies...$(NC)"
	@command -v jq >/dev/null 2>&1 || (echo -e "$(RED)Error: jq is not installed.$(NC)" && exit 1)
	@command -v sha256sum >/dev/null 2>&1 || (echo -e "$(RED)Error: sha256sum is not installed.$(NC)" && exit 1)
	@command -v bats >/dev/null 2>&1 || echo -e "$(YELLOW)Warning: bats is not installed. Tests will fail.$(NC)"
	@echo -e "$(GREEN)Ready for development.$(NC)"

.PHONY: manifest
manifest: ## Regenerate Meta/agent-manifest.json
	@echo -e "$(BLUE)==> Generating agent manifest...$(NC)"
	@bash $(SCRIPTS_DIR)/generate-manifest.sh

.PHONY: verify
verify: ## Verify project file integrity
	@echo -e "$(BLUE)==> Verifying file integrity...$(NC)"
	@bash $(SCRIPTS_DIR)/verify-integrity.sh

.PHONY: test
test: verify ## Run all tests (requires bats)
	@echo -e "$(BLUE)==> Running tests...$(NC)"
	@if command -v bats >/dev/null 2>&1; then \
		bats $(TESTS_DIR)/scripts.bats; \
	else \
		echo -e "$(RED)Error: bats not found. Install it to run tests.$(NC)"; \
		exit 1; \
	fi

.PHONY: lint
lint: ## Lint shell scripts (requires shellcheck)
	@echo -e "$(BLUE)==> Linting shell scripts...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SCRIPTS_DIR)/*.sh; \
	else \
		echo -e "$(YELLOW)Warning: shellcheck not found. Skipping lint.$(NC)"; \
	fi

.PHONY: clean
clean: ## Remove temporary files and logs
	@echo -e "$(BLUE)==> Cleaning up...$(NC)"
	@rm -f $(REPO_DIR)/.mbifc-vault-path
	@rm -f $(REPO_DIR)/project-context-*.txt
	@echo -e "$(GREEN)Cleaned.$(NC)"

.PHONY: context
context: ## Generate project-context-<date>.txt file
	@echo -e "$(BLUE)==> Generating project context...$(NC)"
	@bash $(SCRIPTS_DIR)/generate-context.sh

# --- Installation & Upgrade ---

.PHONY: install
install: ## Install MBIFC into an Obsidian vault
	@echo -e "$(BLUE)==> Starting installation...$(NC)"
	@bash $(SCRIPTS_DIR)/install-opencode.sh

.PHONY: update
update: ## Update existing MBIFC installation
	@echo -e "$(BLUE)==> Starting update...$(NC)"
	@bash $(SCRIPTS_DIR)/update-opencode.sh

.PHONY: vault-status
vault-status: ## Show currently configured vault path
	@if [ -f $(REPO_DIR)/.mbifc-vault-path ]; then \
		echo -e "$(BOLD)Current Vault:$(NC) $$(cat $(REPO_DIR)/.mbifc-vault-path)"; \
	else \
		echo -e "$(YELLOW)No vault path configured.$(NC)"; \
	fi
