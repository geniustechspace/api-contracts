# Common Types Module Structure

This document describes the modular organization of common types and messages in the GeniusTechSpace API contracts.

## Module Organization

The common types have been organized into focused, domain-specific modules for better maintainability, reusability, and clarity.

### Module Index

| Module             | File                  | Purpose                            | Key Types                                                                                                             |
| ------------------ | --------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Enumerations**   | `enums.proto`         | Standardized enum values           | Status, ErrorCode, Severity, LifecycleState, AuditAction, AuthContext, RiskLevel, DataClassification, RetentionPeriod |
| **Base Types**     | `base.proto`          | Core API response types            | ErrorDetail, ApiResponse                                                                                              |
| **Metadata**       | `metadata.proto`      | Audit trails and entity metadata   | Metadata                                                                                                              |
| **Geography**      | `geography.proto`     | Geographic and contact information | Address, PhoneNumber                                                                                                  |
| **Pagination**     | `pagination.proto`    | List operation pagination          | PaginationRequest, PaginationResponse                                                                                 |
| **Authentication** | `auth.proto`          | Authentication and authorization   | Token, Credentials                                                                                                    |
| **Context**        | `context.proto`       | Request context and tracing        | RequestContext                                                                                                        |
| **Money**          | `money.proto`         | Financial and monetary types       | Money                                                                                                                 |
| **Time**           | `time.proto`          | Time ranges and scheduling         | TimeRange, RecurrenceRule                                                                                             |
| **Files**          | `files.proto`         | File and media metadata            | FileMetadata                                                                                                          |
| **Notifications**  | `notifications.proto` | Notification preferences           | NotificationPreferences, ChannelPreferences                                                                           |
| **Health**         | `health.proto`        | Service health checks              | HealthCheckResponse, DependencyHealth                                                                                 |
| **Search**         | `search.proto`        | Search and filtering               | SearchRequest, SearchResponse, SearchResult, FacetResult                                                              |
| **Batch**          | `batch.proto`         | Batch operations                   | BatchRequest, BatchOperation, BatchResponse, BatchOperationResult                                                     |

## Import Strategy

### For Service Definitions

Services should import only the modules they need:

```protobuf
// Import specific modules
import "common/base.proto";        // For ApiResponse, ErrorDetail
import "common/pagination.proto";  // For paginated lists
import "common/auth.proto";        // For authentication
import "common/metadata.proto";    // For entity metadata
```

### Module Dependencies

Some modules depend on other common modules:

```
base.proto → enums.proto
metadata.proto → enums.proto
auth.proto → enums.proto
context.proto → (no dependencies)
health.proto → enums.proto, base.proto
search.proto → pagination.proto, enums.proto
batch.proto → base.proto, enums.proto
```

## Usage Examples

### 1. User Service with Full Metadata

```protobuf
import "common/base.proto";
import "common/metadata.proto";
import "common/pagination.proto";
import "common/geography.proto";

message User {
  string user_id = 1;
  string email = 2;
  string name = 3;

  // Embed common types
  Metadata metadata = 10;
  Address home_address = 11;
  PhoneNumber phone_number = 12;
}

message ListUsersRequest {
  PaginationRequest pagination = 1;
}

message ListUsersResponse {
  ApiResponse response = 1;
  repeated User users = 2;
  PaginationResponse pagination = 3;
}
```

### 2. Payment Service with Money

```protobuf
import "common/base.proto";
import "common/money.proto";
import "common/metadata.proto";

message Payment {
  string payment_id = 1;
  Money amount = 2;
  Metadata metadata = 10;
}

message CreatePaymentResponse {
  ApiResponse response = 1;
  Payment payment = 2;
}
```

### 3. Search Service

```protobuf
import "common/search.proto";
import "common/base.proto";

message SearchProductsRequest {
  SearchRequest search = 1;
}

message SearchProductsResponse {
  ApiResponse response = 1;
  SearchResponse search_results = 2;
}
```

### 4. Batch Import Service

```protobuf
import "common/batch.proto";
import "common/base.proto";

message ImportUsersRequest {
  BatchRequest batch = 1;
}

message ImportUsersResponse {
  ApiResponse response = 1;
  BatchResponse batch_results = 2;
}
```

## Design Principles

### 1. Single Responsibility

Each module focuses on a specific domain:

- **base.proto**: API response envelope
- **auth.proto**: Authentication only
- **money.proto**: Financial types only

### 2. Minimal Dependencies

Modules have minimal cross-dependencies:

- Most modules only depend on `enums.proto`
- Complex modules may depend on foundational modules
- Circular dependencies are prohibited

### 3. Comprehensive Documentation

Every module, message, and field includes:

- Purpose and usage guidelines
- Examples with realistic data
- Validation rules and constraints
- Compliance requirements (GDPR, SOC 2, etc.)
- Security considerations

### 4. Semantic Versioning

- Package: `geniustechspace.common.v1`
- Breaking changes require new version (v2, v3, etc.)
- Within v1, only additive changes allowed

### 5. Language Support

All modules configured for multi-language generation:

- Go: `github.com/geniustechspace/api-contracts/gen/go/common/v1`
- Java: `com.geniustechspace.api.common.v1`
- C#: `GeniusTechSpace.Api.Common.V1`
- PHP: `GeniusTechSpace\Api\Common\V1`
- Ruby: `GeniusTechSpace::Api::Common::V1`

## Compliance & Security

### Data Classification

Use `DataClassification` enum for:

- Encryption requirements
- Access control policies
- Data retention rules
- Audit requirements

### Audit Trails

Embed `Metadata` in all persistent entities:

- Tracks who created/modified/deleted
- Records timestamps for all changes
- Supports version control (optimistic locking)
- Required for SOC 2, ISO 27001, HIPAA compliance

### Security Best Practices

- **Tokens**: Never log, encrypt at rest, use HTTPS
- **Credentials**: Never store plaintext passwords, hash with bcrypt/Argon2
- **PII**: Mark fields with appropriate classification
- **Financial Data**: Use `Money` type, never floating point

## Migration from Monolithic Structure

The previous structure had 3 large files:

- `enums.proto` (1,489 lines) - **Kept as-is**
- `types.proto` (716 lines) - **Split into 7 modules**
- `types_extended.proto` (429 lines) - **Split into 7 modules**

### Migration Mapping

| Old File             | Old Message             | New Module          | New Message             |
| -------------------- | ----------------------- | ------------------- | ----------------------- |
| types.proto          | ErrorDetail             | base.proto          | ErrorDetail             |
| types.proto          | ApiResponse             | base.proto          | ApiResponse             |
| types.proto          | Metadata                | metadata.proto      | Metadata                |
| types.proto          | Address                 | geography.proto     | Address                 |
| types.proto          | PhoneNumber             | geography.proto     | PhoneNumber             |
| types.proto          | PaginationRequest       | pagination.proto    | PaginationRequest       |
| types.proto          | PaginationResponse      | pagination.proto    | PaginationResponse      |
| types.proto          | Token                   | auth.proto          | Token                   |
| types.proto          | Credentials             | auth.proto          | Credentials             |
| types.proto          | RequestContext          | context.proto       | RequestContext          |
| types_extended.proto | Money                   | money.proto         | Money                   |
| types_extended.proto | TimeRange               | time.proto          | TimeRange               |
| types_extended.proto | RecurrenceRule          | time.proto          | RecurrenceRule          |
| types_extended.proto | FileMetadata            | files.proto         | FileMetadata            |
| types_extended.proto | NotificationPreferences | notifications.proto | NotificationPreferences |
| types_extended.proto | HealthCheckResponse     | health.proto        | HealthCheckResponse     |
| types_extended.proto | SearchRequest           | search.proto        | SearchRequest           |
| types_extended.proto | SearchResponse          | search.proto        | SearchResponse          |
| types_extended.proto | BatchRequest            | batch.proto         | BatchRequest            |
| types_extended.proto | BatchOperation          | batch.proto         | BatchOperation          |
| types_extended.proto | BatchResponse           | batch.proto         | BatchResponse           |
| types_extended.proto | BatchOperationResult    | batch.proto         | BatchOperationResult    |

### Import Updates Required

Services importing old files need to update:

**Before:**

```protobuf
import "common/types.proto";
import "common/types_extended.proto";
```

**After:**

```protobuf
// Import only what you need
import "common/base.proto";
import "common/pagination.proto";
import "common/metadata.proto";
// ... other specific modules
```

## Maintenance Guidelines

### Adding New Types

1. **Determine the appropriate module**:

   - Does it fit an existing module's domain?
   - Or does it need a new module?

2. **Create new module if needed**:

   - Follow naming convention: `<domain>.proto`
   - Add module header with version and description
   - Configure language-specific options
   - Document thoroughly

3. **Update this README**:
   - Add to module index table
   - Document dependencies
   - Provide usage examples

### Modifying Existing Types

1. **Additive changes only** (within v1):

   - Add new fields with new field numbers
   - Add new enum values (with proper spacing)
   - Never remove or renumber existing fields

2. **Breaking changes require v2**:
   - Create new package: `geniustechspace.common.v2`
   - Provide migration guide
   - Support v1 and v2 in parallel

### Deprecating Types

1. **Mark as deprecated** in documentation
2. **Provide migration path** to replacement
3. **Set sunset timeline** (e.g., 12 months)
4. **Remove in next major version**

## Validation

Run the validation script to ensure compliance:

```bash
./scripts/validate_modules.sh
```

The script validates:

- Package naming consistency
- Module count and structure
- Documentation coverage
- Compliance annotations
- Import dependencies
- Message and field naming

## Buf Linting

Ensure all modules pass buf lint:

```bash
npx @bufbuild/buf lint
```

Expected output:

```
✓ No lint errors found
```

## Benefits of Modular Structure

### 1. **Maintainability**

- Easier to find and update specific types
- Clear ownership boundaries
- Reduced merge conflicts

### 2. **Reusability**

- Services import only what they need
- Reduces dependency bloat
- Faster compilation

### 3. **Scalability**

- Add new modules without affecting existing ones
- Team can work on different modules independently
- Clear extension points

### 4. **Documentation**

- Focused, domain-specific documentation
- Easier to understand and learn
- Better developer experience

### 5. **Testing**

- Test modules independently
- Mock dependencies easily
- Faster test execution

## Support

For questions or issues:

- Review module documentation in proto files
- Check examples in this README
- Run validation script for automated checks
- Consult team lead for architectural decisions

---

**Last Updated**: 2024-01-15
**Version**: 1.0.0
**Modules**: 14 (1 enum + 13 message modules)
