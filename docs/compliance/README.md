# Compliance Documentation

This directory contains compliance documentation for the GeniusTechSpace API Contracts.

## Supported Compliance Frameworks

The API contracts are designed to support multiple compliance frameworks:

| Framework | Status | Documentation |
|-----------|--------|---------------|
| **GDPR** | ✅ Supported | [GDPR Guide](gdpr.md) |
| **HIPAA** | ✅ Supported | [HIPAA Guide](hipaa.md) |
| **SOC 2** | ✅ Supported | [SOC 2 Guide](soc2.md) |
| **PCI DSS** | ✅ Supported | [PCI DSS Guide](pci-dss.md) |

## Compliance Features in API Contracts

### 1. Tenant-Level Compliance Settings

The `core.v1.ComplianceSettings` message allows per-tenant configuration:

```protobuf
message ComplianceSettings {
  bool gdpr_enabled = 1;
  bool hipaa_enabled = 2;
  bool soc2_enabled = 3;
  bool pci_dss_enabled = 4;
  DataResidency data_residency = 5;
  int32 data_retention_days = 6;
  bool encryption_at_rest_required = 7;
  bool encryption_in_transit_required = 8;
}
```

### 2. Audit Logging

The `core.v1.AuditLogEntry` provides comprehensive audit trails:

- All security-relevant events
- User actions and data access
- Configuration changes
- Authentication and authorization events
- Data modifications

### 3. Data Residency

The `core.v1.DataResidency` message enforces geographic restrictions:

```protobuf
message DataResidency {
  repeated string allowed_regions = 1;
  repeated string prohibited_regions = 2;
  string primary_region = 3;
}
```

### 4. Tenant Isolation

Every request includes `TenantContext` for strict data isolation:

```protobuf
message TenantContext {
  string tenant_id = 1;  // Required
  string organization_id = 2;  // Optional
  string workspace_id = 3;  // Optional
}
```

### 5. Field-Level Validation

All fields include validation rules to prevent invalid data:

```protobuf
string email = 1 [(validate.rules).string.email = true];
```

### 6. Error Handling

Standardized error responses prevent information leakage:

```protobuf
message ErrorResponse {
  string code = 1;
  string message = 2;
  ErrorCategory category = 3;
  ErrorSeverity severity = 4;
}
```

## Implementing Compliance in Services

### For Service Developers

When implementing services using these contracts:

1. **Always validate tenant context**: Every request must include valid tenant context
2. **Enforce compliance settings**: Check tenant compliance settings before processing
3. **Generate audit logs**: Log all security-relevant events
4. **Respect data residency**: Store data only in allowed regions
5. **Implement retention policies**: Honor data retention settings
6. **Use encryption**: Encrypt data at rest and in transit as required

### Example: Checking GDPR Compliance

```rust
// Rust example
async fn process_request(
    tenant_info: &TenantInfo,
    request: &MyRequest,
) -> Result<Response, Error> {
    // Check if GDPR is enabled for this tenant
    if tenant_info.compliance.as_ref().map(|c| c.gdpr_enabled).unwrap_or(false) {
        // Apply GDPR-specific processing
        // - Right to be forgotten
        // - Data portability
        // - Consent management
    }
    
    // Continue with normal processing
    Ok(Response::default())
}
```

### Example: Generating Audit Logs

```go
// Go example
func LogAuditEvent(ctx context.Context, event *corev1.AuditLogEntry) error {
    // Ensure tenant context is included
    if event.TenantContext == nil {
        return errors.New("tenant context required")
    }
    
    // Add timestamp
    event.Timestamp = timestamppb.Now()
    
    // Determine if PII should be included based on tenant settings
    tenantInfo := getTenantInfo(ctx, event.TenantContext.TenantId)
    if !tenantInfo.Audit.IncludePii {
        event = redactPII(event)
    }
    
    // Store audit log
    return storeAuditLog(ctx, event)
}
```

## Compliance Checklist

When adding new services or features:

- [ ] Tenant context included in all requests
- [ ] Audit logging for security-relevant events
- [ ] Compliance settings checked before processing
- [ ] Data residency requirements enforced
- [ ] Validation rules on all inputs
- [ ] Standardized error responses (no sensitive data)
- [ ] Encryption in transit (TLS)
- [ ] Encryption at rest (if required by tenant)
- [ ] Data retention policies honored
- [ ] Documentation includes compliance considerations

## Resources

- [GDPR Official Site](https://gdpr.eu/)
- [HIPAA Official Site](https://www.hhs.gov/hipaa/)
- [SOC 2 Framework](https://www.aicpa.org/soc2)
- [PCI DSS Standards](https://www.pcisecuritystandards.org/)

## Contact

For compliance questions:
- Email: compliance@geniustechspace.com
- Security: security@geniustechspace.com
