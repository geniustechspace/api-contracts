# Extending the Repository

This guide explains how to extend the API contracts repository by adding new services, types, or features.

## Table of Contents

1. [Adding a New Service](#adding-a-new-service)
2. [Adding New Types to Existing Services](#adding-new-types-to-existing-services)
3. [Creating a New Proto Module](#creating-a-new-proto-module)
4. [Best Practices](#best-practices)

## Adding a New Service

### Step 1: Create Proto Directory

```bash
# Create directory for your service
mkdir -p proto/myservice/v1

# Add a README
cat > proto/myservice/README.md << 'EOF'
# MyService

Brief description of what this service does.

## Overview

Detailed overview here.

## Packages

### `myservice.v1`

Current stable version.
EOF
```

### Step 2: Define Proto Files

Create your service definition in `proto/myservice/v1/service.proto`:

```protobuf
syntax = "proto3";

package myservice.v1;

import "core/v1/tenant.proto";
import "core/v1/context.proto";
import "core/v1/errors.proto";
import "core/v1/pagination.proto";
import "validate/validate.proto";
import "google/api/annotations.proto";

// Go package
option go_package = "github.com/geniustechspace/api-contracts/gen/go/myservice/v1;myservicev1";

// Java package
option java_package = "com.geniustechspace.api.myservice.v1";
option java_multiple_files = true;
option java_outer_classname = "MyServiceProto";

// MyService provides [description].
service MyService {
  // GetResource retrieves a resource by ID.
  rpc GetResource(GetResourceRequest) returns (GetResourceResponse) {
    option (google.api.http) = {
      get: "/v1/resources/{resource_id}"
    };
  }

  // ListResources lists resources with pagination.
  rpc ListResources(ListResourcesRequest) returns (ListResourcesResponse) {
    option (google.api.http) = {
      get: "/v1/resources"
    };
  }

  // CreateResource creates a new resource.
  rpc CreateResource(CreateResourceRequest) returns (CreateResourceResponse) {
    option (google.api.http) = {
      post: "/v1/resources"
      body: "resource"
    };
  }
}

// GetResourceRequest requests a resource by ID.
message GetResourceRequest {
  // Tenant context (required).
  core.v1.TenantContext tenant_context = 1;

  // Resource identifier.
  string resource_id = 2 [(validate.rules).string = {
    min_len: 1,
    max_len: 64
  }];
}

// GetResourceResponse returns the requested resource.
message GetResourceResponse {
  // The resource.
  Resource resource = 1;
}

// Resource represents a [description].
message Resource {
  // Unique resource identifier.
  string id = 1;

  // Resource name.
  string name = 2 [(validate.rules).string = {
    min_len: 1,
    max_len: 255
  }];

  // Resource description.
  string description = 3;

  // Resource metadata.
  core.v1.ResourceMetadata metadata = 10;
}
```

### Step 3: Update Client Configurations

Add your new module to each client's configuration:

**Rust** (`clients/rust/Cargo.toml`):
```toml
[workspace]
members = [
    "core",
    "idp",
    "notification",
    "myservice",  # Add here
]
```

**Go**: Create `clients/go/myservice/go.mod`:
```go
module github.com/geniustechspace/api-contracts/gen/go/myservice

go 1.23

require (
    google.golang.org/grpc v1.68.1
    google.golang.org/protobuf v1.35.2
    github.com/geniustechspace/api-contracts/gen/go/core v0.1.0
)
```

**Python**: Create `clients/python/myservice/pyproject.toml`:
```toml
[project]
name = "geniustechspace-myservice"
version = "0.1.0"
description = "MyService API contracts"
dependencies = [
    "grpcio>=1.68.0",
    "protobuf>=5.28.0",
    "geniustechspace-core>=0.1.0",
]
```

**TypeScript** (`clients/typescript/package.json`):
```json
{
  "workspaces": [
    "packages/core",
    "packages/idp",
    "packages/notification",
    "packages/myservice"
  ]
}
```

**Java** (`clients/java/pom.xml`):
```xml
<modules>
    <module>core</module>
    <module>idp</module>
    <module>notification</module>
    <module>myservice</module>
</modules>
```

### Step 4: Generate Clients

```bash
# Generate all clients
make generate

# Or generate for specific language
make generate-rust
make generate-go
make generate-python
make generate-ts
make generate-java
```

### Step 5: Lint and Validate

```bash
# Lint proto files
make lint

# Check for breaking changes
make breaking

# Run all validation
make check
```

### Step 6: Build and Test

```bash
# Build all clients
make build

# Or build specific client
make build-rust
make build-go
make build-python
make build-ts
make build-java

# Run tests
make test
```

## Adding New Types to Existing Services

To add new types to an existing service:

1. Edit the existing `.proto` file in the appropriate directory
2. Add your new message types or RPC methods
3. Ensure all fields have validation rules
4. Add comprehensive documentation
5. Run `make generate` to regenerate clients
6. Test the changes

**Important**: Adding new fields to existing messages is non-breaking. Removing or renaming fields is breaking and requires a new version.

## Creating a New Proto Module

For a new top-level module (like `core`, `idp`, etc.):

1. Create the directory structure: `proto/newmodule/v1/`
2. Add a README explaining the module's purpose
3. Create proto files following the patterns in existing modules
4. Update client configurations for all languages
5. Update documentation

## Best Practices

### Proto Design

1. **Use validation rules**: Every field should have appropriate validation
2. **Document everything**: All services, RPCs, messages, fields, and enums need documentation
3. **Include tenant context**: All service methods should include tenant context
4. **Standard errors**: Use `core.v1.ErrorResponse` for errors
5. **Pagination**: Use `core.v1.PaginationRequest` and `PaginationResponse`
6. **Metadata**: Include `core.v1.ResourceMetadata` on resources

### Naming Conventions

- **Files**: `snake_case.proto`
- **Packages**: `lowercase.with.dots`
- **Messages**: `PascalCase`
- **Fields**: `snake_case`
- **Enums**: `PascalCase`
- **Enum values**: `UPPER_SNAKE_CASE`
- **Services**: `PascalCaseService`
- **RPC methods**: `PascalCase`

### Versioning

- Start with `v1` for new services
- Use directory-based versioning: `proto/service/v1/`, `proto/service/v2/`
- Never make breaking changes to existing versions
- Create a new version for breaking changes

### Documentation

- All public elements must have documentation comments
- Use complete sentences
- Explain the purpose and constraints
- Provide examples where helpful
- Document validation rules

### Dependencies

- Prefer importing from `core` module
- Avoid circular dependencies
- Keep service-specific types in their own modules
- Reuse common types when possible

## Testing Your Changes

### Local Testing

```bash
# Install buf locally
make install

# Generate clients locally
make generate

# Build all clients
make build

# Run tests
make test
```

### CI Testing

All changes are automatically tested in CI:
- Proto linting
- Breaking change detection
- Client generation for all languages
- Build verification for all clients
- Unit tests

## Publishing

Once your changes are merged:

1. Update version numbers in package manifests
2. Tag the release: `git tag v0.2.0`
3. Push the tag: `git push origin v0.2.0`
4. CI will automatically publish to package registries

For individual module releases:
```bash
git tag myservice/v0.1.0
git push origin myservice/v0.1.0
```

## Getting Help

- Check existing proto files for examples
- Review [API Design Standards](../standards/README.md)
- Ask in [GitHub Discussions](https://github.com/geniustechspace/api-contracts/discussions)
- Open an issue for bugs or feature requests
