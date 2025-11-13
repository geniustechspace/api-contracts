# Adding New Services Guide

This guide explains how to add new service packages to the API contracts repository.

## Quick Start

The fastest way to add a new service is using the interactive generator:

```bash
make add-service
```

This launches an interactive wizard that guides you through creating a new service package.

## Interactive Generator Walkthrough

### Step 1: Launch the Tool

```bash
$ make add-service

=== Service Template Generator ===

This tool will help you create a new service package in the proto directory.
You'll be prompted for service details, and proto files will be generated from templates.
```

### Step 2: Enter Service Name

The service name should be lowercase with hyphens (kebab-case).

**Examples:**
- `user-management`
- `billing`
- `notification`
- `inventory-tracking`

**Validation:**
- Must start with a lowercase letter
- Can contain lowercase letters, numbers, and hyphens
- Cannot be a reserved name (`core`, `common`, `google`, `grpc`, `validate`)
- Cannot already exist

```bash
Service name (lowercase, e.g., 'user-management', 'notification'): user-management
```

### Step 3: Enter Service Description

Brief description of what the service does.

**Examples:**
- "User management and authentication"
- "Billing and subscription management"
- "Push notification and email delivery"

```bash
Service description (brief, e.g., 'User management and authentication'): User management and authentication
```

### Step 4: Specify API Version

Default is `v1`. Press Enter to accept default.

For new services, always start with `v1`.

```bash
API version (default: v1): [press Enter]
```

### Step 5: Define Main Entity Name

The primary entity/resource type for your service in TitleCase.

**Examples:**
- Service: `user-management` → Entity: `User`
- Service: `billing` → Entity: `Subscription`
- Service: `notification` → Entity: `Notification`

```bash
Main entity name (TitleCase, e.g., 'User', 'Notification', default: 'UserManagement'): User
```

### Step 6: Review and Confirm

The tool shows a summary of what will be created:

```bash
=== Summary ===

Service Name:    user-management
Description:     User management and authentication
Version:         v1
Entity Name:     User
Location:        proto/user-management/v1/

Proceed with creation? (y/n): y
```

### Step 7: Generation Complete

```bash
=== Success! ===

✓ Service package 'user-management' created successfully!

Next steps:
  1. Review and customize the generated proto files:
     - proto/user-management/README.md
     - proto/user-management/v1/user_management.proto

  2. Generate clients for all languages:
     make generate

  3. Lint proto files:
     make lint

  4. Validate structure:
     make validate-structure
```

## What Gets Generated

### Directory Structure

```
proto/
└── <service-name>/
    ├── README.md              # Service documentation
    └── v1/
        └── <service-file>.proto   # Service definition
```

### README.md

Includes:
- Service overview
- File listing
- Usage examples
- gRPC services documentation
- Message types documentation
- Versioning information
- Client generation instructions

### Service Proto File

A complete gRPC service definition with:

#### Core Features
- **Package declaration** - Properly namespaced package
- **Import statements** - Core types, validation, timestamps
- **Go and Java options** - Language-specific configurations

#### Service Definition
- `Create<Entity>` - Create new entity
- `Get<Entity>` - Retrieve by ID
- `List<Entity>s` - List with pagination
- `Update<Entity>` - Update existing entity
- `Delete<Entity>` - Soft delete entity
- `HealthCheck` - Service health monitoring

#### Message Types
- **Entity message** - Main entity with:
  - ID field
  - Name and description
  - Status enum
  - Tenant context (multitenancy)
  - Timestamps (created, updated, deleted)
  
- **Request/Response messages** - For each operation
- **Status enum** - Entity lifecycle states
- **Health check types** - Health monitoring

#### Enterprise Features
- **Multitenancy** - `core.v1.TenantContext` integration
- **Validation** - Input validation rules via `validate.proto`
- **Error handling** - Standard error response integration
- **Pagination** - List operations with pagination
- **Soft deletes** - Recoverable deletion with timestamps

## Customizing Generated Files

After generation, you'll likely want to customize the proto files:

### Adding Fields to Entity

```protobuf
message User {
  string id = 1;
  string name = 2;
  string description = 3;
  UserStatus status = 4;
  
  // Add your custom fields here
  string email = 5 [(validate.rules).string.email = true];
  string phone_number = 6;
  repeated string roles = 7;
  
  core.v1.TenantContext tenant_context = 10;
  google.protobuf.Timestamp created_at = 20;
  google.protobuf.Timestamp updated_at = 21;
  google.protobuf.Timestamp deleted_at = 22;
}
```

### Adding Custom RPCs

```protobuf
service UserManagementService {
  // Standard CRUD operations...
  
  // Add custom operations
  rpc ActivateUser(ActivateUserRequest) returns (ActivateUserResponse);
  rpc ResetPassword(ResetPasswordRequest) returns (ResetPasswordResponse);
}
```

### Adding New Message Types

```protobuf
// Add after the main entity
message UserProfile {
  string user_id = 1;
  string avatar_url = 2;
  string bio = 3;
  map<string, string> preferences = 4;
}
```

### Modifying Validation Rules

```protobuf
message CreateUserRequest {
  core.v1.TenantContext tenant_context = 1 [(validate.rules).message.required = true];
  
  string name = 2 [(validate.rules).string = {
    min_len: 3,      // Changed from 1
    max_len: 100     // Changed from 255
  }];
  
  // Add email with validation
  string email = 3 [(validate.rules).string.email = true];
}
```

## Best Practices

### Naming Conventions

✅ **Do:**
- Use kebab-case for service names: `user-management`, `order-processing`
- Use TitleCase for entity names: `User`, `Order`, `Subscription`
- Use snake_case for proto file names: `user_management.proto`
- Use descriptive names: `billing` not `b`, `notification` not `notif`

❌ **Don't:**
- Use uppercase in service names: `USER-MANAGEMENT`
- Mix naming styles: `user_management` or `userManagement`
- Use abbreviations: `usr`, `notif`, `sub`

### Service Design

✅ **Do:**
- Keep services focused on a single domain
- Use core types for common patterns
- Add comprehensive validation rules
- Include health check endpoints
- Document all fields and services

❌ **Don't:**
- Mix multiple domains in one service
- Skip validation rules
- Forget to add tenant context
- Leave fields undocumented

### Field Numbering

✅ **Do:**
- Start IDs at 1
- Use 1-15 for frequently used fields (1-byte encoding)
- Reserve ranges: 10-19 for core fields, 20-29 for timestamps
- Leave gaps for future fields

❌ **Don't:**
- Use field numbers > 536870911
- Reuse field numbers (breaks compatibility)
- Use 19000-19999 (reserved by Protocol Buffers)

### Versioning

✅ **Do:**
- Start with v1 for new services
- Use v2, v3 for breaking changes
- Keep v1 stable as long as possible
- Document migration guides when versioning

❌ **Don't:**
- Make breaking changes in existing versions
- Skip version numbers
- Use dates or git hashes as versions

## After Generation

### 1. Review Generated Files

```bash
# Review README
cat proto/<service-name>/README.md

# Review proto file
cat proto/<service-name>/v1/<service-file>.proto
```

### 2. Customize as Needed

Edit the proto file to add:
- Custom fields
- Additional RPCs
- New message types
- Business-specific validation rules

### 3. Generate Clients

```bash
make generate
```

This generates clients for all languages:
- Rust (primary)
- Go
- Python
- TypeScript
- Java

### 4. Lint Proto Files

```bash
make lint
```

Ensures your proto files follow best practices and standards.

### 5. Validate Structure

```bash
make validate-structure
```

Verifies that client structure matches proto structure.

### 6. Build Clients

```bash
# Build all
make build

# Or build specific language
make build-rust
make build-python
make build-ts
```

### 7. Run Tests

```bash
# Test all
make test

# Or test specific language
make test-rust
make test-python
```

## Troubleshooting

### "Service already exists" Error

If you see:
```
✗ Service 'my-service' already exists in proto/
```

**Solution:** Choose a different name or remove the existing service if it's not needed.

### "Service name is reserved" Error

If you see:
```
✗ Service name 'core' is reserved
```

**Solution:** Reserved names are `core`, `common`, `google`, `grpc`, `validate`. Choose a different name.

### Generated File Has Template Variables

If you see `{{SERVICE_NAME}}` or other template variables in generated files:

**Solution:** This is a bug in the generator. Report it and manually replace the variables.

### Lint Failures After Generation

If `make lint` fails:

**Possible causes:**
1. Missing imports - Add required imports
2. Invalid field numbers - Ensure no duplicates or reserved ranges
3. Style violations - Follow buf linting rules

**Solution:** Review lint errors and fix them in the proto file.

### Service Not Discovered by Scripts

If scripts don't find your new service:

**Solution:**
```bash
# Test discovery manually
source scripts/common.sh
discover_proto_modules "$(pwd)"

# Should list your service
```

If not listed, ensure directory structure is correct:
```
proto/<service-name>/v1/<proto-files>
```

## Advanced Usage

### Using Multiple Versions

As your service evolves, you may need new versions:

```bash
# Keep v1 stable
proto/user-management/v1/user_management.proto

# Add v2 for breaking changes
proto/user-management/v2/user_management.proto
```

Both versions coexist and can be used simultaneously.

### Organizing Complex Services

For complex services, split into multiple proto files:

```
proto/user-management/
├── README.md
└── v1/
    ├── user_management.proto      # Main service
    ├── types.proto                # Custom types
    ├── events.proto               # Event definitions
    └── errors.proto               # Service-specific errors
```

Import in service file:
```protobuf
import "user-management/v1/types.proto";
import "user-management/v1/events.proto";
```

### Integration with CI/CD

The generated services automatically work with CI/CD:

**On Pull Request:**
- Linting checks
- Breaking change detection
- Structure validation

**On Merge:**
- Client generation
- Client builds
- Client testing
- Documentation generation

## Examples

### Example 1: E-commerce Order Service

```bash
$ make add-service

Service name: order-processing
Description: Order management and fulfillment
Version: v1
Entity name: Order

# Generated structure:
proto/order-processing/
├── README.md
└── v1/
    └── order_processing.proto
```

### Example 2: Analytics Service

```bash
$ make add-service

Service name: analytics
Description: Usage analytics and reporting
Version: v1
Entity name: Report

# Generated structure:
proto/analytics/
├── README.md
└── v1/
    └── analytics.proto
```

### Example 3: File Storage Service

```bash
$ make add-service

Service name: file-storage
Description: File upload, storage, and retrieval
Version: v1
Entity name: File

# Generated structure:
proto/file-storage/
├── README.md
└── v1/
    └── file_storage.proto
```

## See Also

- [Templates README](../../templates/README.md) - Template system documentation
- [Scripts Summary](../../SCRIPTS_SUMMARY.md) - Build script documentation
- [Architecture Guide](../../ARCHITECTURE.md) - System architecture
- [Core Types](../../proto/core/README.md) - Core infrastructure types
