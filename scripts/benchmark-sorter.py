#!/usr/bin/env python3
import json
import sys
import os

def run_benchmark(answer_key_path, predictions_path):
    with open(answer_key_path, 'r') as f:
        answer_key = json.load(f)
    
    with open(predictions_path, 'r') as f:
        predictions = json.load(f)

    total = len(answer_key)
    correct = 0
    false_positives = 0
    false_negatives = 0
    true_positives = 0
    true_negatives = 0

    for filename, expected_path in answer_key.items():
        # Handle case where expected_path is dict or string
        if isinstance(expected_path, dict):
            exp_path = expected_path.get("path", "")
            exp_create = expected_path.get("create_folder", False)
        else:
            exp_path = expected_path
            # infer create_folder from noise
            exp_create = "Noise" in filename

        pred = predictions.get(filename, {})
        if isinstance(pred, dict):
            pred_path = pred.get("path", "")
            pred_create = pred.get("create_folder", False)
        else:
            pred_path = pred
            pred_create = False

        if pred_path == exp_path:
            correct += 1

        if exp_create and pred_create:
            true_positives += 1
        elif not exp_create and not pred_create:
            true_negatives += 1
        elif not exp_create and pred_create:
            false_positives += 1
        elif exp_create and not pred_create:
            false_negatives += 1

    accuracy = (correct / total) * 100 if total > 0 else 0
    
    print(f"=== Sorter Routing Benchmark ===")
    print(f"Total notes evaluated : {total}")
    print(f"Baseline Accuracy     : {accuracy:.2f}% ({correct}/{total})")
    print(f"Folder Creation False Positives: {false_positives}")
    print(f"Folder Creation False Negatives: {false_negatives}")
    
    return {
        "accuracy": accuracy,
        "false_positives": false_positives,
        "false_negatives": false_negatives
    }

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python benchmark-sorter.py <answer_key.json> <predictions.json>")
        sys.exit(1)
        
    run_benchmark(sys.argv[1], sys.argv[2])
