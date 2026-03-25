#!/usr/bin/env python3
import os
import re
import sys

def benchmark_connector(vault_path):
    if not os.path.exists(vault_path):
        print(f"Error: Vault path '{vault_path}' does not exist.")
        sys.exit(1)

    wikilink_pattern = re.compile(r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')
    
    # First, index all existing files (basenames without extension)
    existing_files = set()
    for root, _, files in os.walk(vault_path):
        for file in files:
            if file.endswith('.md'):
                name_without_ext = os.path.splitext(file)[0]
                existing_files.add(name_without_ext)
    
    total_links = 0
    valid_links = 0
    dead_links = 0

    # Now, scan for wikilinks and check against index
    for root, _, files in os.walk(vault_path):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    links = wikilink_pattern.findall(content)
                    for link in links:
                        # Strip anchor tags if any (e.g., [[Note Name#Section]])
                        target_name = link.split('#')[0].strip()
                        
                        total_links += 1
                        if target_name in existing_files:
                            valid_links += 1
                        else:
                            dead_links += 1

    print(f"Total Wikilinks Found: {total_links}")
    print(f"Valid Semantic Connections: {valid_links}")
    print(f"Dead Links: {dead_links}")
    
    if total_links > 0:
        dead_link_rate = (dead_links / total_links) * 100
        print(f"Dead Link Rate: {dead_link_rate:.2f}%")
    else:
        print("Dead Link Rate: 0.00%")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 benchmark-connector.py <vault_root>")
        sys.exit(1)
        
    vault_root = sys.argv[1]
    benchmark_connector(vault_root)
