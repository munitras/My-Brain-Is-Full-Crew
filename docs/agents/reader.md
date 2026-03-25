# Reader

> Friction-less capture of external research directly into the vault.

## What it does

The Reader subagent is designed to ingest web content seamlessly. Rather than copy-pasting an entire article and losing the context, you simply ask the Reader to ingest a URL. It fetches the article, explicitly removes boilerplate and ads, extracts the core thesis, and formats everything cleanly using strict YAML `summary` rules. The ingested data is saved directly to your `00-Inbox/`.

## Capabilities

- **Web Fetching**: Connects to the internet to capture article content.
- **Boilerplate Removal**: Strips out ads, navigation links, and unnecessary cruft.
- **Synthesis & Extraction**: Reads the content to extract the main thesis and key points.
- **YAML Formatting**: Automatically formats the captured data with a strict YAML frontmatter block for seamless processing by other agents (like the Sorter).

## How to use it

- "Read this link: https://example.com/article"
- "Summarize this article: [URL]"
- "Capture this url: [URL]"

## Works with

- **Sorter**: After the Reader captures a web page and formats it with proper metadata in the Inbox, the Sorter can route it to your reading list or specific project folders.
- **Seeker**: Notes ingested by the Reader immediately become searchable and available as source material for the Seeker.