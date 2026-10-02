from flask import Flask, jsonify, request
import requests
from qwen_service import analyze
from duplicate_service import find_duplicate
app = Flask(__name__)

@app.get("/health")
def health():
    try: available = requests.get("http://localhost:11434/api/tags", timeout=2).ok
    except requests.RequestException: available = False
    return jsonify({"status": "ok", "modelAvailable": available})

@app.post("/api/analyze")
def analyze_complaint():
    data = request.get_json(silent=True) or {}; title = str(data.get("title", "")).strip(); description = str(data.get("description", "")).strip()
    if not title or not description: return jsonify({"message": "Title and description are required."}), 400
    try: return jsonify(analyze(title, description, str(data.get("location", "")).strip()))
    except requests.RequestException: return jsonify({"message": "Ollama/Qwen is unavailable. Start Ollama and try again."}), 503

@app.post("/api/duplicate-check")
def duplicate_check():
    data = request.get_json(silent=True) or {}; return jsonify(find_duplicate(data.get("complaint", {}), data.get("existing", [])))

if __name__ == "__main__": app.run(host="0.0.0.0", port=5000, debug=False)
