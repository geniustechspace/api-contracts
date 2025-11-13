# API Contracts Architecture

This document provides a comprehensive overview of the GeniusTechSpace API Contracts repository architecture.

## Table of Contents

1. [Overview](#overview)
2. [Design Principles](#design-principles)
3. [Repository Structure](#repository-structure)
4. [Proto Organization](#proto-organization)
5. [Client Generation](#client-generation)
6. [Monorepo Strategy](#monorepo-strategy)
7. [Versioning](#versioning)
8. [Build System](#build-system)
9. [Enterprise Features](#enterprise-features)

## Overview

This repository serves as the **single source of truth** for all API contracts across the GeniusTechSpace platform. It uses Protocol Buffers (proto3) to define APIs and automatically generates type-safe clients for multiple languages.

### Key Characteristics

- **Proto-First**: All APIs defined in `.proto` files
- **Multi-Language**: Generates clients for Rust, Go, Python, TypeScript, and Java
- **Modular**: Each service is a separate, independently installable package
- **Enterprise-Grade**: Built-in multitenancy, compliance, audit logging
- **Type-Safe**: Comprehensive validation rules and type safety
- **Well-Documented**: Extensive inline and external documentation

## Design Principles

### 1. Single Source of Truth

All API definitions live in `.proto` files. Client code is never hand-written; it's always generated from these definitions. This ensures:

- **Consistency**: All clients behave identically
- **Type Safety**: Compile-time type checking in all languages
- **Documentation**: Single place to document APIs
- **Maintainability**: Changes propagate automatically to all clients

### 2. Modular Architecture

Each logical service or module is independent:

```
proto/
├── core/v1/         → geniustechspace-core (Rust), @geniustechspace/core (TS)
├── common/v1/       → Part of core package
├── idp/v1/          → geniustechspace-idp, @geniustechspace/idp
└── notification/v1/ → geniustechspace-notification, @geniustechspace/notification
```

Consumers install only what they need:

```bash
# Rust: Install only IDP
cargo add geniustechspace-idp

# TypeScript: Install only core
npm install @geniustechspace/core
```

### 3. Language-Specific Best Practices

Each language client follows that language's conventions and best practices:

- **Rust**: Workspace with separate crates, published to crates.io
- **Go**: Separate modules with independent go.mod files
- **Python**: Separate packages with pyproject.toml, published to PyPI
- **TypeScript**: npm workspace with scoped packages (@geniustechspace/*)
- **Java**: Maven multi-module project, published to Maven Central

### 4. Enterprise Standards

All APIs include:

- **Multitenancy**: Tenant context required on all requests
- **Audit Logging**: Security events tracked automatically
- **Compliance**: GDPR, HIPAA, SOC 2, PCI DSS support
- **Validation**: Input validation rules on all fields
- **Error Handling**: Standardized error responses
- **Metadata**: Standard metadata on all resources

## Repository Structure

```
api-contracts/
├── proto/                              # Proto definitions (SOURCE OF TRUTH)
│   ├── core/v1/                        # Core infrastructure
│   │   ├── tenant.proto               # Multitenancy primitives
│   │   ├── context.proto              # Request/response context
│   │   ├── errors.proto               # Standard error handling
│   │   ├── audit.proto                # Audit logging
│   │   ├── metadata.proto             # Resource metadata
│   │   └── health.proto               # Health checks
│   ├── common/v1/                      # Common types
│   │   ├── pagination.proto           # Pagination patterns
│   │   └── types.proto                # Common data types
│   ├── idp/v1/                         # Identity Provider
│   └── [services]/v1/                  # Additional services
│
├── clients/                            # Generated clients (NOT IN GIT)
│   ├── rust/                           # Rust Cargo workspace
│   │   ├── Cargo.toml                 # Workspace manifest
│   │   ├── core/                      # geniustechspace-core crate
│   │   │   ├── Cargo.toml
│   │   │   ├── src/lib.rs            # Library entry point
│   │   │   └── build.rs              # Build script
│   │   ├── idp/                       # geniustechspace-idp crate
│   │   └── notification/              # geniustechspace-notification
│   │
│   ├── go/                             # Go modules
│   │   ├── core/go.mod                # Separate module
│   │   ├── idp/go.mod
│   │   └── notification/go.mod
│   │
│   ├── python/                         # Python packages
│   │   ├── pyproject.toml             # Workspace config
│   │   ├── core/pyproject.toml        # geniustechspace-core
│   │   ├── idp/pyproject.toml         # geniustechspace-idp
│   │   └── notification/pyproject.toml
│   │
│   ├── typescript/                     # TypeScript npm workspace
│   │   ├── package.json               # Workspace root
│   │   └── packages/
│   │       ├── core/                  # @geniustechspace/core
│   │       ├── idp/                   # @geniustechspace/idp
│   │       └── notification/          # @geniustechspace/notification
│   │
│   └── java/                           # Maven multi-module
│       ├── pom.xml                    # Parent POM
│       ├── core/pom.xml               # api-contracts-core
│       ├── idp/pom.xml                # api-contracts-idp
│       └── notification/pom.xml       # api-contracts-notification
│
├── docs/                               # Documentation
│   ├── architecture/                  # Architecture docs
│   ├── guides/                        # How-to guides
│   ├── compliance/                    # Compliance guides
│   └── standards/                     # API standards
│
├── scripts/                            # Build automation
│   ├── generate_clients.sh            # Generate all clients
│   ├── generate_rust.sh               # Rust-specific generation
│   ├── generate_python.sh             # Python-specific generation
│   └── validate_structure.sh          # Validate structure
│
├── buf.yaml                            # Buf configuration
├── buf.gen.yaml                        # Code generation config
├── Makefile                            # Build automation
└── README.md                           # Main documentation
```

## Proto Organization

### Core Module (`proto/core/v1/`)

Fundamental infrastructure types used by all services:

- **tenant.proto**: Multitenancy primitives (TenantContext, TenantInfo)
- **context.proto**: Request/response context
- **errors.proto**: Standard error responses
- **audit.proto**: Audit logging types
- **metadata.proto**: Resource metadata
- **health.proto**: Health check definitions

### Common Module (`proto/common/v1/`)

Shared business types:

- **pagination.proto**: Pagination patterns
- **types.proto**: Common types (email, phone, address)
- **enums.proto**: Common enumerations (planned)
- **search.proto**: Search and filtering (planned)
- **money.proto**: Currency types (planned)
- **geography.proto**: Geographic types (planned)

### Service Modules

Each service has its own module:

- **idp**: Identity Provider (auth, users, organizations, roles)
- **notification**: Notifications (email, SMS, push)
- **[future services]**: Additional services as needed

## Client Generation

### Generation Pipeline

```
Proto Files → buf lint → buf generate → Language-Specific Clients
```

### Buf Configuration

**buf.yaml**: Defines proto modules, dependencies, and linting rules

```yaml
version: v2
modules:
  - path: proto
    name: buf.build/geniustechspace/api-contracts

deps:
  - buf.build/googleapis/googleapis
  - buf.build/envoyproxy/protoc-gen-validate
  - buf.build/grpc-ecosystem/grpc-gateway

lint:
  use:
    - STANDARD
    - COMMENTS
    - FILE_LOWER_SNAKE_CASE
    # ... and more strict rules
```

**buf.gen.yaml**: Defines code generation for each language

```yaml
version: v2
plugins:
  # Rust
  - remote: buf.build/community/neoeinstein-prost:v0.4.0
    out: clients/rust
  - remote: buf.build/community/neoeinstein-tonic:v0.4.0
    out: clients/rust
  
  # Go
  - remote: buf.build/protocolbuffers/go:v1.35.2
    out: clients/go
  - remote: buf.build/grpc/go:v1.5.1
    out: clients/go
  
  # Python
  - remote: buf.build/protocolbuffers/python:v28.3
    out: clients/python
  - remote: buf.build/grpc/python:v1.68.1
    out: clients/python
  
  # TypeScript
  - remote: buf.build/community/timostamm-protobuf-ts:v2.9.4
    out: clients/typescript/packages
  
  # Java
  - remote: buf.build/protocolbuffers/java:v28.3
    out: clients/java
  - remote: buf.build/grpc/java:v1.68.1
    out: clients/java
```

### What Gets Generated

For each proto file, buf generates:

**Rust**: 
- Message types (structs)
- gRPC service traits
- Client implementations

**Go**:
- Message types (structs)
- gRPC service definitions
- Client stubs

**Python**:
- Message classes
- gRPC service stubs
- Type hints

**TypeScript**:
- Interface definitions
- Client implementations
- Type definitions

**Java**:
- POJO classes
- gRPC service interfaces
- Client stubs

## Monorepo Strategy

### Why Monorepo?

1. **Single Source of Truth**: All proto definitions in one place
2. **Atomic Changes**: Update multiple clients in single commit
3. **Consistent Versioning**: All clients stay in sync
4. **Simplified CI/CD**: Single pipeline for all languages
5. **Easier Testing**: Test cross-language compatibility

### Multi-Package Approach

While it's a monorepo for proto files, each language generates **separate packages**:

```
Proto Monorepo → Multiple Language-Specific Packages
```

This gives us:
- **Modularity**: Install only what you need
- **Independent versioning**: Update one package without affecting others
- **Smaller dependencies**: Don't pull in unused code
- **Clear boundaries**: Well-defined module responsibilities

### Workspace Structure

Each language uses its native workspace tooling:

**Rust** - Cargo Workspace:
```toml
[workspace]
members = ["core", "idp", "notification"]
```

**Go** - Module per package:
```
go/core/go.mod
go/idp/go.mod
go/notification/go.mod
```

**Python** - pip packages:
```
python/core/pyproject.toml
python/idp/pyproject.toml
python/notification/pyproject.toml
```

**TypeScript** - npm workspace:
```json
{
  "workspaces": ["packages/*"]
}
```

**Java** - Maven multi-module:
```xml
<modules>
  <module>core</module>
  <module>idp</module>
</modules>
```

## Versioning

### Proto Versioning

Directory-based versioning:

```
proto/service/v1/  # Version 1 (stable)
proto/service/v2/  # Version 2 (new features or breaking changes)
```

Rules:
- **Never break existing versions**: v1 stays forever
- **New major features**: Create v2
- **Breaking changes**: Create v2
- **Non-breaking additions**: Add to v1

### Client Versioning

Semantic versioning (SemVer):

```
v0.1.0  # Initial development
v1.0.0  # First stable release
v1.1.0  # New features (backward compatible)
v1.1.1  # Bug fixes
v2.0.0  # Breaking changes
```

## Build System

### Makefile Targets

```bash
make install       # Install dependencies
make generate      # Generate all clients
make lint          # Lint proto files
make breaking      # Check for breaking changes
make build         # Build all clients
make test          # Run all tests
make clean         # Clean generated files
```

### CI/CD Pipeline

```
1. Checkout code
2. Install buf
3. Lint proto files
4. Check for breaking changes
5. Generate clients for all languages
6. Build each client
7. Run tests
8. Publish packages (on release)
```

## Enterprise Features

### 1. Multitenancy

Every request includes tenant context:

```protobuf
message TenantContext {
  string tenant_id = 1;        // Required
  string organization_id = 2;  // Optional
  string workspace_id = 3;     // Optional
}
```

### 2. Audit Logging

Comprehensive audit trail:

```protobuf
message AuditLogEntry {
  string id = 1;
  TenantContext tenant_context = 2;
  AuditEventType event_type = 3;
  google.protobuf.Timestamp timestamp = 4;
  string user_id = 5;
  // ... more fields
}
```

### 3. Compliance

Per-tenant compliance settings:

```protobuf
message ComplianceSettings {
  bool gdpr_enabled = 1;
  bool hipaa_enabled = 2;
  bool soc2_enabled = 3;
  bool pci_dss_enabled = 4;
  DataResidency data_residency = 5;
}
```

### 4. Validation

Field-level validation:

```protobuf
string email = 1 [(validate.rules).string.email = true];
int32 age = 2 [(validate.rules).int32 = {gte: 0, lte: 150}];
```

### 5. Standard Error Handling

Consistent error responses:

```protobuf
message ErrorResponse {
  string code = 1;
  string message = 2;
  ErrorCategory category = 3;
  ErrorSeverity severity = 4;
  repeated FieldViolation field_violations = 5;
}
```

## Related Documentation

- [Monorepo Guide](MONOREPO_GUIDE.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Multi-Package Architecture](clients/MULTI_PACKAGE_ARCHITECTURE.md)
- [Extending the Repository](docs/guides/extending-the-repository.md)
- [API Standards](docs/standards/README.md)
- [Compliance](docs/compliance/README.md)
