# SOC 2 Compliance Guide

## Overview

Service Organization Control 2 (SOC 2) is an auditing standard developed by the American Institute of CPAs (AICPA) for service providers storing customer data in the cloud. This guide explains how the GeniusTechSpace API Contracts support SOC 2 compliance across the five Trust Services Criteria.

## SOC 2 Trust Services Criteria

SOC 2 compliance is based on five Trust Services Criteria (TSC):

1. **Security** - Protection against unauthorized access
2. **Availability** - System availability for operation and use
3. **Processing Integrity** - System processing is complete, valid, accurate, timely, and authorized
4. **Confidentiality** - Information designated as confidential is protected
5. **Privacy** - Personal information is collected, used, retained, disclosed, and disposed of per commitments

## 1. Security (CC)

### CC6.1 - Logical and Physical Access Controls

The API contracts enforce logical access controls through tenant context and authentication:

```protobuf
message TenantContext {
  string tenant_id = 1;      // Required - isolates customer data
  string organization_id = 2;
  string workspace_id = 3;
}
```

Implementation:

```rust
async fn enforce_access_controls(
    user_id: &str,
    tenant_id: &str,
    resource_id: &str,
    action: Action,
) -> Result<bool, Error> {
    // Verify user belongs to tenant
    if !verify_user_tenant_membership(user_id, tenant_id).await? {
        log_audit_event(AuditLogEntry {
            action: "ACCESS_DENIED_WRONG_TENANT".to_string(),
            user_id: user_id.to_string(),
            category: AuditCategory::Security,
            severity: ErrorSeverity::Warning,
            metadata: hashmap!{
                "soc2_control".to_string() => "CC6.1".to_string(),
                "reason".to_string() => "user_not_in_tenant".to_string(),
            },
            ..Default::default()
        }).await?;
        
        return Ok(false);
    }
    
    // Check role-based permissions
    let has_permission = check_rbac_permission(user_id, resource_id, action).await?;
    
    // Log access decision
    log_audit_event(AuditLogEntry {
        action: format!("ACCESS_{}", if has_permission { "GRANTED" } else { "DENIED" }),
        user_id: user_id.to_string(),
        resource_id: resource_id.to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "soc2_control".to_string() => "CC6.1".to_string(),
            "action".to_string() => format!("{:?}", action),
        },
        ..Default::default()
    }).await?;
    
    Ok(has_permission)
}
```

### CC6.6 - Logical Access Controls - Audit Logging

All access attempts and security events must be logged:

```protobuf
message AuditLogEntry {
  string event_id = 1;
  google.protobuf.Timestamp timestamp = 2;
  TenantContext tenant_context = 3;
  string user_id = 4;
  string action = 5;
  string resource_type = 6;
  string resource_id = 7;
  AuditCategory category = 8;
  string ip_address = 9;
  string user_agent = 10;
  map<string, string> metadata = 11;
}
```

### CC6.7 - System Monitoring

Implement continuous monitoring for security events:

```rust
async fn monitor_security_events(tenant_id: &str) -> Result<SecurityReport, Error> {
    let time_window = Duration::hours(1);
    let logs = query_recent_audit_logs(tenant_id, time_window).await?;
    
    // Detect anomalies
    let failed_logins = count_failed_authentications(&logs);
    let unusual_access = detect_unusual_access_patterns(&logs);
    let privilege_escalations = detect_privilege_changes(&logs);
    
    // Log monitoring activity
    log_audit_event(AuditLogEntry {
        action: "SECURITY_MONITORING_COMPLETED".to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "soc2_control".to_string() => "CC6.7".to_string(),
            "failed_logins".to_string() => failed_logins.to_string(),
            "anomalies_detected".to_string() => unusual_access.len().to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(SecurityReport {
        failed_logins,
        unusual_access,
        privilege_escalations,
        timestamp: Utc::now(),
    })
}
```

### CC7.2 - System Security - Encryption

Enforce encryption for data at rest and in transit:

```protobuf
message ComplianceSettings {
  bool soc2_enabled = 3;
  bool encryption_at_rest_required = 7;
  bool encryption_in_transit_required = 8;
}
```

```rust
// Enforce TLS 1.3 for all connections
fn configure_tls() -> tonic::transport::ServerTlsConfig {
    ServerTlsConfig::new()
        .identity(load_identity())
        .min_tls_version(tonic::transport::TlsVersion::Tls13)
        .with_native_roots()
}

// Encrypt sensitive data at rest
async fn store_sensitive_data(
    tenant_info: &TenantInfo,
    data: &SensitiveData,
) -> Result<(), Error> {
    if tenant_info.compliance.as_ref().map(|c| c.soc2_enabled).unwrap_or(false) {
        // Verify encryption is enabled
        if !tenant_info.compliance.as_ref().map(|c| c.encryption_at_rest_required).unwrap_or(false) {
            return Err(Error::ComplianceViolation("SOC 2 requires encryption at rest".to_string()));
        }
        
        // Encrypt data using AES-256
        let encrypted_data = encrypt_aes_256(data, &get_encryption_key())?;
        
        // Store encrypted data
        store_data(&encrypted_data).await?;
        
        // Log encryption
        log_audit_event(AuditLogEntry {
            action: "DATA_ENCRYPTED".to_string(),
            category: AuditCategory::DataAccess,
            metadata: hashmap!{
                "soc2_control".to_string() => "CC7.2".to_string(),
                "encryption_algorithm".to_string() => "AES-256".to_string(),
            },
            ..Default::default()
        }).await?;
    }
    
    Ok(())
}
```

## 2. Availability (A)

### A1.2 - System Availability

Implement health checks and monitoring:

```protobuf
// Standard health check service
service HealthService {
  rpc Check(HealthCheckRequest) returns (HealthCheckResponse);
  rpc Watch(HealthCheckRequest) returns (stream HealthCheckResponse);
}

message HealthCheckResponse {
  enum ServingStatus {
    UNKNOWN = 0;
    SERVING = 1;
    NOT_SERVING = 2;
    SERVICE_UNKNOWN = 3;
  }
  ServingStatus status = 1;
  map<string, string> metadata = 2;
}
```

Implementation:

```rust
async fn health_check(service: &str) -> HealthCheckResponse {
    let status = check_service_health(service).await;
    
    // Log health check
    log_audit_event(AuditLogEntry {
        action: "HEALTH_CHECK_PERFORMED".to_string(),
        resource_type: "SERVICE".to_string(),
        resource_id: service.to_string(),
        metadata: hashmap!{
            "soc2_control".to_string() => "A1.2".to_string(),
            "status".to_string() => format!("{:?}", status),
        },
        ..Default::default()
    }).await.ok();
    
    HealthCheckResponse {
        status,
        metadata: hashmap!{
            "version".to_string() => env!("CARGO_PKG_VERSION").to_string(),
            "timestamp".to_string() => Utc::now().to_rfc3339(),
        },
    }
}
```

### A1.3 - System Availability - Backups

Implement regular backups and recovery procedures:

```rust
async fn perform_backup(tenant_id: &str) -> Result<BackupInfo, Error> {
    // Create backup
    let backup_id = generate_backup_id();
    let backup_data = collect_tenant_data(tenant_id).await?;
    
    // Encrypt backup
    let encrypted_backup = encrypt_backup(&backup_data)?;
    
    // Store backup
    store_backup(tenant_id, &backup_id, &encrypted_backup).await?;
    
    // Verify backup integrity
    verify_backup_integrity(tenant_id, &backup_id).await?;
    
    // Log backup completion
    log_audit_event(AuditLogEntry {
        action: "BACKUP_COMPLETED".to_string(),
        category: AuditCategory::System,
        metadata: hashmap!{
            "soc2_control".to_string() => "A1.3".to_string(),
            "backup_id".to_string() => backup_id.clone(),
            "backup_size".to_string() => backup_data.len().to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(BackupInfo {
        backup_id,
        timestamp: Utc::now(),
        size_bytes: backup_data.len(),
    })
}
```

## 3. Processing Integrity (PI)

### PI1.1 - Processing Integrity - Input Validation

Use validation rules to ensure data integrity:

```protobuf
import "validate/validate.proto";

message UserProfile {
  string email = 1 [(validate.rules).string.email = true];
  string phone = 2 [(validate.rules).string.pattern = "^\\+?[1-9]\\d{1,14}$"];
  string name = 3 [(validate.rules).string = {min_len: 1, max_len: 100}];
  int32 age = 4 [(validate.rules).int32 = {gte: 0, lte: 150}];
}
```

### PI1.4 - Processing Integrity - Error Handling

Implement standardized error handling:

```protobuf
message ErrorResponse {
  string code = 1;
  string message = 2;
  ErrorCategory category = 3;
  ErrorSeverity severity = 4;
  repeated FieldViolation fields = 5;
  RetryInfo retry_info = 6;
}

enum ErrorCategory {
  ERROR_CATEGORY_UNSPECIFIED = 0;
  ERROR_CATEGORY_AUTHENTICATION = 1;
  ERROR_CATEGORY_AUTHORIZATION = 2;
  ERROR_CATEGORY_VALIDATION = 3;
  ERROR_CATEGORY_NOT_FOUND = 4;
  ERROR_CATEGORY_CONFLICT = 5;
  ERROR_CATEGORY_RATE_LIMIT = 6;
  ERROR_CATEGORY_INTERNAL = 7;
  ERROR_CATEGORY_EXTERNAL = 8;
}
```

```rust
async fn process_request_with_integrity<T, R>(
    request: T,
    processor: impl Fn(T) -> Result<R, Error>,
) -> Result<R, Error> {
    // Log request received
    log_audit_event(AuditLogEntry {
        action: "REQUEST_RECEIVED".to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "PI1.4".to_string(),
        },
        ..Default::default()
    }).await?;
    
    // Validate input
    validate_request(&request)?;
    
    // Process request
    let result = processor(request);
    
    // Log outcome
    let success = result.is_ok();
    log_audit_event(AuditLogEntry {
        action: format!("REQUEST_{}", if success { "SUCCESS" } else { "FAILED" }),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "PI1.4".to_string(),
        },
        ..Default::default()
    }).await?;
    
    result
}
```

### PI1.5 - Processing Integrity - Data Validation

Verify data integrity throughout processing:

```rust
async fn process_with_verification(data: &ProcessingData) -> Result<ProcessedData, Error> {
    // Calculate input hash
    let input_hash = calculate_hash(data);
    
    // Process data
    let processed = process_data(data).await?;
    
    // Verify no corruption occurred
    verify_processing_integrity(&input_hash, &processed)?;
    
    // Log verification
    log_audit_event(AuditLogEntry {
        action: "PROCESSING_INTEGRITY_VERIFIED".to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "PI1.5".to_string(),
            "input_hash".to_string() => input_hash,
        },
        ..Default::default()
    }).await?;
    
    Ok(processed)
}
```

## 4. Confidentiality (C)

### C1.1 - Confidentiality - Access Controls

Implement strict access controls for confidential information:

```rust
#[derive(Debug, Clone)]
enum DataClassification {
    Public,
    Internal,
    Confidential,
    Restricted,
}

async fn access_confidential_data(
    user_id: &str,
    data_id: &str,
    classification: DataClassification,
) -> Result<Data, Error> {
    // Verify user clearance level
    let user_clearance = get_user_clearance(user_id).await?;
    
    let can_access = match classification {
        DataClassification::Public => true,
        DataClassification::Internal => user_clearance >= ClearanceLevel::Internal,
        DataClassification::Confidential => user_clearance >= ClearanceLevel::Confidential,
        DataClassification::Restricted => user_clearance >= ClearanceLevel::Restricted,
    };
    
    if !can_access {
        log_audit_event(AuditLogEntry {
            action: "CONFIDENTIAL_ACCESS_DENIED".to_string(),
            user_id: user_id.to_string(),
            resource_id: data_id.to_string(),
            category: AuditCategory::Security,
            severity: ErrorSeverity::Warning,
            metadata: hashmap!{
                "soc2_control".to_string() => "C1.1".to_string(),
                "classification".to_string() => format!("{:?}", classification),
                "user_clearance".to_string() => format!("{:?}", user_clearance),
            },
            ..Default::default()
        }).await?;
        
        return Err(Error::InsufficientClearance);
    }
    
    // Log successful access
    log_audit_event(AuditLogEntry {
        action: "CONFIDENTIAL_DATA_ACCESSED".to_string(),
        user_id: user_id.to_string(),
        resource_id: data_id.to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "C1.1".to_string(),
            "classification".to_string() => format!("{:?}", classification),
        },
        ..Default::default()
    }).await?;
    
    get_data(data_id).await
}
```

### C1.2 - Confidentiality - Data Disposal

Implement secure data disposal:

```rust
async fn dispose_confidential_data(
    tenant_id: &str,
    data_id: &str,
) -> Result<(), Error> {
    // Get data classification
    let classification = get_data_classification(data_id).await?;
    
    // For confidential data, use secure deletion
    if matches!(classification, DataClassification::Confidential | DataClassification::Restricted) {
        // Overwrite data multiple times before deletion
        secure_delete(data_id).await?;
    } else {
        // Standard deletion
        delete_data(data_id).await?;
    }
    
    // Log disposal
    log_audit_event(AuditLogEntry {
        action: "CONFIDENTIAL_DATA_DISPOSED".to_string(),
        resource_id: data_id.to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "C1.2".to_string(),
            "classification".to_string() => format!("{:?}", classification),
            "disposal_method".to_string() => "secure_delete".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

## 5. Privacy (P)

### P1.1 - Privacy Notice

Document privacy practices in compliance settings:

```protobuf
message PrivacySettings {
  string privacy_policy_url = 1;
  string privacy_policy_version = 2;
  google.protobuf.Timestamp privacy_policy_effective_date = 3;
  repeated string data_collection_purposes = 4;
  repeated string data_sharing_parties = 5;
  int32 data_retention_days = 6;
}
```

### P3.2 - Privacy - Choice and Consent

Track user consent for data processing:

```rust
#[derive(Debug, Clone)]
struct UserConsent {
    user_id: String,
    consent_type: ConsentType,
    granted: bool,
    timestamp: DateTime<Utc>,
    ip_address: String,
}

async fn record_user_consent(consent: &UserConsent) -> Result<(), Error> {
    // Store consent record
    store_consent(consent).await?;
    
    // Log consent decision
    log_audit_event(AuditLogEntry {
        action: format!("CONSENT_{}", if consent.granted { "GRANTED" } else { "REVOKED" }),
        user_id: consent.user_id.clone(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "soc2_control".to_string() => "P3.2".to_string(),
            "consent_type".to_string() => format!("{:?}", consent.consent_type),
            "ip_address".to_string() => consent.ip_address.clone(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

### P4.3 - Privacy - Data Retention and Disposal

Enforce privacy-compliant data retention:

```rust
async fn enforce_privacy_retention(tenant_id: &str) -> Result<(), Error> {
    let tenant_info = get_tenant_info(tenant_id).await?;
    
    if let Some(compliance) = &tenant_info.compliance {
        if compliance.soc2_enabled {
            let retention_days = compliance.data_retention_days;
            let cutoff_date = Utc::now() - Duration::days(retention_days as i64);
            
            // Delete personal data older than retention period
            let deleted_count = delete_old_personal_data(tenant_id, cutoff_date).await?;
            
            // Log retention enforcement
            log_audit_event(AuditLogEntry {
                action: "PRIVACY_RETENTION_ENFORCED".to_string(),
                category: AuditCategory::DataAccess,
                metadata: hashmap!{
                    "soc2_control".to_string() => "P4.3".to_string(),
                    "retention_days".to_string() => retention_days.to_string(),
                    "records_deleted".to_string() => deleted_count.to_string(),
                },
                ..Default::default()
            }).await?;
        }
    }
    
    Ok(())
}
```

## Implementation Checklist

When implementing SOC 2-compliant services:

**Security (CC):**
- [ ] Tenant-based access controls implemented
- [ ] Role-based access control (RBAC) enforced
- [ ] All access attempts logged
- [ ] TLS 1.3 for all connections
- [ ] Data encrypted at rest (AES-256)
- [ ] Security monitoring and alerting
- [ ] Regular security assessments

**Availability (A):**
- [ ] Health check endpoints implemented
- [ ] Automated backups configured
- [ ] Disaster recovery procedures documented
- [ ] High availability architecture
- [ ] Monitoring and alerting for downtime
- [ ] Capacity planning processes

**Processing Integrity (PI):**
- [ ] Input validation on all requests
- [ ] Standardized error handling
- [ ] Data integrity verification
- [ ] Transaction logging
- [ ] Change management procedures
- [ ] Automated testing

**Confidentiality (C):**
- [ ] Data classification system
- [ ] Confidential data encryption
- [ ] Access controls based on classification
- [ ] Secure data disposal procedures
- [ ] Confidentiality agreements with staff
- [ ] Regular access reviews

**Privacy (P):**
- [ ] Privacy policy documented
- [ ] User consent tracking
- [ ] Data retention policies
- [ ] User data access/export capabilities
- [ ] User data deletion capabilities
- [ ] Privacy impact assessments

## Configuration Example

```rust
// Example tenant configuration for SOC 2 compliance
let tenant_config = TenantInfo {
    tenant_id: "soc2-tenant-001".to_string(),
    compliance: Some(ComplianceSettings {
        gdpr_enabled: false,
        hipaa_enabled: false,
        soc2_enabled: true,
        pci_dss_enabled: false,
        data_residency: Some(DataResidency {
            allowed_regions: vec!["us-east-1".to_string(), "us-west-2".to_string()],
            prohibited_regions: vec![],
            primary_region: "us-east-1".to_string(),
        }),
        data_retention_days: 2555,  // ~7 years
        encryption_at_rest_required: true,
        encryption_in_transit_required: true,
    }),
    ..Default::default()
};
```

## Audit Evidence Collection

SOC 2 audits require evidence. The API contracts support evidence collection through:

```rust
async fn collect_audit_evidence(
    tenant_id: &str,
    control: &str,
    period: TimeRange,
) -> Result<AuditEvidence, Error> {
    // Query audit logs for specific control
    let logs = query_audit_logs_by_metadata(
        tenant_id,
        "soc2_control",
        control,
        period,
    ).await?;
    
    // Generate evidence report
    let evidence = AuditEvidence {
        control,
        period,
        total_events: logs.len(),
        sample_events: logs.iter().take(10).cloned().collect(),
        summary: generate_evidence_summary(&logs),
    };
    
    Ok(evidence)
}
```

## Resources

- [SOC 2 Official Framework](https://www.aicpa.org/soc2)
- [Trust Services Criteria](https://www.aicpa.org/content/dam/aicpa/interestareas/frc/assuranceadvisoryservices/downloadabledocuments/trust-services-criteria.pdf)
- [SOC 2 Compliance Guide](https://www.imperva.com/learn/data-security/soc-2-compliance/)

## Contact

For SOC 2 compliance questions:
- Email: compliance@geniustechspace.com
- Audit inquiries: audit@geniustechspace.com
