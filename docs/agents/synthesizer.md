# Synthesizer

> Transform raw data "minerals" into actionable project plans and delegation maps.

## What it does

The Synthesizer subagent acts as your high-level drafting and planning assistant. It reads raw notes, ideas, and "Scratchpad" data (minerals) and turns them into structured documents. It implements specific delegation logic (e.g., categorizing tasks for AI vs. Human-In-The-Loop vs. Human-Out-Of-The-Loop), standardizes Markdown tables for task plans, and enforces deep-link citations to verify where the plan came from.

## Capabilities

- **Drafting Essays & Proposals**: Reads your related notes to draft long-form content.
- **Delegation Mapping**: Extracts actionable steps and categorizes them by owner type.
- **Linkage Enforcement**: Cites source material in its outputs (specifically referencing `Meta/Scratchpad/` or other vault areas) to ensure zero hallucination.

## How to use it

- "Draft an essay based on my notes about [Topic]"
- "Write a proposal based on [Project X]"
- "Synthesize my notes about [Subject] into a delegation map"

## Output Location

The Synthesizer places all of its generated drafts safely in `01-Projects/Drafts/`, allowing you to review, edit, and approve them.

## Works with

- **Archaeologist**: Often takes the raw data "mined" by the Archaeologist and synthesizes it into a cohesive action plan.
- **Seeker**: Uses the Seeker to find all notes relevant to a given topic before beginning the synthesis process.