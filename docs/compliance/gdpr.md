# GDPR Compliance Guide

## Overview

The General Data Protection Regulation (GDPR) is a comprehensive data protection law that applies to organizations processing personal data of individuals in the European Union (EU) and European Economic Area (EEA). This guide explains how the GeniusTechSpace API Contracts support GDPR compliance.

## Key GDPR Requirements

### 1. Lawful Basis for Processing

GDPR requires a lawful basis for processing personal data (Article 6). The API contracts support tracking consent and legal basis through:

```protobuf
message ComplianceSettings {
  bool gdpr_enabled = 1;
  DataResidency data_residency = 5;
  int32 data_retention_days = 6;
  bool encryption_at_rest_required = 7;
  bool encryption_in_transit_required = 8;
}
```

### 2. Data Subject Rights

GDPR grants individuals specific rights regarding their personal data:

#### Right to Access (Article 15)
Services must be able to retrieve all personal data for a specific user. Use the tenant context to filter data:

```rust
// Example: Retrieve all user data
async fn get_user_data(tenant_id: &str, user_id: &str) -> Result<UserData, Error> {
    // Query all services with tenant and user context
    let audit_logs = query_audit_logs(tenant_id, user_id).await?;
    let profile = query_user_profile(tenant_id, user_id).await?;
    let activities = query_user_activities(tenant_id, user_id).await?;
    
    Ok(UserData {
        profile,
        audit_logs,
        activities,
    })
}
```

#### Right to Rectification (Article 16)
All update operations must be logged in audit trails:

```protobuf
message AuditLogEntry {
  string event_id = 1;
  google.protobuf.Timestamp timestamp = 2;
  TenantContext tenant_context = 3;
  string user_id = 4;
  string action = 5;  // e.g., "USER_DATA_UPDATED"
  string resource_type = 6;
  string resource_id = 7;
  map<string, string> metadata = 8;
}
```

#### Right to Erasure / Right to be Forgotten (Article 17)
Implement data deletion with comprehensive audit logging:

```rust
async fn delete_user_data(tenant_id: &str, user_id: &str, reason: &str) -> Result<(), Error> {
    // Log the deletion request
    log_audit_event(AuditLogEntry {
        action: "USER_DATA_DELETION_REQUESTED".to_string(),
        user_id: user_id.to_string(),
        metadata: hashmap!{
            "reason".to_string() => reason.to_string(),
            "gdpr_article".to_string() => "17".to_string(),
        },
        ..Default::default()
    }).await?;
    
    // Delete data across all services
    delete_user_profile(tenant_id, user_id).await?;
    delete_user_sessions(tenant_id, user_id).await?;
    anonymize_audit_logs(tenant_id, user_id).await?;
    
    // Log completion
    log_audit_event(AuditLogEntry {
        action: "USER_DATA_DELETED".to_string(),
        user_id: user_id.to_string(),
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

#### Right to Data Portability (Article 20)
Export user data in a structured, machine-readable format:

```rust
async fn export_user_data(tenant_id: &str, user_id: &str) -> Result<Vec<u8>, Error> {
    let user_data = get_user_data(tenant_id, user_id).await?;
    
    // Export as JSON (structured, commonly used, machine-readable)
    let json_data = serde_json::to_vec_pretty(&user_data)?;
    
    // Log the export
    log_audit_event(AuditLogEntry {
        action: "USER_DATA_EXPORTED".to_string(),
        user_id: user_id.to_string(),
        metadata: hashmap!{
            "format".to_string() => "json".to_string(),
            "gdpr_article".to_string() => "20".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(json_data)
}
```

### 3. Data Protection by Design and Default (Article 25)

The API contracts enforce data protection principles at the protocol level:

**Tenant Isolation**: Every request requires tenant context, ensuring data segregation:

```protobuf
message TenantContext {
  string tenant_id = 1;  // Required - ensures data isolation
  string organization_id = 2;
  string workspace_id = 3;
}
```

**Minimal Data Collection**: Use validation rules to limit data collection:

```protobuf
message UserProfile {
  string email = 1 [(validate.rules).string.email = true];  // Only valid emails
  string phone = 2;  // Optional - collect only if needed
  string name = 3 [(validate.rules).string.min_len = 1];
  // Do NOT collect unnecessary fields
}
```

**Encryption Requirements**: Configure encryption per tenant:

```protobuf
message ComplianceSettings {
  bool encryption_at_rest_required = 7;
  bool encryption_in_transit_required = 8;  // Should always be true
}
```

### 4. Data Processing Records (Article 30)

Maintain comprehensive audit logs for all data processing activities:

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

**Required audit events for GDPR compliance:**
- User authentication and authorization
- Data access (read operations)
- Data modifications (create, update, delete)
- Consent changes
- Data exports and deletions
- Configuration changes affecting data processing

### 5. Data Breach Notification (Article 33, 34)

When a breach occurs, use audit logs to:
1. Identify affected users
2. Determine what data was accessed
3. Generate breach notifications

```rust
async fn handle_data_breach(
    tenant_id: &str,
    breach_details: &BreachDetails,
) -> Result<Vec<String>, Error> {
    // Query audit logs to identify affected users
    let affected_users = query_audit_logs_by_timerange(
        tenant_id,
        breach_details.start_time,
        breach_details.end_time,
    ).await?;
    
    // Log the breach detection
    log_audit_event(AuditLogEntry {
        action: "DATA_BREACH_DETECTED".to_string(),
        category: AuditCategory::Security,
        severity: ErrorSeverity::Critical,
        metadata: hashmap!{
            "affected_users_count".to_string() => affected_users.len().to_string(),
            "breach_type".to_string() => breach_details.breach_type.clone(),
        },
        ..Default::default()
    }).await?;
    
    Ok(affected_users)
}
```

### 6. Data Residency (Article 44-50)

GDPR restricts data transfers outside the EU/EEA. Enforce data residency:

```protobuf
message DataResidency {
  repeated string allowed_regions = 1;  // e.g., ["eu-west-1", "eu-central-1"]
  repeated string prohibited_regions = 2;  // e.g., ["us-east-1", "ap-south-1"]
  string primary_region = 3;
}
```

Implementation example:

```rust
async fn store_user_data(
    tenant_info: &TenantInfo,
    user_data: &UserData,
) -> Result<(), Error> {
    // Check GDPR compliance settings
    if let Some(compliance) = &tenant_info.compliance {
        if compliance.gdpr_enabled {
            // Verify data residency
            if let Some(residency) = &compliance.data_residency {
                let current_region = get_current_region();
                
                // Ensure we're in an allowed region
                if !residency.allowed_regions.contains(&current_region) {
                    return Err(Error::DataResidencyViolation(
                        format!("Region {} not allowed for GDPR tenant", current_region)
                    ));
                }
                
                // Ensure we're not in a prohibited region
                if residency.prohibited_regions.contains(&current_region) {
                    return Err(Error::DataResidencyViolation(
                        format!("Region {} is prohibited for GDPR tenant", current_region)
                    ));
                }
            }
        }
    }
    
    // Store data
    store_data(user_data).await?;
    
    Ok(())
}
```

### 7. Data Retention (Article 5(1)(e))

Data must not be kept longer than necessary. Implement retention policies:

```rust
async fn enforce_data_retention(tenant_id: &str) -> Result<(), Error> {
    let tenant_info = get_tenant_info(tenant_id).await?;
    
    if let Some(compliance) = &tenant_info.compliance {
        let retention_days = compliance.data_retention_days;
        let cutoff_date = Utc::now() - Duration::days(retention_days as i64);
        
        // Delete data older than retention period
        delete_old_audit_logs(tenant_id, cutoff_date).await?;
        delete_old_sessions(tenant_id, cutoff_date).await?;
        
        // Log retention enforcement
        log_audit_event(AuditLogEntry {
            action: "DATA_RETENTION_ENFORCED".to_string(),
            metadata: hashmap!{
                "retention_days".to_string() => retention_days.to_string(),
                "cutoff_date".to_string() => cutoff_date.to_rfc3339(),
            },
            ..Default::default()
        }).await?;
    }
    
    Ok(())
}
```

## Implementation Checklist

When implementing GDPR-compliant services:

- [ ] **Tenant Context**: All requests include tenant context
- [ ] **Audit Logging**: All data access and modifications are logged
- [ ] **Data Minimization**: Collect only necessary data
- [ ] **Encryption**: TLS 1.3+ for transit, AES-256 for rest
- [ ] **Data Residency**: Enforce geographic restrictions
- [ ] **Retention Policies**: Implement automated data deletion
- [ ] **Right to Access**: API endpoint to export user data
- [ ] **Right to Erasure**: API endpoint to delete user data
- [ ] **Right to Rectification**: Audit trail for all updates
- [ ] **Right to Portability**: Export data in machine-readable format
- [ ] **Consent Management**: Track and honor user consent
- [ ] **Breach Detection**: Monitor and log security events
- [ ] **Data Processing Records**: Maintain audit logs for 7+ years

## Configuration Example

```rust
// Example tenant configuration for GDPR compliance
let tenant_config = TenantInfo {
    tenant_id: "tenant-eu-001".to_string(),
    compliance: Some(ComplianceSettings {
        gdpr_enabled: true,
        hipaa_enabled: false,
        soc2_enabled: true,
        pci_dss_enabled: false,
        data_residency: Some(DataResidency {
            allowed_regions: vec!["eu-west-1".to_string(), "eu-central-1".to_string()],
            prohibited_regions: vec!["us-east-1".to_string(), "ap-south-1".to_string()],
            primary_region: "eu-west-1".to_string(),
        }),
        data_retention_days: 2555,  // ~7 years for audit logs
        encryption_at_rest_required: true,
        encryption_in_transit_required: true,
    }),
    ..Default::default()
};
```

## Testing GDPR Compliance

```rust
#[cfg(test)]
mod gdpr_tests {
    use super::*;
    
    #[tokio::test]
    async fn test_data_residency_enforcement() {
        let tenant = create_gdpr_tenant().await;
        
        // Should succeed in allowed region
        set_region("eu-west-1");
        assert!(store_user_data(&tenant, &sample_data()).await.is_ok());
        
        // Should fail in prohibited region
        set_region("us-east-1");
        assert!(store_user_data(&tenant, &sample_data()).await.is_err());
    }
    
    #[tokio::test]
    async fn test_right_to_erasure() {
        let tenant = create_gdpr_tenant().await;
        let user = create_test_user(&tenant).await;
        
        // Delete user data
        delete_user_data(&tenant.tenant_id, &user.user_id, "User request").await.unwrap();
        
        // Verify data is deleted
        assert!(get_user_profile(&tenant.tenant_id, &user.user_id).await.is_err());
        
        // Verify audit log exists
        let logs = query_audit_logs(&tenant.tenant_id, &user.user_id).await.unwrap();
        assert!(logs.iter().any(|log| log.action == "USER_DATA_DELETED"));
    }
    
    #[tokio::test]
    async fn test_data_export() {
        let tenant = create_gdpr_tenant().await;
        let user = create_test_user(&tenant).await;
        
        // Export user data
        let data = export_user_data(&tenant.tenant_id, &user.user_id).await.unwrap();
        
        // Verify it's valid JSON
        let json: serde_json::Value = serde_json::from_slice(&data).unwrap();
        assert!(json.is_object());
        
        // Verify audit log
        let logs = query_audit_logs(&tenant.tenant_id, &user.user_id).await.unwrap();
        assert!(logs.iter().any(|log| log.action == "USER_DATA_EXPORTED"));
    }
}
```

## Resources

- [GDPR Official Text](https://gdpr-info.eu/)
- [GDPR Article 6 - Lawful Basis](https://gdpr-info.eu/art-6-gdpr/)
- [GDPR Article 17 - Right to Erasure](https://gdpr-info.eu/art-17-gdpr/)
- [GDPR Article 20 - Data Portability](https://gdpr-info.eu/art-20-gdpr/)
- [GDPR Article 25 - Data Protection by Design](https://gdpr-info.eu/art-25-gdpr/)
- [GDPR Article 30 - Records of Processing](https://gdpr-info.eu/art-30-gdpr/)
- [GDPR Article 33 - Breach Notification](https://gdpr-info.eu/art-33-gdpr/)

## Contact

For GDPR compliance questions:
- Email: compliance@geniustechspace.com
- DPO: dpo@geniustechspace.com
