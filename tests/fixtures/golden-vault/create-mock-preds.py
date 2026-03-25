import json
with open("tests/fixtures/golden-vault/answer-key.json", "r") as f:
    ans = json.load(f)
preds = {}
for k, v in ans.items():
    preds[k] = {"path": v if "Clear" in k or "Noise" in k else "01-Projects/Alpha", "create_folder": "Noise" in k}
with open("tests/fixtures/golden-vault/mock-predictions.json", "w") as f:
    json.dump(preds, f)
