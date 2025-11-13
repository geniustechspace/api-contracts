# HIPAA Compliance Guide

## Overview

The Health Insurance Portability and Accountability Act (HIPAA) is a US federal law that establishes standards for protecting sensitive patient health information. This guide explains how the GeniusTechSpace API Contracts support HIPAA compliance for healthcare applications.

## Key HIPAA Requirements

### 1. Protected Health Information (PHI)

HIPAA protects 18 types of identifiers that constitute Protected Health Information (PHI). The API contracts support PHI protection through:

```protobuf
message ComplianceSettings {
  bool hipaa_enabled = 2;
  bool encryption_at_rest_required = 7;
  bool encryption_in_transit_required = 8;
  int32 data_retention_days = 6;
}
```

**PHI Examples:**
- Names
- Dates (birth, admission, discharge, death)
- Telephone/fax numbers
- Email addresses
- Social Security numbers
- Medical record numbers
- Health plan beneficiary numbers
- Account numbers
- Certificate/license numbers
- Device identifiers and serial numbers
- Web URLs
- IP addresses
- Biometric identifiers
- Full-face photos
- Any unique identifying number or code

### 2. Administrative Safeguards

#### Access Control (§164.308(a)(4))

Implement role-based access control with comprehensive audit logging:

```rust
async fn check_phi_access(
    user_id: &str,
    patient_id: &str,
    access_type: AccessType,
) -> Result<bool, Error> {
    // Verify user has appropriate role
    let user_roles = get_user_roles(user_id).await?;
    
    // Check if user has permission to access this patient's PHI
    let has_access = match access_type {
        AccessType::Read => user_roles.can_read_phi(),
        AccessType::Write => user_roles.can_write_phi(),
        AccessType::Delete => user_roles.can_delete_phi(),
    };
    
    // Log the access attempt
    log_audit_event(AuditLogEntry {
        action: format!("PHI_ACCESS_{}", access_type.as_str()),
        user_id: user_id.to_string(),
        resource_type: "PATIENT_RECORD".to_string(),
        resource_id: patient_id.to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "access_granted".to_string() => has_access.to_string(),
            "hipaa_safeguard".to_string() => "164.308(a)(4)".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(has_access)
}
```

#### Audit Controls (§164.312(b))

HIPAA requires audit trails for all PHI access. Use comprehensive audit logging:

```protobuf
message AuditLogEntry {
  string event_id = 1;
  google.protobuf.Timestamp timestamp = 2;
  TenantContext tenant_context = 3;
  string user_id = 4;
  string action = 5;  // e.g., "PHI_ACCESSED", "PHI_MODIFIED", "PHI_DELETED"
  string resource_type = 6;  // e.g., "PATIENT_RECORD"
  string resource_id = 7;
  AuditCategory category = 8;
  string ip_address = 9;
  string user_agent = 10;
  map<string, string> metadata = 11;
}
```

**Required audit events for HIPAA compliance:**
- Every access to PHI (read, write, delete)
- User authentication and logout
- Failed access attempts
- Changes to access controls
- Security configuration changes
- System administrator activities
- Backup and restore operations

#### Security Incident Procedures (§164.308(a)(6))

Implement incident detection and response:

```rust
async fn detect_security_incident(
    tenant_id: &str,
    incident: &SecurityIncident,
) -> Result<(), Error> {
    // Log the security incident
    log_audit_event(AuditLogEntry {
        action: "SECURITY_INCIDENT_DETECTED".to_string(),
        category: AuditCategory::Security,
        severity: ErrorSeverity::Critical,
        metadata: hashmap!{
            "incident_type".to_string() => incident.incident_type.clone(),
            "affected_phi".to_string() => incident.phi_affected.to_string(),
            "hipaa_requirement".to_string() => "164.308(a)(6)".to_string(),
        },
        ..Default::default()
    }).await?;
    
    // If PHI is potentially affected, trigger breach protocol
    if incident.phi_affected {
        trigger_breach_notification(tenant_id, incident).await?;
    }
    
    Ok(())
}
```

### 3. Physical Safeguards

While API contracts operate at the application layer, they support physical safeguard requirements through:

#### Facility Access Controls (§164.310(a))

Log all access to systems handling PHI:

```rust
async fn log_facility_access(
    user_id: &str,
    facility_id: &str,
    access_granted: bool,
) -> Result<(), Error> {
    log_audit_event(AuditLogEntry {
        action: "FACILITY_ACCESS_ATTEMPT".to_string(),
        user_id: user_id.to_string(),
        resource_type: "FACILITY".to_string(),
        resource_id: facility_id.to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "access_granted".to_string() => access_granted.to_string(),
            "hipaa_requirement".to_string() => "164.310(a)".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

### 4. Technical Safeguards

#### Access Control (§164.312(a))

Implement unique user identification and emergency access procedures:

```protobuf
message UserContext {
  string user_id = 1;  // Unique identifier - required
  string session_id = 2;
  repeated string roles = 3;
  bool emergency_access = 4;  // Break-glass access
}
```

```rust
async fn authenticate_user(
    credentials: &Credentials,
    emergency: bool,
) -> Result<UserSession, Error> {
    let session = if emergency {
        // Emergency access - requires special logging
        log_audit_event(AuditLogEntry {
            action: "EMERGENCY_ACCESS_GRANTED".to_string(),
            user_id: credentials.user_id.clone(),
            category: AuditCategory::Security,
            severity: ErrorSeverity::High,
            metadata: hashmap!{
                "reason".to_string() => credentials.emergency_reason.clone(),
                "hipaa_requirement".to_string() => "164.312(a)(2)(ii)".to_string(),
            },
            ..Default::default()
        }).await?;
        
        create_emergency_session(credentials).await?
    } else {
        create_normal_session(credentials).await?
    };
    
    Ok(session)
}
```

#### Audit Controls (§164.312(b))

Record and examine activity in systems containing PHI:

```rust
async fn examine_phi_access_patterns(
    tenant_id: &str,
    timeframe: TimeRange,
) -> Result<AuditReport, Error> {
    // Query audit logs for PHI access
    let logs = query_audit_logs_by_category(
        tenant_id,
        AuditCategory::DataAccess,
        timeframe,
    ).await?;
    
    // Analyze for suspicious patterns
    let report = AuditReport {
        total_accesses: logs.len(),
        unique_users: count_unique_users(&logs),
        unusual_access_times: detect_unusual_times(&logs),
        high_volume_users: detect_high_volume(&logs),
        failed_access_attempts: count_failed_attempts(&logs),
    };
    
    // Log the examination
    log_audit_event(AuditLogEntry {
        action: "AUDIT_EXAMINATION_COMPLETED".to_string(),
        metadata: hashmap!{
            "records_examined".to_string() => logs.len().to_string(),
            "hipaa_requirement".to_string() => "164.312(b)".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(report)
}
```

#### Integrity Controls (§164.312(c))

Ensure PHI is not improperly altered or destroyed:

```rust
async fn verify_phi_integrity(
    record_id: &str,
) -> Result<IntegrityCheck, Error> {
    // Retrieve record and its hash
    let record = get_phi_record(record_id).await?;
    let stored_hash = get_record_hash(record_id).await?;
    
    // Calculate current hash
    let current_hash = calculate_hash(&record);
    
    // Compare hashes
    let integrity_valid = stored_hash == current_hash;
    
    // Log integrity check
    log_audit_event(AuditLogEntry {
        action: "PHI_INTEGRITY_CHECK".to_string(),
        resource_type: "PHI_RECORD".to_string(),
        resource_id: record_id.to_string(),
        metadata: hashmap!{
            "integrity_valid".to_string() => integrity_valid.to_string(),
            "hipaa_requirement".to_string() => "164.312(c)".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(IntegrityCheck {
        record_id: record_id.to_string(),
        valid: integrity_valid,
        checked_at: Utc::now(),
    })
}
```

#### Transmission Security (§164.312(e))

Protect PHI during transmission:

```protobuf
message ComplianceSettings {
  bool encryption_in_transit_required = 8;  // Must be true for HIPAA
}
```

```rust
// All connections must use TLS 1.2 or higher
fn enforce_transmission_security() -> tonic::transport::ServerTlsConfig {
    ServerTlsConfig::new()
        .identity(load_identity())
        .min_tls_version(tonic::transport::TlsVersion::Tls12)
        // Require client authentication
        .client_auth(ClientAuth::Required)
}
```

### 5. Minimum Necessary Rule (§164.502(b))

Limit PHI access to minimum necessary for the intended purpose:

```rust
#[derive(Debug, Clone)]
enum PhiAccessLevel {
    Minimal,      // Name, DOB only
    Standard,     // Add contact info, medical record number
    Clinical,     // Add diagnoses, medications, treatments
    Full,         // All PHI
}

async fn get_patient_data(
    user_id: &str,
    patient_id: &str,
    access_level: PhiAccessLevel,
) -> Result<PatientData, Error> {
    // Determine what data user needs
    let data = match access_level {
        PhiAccessLevel::Minimal => {
            // Billing staff might only need name and DOB
            PatientData {
                name: get_patient_name(patient_id).await?,
                date_of_birth: get_patient_dob(patient_id).await?,
                ..Default::default()
            }
        }
        PhiAccessLevel::Clinical => {
            // Clinicians need medical information
            get_clinical_data(patient_id).await?
        }
        PhiAccessLevel::Full => {
            // Limited to specific roles (e.g., primary care provider)
            get_full_patient_record(patient_id).await?
        }
        _ => get_standard_data(patient_id).await?,
    };
    
    // Log access with level
    log_audit_event(AuditLogEntry {
        action: "PHI_ACCESSED".to_string(),
        user_id: user_id.to_string(),
        resource_id: patient_id.to_string(),
        metadata: hashmap!{
            "access_level".to_string() => format!("{:?}", access_level),
            "hipaa_rule".to_string() => "minimum_necessary".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(data)
}
```

### 6. Breach Notification Rule

#### Breach Detection

Implement monitoring to detect unauthorized PHI access:

```rust
async fn monitor_phi_breach(tenant_id: &str) -> Result<(), Error> {
    // Get recent audit logs
    let logs = get_recent_phi_access(tenant_id).await?;
    
    // Check for breach indicators
    for log in logs {
        let is_breach = check_breach_indicators(&log);
        
        if is_breach {
            // Record potential breach
            log_audit_event(AuditLogEntry {
                action: "POTENTIAL_PHI_BREACH_DETECTED".to_string(),
                category: AuditCategory::Security,
                severity: ErrorSeverity::Critical,
                metadata: hashmap!{
                    "original_event_id".to_string() => log.event_id,
                    "breach_type".to_string() => "unauthorized_access".to_string(),
                },
                ..Default::default()
            }).await?;
            
            // Trigger breach assessment
            trigger_breach_assessment(tenant_id, &log).await?;
        }
    }
    
    Ok(())
}
```

#### Breach Notification (Within 60 days)

Track breach notifications:

```rust
async fn notify_breach(
    tenant_id: &str,
    affected_individuals: Vec<String>,
    breach_details: &BreachDetails,
) -> Result<(), Error> {
    // Record breach notification
    log_audit_event(AuditLogEntry {
        action: "BREACH_NOTIFICATION_INITIATED".to_string(),
        category: AuditCategory::Security,
        severity: ErrorSeverity::Critical,
        metadata: hashmap!{
            "affected_count".to_string() => affected_individuals.len().to_string(),
            "breach_date".to_string() => breach_details.date.to_rfc3339(),
            "discovery_date".to_string() => breach_details.discovery_date.to_rfc3339(),
            "notification_method".to_string() => "email_and_mail".to_string(),
            "hhs_notification_required".to_string() => (affected_individuals.len() >= 500).to_string(),
        },
        ..Default::default()
    }).await?;
    
    // Send notifications to affected individuals
    for individual_id in affected_individuals {
        send_breach_notification(&individual_id, breach_details).await?;
    }
    
    // If 500+ individuals affected, notify HHS and media
    if affected_individuals.len() >= 500 {
        notify_hhs(tenant_id, breach_details).await?;
        notify_media(tenant_id, breach_details).await?;
    }
    
    Ok(())
}
```

### 7. Data Retention

HIPAA requires retention of PHI for 6 years from creation or last use:

```rust
async fn enforce_hipaa_retention(tenant_id: &str) -> Result<(), Error> {
    let tenant_info = get_tenant_info(tenant_id).await?;
    
    if let Some(compliance) = &tenant_info.compliance {
        if compliance.hipaa_enabled {
            // HIPAA requires minimum 6 years (2190 days)
            let retention_days = compliance.data_retention_days.max(2190);
            let cutoff_date = Utc::now() - Duration::days(retention_days as i64);
            
            // Delete PHI older than retention period
            // Note: Audit logs must be kept longer (typically 7 years)
            delete_old_phi_records(tenant_id, cutoff_date).await?;
            
            // Log retention enforcement
            log_audit_event(AuditLogEntry {
                action: "HIPAA_RETENTION_ENFORCED".to_string(),
                metadata: hashmap!{
                    "retention_days".to_string() => retention_days.to_string(),
                    "cutoff_date".to_string() => cutoff_date.to_rfc3339(),
                },
                ..Default::default()
            }).await?;
        }
    }
    
    Ok(())
}
```

## Implementation Checklist

When implementing HIPAA-compliant services:

- [ ] **Encryption in Transit**: TLS 1.2+ for all connections
- [ ] **Encryption at Rest**: AES-256 for all PHI storage
- [ ] **Unique User IDs**: Every user has unique identifier
- [ ] **Automatic Logoff**: Implement session timeouts
- [ ] **Audit Controls**: Log all PHI access and modifications
- [ ] **Access Control**: Implement role-based access control
- [ ] **Minimum Necessary**: Limit data access to minimum required
- [ ] **Emergency Access**: Support break-glass procedures
- [ ] **Integrity Controls**: Verify PHI not altered improperly
- [ ] **Authentication**: Strong password requirements
- [ ] **Transmission Security**: Encrypt all PHI transmissions
- [ ] **Data Backup**: Regular backups with encryption
- [ ] **Disaster Recovery**: Test recovery procedures
- [ ] **Audit Log Retention**: Keep logs for 7+ years
- [ ] **PHI Retention**: Retain PHI for 6+ years
- [ ] **Breach Detection**: Monitor for unauthorized access
- [ ] **Incident Response**: Documented procedures

## Configuration Example

```rust
// Example tenant configuration for HIPAA compliance
let tenant_config = TenantInfo {
    tenant_id: "healthcare-tenant-001".to_string(),
    compliance: Some(ComplianceSettings {
        gdpr_enabled: false,
        hipaa_enabled: true,
        soc2_enabled: true,
        pci_dss_enabled: false,
        data_residency: Some(DataResidency {
            allowed_regions: vec!["us-east-1".to_string(), "us-west-2".to_string()],
            prohibited_regions: vec![],  // No specific prohibitions
            primary_region: "us-east-1".to_string(),
        }),
        data_retention_days: 2190,  // 6 years minimum for HIPAA
        encryption_at_rest_required: true,   // Required
        encryption_in_transit_required: true,  // Required
    }),
    ..Default::default()
};
```

## Testing HIPAA Compliance

```rust
#[cfg(test)]
mod hipaa_tests {
    use super::*;
    
    #[tokio::test]
    async fn test_phi_access_logging() {
        let tenant = create_hipaa_tenant().await;
        let patient = create_test_patient(&tenant).await;
        let user = create_test_user(&tenant).await;
        
        // Access patient PHI
        let data = get_patient_data(&user.user_id, &patient.patient_id, PhiAccessLevel::Clinical).await.unwrap();
        
        // Verify audit log was created
        let logs = query_audit_logs(&tenant.tenant_id, &user.user_id).await.unwrap();
        assert!(logs.iter().any(|log| {
            log.action == "PHI_ACCESSED" && log.resource_id == patient.patient_id
        }));
    }
    
    #[tokio::test]
    async fn test_minimum_necessary_access() {
        let tenant = create_hipaa_tenant().await;
        let patient = create_test_patient(&tenant).await;
        
        // Minimal access should only return name and DOB
        let minimal_data = get_patient_data("user-1", &patient.patient_id, PhiAccessLevel::Minimal).await.unwrap();
        assert!(minimal_data.name.is_some());
        assert!(minimal_data.date_of_birth.is_some());
        assert!(minimal_data.diagnoses.is_empty());
        
        // Clinical access should include medical information
        let clinical_data = get_patient_data("user-1", &patient.patient_id, PhiAccessLevel::Clinical).await.unwrap();
        assert!(!clinical_data.diagnoses.is_empty());
    }
    
    #[tokio::test]
    async fn test_emergency_access() {
        let tenant = create_hipaa_tenant().await;
        let credentials = Credentials {
            user_id: "user-1".to_string(),
            emergency_reason: "Patient life-threatening emergency".to_string(),
            ..Default::default()
        };
        
        // Grant emergency access
        let session = authenticate_user(&credentials, true).await.unwrap();
        assert!(session.emergency_access);
        
        // Verify emergency access was logged
        let logs = query_audit_logs(&tenant.tenant_id, "user-1").await.unwrap();
        assert!(logs.iter().any(|log| log.action == "EMERGENCY_ACCESS_GRANTED"));
    }
    
    #[tokio::test]
    async fn test_phi_integrity() {
        let tenant = create_hipaa_tenant().await;
        let record = create_phi_record(&tenant).await;
        
        // Verify integrity
        let check = verify_phi_integrity(&record.record_id).await.unwrap();
        assert!(check.valid);
        
        // Tamper with record
        tamper_with_record(&record.record_id).await;
        
        // Integrity check should fail
        let check = verify_phi_integrity(&record.record_id).await.unwrap();
        assert!(!check.valid);
    }
}
```

## Business Associate Agreements (BAA)

If your service processes PHI on behalf of covered entities, you must:

1. Sign a Business Associate Agreement (BAA)
2. Implement all required HIPAA safeguards
3. Report breaches to the covered entity
4. Make audit logs available for inspection
5. Return or destroy PHI at contract termination

## Resources

- [HIPAA Official Site](https://www.hhs.gov/hipaa/)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/)
- [HIPAA Privacy Rule](https://www.hhs.gov/hipaa/for-professionals/privacy/)
- [Breach Notification Rule](https://www.hhs.gov/hipaa/for-professionals/breach-notification/)
- [HIPAA Audit Protocol](https://www.hhs.gov/hipaa/for-professionals/compliance-enforcement/audit/)

## Contact

For HIPAA compliance questions:
- Email: compliance@geniustechspace.com
- Privacy Officer: privacy@geniustechspace.com
- Security: security@geniustechspace.com
