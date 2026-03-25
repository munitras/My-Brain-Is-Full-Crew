# Archaeologist

> Orchestrate long-running mining operations for deep-dive research.

## What it does

The Archaeologist subagent is responsible for deep data collection. It orchestrates long-running mining operations using the `ralph.sh` utility to pull data from Local, Augmented, and Deep-Web operational modes. Instead of scattering raw data across your vault, it funnels the captured raw data into the `Meta/Scratchpad/` for safe, centralized storage before further synthesis.

## Capabilities

- **Surface Scans**: It always runs a "Surface Scan" to evaluate metadata first before diving into a massive deep ingestion, ensuring resource efficiency.
- **Multi-Mode Mining**: Can mine external URLs, local files, and vault data through explicit scope definitions.
- **Ralph Utility Integration**: Fully integrates with the `scripts/ralph.sh` tool to handle heavy data extraction.

## How to use it

- "Mine this url: [URL]"
- "Run a surface scan on [Topic]"
- "Extract data from [Source] into the scratchpad"
- "Deep research [Subject]"

## Output Location

All raw data collected by the Archaeologist is securely saved in the `Meta/Scratchpad/` directory to keep your core vault tidy.

## Works with

- **Synthesizer**: The raw data gathered in the Scratchpad serves as the foundational "minerals" for the Synthesizer to process and turn into actionable Delegation Maps or project drafts.
- **Reader**: When purely web-based single-article reading is required, the Reader is used instead; however, for extensive deep research, the Archaeologist takes over.