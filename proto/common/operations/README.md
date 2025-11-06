# Common Operations Module

Enterprise-grade operation type definitions and comprehensive operation messages for the GeniusTechSpace organizations platform.

## Overview

This module provides standardized operation types, request/response envelopes, batch processing, async execution, tracking, audit logging, and reporting structures for all operations across the platform.

## File Organization

```
proto/common/operations/
├── operations.proto    # Main index/aggregator (import all)
├── types.proto         # Operation type enumerations
├── request.proto       # Request messages and client context
├── response.proto      # Response messages and error details
├── batch.proto         # Batch operation processing
├── async.proto         # Asynchronous operation support
├── tracking.proto      # Operation tracking, audit, and tracing
├── reporting.proto     # Reports, metrics, and analytics
└── README.md          # This file
```

**Design Philosophy:**

- **Single Responsibility**: Each file has one clear purpose
- **Modularity**: Import only what you need
- **Scalability**: Easy to add new operation features
- **Maintainability**: Changes isolated to specific files

## Module Structure

The operations module is organized into focused, single-purpose proto files for scalability and maintainability:

### `types.proto` - Operation Type Enumerations

Defines the `Operation` enum with standardized operation types:

- **CRUD Operations**: CREATE, READ, UPDATE, DELETE, LIST
- **Data Management**: ARCHIVE, RESTORE, EXPORT, IMPORT
- **Advanced Operations**: BATCH, SEARCH

**Use for:**

- Authorization policy definitions
- Audit logging classification
- Metrics and monitoring categorization
- Operation type validation

### `request.proto` - Operation Request Messages

Defines standardized request envelopes:

- **OperationRequest**: Core request message with metadata
- **ClientContext**: Client application and device information

**Use for:**

- Wrapping service-specific requests
- Idempotency and distributed tracing
- Authorization context
- Security monitoring metadata

### `response.proto` - Operation Response Messages

Defines standardized response envelopes:

- **OperationResponse**: Core response with execution details
- **ErrorDetail**: Comprehensive error information
- **ValidationError**: Field-level validation failures
- **Warning**: Non-fatal operation warnings
- **RetryInfo**: Retry attempt tracking

**Use for:**

- Wrapping service-specific responses
- Error handling and debugging
- Performance monitoring
- Retry strategy tracking

### `batch.proto` - Batch Operation Messages

Defines bulk operation processing:

- **BatchOperationRequest**: Execute multiple operations
- **BatchOperationResponse**: Batch execution results
- **BatchStatistics**: Aggregate batch metrics
- **ExecutionMode**: Sequential, parallel, or optimized execution

**Use for:**

- Bulk data operations
- Transactional batch processing
- Network overhead optimization
- Parallel execution coordination

### `async.proto` - Asynchronous Operation Messages

Defines long-running operation support:

- **AsyncOperation**: Async operation lifecycle
- **AsyncOperationStatus**: Queued, running, completed states
- **ResourceLock**: Distributed locking coordination
- **CancellationInfo**: Operation cancellation tracking

**Use for:**

- Long-running operations
- Background job processing
- Operation polling and status tracking
- Cancellation and retry management

### `tracking.proto` - Operation Tracking & Audit

Defines operation indexing and audit logging:

- **OperationIndex**: Searchable operation records
- **OperationTrace**: Distributed tracing spans
- **OperationAuditLog**: Compliance audit entries
- **ActorInfo**: Detailed actor information
- **ResourceInfo**: Resource metadata
- **FieldChange**: Before/after change tracking

**Use for:**

- Audit trail and compliance
- Operation search and lookup
- Distributed tracing
- Forensic investigation
- GDPR/HIPAA compliance

### `reporting.proto` - Operation Reports & Analytics

Defines comprehensive reporting and metrics:

- **OperationReport**: Aggregate operation statistics
- **SLAReport**: Service level agreement tracking
- **ComplianceReport**: Compliance-specific metrics
- **OperationSummary**: High-level dashboard data
- **TimeSeriesPoint**: Granular time-based metrics

**Use for:**

- Performance monitoring
- SLA compliance tracking
- Capacity planning
- Executive reporting
- Anomaly detection

### `operations.proto` - Main Index File

Aggregates all operation modules for convenience.

**Use for:**

- Importing all operation definitions at once
- Comprehensive operation API access

## Package Structure

```
geniustechspace.common.operations.v1
```

## Language Mappings

- **Go**: `github.com/geniustechspace/api-contracts/gen/go/common/operations/v1`
- **Java**: `com.geniustechspace.api.common.operations.v1`
- **C#**: `GeniusTechSpace.Api.Common.Operations.V1`
- **PHP**: `GeniusTechSpace\Api\Common\Operations\V1`
- **Ruby**: `GeniusTechSpace::Api::Common::Operations::V1`

## Usage Examples

## Usage Examples

### Synchronous Operation

```protobuf
import "common/operations/request.proto";
import "common/operations/response.proto";

// Create operation request
OperationRequest request = {
  operation: OPERATION_CREATE,
  resource_type: "user",
  idempotency_key: "req-123-abc",
  actor_id: "admin-456",
  tenant_id: "org-789",
  client_context: {
    client_id: "web-app",
    ip_address: "192.168.1.1"
  },
  request_data: Any(CreateUserRequest {...})
};

// Process response
OperationResponse response = {
  operation_id: "op-xyz-123",
  status: STATUS_SUCCESS,
  resource_id: "user-456",
  duration: Duration(250ms)
};
```

### Batch Operations

```protobuf
import "common/operations/batch.proto";

BatchOperationRequest batch = {
  operations: [
    {operation: OPERATION_CREATE, resource_type: "user", ...},
    {operation: OPERATION_UPDATE, resource_type: "user", ...},
    {operation: OPERATION_DELETE, resource_type: "user", ...}
  ],
  transactional: true,
  execution_mode: EXECUTION_MODE_PARALLEL,
  stop_on_error: false
};
```

### Async Operation with Progress Tracking

```protobuf
import "common/operations/async.proto";

AsyncOperation async_op = {
  operation_id: "async-op-123",
  status: ASYNC_STATUS_RUNNING,
  progress: 45.5,
  status_message: "Processing 450 of 1000 records",
  estimated_completion_at: Timestamp(future_time),
  callback_url: "https://api.example.com/webhooks/operation-complete"
};
```

### Operation Audit Logging

```protobuf
import "common/operations/tracking.proto";

OperationAuditLog audit = {
  audit_id: "audit-123",
  operation_id: "op-789-xyz",
  operation: OPERATION_UPDATE,
  actor: {
    actor_id: "admin-456",
    actor_email: "admin@example.com",
    roles: ["admin", "user_manager"],
    auth_method: "mfa",
    ip_address: "192.168.1.1"
  },
  resource: {
    resource_type: "user",
    resource_id: "user-123",
    data_classification: "confidential",
    contains_pii: true
  },
  changes: [
    {field_path: "user.email", old_value: "old@...", new_value: "new@..."}
  ],
  compliance_tags: ["GDPR", "SOC2"]
};
```

### Performance Reporting

```protobuf
import "common/operations/reporting.proto";

OperationReport report = {
  operation: OPERATION_CREATE,
  resource_type: "user",
  period_start: start_time,
  period_end: end_time,
  total_count: 10000,
  success_count: 9850,
  failure_count: 150,
  success_rate: 98.5,
  avg_duration: Duration(425ms),
  p95_duration: Duration(850ms),
  p99_duration: Duration(1200ms),
  error_code_counts: {
    ERROR_CODE_INVALID_ARGUMENT: 80,
    ERROR_CODE_RATE_LIMIT_EXCEEDED: 70
  }
};
```

### SLA Compliance Tracking

```protobuf
import "common/operations/reporting.proto";

SLAReport sla = {
  sla_name: "Premium Tier SLA",
  period_start: month_start,
  period_end: month_end,
  objectives: [
    {
      name: "availability",
      target_value: 99.9,
      actual_value: 99.95,
      unit: "percentage",
      met: true
    },
    {
      name: "latency_p95",
      target_value: 500,
      actual_value: 425,
      unit: "milliseconds",
      met: true
    }
  ],
  overall_compliance: 100.0,
  sla_met: true
};
```

## Compliance & Security

### SOC 2 Type II

- All operations must be logged with timestamp, actor, and resource
- Operation reports support operational monitoring requirements

### ISO 27001

- Operation types enable access control audit trail (A.9.4.1)
- Operation index supports security event logging (A.12.4)

### GDPR

- Operation tracking essential for data subject access requests (Article 15)
- OPERATION_EXPORT, OPERATION_DELETE support data subject rights

### HIPAA

- Operation audit logs support PHI access requirements (§164.312(b))
- Comprehensive metadata enables compliance reporting

## Design Principles

1. **Numeric Spacing**: 10-point spacing (0, 10, 20, 30...) for extensibility
2. **Backward Compatibility**: Never renumber existing enum values
3. **Reserved Ranges**: Protect legacy values and common names
4. **Comprehensive Documentation**: Each operation includes HTTP, database, auth, and compliance notes
5. **Enterprise Standards**: Aligned with SOC 2, ISO 27001, GDPR, HIPAA requirements

## Integration

### Import All Operation Definitions

```protobuf
// Import everything at once
import "common/operations/operations.proto";

service YourService {
  rpc ExecuteOperation(OperationRequest) returns (OperationResponse);
  rpc ExecuteBatch(BatchOperationRequest) returns (BatchOperationResponse);
  rpc StartAsync(OperationRequest) returns (AsyncOperation);
  rpc GetOperationStatus(GetAsyncOperationRequest) returns (AsyncOperation);
}
```

### Import Specific Modules

```protobuf
// Import only what you need
import "common/operations/types.proto";
import "common/operations/request.proto";
import "common/operations/response.proto";

service UserService {
  rpc CreateUser(OperationRequest) returns (OperationResponse);
  rpc UpdateUser(OperationRequest) returns (OperationResponse);
}
```

### Service-Specific Operations

```protobuf
import "common/operations/request.proto";
import "common/operations/response.proto";
import "common/operations/tracking.proto";

// Define service-specific messages that wrap operation envelopes
message CreateUserRequest {
  string email = 1;
  string name = 2;
}

message CreateUserResponse {
  string user_id = 1;
  string email = 2;
}

// Service implementation wraps these in OperationRequest/Response
service UserService {
  // Client sends: OperationRequest{request_data: Any(CreateUserRequest)}
  // Server returns: OperationResponse{response_data: Any(CreateUserResponse)}
  rpc CreateUser(OperationRequest) returns (OperationResponse);
}
```

## Version History

- **v1.0.0** (2025-11-01): Initial enterprise-standard release
  - Core operation types (CRUD + advanced)
  - Operation request/response messages
  - Reporting and indexing structures
  - Batch operation support

## Related Modules

- `common/enums.proto`: Status, ErrorCode, Severity enums
- `common/metadata.proto`: Request/response metadata
- `audit/v1/service.proto`: Audit logging service
