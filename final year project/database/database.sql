CREATE DATABASE IF NOT EXISTS complaint_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE complaint_management;

CREATE TABLE IF NOT EXISTS users (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE,
 password VARCHAR(255) NOT NULL, role VARCHAR(30) NOT NULL DEFAULT 'USER', created_at DATETIME(6)
);
CREATE TABLE IF NOT EXISTS complaints (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, user_id BIGINT NOT NULL, title VARCHAR(255) NOT NULL,
 description VARCHAR(5000) NOT NULL, location VARCHAR(255), detected_location VARCHAR(255), detected_time VARCHAR(255),
 quality_passed BIT(1) NOT NULL, quality_message VARCHAR(1000), missing_information VARCHAR(500), category VARCHAR(255),
 category_confidence DOUBLE NOT NULL, urgency VARCHAR(255), urgency_confidence DOUBLE NOT NULL, priority_score INT NOT NULL,
 priority_level VARCHAR(255), department VARCHAR(255), status VARCHAR(255), ai_reason VARCHAR(255), duplicate_complaint_id VARCHAR(255),
 similarity_score DOUBLE NOT NULL, created_at DATETIME(6), updated_at DATETIME(6),
 CONSTRAINT fk_complaint_user FOREIGN KEY(user_id) REFERENCES users(id), INDEX idx_complaint_created(created_at), INDEX idx_complaint_department(department)
);
CREATE TABLE IF NOT EXISTS complaint_updates (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, complaint_id BIGINT NOT NULL, status VARCHAR(255), remark VARCHAR(2000),
 updated_by VARCHAR(255), updated_at DATETIME(6), CONSTRAINT fk_update_complaint FOREIGN KEY(complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS duplicate_complaints (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, complaint_id BIGINT, similar_complaint_id BIGINT, similarity_score DOUBLE NOT NULL, created_at DATETIME(6)
);
CREATE TABLE IF NOT EXISTS reviews (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, complaint_id BIGINT NOT NULL UNIQUE, user_id BIGINT NOT NULL,
 rating INT NOT NULL, comment VARCHAR(2000), created_at DATETIME(6),
 CONSTRAINT fk_review_complaint FOREIGN KEY(complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
 CONSTRAINT fk_review_user FOREIGN KEY(user_id) REFERENCES users(id)
);

-- Demo users share password: password (BCrypt encoded; change for real use).
INSERT IGNORE INTO users (id,name,email,password,role,created_at) VALUES
(2,'Aarav Mehta','aarav@example.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','USER',NOW()),
(3,'Mira Shah','mira@example.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','USER',NOW()),
(4,'Kabir Patel','kabir@example.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','USER',NOW()),
(5,'Sara Khan','sara@example.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','USER',NOW()),
(6,'Dev Rao','dev@example.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','USER',NOW());

INSERT INTO complaints (user_id,title,description,location,detected_location,detected_time,quality_passed,quality_message,missing_information,category,category_confidence,urgency,urgency_confidence,priority_score,priority_level,department,status,ai_reason,created_at,updated_at) VALUES
(2,'Wi-Fi not working in Computer Lab 2','Wi-Fi is unavailable in Computer Lab 2 since this morning. Students cannot access the internet for practical work.','Computer Lab 2','Computer Lab 2','Since this morning',1,'Complaint information is sufficient.','[]','IT',0.94,'HIGH',0.89,70,'HIGH','IT Department','PENDING','Internet outage affects student practical work.',NOW() - INTERVAL 2 HOUR,NOW() - INTERVAL 2 HOUR),
(3,'Internet connection unavailable','The internet connection is not working in Computer Lab 2 and our lab session is affected.','Computer Lab 2','Computer Lab 2','',1,'Complaint information is sufficient.','[]','IT',0.91,'HIGH',0.82,70,'HIGH','IT Department','PENDING','Likely related to a same-day computer lab internet outage.',NOW() - INTERVAL 1 HOUR,NOW() - INTERVAL 1 HOUR),
(4,'Projector remote missing','The projector remote is missing from Room 104.','Room 104','Room 104','',1,'Complaint information is sufficient.','[]','IT',0.83,'LOW',0.86,42,'MEDIUM','IT Department','IN_PROGRESS','A missing AV accessory is a low urgency IT issue.',NOW() - INTERVAL 1 DAY,NOW()),
(5,'Broken classroom door','The classroom door hinge is broken in Block A Room 12 and does not close safely.','Block A Room 12','Block A Room 12','',1,'Complaint information is sufficient.','[]','Infrastructure',0.92,'MEDIUM',0.82,50,'MEDIUM','Maintenance Department','PENDING','A damaged classroom door needs maintenance.',NOW() - INTERVAL 3 HOUR,NOW() - INTERVAL 3 HOUR),
(6,'Ceiling leak in library','Water is dripping from the ceiling near the second floor reading tables during rain.','Library second floor','Library second floor','During rain',1,'Complaint information is sufficient.','[]','Water',0.9,'HIGH',0.84,71,'HIGH','Plumbing Department','IN_PROGRESS','Leak may damage the room and needs prompt plumbing attention.',NOW() - INTERVAL 5 HOUR,NOW() - INTERVAL 30 MINUTE),
(2,'Exposed electrical wire','An exposed electrical wire is hanging beside the lecture hall entrance.','Lecture Hall entrance','Lecture Hall entrance','',1,'Complaint information is sufficient.','[]','Electricity',0.96,'CRITICAL',0.98,81,'CRITICAL','Electrical Department','PENDING','Exposed wiring presents an immediate safety hazard.',NOW() - INTERVAL 40 MINUTE,NOW() - INTERVAL 40 MINUTE),
(3,'Garbage not collected','Garbage bins have not been emptied near the canteen for two days and there is a strong smell.','Canteen','Canteen','For two days',1,'Complaint information is sufficient.','[]','Cleanliness',0.9,'MEDIUM',0.75,49,'MEDIUM','Housekeeping Department','PENDING','Uncollected waste needs housekeeping attention.',NOW() - INTERVAL 6 HOUR,NOW() - INTERVAL 6 HOUR),
(4,'Unauthorized entry near hostel','An unknown visitor has entered the hostel area without checking in at the gate.','North hostel gate','North hostel gate','Today',1,'Complaint information is sufficient.','[]','Security',0.89,'HIGH',0.85,73,'HIGH','Security Department','IN_PROGRESS','An unregistered visitor needs security review.',NOW() - INTERVAL 8 HOUR,NOW() - INTERVAL 2 HOUR),
(5,'Washroom tap leaking','The tap in the ground floor washroom continues leaking when closed.','Ground floor washroom','Ground floor washroom','',1,'Complaint information is sufficient.','[]','Water',0.88,'MEDIUM',0.81,51,'MEDIUM','Plumbing Department','RESOLVED','A fixture leak wastes water and has been repaired.',NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 1 DAY),
(6,'Classroom lights flickering','Two lights are flickering in Room 208 during lectures.','Room 208','Room 208','During lectures',1,'Complaint information is sufficient.','[]','Electricity',0.86,'MEDIUM',0.78,50,'MEDIUM','Electrical Department','PENDING','Faulty lighting should be inspected.',NOW() - INTERVAL 1 DAY,NOW() - INTERVAL 1 DAY),
(2,'Broken library chair','A chair has a loose leg at the study area near the library help desk.','Library study area','Library study area','',1,'Complaint information is sufficient.','[]','Infrastructure',0.84,'MEDIUM',0.7,49,'MEDIUM','Maintenance Department','RESOLVED','Damaged furniture has been reported for repair.',NOW() - INTERVAL 4 DAY,NOW() - INTERVAL 2 DAY),
(3,'Campus notice board request','Please add a covered notice board near the sports ground for event notices.','Sports ground','Sports ground','',1,'Complaint information is sufficient.','[]','Other',0.62,'LOW',0.66,39,'LOW','General Administration','PENDING','Administrative request for a campus notice board.',NOW() - INTERVAL 1 DAY,NOW() - INTERVAL 1 DAY),
(4,'Network outage in seminar room','The wired network has been unavailable in Seminar Room 3 since yesterday afternoon.','Seminar Room 3','Seminar Room 3','Since yesterday afternoon',1,'Complaint information is sufficient.','[]','IT',0.87,'HIGH',0.88,69,'HIGH','IT Department','PENDING','Network outage affects scheduled academic use.',NOW() - INTERVAL 1 DAY,NOW() - INTERVAL 1 DAY),
(5,'Drain blockage near cafeteria','Water is pooling around a blocked drain beside the cafeteria entrance.','Cafeteria entrance','Cafeteria entrance','',1,'Complaint information is sufficient.','[]','Water',0.91,'HIGH',0.8,70,'HIGH','Plumbing Department','PENDING','Standing water at a busy entrance needs attention.',NOW() - INTERVAL 7 HOUR,NOW() - INTERVAL 7 HOUR),
(6,'Waste left in corridor','Paper waste has been left in the science block corridor since yesterday.','Science block corridor','Science block corridor','Since yesterday',1,'Complaint information is sufficient.','[]','Cleanliness',0.88,'LOW',0.69,39,'LOW','Housekeeping Department','RESOLVED','Housekeeping cleared the corridor.',NOW() - INTERVAL 3 DAY,NOW() - INTERVAL 2 DAY);

-- Demonstration pair: the second same-day Computer Lab 2 report is flagged as similar.
UPDATE complaints second_report
JOIN complaints first_report ON first_report.title='Wi-Fi not working in Computer Lab 2'
SET second_report.duplicate_complaint_id=CAST(first_report.id AS CHAR), second_report.similarity_score=0.77
WHERE second_report.title='Internet connection unavailable';
INSERT INTO duplicate_complaints (complaint_id,similar_complaint_id,similarity_score,created_at)
SELECT second_report.id,first_report.id,0.77,NOW() FROM complaints second_report
JOIN complaints first_report ON first_report.title='Wi-Fi not working in Computer Lab 2'
WHERE second_report.title='Internet connection unavailable';

INSERT INTO complaint_updates (complaint_id,status,remark,updated_by,updated_at)
SELECT id,status,'Complaint submitted and AI analysis completed.','System',created_at FROM complaints WHERE id >= 1;
