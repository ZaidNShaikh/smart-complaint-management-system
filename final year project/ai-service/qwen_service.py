import json, os, re, requests
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
QWEN_MODEL = os.getenv("QWEN_MODEL", "qwen2.5:3b")
CATEGORIES = {"IT", "Infrastructure", "Electricity", "Water", "Cleanliness", "Security", "Other"}
URGENCIES = {"LOW", "MEDIUM", "HIGH", "CRITICAL"}
PROMPT = """Analyze this college complaint. Return ONLY valid JSON keys qualityPassed (boolean), qualityMessage, missingInformation (array), category (IT/Infrastructure/Electricity/Water/Cleanliness/Security/Other), categoryConfidence (0..1), urgency (LOW/MEDIUM/HIGH/CRITICAL), urgencyConfidence (0..1), detectedLocation, detectedTime, reason. Quality passes when the actual problem and actionable detail are clear. Use the supplied location. If neither it nor description gives a usable place, ask for location. A short title alone such as Wi-Fi problem is insufficient: ask where and what specifically is happening. Ask about start time only if useful; do not require it universally. CRITICAL means immediate safety threat such as exposed live wiring; HIGH means major interruption or issue lasting days; ordinary faults are MEDIUM; minor missing items LOW. Choose Other if unsure. Never invent facts."""

def _fallback(title, description, location):
    text = f"{title} {description}".lower(); missing = []
    if not location and not re.search(r"\b(room|lab|block|building|floor|hostel|canteen|library|classroom|near|at)\b", text): missing.append("location")
    if len(description.split()) < 7 or description.strip().lower() == title.strip().lower(): missing.append("more details about the problem")
    category = "IT" if re.search(r"wifi|wi-fi|internet|computer|network|projector|software", text) else "Electricity" if re.search(r"wire|electric|power|socket|current", text) else "Water" if re.search(r"water|leak|tap|pipe", text) else "Cleanliness" if re.search(r"garbage|clean|waste|dirty", text) else "Security" if re.search(r"security|unauthorized|intruder|threat", text) else "Infrastructure" if re.search(r"door|window|wall|ceiling|furniture|broken", text) else "Other"
    urgency = "CRITICAL" if re.search(r"exposed.*wire|fire|smoke|injur|live wire", text) else "HIGH" if re.search(r"several days|days|cannot access|unavailable|flood", text) else "LOW" if re.search(r"remote missing|missing item", text) else "MEDIUM"
    return {"qualityPassed": not missing, "qualityMessage": "Please provide " + " and ".join(missing) + "." if missing else "Complaint information is sufficient.", "missingInformation": missing, "category": category, "categoryConfidence": .55, "urgency": urgency, "urgencyConfidence": .55, "detectedLocation": location, "detectedTime": "", "reason": "Fallback analysis used because the model response could not be parsed."}

def analyze(title, description, location=""):
    prompt = PROMPT + "\nInput:\n" + json.dumps({"title": title, "description": description, "location": location}, ensure_ascii=False)
    response = requests.post(f"{OLLAMA_URL}/api/generate", json={"model": QWEN_MODEL, "prompt": prompt, "stream": False, "format": "json", "options": {"temperature": .1}}, timeout=90)
    response.raise_for_status()
    try: result = json.loads(response.json().get("response", ""))
    except (json.JSONDecodeError, TypeError): result = _fallback(title, description, location)
    if not isinstance(result, dict) or not isinstance(result.get("qualityPassed"), bool): result = _fallback(title, description, location)
    result["category"] = result.get("category") if result.get("category") in CATEGORIES else "Other"
    result["urgency"] = result.get("urgency") if result.get("urgency") in URGENCIES else "MEDIUM"
    result["missingInformation"] = result.get("missingInformation") if isinstance(result.get("missingInformation"), list) else []
    for f in ("categoryConfidence", "urgencyConfidence"):
        try: result[f] = max(0., min(1., float(result.get(f, .5))))
        except (TypeError, ValueError): result[f] = .5
    for f in ("qualityMessage", "detectedLocation", "detectedTime", "reason"): result[f] = str(result.get(f, ""))
    return result
