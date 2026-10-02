package com.complaint.management;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.*;

interface UserRepository extends JpaRepository<User,Long>{Optional<User> findByEmail(String email);}
interface ComplaintRepository extends JpaRepository<Complaint,Long>{List<Complaint> findByUserIdOrderByCreatedAtDesc(Long userId);List<Complaint> findByCreatedAtBetweenAndIdNot(LocalDateTime start,LocalDateTime end,Long id);List<Complaint> findByDuplicateComplaintId(String duplicateComplaintId);}
interface UpdateRepository extends JpaRepository<ComplaintUpdate,Long>{List<ComplaintUpdate> findByComplaintIdOrderByUpdatedAtAsc(Long id);}
interface ReviewRepository extends JpaRepository<Review,Long>{Optional<Review> findByComplaintId(Long id);}
interface DuplicateRepository extends JpaRepository<DuplicateRecord,Long>{void deleteByComplaintIdOrSimilarComplaintId(Long complaintId,Long similarComplaintId);}
