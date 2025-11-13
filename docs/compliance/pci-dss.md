# PCI DSS Compliance Guide

## Overview

The Payment Card Industry Data Security Standard (PCI DSS) is a set of security standards designed to ensure that all companies that accept, process, store, or transmit credit card information maintain a secure environment. This guide explains how the GeniusTechSpace API Contracts support PCI DSS compliance.

## PCI DSS Requirements

PCI DSS consists of 12 requirements organized into 6 goals:

### Build and Maintain a Secure Network (Requirements 1-2)
### Protect Cardholder Data (Requirements 3-4)
### Maintain a Vulnerability Management Program (Requirements 5-6)
### Implement Strong Access Control Measures (Requirements 7-9)
### Regularly Monitor and Test Networks (Requirements 10-11)
### Maintain an Information Security Policy (Requirement 12)

## Key Cardholder Data (CHD) Elements

PCI DSS protects:
- **Primary Account Number (PAN)** - The credit card number
- **Cardholder Name**
- **Expiration Date**
- **Service Code**
- **Sensitive Authentication Data (SAD)** - CVV, PIN, magnetic stripe data (must NEVER be stored)

## Requirement 1 & 2: Secure Network

### Requirement 1: Install and maintain a firewall configuration

While network firewalls are infrastructure-level, the API contracts support network security through:

```protobuf
message ComplianceSettings {
  bool pci_dss_enabled = 4;
  DataResidency data_residency = 5;
  bool encryption_in_transit_required = 8;  // Must be true for PCI
}
```

### Requirement 2: Do not use vendor-supplied defaults

Implement strong authentication and unique credentials:

```rust
async fn enforce_pci_authentication() -> Result<(), Error> {
    // Ensure no default passwords
    verify_no_default_credentials().await?;
    
    // Enforce strong password policy
    enforce_password_policy(PasswordPolicy {
        min_length: 12,
        require_uppercase: true,
        require_lowercase: true,
        require_numbers: true,
        require_special: true,
        max_age_days: 90,
    }).await?;
    
    Ok(())
}
```

## Requirement 3: Protect Stored Cardholder Data

### Requirement 3.4: Render PAN unreadable

**CRITICAL**: Never store full PAN in plain text. Use tokenization or encryption:

```rust
#[derive(Debug, Clone)]
struct CardToken {
    token_id: String,      // Unique token (e.g., "tok_1234567890")
    last_four: String,     // Last 4 digits of PAN (safe to store)
    card_brand: CardBrand, // Visa, Mastercard, etc.
    exp_month: u8,
    exp_year: u16,
    cardholder_name: String,
}

async fn tokenize_card(card: &CreditCard) -> Result<CardToken, Error> {
    // Generate unique token
    let token_id = generate_secure_token();
    
    // Store encrypted PAN in secure vault (separate from application database)
    store_pan_in_vault(&token_id, &card.pan).await?;
    
    // Create token with non-sensitive data
    let token = CardToken {
        token_id: token_id.clone(),
        last_four: card.pan[card.pan.len() - 4..].to_string(),
        card_brand: detect_card_brand(&card.pan),
        exp_month: card.exp_month,
        exp_year: card.exp_year,
        cardholder_name: card.cardholder_name.clone(),
    };
    
    // Log tokenization (without PAN)
    log_audit_event(AuditLogEntry {
        action: "CARD_TOKENIZED".to_string(),
        category: AuditCategory::DataAccess,
        metadata: hashmap!{
            "pci_requirement".to_string() => "3.4".to_string(),
            "token_id".to_string() => token_id,
            "last_four".to_string() => token.last_four.clone(),
            "card_brand".to_string() => format!("{:?}", token.card_brand),
        },
        ..Default::default()
    }).await?;
    
    Ok(token)
}
```

### Requirement 3.5: Protect cryptographic keys

Implement key management:

```rust
async fn manage_encryption_keys() -> Result<(), Error> {
    // Use hardware security module (HSM) or key management service
    let key_id = rotate_encryption_key().await?;
    
    // Log key rotation
    log_audit_event(AuditLogEntry {
        action: "ENCRYPTION_KEY_ROTATED".to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "3.5".to_string(),
            "key_id".to_string() => key_id,
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

### Requirement 3.6: Document and implement key management processes

```rust
#[derive(Debug)]
struct KeyManagementPolicy {
    key_rotation_days: u32,      // Rotate keys every 90 days
    key_strength: KeyStrength,   // AES-256 minimum
    key_storage: KeyStorage,     // HSM or KMS
    key_access_control: AccessControl,
    key_destruction: DestructionMethod,
}

const PCI_KEY_POLICY: KeyManagementPolicy = KeyManagementPolicy {
    key_rotation_days: 90,
    key_strength: KeyStrength::Aes256,
    key_storage: KeyStorage::HSM,
    key_access_control: AccessControl::DualControl,
    key_destruction: DestructionMethod::SecureErase,
};
```

## Requirement 4: Encrypt Transmission of Cardholder Data

### Requirement 4.1: Use strong cryptography for transmission

Enforce TLS 1.2+ with strong cipher suites:

```rust
fn configure_pci_tls() -> tonic::transport::ServerTlsConfig {
    ServerTlsConfig::new()
        .identity(load_identity())
        // PCI DSS requires TLS 1.2 minimum (1.3 recommended)
        .min_tls_version(tonic::transport::TlsVersion::Tls12)
        // Use only strong cipher suites
        .with_native_roots()
}

async fn enforce_transmission_security(
    tenant_info: &TenantInfo,
) -> Result<(), Error> {
    if let Some(compliance) = &tenant_info.compliance {
        if compliance.pci_dss_enabled {
            // Verify TLS is enforced
            if !compliance.encryption_in_transit_required {
                return Err(Error::PciViolation(
                    "PCI DSS requires encryption in transit".to_string()
                ));
            }
        }
    }
    Ok(())
}
```

## Requirement 7-9: Access Control

### Requirement 7: Restrict access to cardholder data by business need-to-know

Implement role-based access control:

```rust
#[derive(Debug, Clone, PartialEq)]
enum PciRole {
    CardholderDataNone,       // No access to CHD
    CardholderDataReadOnly,   // View tokenized data only
    CardholderDataLimited,    // Process payments
    CardholderDataFull,       // Full access (very restricted)
}

async fn check_chd_access(
    user_id: &str,
    action: CardDataAction,
) -> Result<bool, Error> {
    let user_role = get_user_pci_role(user_id).await?;
    
    let has_access = match (user_role, action) {
        (PciRole::CardholderDataNone, _) => false,
        (PciRole::CardholderDataReadOnly, CardDataAction::View) => true,
        (PciRole::CardholderDataLimited, CardDataAction::Process) => true,
        (PciRole::CardholderDataFull, _) => true,
        _ => false,
    };
    
    // Log access attempt
    log_audit_event(AuditLogEntry {
        action: format!("CHD_ACCESS_{}", if has_access { "GRANTED" } else { "DENIED" }),
        user_id: user_id.to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "7".to_string(),
            "user_role".to_string() => format!("{:?}", user_role),
            "action".to_string() => format!("{:?}", action),
        },
        ..Default::default()
    }).await?;
    
    Ok(has_access)
}
```

### Requirement 8: Identify and authenticate access to system components

Implement unique user IDs and strong authentication:

```rust
async fn authenticate_user_pci(
    credentials: &Credentials,
) -> Result<UserSession, Error> {
    // Verify unique user ID
    let user = verify_credentials(credentials).await?;
    
    // Enforce multi-factor authentication for CHD access
    if user.has_chd_access() && !credentials.has_mfa() {
        log_audit_event(AuditLogEntry {
            action: "AUTH_FAILED_MFA_REQUIRED".to_string(),
            user_id: user.user_id.clone(),
            category: AuditCategory::Security,
            severity: ErrorSeverity::Warning,
            metadata: hashmap!{
                "pci_requirement".to_string() => "8.3".to_string(),
            },
            ..Default::default()
        }).await?;
        
        return Err(Error::MfaRequired);
    }
    
    // Create session
    let session = create_user_session(&user).await?;
    
    // Log successful authentication
    log_audit_event(AuditLogEntry {
        action: "USER_AUTHENTICATED".to_string(),
        user_id: user.user_id.clone(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "8".to_string(),
            "mfa_used".to_string() => credentials.has_mfa().to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(session)
}
```

### Requirement 9: Restrict physical access to cardholder data

While primarily physical security, track system access:

```rust
async fn log_system_access(
    user_id: &str,
    system: &str,
    access_type: AccessType,
) -> Result<(), Error> {
    log_audit_event(AuditLogEntry {
        action: format!("SYSTEM_ACCESS_{:?}", access_type),
        user_id: user_id.to_string(),
        resource_type: "SYSTEM".to_string(),
        resource_id: system.to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "9".to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

## Requirement 10: Track and monitor all access to network resources and cardholder data

### Requirement 10.1-10.7: Implement audit logging

**CRITICAL**: Log all access to cardholder data:

```protobuf
message AuditLogEntry {
  string event_id = 1;
  google.protobuf.Timestamp timestamp = 2;  // 10.3.1: Date and time
  TenantContext tenant_context = 3;
  string user_id = 4;                       // 10.3.2: User identification
  string action = 5;                        // 10.3.3: Event type
  string resource_type = 6;                 // 10.3.4: Identification of affected data
  string resource_id = 7;
  AuditCategory category = 8;
  string ip_address = 9;                    // 10.3.5: Source of event
  string user_agent = 10;
  map<string, string> metadata = 11;        // 10.3.6: Results (success/failure)
}
```

Implementation:

```rust
async fn log_chd_access(
    user_id: &str,
    token_id: &str,
    action: &str,
    result: Result<(), Error>,
) -> Result<(), Error> {
    // Get client IP
    let ip_address = get_client_ip();
    
    // Determine success/failure
    let (status, error_code) = match result {
        Ok(_) => ("SUCCESS", None),
        Err(ref e) => ("FAILURE", Some(format!("{:?}", e))),
    };
    
    // Log the event (PCI Requirement 10)
    log_audit_event(AuditLogEntry {
        event_id: generate_event_id(),
        timestamp: Some(Utc::now().into()),
        user_id: user_id.to_string(),
        action: action.to_string(),
        resource_type: "CARDHOLDER_DATA".to_string(),
        resource_id: token_id.to_string(),
        category: AuditCategory::DataAccess,
        ip_address,
        metadata: hashmap!{
            "pci_requirement".to_string() => "10".to_string(),
            "status".to_string() => status.to_string(),
            "error_code".to_string() => error_code.unwrap_or_default(),
        },
        ..Default::default()
    }).await?;
    
    result
}
```

### Requirement 10.5: Secure audit trails

Protect audit logs from tampering:

```rust
async fn protect_audit_logs(logs: &[AuditLogEntry]) -> Result<(), Error> {
    // Write logs to write-once storage
    write_to_immutable_storage(logs).await?;
    
    // Create cryptographic hash chain
    let hash_chain = create_hash_chain(logs)?;
    store_hash_chain(&hash_chain).await?;
    
    // Restrict access to audit logs
    enforce_audit_log_access_control().await?;
    
    Ok(())
}
```

### Requirement 10.6: Review logs daily

Implement automated log monitoring:

```rust
async fn review_pci_logs_daily(tenant_id: &str) -> Result<LogReview, Error> {
    let logs = get_last_24h_logs(tenant_id).await?;
    
    // Check for suspicious activities
    let findings = vec![
        detect_invalid_access_attempts(&logs),
        detect_privilege_escalations(&logs),
        detect_suspicious_chd_access(&logs),
        detect_failed_authentications(&logs),
        detect_unauthorized_modifications(&logs),
    ];
    
    let review = LogReview {
        review_date: Utc::now().date_naive(),
        logs_reviewed: logs.len(),
        findings: findings.into_iter().flatten().collect(),
    };
    
    // Log the review
    log_audit_event(AuditLogEntry {
        action: "PCI_LOG_REVIEW_COMPLETED".to_string(),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "10.6".to_string(),
            "logs_reviewed".to_string() => logs.len().to_string(),
            "findings_count".to_string() => review.findings.len().to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(review)
}
```

### Requirement 10.7: Retain audit trail history for at least one year

```rust
async fn enforce_pci_log_retention(tenant_id: &str) -> Result<(), Error> {
    // PCI requires minimum 1 year retention (365 days)
    // with at least 3 months immediately available
    const MIN_RETENTION_DAYS: i64 = 365;
    const IMMEDIATE_ACCESS_DAYS: i64 = 90;
    
    let cutoff_date = Utc::now() - Duration::days(MIN_RETENTION_DAYS);
    let archive_date = Utc::now() - Duration::days(IMMEDIATE_ACCESS_DAYS);
    
    // Archive logs older than 3 months
    archive_old_logs(tenant_id, archive_date).await?;
    
    // Delete logs older than 1 year
    delete_old_logs(tenant_id, cutoff_date).await?;
    
    // Log retention enforcement
    log_audit_event(AuditLogEntry {
        action: "PCI_LOG_RETENTION_ENFORCED".to_string(),
        metadata: hashmap!{
            "pci_requirement".to_string() => "10.7".to_string(),
            "retention_days".to_string() => MIN_RETENTION_DAYS.to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

## Requirement 11: Regularly test security systems and processes

### Requirement 11.3: Implement penetration testing

Document security testing in audit logs:

```rust
async fn record_security_test(
    test_type: SecurityTestType,
    findings: &[SecurityFinding],
) -> Result<(), Error> {
    log_audit_event(AuditLogEntry {
        action: format!("SECURITY_TEST_{:?}", test_type),
        category: AuditCategory::Security,
        metadata: hashmap!{
            "pci_requirement".to_string() => "11.3".to_string(),
            "findings_count".to_string() => findings.len().to_string(),
            "critical_findings".to_string() => count_critical_findings(findings).to_string(),
        },
        ..Default::default()
    }).await?;
    
    Ok(())
}
```

## Requirement 12: Maintain an information security policy

Document security policies in code and configuration:

```rust
#[derive(Debug)]
struct PciSecurityPolicy {
    password_policy: PasswordPolicy,
    access_control_policy: AccessControlPolicy,
    encryption_policy: EncryptionPolicy,
    audit_policy: AuditPolicy,
    incident_response: IncidentResponsePolicy,
}

const PCI_SECURITY_POLICY: PciSecurityPolicy = PciSecurityPolicy {
    password_policy: PasswordPolicy {
        min_length: 12,
        require_complexity: true,
        max_age_days: 90,
        history_count: 4,
        lockout_threshold: 6,
        lockout_duration_minutes: 30,
    },
    access_control_policy: AccessControlPolicy {
        require_unique_ids: true,
        require_mfa_for_chd: true,
        session_timeout_minutes: 15,
        require_reauth_for_privileged: true,
    },
    encryption_policy: EncryptionPolicy {
        min_tls_version: TlsVersion::Tls12,
        require_strong_ciphers: true,
        encrypt_at_rest: true,
        key_rotation_days: 90,
    },
    audit_policy: AuditPolicy {
        log_all_access: true,
        log_retention_days: 365,
        daily_review_required: true,
        automated_monitoring: true,
    },
    incident_response: IncidentResponsePolicy {
        document_incidents: true,
        immediate_notification: true,
        root_cause_analysis: true,
        implement_controls: true,
    },
};
```

## Sensitive Authentication Data (SAD)

**CRITICAL**: NEVER store these after authorization:

```rust
#[derive(Debug)]
struct PaymentProcessing {
    // ✅ SAFE to store (after tokenization)
    token_id: String,
    last_four: String,
    exp_month: u8,
    exp_year: u16,
    
    // ❌ NEVER STORE THESE
    // cvv: String,           // FORBIDDEN by PCI
    // pin: String,           // FORBIDDEN by PCI
    // magnetic_stripe: Vec<u8>, // FORBIDDEN by PCI
}

async fn process_payment(card: &CreditCard) -> Result<PaymentResult, Error> {
    // Use CVV for authorization only
    let auth_result = authorize_payment(card).await?;
    
    // ❌ DO NOT store CVV, PIN, or magnetic stripe data
    // cvv is discarded here and never stored
    
    // ✅ Store only token
    let token = tokenize_card(card).await?;
    store_payment_token(&token).await?;
    
    Ok(PaymentResult {
        token_id: token.token_id,
        authorization_code: auth_result.auth_code,
    })
}
```

## Implementation Checklist

When implementing PCI DSS-compliant services:

**Protect Cardholder Data:**
- [ ] Never store full PAN in plain text
- [ ] Use tokenization for card numbers
- [ ] NEVER store CVV/CVC
- [ ] NEVER store PIN
- [ ] NEVER store magnetic stripe data
- [ ] Encrypt PAN if must store (in separate vault)
- [ ] Mask PAN when displayed (show last 4 only)
- [ ] Limit cardholder data storage to business need

**Encryption:**
- [ ] TLS 1.2+ for all transmissions
- [ ] Strong cipher suites only
- [ ] AES-256 for data at rest
- [ ] Implement key rotation (90 days)
- [ ] Use HSM or KMS for key storage

**Access Control:**
- [ ] Unique user IDs
- [ ] Multi-factor authentication for CHD access
- [ ] Role-based access control
- [ ] Restrict access by business need-to-know
- [ ] Session timeouts (15 minutes)
- [ ] Account lockout after failed attempts

**Audit Logging:**
- [ ] Log all CHD access
- [ ] Log authentication attempts
- [ ] Log privilege escalations
- [ ] Log system changes
- [ ] Protect logs from tampering
- [ ] Retain logs for 1+ year
- [ ] Review logs daily

**Testing & Monitoring:**
- [ ] Regular vulnerability scans
- [ ] Annual penetration testing
- [ ] File integrity monitoring
- [ ] Intrusion detection
- [ ] Security incident procedures

## Configuration Example

```rust
// Example tenant configuration for PCI DSS compliance
let tenant_config = TenantInfo {
    tenant_id: "payment-processor-001".to_string(),
    compliance: Some(ComplianceSettings {
        gdpr_enabled: false,
        hipaa_enabled: false,
        soc2_enabled: true,
        pci_dss_enabled: true,  // PCI enabled
        data_residency: Some(DataResidency {
            allowed_regions: vec!["us-east-1".to_string()],
            prohibited_regions: vec![],
            primary_region: "us-east-1".to_string(),
        }),
        data_retention_days: 365,  // 1 year minimum
        encryption_at_rest_required: true,   // Required
        encryption_in_transit_required: true,  // Required
    }),
    ..Default::default()
};
```

## Testing PCI Compliance

```rust
#[cfg(test)]
mod pci_tests {
    use super::*;
    
    #[tokio::test]
    async fn test_card_tokenization() {
        let card = CreditCard {
            pan: "4532015112830366".to_string(),
            exp_month: 12,
            exp_year: 2025,
            cvv: "123".to_string(),
            cardholder_name: "John Doe".to_string(),
        };
        
        // Tokenize card
        let token = tokenize_card(&card).await.unwrap();
        
        // Verify token doesn't contain PAN
        assert_ne!(token.token_id, card.pan);
        assert_eq!(token.last_four, "0366");
        
        // Verify CVV is not stored
        let stored = retrieve_token(&token.token_id).await.unwrap();
        assert!(stored.cvv.is_none());
    }
    
    #[tokio::test]
    async fn test_chd_access_control() {
        let tenant = create_pci_tenant().await;
        
        // User without CHD access
        let user_no_access = create_user_with_role(PciRole::CardholderDataNone).await;
        assert!(!check_chd_access(&user_no_access.user_id, CardDataAction::View).await.unwrap());
        
        // User with CHD access
        let user_with_access = create_user_with_role(PciRole::CardholderDataReadOnly).await;
        assert!(check_chd_access(&user_with_access.user_id, CardDataAction::View).await.unwrap());
    }
    
    #[tokio::test]
    async fn test_audit_logging() {
        let tenant = create_pci_tenant().await;
        let token = create_test_token(&tenant).await;
        
        // Access cardholder data
        let _ = get_token_details(&token.token_id).await;
        
        // Verify audit log was created
        let logs = query_audit_logs(&tenant.tenant_id, "").await.unwrap();
        assert!(logs.iter().any(|log| {
            log.action.contains("CHD_ACCESS") && log.resource_id == token.token_id
        }));
    }
    
    #[tokio::test]
    async fn test_log_retention() {
        let tenant = create_pci_tenant().await;
        
        // Create old logs
        create_old_logs(&tenant, 400).await;  // 400 days old
        
        // Enforce retention
        enforce_pci_log_retention(&tenant.tenant_id).await.unwrap();
        
        // Verify logs older than 365 days are deleted
        let old_logs = query_logs_older_than(&tenant.tenant_id, 365).await.unwrap();
        assert_eq!(old_logs.len(), 0);
    }
}
```

## PCI DSS Levels

Determine your PCI compliance level based on transaction volume:

| Level | Annual Visa Transactions | Validation Requirements |
|-------|-------------------------|------------------------|
| 1 | >6 million | Annual onsite audit by QSA |
| 2 | 1-6 million | Annual self-assessment + quarterly scans |
| 3 | 20,000-1 million (e-commerce) | Annual self-assessment + quarterly scans |
| 4 | <20,000 (e-commerce) or <1 million (other) | Annual self-assessment + quarterly scans |

## Resources

- [PCI DSS Official Site](https://www.pcisecuritystandards.org/)
- [PCI DSS Quick Reference Guide](https://www.pcisecuritystandards.org/documents/PCI_DSS-QRG-v3_2_1.pdf)
- [PCI DSS v4.0](https://www.pcisecuritystandards.org/document_library/)
- [Tokenization Guidelines](https://www.pcisecuritystandards.org/documents/Tokenization_Guidelines_Info_Supplement.pdf)

## Contact

For PCI DSS compliance questions:
- Email: compliance@geniustechspace.com
- Payment security: payments@geniustechspace.com
- QSA inquiries: audit@geniustechspace.com
