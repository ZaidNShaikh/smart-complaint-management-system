package com.complaint.management;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity @Table(name="users") class User {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
 public String name;
 @Column(unique=true,nullable=false) public String email;
 @Column(nullable=false) public String password;
 public String role="USER";
 public LocalDateTime createdAt=LocalDateTime.now();
 public User(){} User(String n,String e,String p,String r){name=n;email=e;password=p;role=r;}
}

@Entity @Table(name="complaints") class Complaint {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
 @ManyToOne(optional=false) public User user;
 @Column(nullable=false) public String title;
 @Column(nullable=false,length=5000) public String description;
 public String location, detectedLocation, detectedTime;
 public boolean qualityPassed;
 @Column(length=1000) public String qualityMessage;
 @Column(length=500) public String missingInformation;
 public String category, urgency;
 public double categoryConfidence, urgencyConfidence;
 public int priorityScore;
 public String priorityLevel, department, status="PENDING", aiReason;
 public String duplicateComplaintId;
 public double similarityScore;
 public LocalDateTime createdAt=LocalDateTime.now(), updatedAt=LocalDateTime.now();
 public Complaint(){}
}

@Entity @Table(name="complaint_updates") class ComplaintUpdate {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
 @ManyToOne(optional=false) public Complaint complaint;
 public String status;
 @Column(length=2000) public String remark;
 public String updatedBy;
 public LocalDateTime updatedAt=LocalDateTime.now();
 public ComplaintUpdate(){}
 ComplaintUpdate(Complaint c,String s,String r,String by){complaint=c;status=s;remark=r;updatedBy=by;}
}

@Entity @Table(name="reviews",uniqueConstraints=@UniqueConstraint(columnNames={"complaint_id"})) class Review {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
 @OneToOne(optional=false) @JoinColumn(name="complaint_id") public Complaint complaint;
 @ManyToOne(optional=false) public User user;
 public int rating;
 @Column(length=2000) public String comment;
 public LocalDateTime createdAt=LocalDateTime.now();
 public Review(){}
}

@Entity @Table(name="duplicate_complaints") class DuplicateRecord {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
 public Long complaintId;
 public Long similarComplaintId;
 public double similarityScore;
 public LocalDateTime createdAt=LocalDateTime.now();
 public DuplicateRecord(){}
 DuplicateRecord(Long c,Long s,double score){complaintId=c;similarComplaintId=s;similarityScore=score;}
}
