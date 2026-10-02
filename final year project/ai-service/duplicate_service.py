from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def find_duplicate(complaint, existing, threshold=.42):
    if not existing: return {"duplicateFound": False, "similarComplaintId": None, "similarityScore": 0.0}
    def text(item): return " ".join(str(item.get(k, "")) for k in ("title", "description", "location"))
    try:
        matrix = TfidfVectorizer(stop_words="english", ngram_range=(1, 2)).fit_transform([text(complaint)] + [text(x) for x in existing])
    except ValueError:
        return {"duplicateFound": False, "similarComplaintId": None, "similarityScore": 0.0}
    scores = cosine_similarity(matrix[0:1], matrix[1:]).ravel(); index = int(scores.argmax()); score = float(scores[index]); found = score >= threshold
    return {"duplicateFound": found, "similarComplaintId": existing[index].get("id") if found else None, "similarityScore": round(score, 4) if found else 0.0}
