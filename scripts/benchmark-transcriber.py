#!/usr/bin/env python3
import json
import sys
import re

def normalize_text(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    return text.strip()

def calculate_overlap(expected, predicted_list):
    exp_norm = normalize_text(expected)
    words_exp = set(exp_norm.split())
    
    best_match_score = 0
    for pred in predicted_list:
        pred_norm = normalize_text(pred)
        words_pred = set(pred_norm.split())
        
        if not words_exp or not words_pred:
            continue
            
        intersection = words_exp.intersection(words_pred)
        score = len(intersection) / len(words_exp)
        if score > best_match_score:
            best_match_score = score
            
    return best_match_score

def run_benchmark(answer_key_path, predictions_path):
    with open(answer_key_path, 'r') as f:
        answer_key = json.load(f)
        
    with open(predictions_path, 'r') as f:
        predictions = json.load(f)
        
    explicit_tasks = answer_key.get("explicit_tasks", [])
    implicit_tasks = answer_key.get("implicit_tasks", [])
    extracted_tasks = predictions.get("extracted_tasks", [])
    
    # Check explicit tasks (Recall)
    explicit_scores = []
    for task in explicit_tasks:
        score = calculate_overlap(task, extracted_tasks)
        explicit_scores.append(score)
        
    captured_explicit = sum(1 for s in explicit_scores if s >= 0.5)
    total_explicit = len(explicit_tasks)
    explicit_recall = (captured_explicit / total_explicit) * 100 if total_explicit > 0 else 0
    
    # Check hallucinations
    # A task is a hallucination if it doesn't match any explicit or implicit task
    all_expected = explicit_tasks + implicit_tasks
    hallucinations = 0
    for task in extracted_tasks:
        score = calculate_overlap(task, all_expected)
        if score < 0.4: # If it barely overlaps with anything expected
            hallucinations += 1
            
    total_extracted = len(extracted_tasks)
    hallucination_rate = (hallucinations / total_extracted) * 100 if total_extracted > 0 else 0
    
    print(f"=== Transcriber Extraction Benchmark ===")
    print(f"Explicit Tasks Captured: {captured_explicit}/{total_explicit} ({explicit_recall:.2f}%)")
    print(f"Hallucinated Tasks     : {hallucinations}/{total_extracted} ({hallucination_rate:.2f}%)")
    
    return {
        "explicit_recall": explicit_recall,
        "hallucination_rate": hallucination_rate
    }

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python benchmark-transcriber.py <answer_key.json> <predictions.json>")
        sys.exit(1)
        
    run_benchmark(sys.argv[1], sys.argv[2])