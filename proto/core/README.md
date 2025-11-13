# Core Infrastructure Types

This directory contains fundamental infrastructure types used across all services:

## Files

- **tenant.proto** - Multitenancy primitives and tenant management
- **context.proto** - Request/response context and metadata
- **errors.proto** - Standard error handling and responses
- **audit.proto** - Audit logging types
- **metadata.proto** - Standard metadata fields
- **health.proto** - Health check definitions
- **pagination.proto** - Pagination patterns for list/search APIs
- **types.proto** - Common data types (email, phone, address)

## Usage

All services MUST import these core types:

```protobuf
import "core/v1/tenant.proto";
import "core/v1/context.proto";
import "core/v1/errors.proto";
```

## Key Concepts

### Tenant Context
Every request must include tenant context for proper isolation:
- Tenant ID (required)
- Organization ID (optional)
- Workspace ID (optional)

### Request Context
Standard metadata for all requests:
- Request ID
- Correlation ID
- User context
- Client context
- Tracing context

### Error Handling
All services must return standardized error responses for consistency.
