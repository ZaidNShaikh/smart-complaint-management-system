package com.complaint.management;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestClient;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@SpringBootApplication
public class ComplaintManagementApplication {
  public static void main(String[] args) { SpringApplication.run(ComplaintManagementApplication.class, args); }
  @Bean RestClient restClient(){ return RestClient.builder().build(); }
  @Bean BCryptPasswordEncoder passwordEncoder(){ return new BCryptPasswordEncoder(); }
}
