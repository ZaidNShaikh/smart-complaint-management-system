# Intelligent Complaint Management System

A local college complaint application for students and administrators. Students submit a title, description and location. A Python service asks a locally installed Qwen model through Ollama to check whether the report is actionable and, when it passes, suggest its category and urgency. Spring Boot calculates priority, assigns a department and stores the result in MySQL. An administrator can change any AI suggestion and manage the complaint through resolution.

## Problem statement

Email, paper forms and informal messages make campus complaints hard to route, track and review. Students may not know who owns an issue, and administrators may miss repeat reports or status updates.

## Existing and proposed systems

The existing manual process relies on students contacting the correct office and following up themselves. It offers limited visibility and can duplicate work. This project provides one submission and tracking point, AI-assisted routing, same-day similarity checks and an admin-controlled status history. AI results are suggestions; the administrator owns the final decision.

## Objectives and features

- Register students and sign in with BCrypt-hashed passwords.
- Keep one administrator account with no public admin registration.
- Require enough actionable detail before routing a complaint.
- Use Qwen locally through Ollama for quality, category, urgency and explanation.
- Compare passed complaints with same-day reports using TF-IDF/cosine similarity.
- Calculate priority in Java and map categories to campus departments.
- Let students view their own reports, track updates and review resolved complaints.
- Let the administrator filter all reports, open department queues, edit AI suggestions, add status remarks and delete reports.
- Keep the interface as custom HTML, CSS and vanilla JavaScript.

## System flow and architecture

```text
Browser (HTML/CSS/JS) → Spring Boot REST API → Flask AI service → Ollama/Qwen
                                  ↓                 ↓
                                MySQL         JSON analysis + TF-IDF
```

On submit, the browser sends title, description and location to Spring. Spring calls `POST /api/analyze` on Flask. Qwen decides whether the text is actionable. If it is not, Flask returns missing information and Spring returns that result without creating/routing a complaint. The student edits and submits again. If it passes, Spring saves the AI prediction, calculates priority and department, then sends the new report and only today's existing reports to the Python duplicate endpoint. Possible duplicates remain stored for admin review.

## Stack

- Frontend: HTML5, custom CSS3 and vanilla JavaScript
- Backend: Java 17, Spring Boot, Spring Web, Spring Data JPA, BCrypt, Maven
- Database: MySQL
- AI: Python 3, Flask, Qwen via local Ollama; scikit-learn for duplicate similarity

## AI pipeline

`ai-service/qwen_service.py` has one configurable model setting, `QWEN_MODEL` (defaults to `qwen2.5:3b`) and asks Ollama for JSON. The response is parsed and category, urgency, confidences and required fields are validated. If Ollama is unreachable, Flask returns HTTP 503 and the frontend shows a retry message. If a model response is malformed, a small deterministic fallback provides validated values. The fallback never sends a cloud request.

Quality is context-sensitive: the model looks for a real issue and enough detail to act, with a usable location from either the location field or description. It may ask for clarification (for example, “Wi-Fi problem” without a location or details). Start time is requested only when useful, not as a universal required field.

Categories: IT, Infrastructure, Electricity, Water, Cleanliness, Security, Other. Urgency: LOW, MEDIUM, HIGH, CRITICAL.

Duplicate detection receives only same-day complaints. Python builds TF-IDF vectors over title, description and location, then checks cosine similarity against a 0.42 threshold. It returns the best match and score; it does not merge or delete reports.

Priority is calculated in Spring as urgency (50%) + impact (25%) + category importance (15%) + age (10%). Urgency inputs are 20/40/70/90; category importance follows the brief. The implementation uses a neutral impact baseline of 50, 90 when broad impact terms are present, and an age baseline of 20 until an escalation policy is configured. The weighted result is clamped to 0–100. Levels are LOW (0–39), MEDIUM (40–59), HIGH (60–79), CRITICAL (80–100). Department mapping: IT→IT Department, Infrastructure→Maintenance Department, Electricity→Electrical Department, Water→Plumbing Department, Cleanliness→Housekeeping Department, Security→Security Department, Other→General Administration.

## Database

`database/database.sql` creates `complaint_management` and the users, complaints, duplicate_complaints, complaint_updates and reviews tables with foreign keys and indexes. JPA uses `ddl-auto=update` to align schema changes. The optional seed section includes five demo users and 15 complaints across categories, including same-day Wi-Fi reports. The seed users' password is `password`; change or remove those demo accounts before using the system with real data. The application creates the sole admin on startup if missing.

## API endpoints

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Register a student |
| POST | `/api/auth/login` | Student or admin login; returns bearer token |
| GET | `/api/auth/me` | Current account |
| POST | `/api/complaints` | AI quality gate and complaint submission |
| GET | `/api/complaints/my` | Signed-in student's history |
| GET | `/api/complaints/{id}` | Own complaint details (admin can access all) |
| GET | `/api/complaints/{id}/updates` | Complaint timeline |
| POST | `/api/complaints/{id}/review` | One review after resolution |
| GET | `/api/admin/dashboard` | Admin counts |
| GET | `/api/admin/complaints` | Admin list; supports category, urgency, priority, department, status and search filters |
| GET | `/api/admin/complaints/department/{department}` | Department queue |
| GET | `/api/admin/complaints/{id}` | Admin complaint details |
| PUT | `/api/admin/complaints/{id}` | Edit category, urgency, department or priority score |
| PUT | `/api/admin/complaints/{id}/status` | Add status and remark to history |
| PUT | `/api/admin/complaints/{id}/department` | Update department |
| DELETE | `/api/admin/complaints/{id}` | Admin-only delete with related records removed safely |
| POST | Flask `/api/analyze` | Qwen-backed quality/routing analysis |
| POST | Flask `/api/duplicate-check` | Same-day TF-IDF duplicate comparison |
| GET | Flask `/health` | Python and Ollama status |

The backend verifies signed bearer tokens on protected requests. Student complaint endpoints scope records to the logged-in user. Admin endpoints require the ADMIN role. Public registration always creates USER accounts.

## Installation and running

Requirements: Java 17+, Maven, MySQL 8+, Python 3.10+, and local Ollama with a Qwen model already pulled.

1. Create the database and tables by running `database/database.sql` in MySQL. For first-time setup, run the script once before sample inserts; JPA also creates/updates entity tables on backend startup. If your MySQL account is not `root` with no password, configure environment variables below.
2. Start Ollama and confirm your model is available (`ollama list`). Set `QWEN_MODEL` if its installed tag differs from `qwen2.5:3b`.
3. Start Python:

   ```bash
   cd ai-service
   python -m venv .venv
   # Windows: .venv\\Scripts\\activate
   # macOS/Linux: source .venv/bin/activate
   pip install -r requirements.txt
   python app.py
   ```

4. Start Spring Boot in a second terminal:

   ```bash
   cd backend
   mvn spring-boot:run
   ```

5. Serve `frontend/` with VS Code Live Server (or another static server) and open `index.html` through that server. The API base URL is `http://localhost:8080/api` in `frontend/js/app.js`.

Backend configuration environment variables: `DB_URL`, `DB_USER`, `DB_PASSWORD`, `AI_SERVICE_URL`, `TOKEN_SECRET`, `ADMIN_PASSWORD`. The default admin email is `admin@college.edu`; default local demo password is `Admin@123`. Set `ADMIN_PASSWORD` before the first startup for a different password. Keep `TOKEN_SECRET` private and use a long random value outside a local demo. Python configuration: `QWEN_MODEL`, `OLLAMA_URL`.

## Sample credentials

- Admin: `admin@college.edu` / `Admin@123` (unless `ADMIN_PASSWORD` was set on first run)
- Seed students: `aarav@example.edu`, `mira@example.edu`, `kabir@example.edu`, `sara@example.edu`, `dev@example.edu` / `password`
- Students can also register their own accounts from the UI.

## Limitations and future scope

This is a local academic demonstration. It uses a simple bearer token with an HMAC signature and no token expiry/refresh flow, does not yet provide password reset, and the impact/age inputs use documented fixed heuristics. Qwen's interpretation depends on the locally installed model and prompt. Future work could add token expiry, admin audit identity, configurable service-level escalation, campus SSO, attachments, notifications and measured model evaluation.

## Final-year demonstration checklist

Run the services, register a student, submit “Wi-Fi problem” to see the quality gate, add a location and actionable details, and submit again. Check AI classification, same-day duplicate result, priority, department and saved history. Sign in as admin to view the submitter, edit the AI suggestions, add a status remark, resolve the complaint, and confirm the student can track it and submit one review. Try a second student's record URL and an admin API as a student; access should be denied. Stop Ollama and submit to see the clear service-unavailable response.
