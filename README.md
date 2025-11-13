# Enterprise API Contracts

<div align="center">

[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](LICENSE)
[![Buf](https://img.shields.io/badge/buf-v2-blue.svg)](https://buf.build)
[![Rust](https://img.shields.io/badge/rust-primary-orange.svg)](https://www.rust-lang.org/)

**Enterprise-Grade gRPC API Contracts with Multi-Language Client Generation**

*Single Source of Truth for GeniusTechSpace Platform*

[Features](#-features) •
[Quick Start](#-quick-start) •
[Architecture](#-architecture) •
[Documentation](#-documentation) •
[Contributing](#-contributing)

</div>

---

## 🎯 Overview

This repository is the **single source of truth** for all API contracts across the GeniusTechSpace platform. It provides:

- **Protocol Buffer Definitions**: Complete API specifications using proto3
- **Multi-Language Clients**: Auto-generated clients for Rust, Go, Python, TypeScript, and Java
- **Enterprise Features**: Multitenancy, compliance, audit logging, and security
- **Developer Experience**: Strong typing, validation, comprehensive documentation
- **CI/CD Integration**: Automated testing, breaking change detection, and publishing

### 🎯 Primary Language: Rust

This project prioritizes **Rust** for high-performance, type-safe service development while supporting multiple languages for diverse use cases.

---

## ✨ Features

### Core Capabilities

- **🏢 Enterprise Multitenancy** - Tenant/Organization/Workspace isolation
- **🔐 Security First** - TLS, authentication, authorization, encryption
- **📊 Comprehensive Audit Logging** - Compliance-ready audit trails
- **🌍 Data Residency** - Geographic data storage controls
- **⚡ High Performance** - gRPC binary protocol, streaming support
- **🔄 Backward Compatibility** - Breaking change detection
- **📝 Self-Documenting** - Auto-generated documentation
- **✅ Input Validation** - Request/response validation rules

### Compliance & Standards

- **GDPR** - General Data Protection Regulation
- **HIPAA** - Health Insurance Portability and Accountability Act
- **SOC 2** - Service Organization Control 2
- **PCI DSS** - Payment Card Industry Data Security Standard
- **ISO 27001** - Information Security Management

---

## 🚀 Quick Start

### Prerequisites

- **Buf** >= 1.28.0 (required)
- **Rust** >= 1.75 (primary language)
- **Go** >= 1.21 (optional)
- **Python** >= 3.8 (optional)
- **Node.js** >= 18 (optional)
- **Java** >= 17 (optional)

### Installation

```bash
# Clone the repository
git clone https://github.com/geniustechspace/api-contracts.git
cd api-contracts

# Install dependencies
make install

# Set up enterprise structure
make setup

# Generate clients
make generate

# Build Rust client (primary)
make build-rust
```

### Verify Installation

```bash
# Check setup
make help

# Lint proto files
make lint

# Run tests
make test
```

---

## 📁 Repository Structure

```
api-contracts/
├── proto/                              # Protocol Buffer definitions
│   ├── core/v1/                        # Core infrastructure types
│   │   ├── tenant.proto               # Multitenancy primitives ✅
│   │   ├── context.proto              # Request/response context
│   │   ├── errors.proto               # Standard error handling
│   │   ├── audit.proto                # Audit logging
│   │   ├── metadata.proto             # Standard metadata
│   │   ├── health.proto               # Health checks
│   │   ├── pagination.proto           # Pagination patterns
│   │   └── types.proto                # Common data types (email, phone, address)
│   ├── idp/v1/                        # Identity Provider
│   │   ├── auth/                      # Authentication
│   │   ├── user/                      # User management
│   │   ├── organization/              # Organization management
│   │   ├── role/                      # RBAC
│   │   ├── permission/                # Permissions
│   │   └── session/                   # Session management
│   └── services/                      # Business services
├── clients/                           # Generated clients
│   ├── rust/                          # Rust (PRIMARY)
│   ├── go/                            # Go
│   ├── python/                        # Python
│   ├── typescript/                    # TypeScript/JavaScript
│   └── java/                          # Java
├── docs/                              # Documentation
│   ├── api/                           # Generated API docs
│   ├── standards/                     # Design standards
│   ├── compliance/                    # Compliance guides
│   ├── architecture/                  # Architecture docs
│   └── guides/                        # How-to guides
├── scripts/                           # Automation scripts
├── tests/                             # Integration tests
├── buf.yaml                           # Buf configuration
├── buf.gen.yaml                       # Code generation config
├── Makefile                           # Build automation
└── README.md                          # This file
```

---

## 🏗️ Architecture

### Multitenancy Model

```
Tenant (Required)
  └── Organization (Optional)
      └── Workspace (Optional)
```

Every request **MUST** include tenant context:

**gRPC Metadata:**
```
x-tenant-id: tenant-123
x-organization-id: org-456
x-workspace-id: workspace-789
```

**HTTP Headers:**
```
X-Tenant-ID: tenant-123
X-Organization-ID: org-456
X-Workspace-ID: workspace-789
```

### Request Flow

```
Client → API Gateway → Service → Database
         ↓
      Metadata:
      - x-tenant-id (required)
      - x-request-id (required)
      - x-correlation-id (for tracing)
      - x-user-id (if authenticated)
      - Authorization: Bearer <token>
```

### Error Handling

All services return standardized errors:

```protobuf
message ErrorResponse {
  string code = 1;                    // Application error code
  string message = 2;                 // Human-readable message
  ErrorCategory category = 3;          // Classification
  ErrorSeverity severity = 4;          // Severity level
  repeated FieldViolation fields = 5;  // Field-level errors
  RetryInfo retry_info = 6;           // Retry guidance
}
```

---

## 📝 Usage Examples

### Rust (Primary Language)

```rust
use geniustechspace_api_contracts::idp::auth::v1::*;
use tonic::Request;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to auth service
    let mut client = AuthServiceClient::connect("http://[::1]:50051").await?;
    
    // Create request with tenant context
    let mut request = Request::new(SignInRequest {
        tenant_id: "tenant-123".into(),
        email: "user@example.com".into(),
        password: "secure-password".into(),
    });
    
    // Add metadata
    request.metadata_mut().insert(
        "x-request-id",
        "req-123".parse().unwrap()
    );
    
    // Make request
    let response = client.sign_in(request).await?;
    let token = response.into_inner().access_token;
    
    println!("✅ Authenticated: {}", token);
    
    Ok(())
}
```

### Go

```go
package main

import (
    "context"
    "log"
    
    "google.golang.org/grpc"
    authv1 "github.com/geniustechspace/api-contracts/gen/go/idp/v1/auth"
)

func main() {
    conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
    if err != nil {
        log.Fatalf("Failed to connect: %v", err)
    }
    defer conn.Close()
    
    client := authv1.NewAuthServiceClient(conn)
    
    resp, err := client.SignIn(context.Background(), &authv1.SignInRequest{
        TenantId: "tenant-123",
        Email:    "user@example.com",
        Password: "secure-password",
    })
    
    if err != nil {
        log.Fatalf("SignIn failed: %v", err)
    }
    
    log.Printf("✅ Authenticated: %s", resp.AccessToken)
}
```

### Python

```python
import grpc
from proto.idp.v1.auth import auth_service_pb2, auth_service_pb2_grpc

# Connect to service
channel = grpc.insecure_channel('localhost:50051')
stub = auth_service_pb2_grpc.AuthServiceStub(channel)

# Make request
request = auth_service_pb2.SignInRequest(
    tenant_id="tenant-123",
    email="user@example.com",
    password="secure-password"
)

response = stub.SignIn(request)
print(f"✅ Authenticated: {response.access_token}")
```

### TypeScript

```typescript
import * as grpc from '@grpc/grpc-js';
import { AuthServiceClient } from '@geniustechspace/api-contracts/idp/v1/auth';

const client = new AuthServiceClient(
  'localhost:50051',
  grpc.credentials.createInsecure()
);

client.signIn({
  tenantId: 'tenant-123',
  email: 'user@example.com',
  password: 'secure-password'
}, (err, response) => {
  if (err) {
    console.error('❌ Error:', err);
    return;
  }
  console.log('✅ Authenticated:', response.accessToken);
});
```

---

## 🛠️ Development

### Adding a New Service

1. **Create proto directory:**
   ```bash
   mkdir -p proto/services/myservice/v1
   ```

2. **Define service** (`proto/services/myservice/v1/service.proto`):
   ```protobuf
   syntax = "proto3";
   
   package geniustechspace.services.myservice.v1;
   
   import "core/v1/tenant.proto";
   import "core/v1/errors.proto";
   import "google/api/annotations.proto";
   import "validate/validate.proto";
   
   option rust_package = "geniustechspace::services::myservice::v1";
   
   // MyService provides example functionality.
   service MyService {
     // GetResource retrieves a resource by ID.
     rpc GetResource(GetResourceRequest) returns (GetResourceResponse) {
       option (google.api.http) = {
         get: "/v1/resources/{id}"
       };
     }
   }
   
   // GetResourceRequest requests a resource by ID.
   message GetResourceRequest {
     // Resource identifier.
     string id = 1 [(validate.rules).string.uuid = true];
   }
   
   // GetResourceResponse returns the requested resource.
   message GetResourceResponse {
     // Resource identifier.
     string id = 1;
     
     // Resource name.
     string name = 2;
   }
   ```

3. **Generate clients:**
   ```bash
   make generate
   ```

4. **Build and test:**
   ```bash
   make build
   make test
   ```

### Code Quality

```bash
# Lint proto files
make lint

# Format proto files
make format

# Check for breaking changes
make breaking

# Run all checks
make check
```

---

## 📚 Documentation

### Generated Documentation

- **API Reference**: [`docs/api/index.html`](docs/api/index.html) (after generation)
- **OpenAPI Spec**: [`docs/openapi/api.yaml`](docs/openapi/api.yaml) (after generation)

### Standards & Guides

- [Architecture Documentation](docs/architecture/)
- [API Design Standards](docs/standards/)
- [Compliance Requirements](docs/compliance/)
- [Developer Guides](docs/guides/)

### Key Documents

- [Multitenancy Guide](docs/guides/multitenancy.md)
- [Authentication Guide](docs/guides/authentication.md)
- [Error Handling Guide](docs/guides/error-handling.md)
- [Naming Conventions](docs/standards/naming-conventions.md)
- [Versioning Strategy](docs/standards/versioning.md)

---

## 🔒 Security

### Best Practices

- **TLS Required**: All connections must use TLS 1.3+
- **Token Validation**: JWT tokens validated on every request
- **Rate Limiting**: Per-tenant rate limits enforced
- **Audit Logging**: All security events logged
- **Encryption**: Data encrypted at rest and in transit

### Reporting Vulnerabilities

Email security concerns to: **security@geniustechspace.com**

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Add/modify proto files
4. Generate clients (`make generate`)
5. Run tests (`make test`)
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Review

All changes require:
- ✅ Passing CI checks
- ✅ No breaking changes (or properly versioned)
- ✅ Complete documentation
- ✅ Code review approval

---

## 📋 Compliance

This project supports the following compliance frameworks:

| Framework | Status | Documentation |
|-----------|--------|---------------|
| **GDPR** | ✅ Supported | [docs/compliance/gdpr.md](docs/compliance/gdpr.md) |
| **HIPAA** | ✅ Supported | [docs/compliance/hipaa.md](docs/compliance/hipaa.md) |
| **SOC 2** | ✅ Supported | [docs/compliance/soc2.md](docs/compliance/soc2.md) |
| **PCI DSS** | ✅ Supported | [docs/compliance/pci-dss.md](docs/compliance/pci-dss.md) |

---

## 🔄 Versioning

We use a **dual versioning strategy** that combines directory-based API versioning with Buf's module versioning:

- **Proto API Versioning**: Directory-based (`v1/`, `v2/`, etc.) for API evolution
  - Enables multiple API versions to coexist
  - Allows smooth client migration without breaking changes
  - Industry standard (used by Google, Kubernetes, etc.)
  
- **Module Versioning**: Semantic versioning (SemVer) via Buf for releases
  - Tags: Format `v<major>.<minor>.<patch>` (e.g., `v1.0.0`)
  - Breaking changes in API require new directory (v2) AND new major version (v2.0.0)
  - Buf tracks module dependencies and ensures reproducible builds

**Why both?** They solve different problems:
- Directory versioning = API contract evolution (runtime coexistence)
- Buf versioning = Module release management (dependency tracking)

See [Versioning Strategy](docs/architecture/versioning-strategy.md) for detailed explanation.

---

## 📦 Client Packages

This project uses a **modular, multi-package architecture** where each API module is independently installable. See [MULTI_PACKAGE_ARCHITECTURE.md](clients/MULTI_PACKAGE_ARCHITECTURE.md) for details.

### Rust (Primary)

```toml
[dependencies]
# Install only what you need
geniustechspace-core = "0.1.0"
geniustechspace-idp = "0.1.0"
geniustechspace-notification = "0.1.0"
```

### Go

```bash
# Install only what you need
go get github.com/geniustechspace/api-contracts/gen/go/core
go get github.com/geniustechspace/api-contracts/gen/go/idp
go get github.com/geniustechspace/api-contracts/gen/go/notification
```

### Python

```bash
# Install only what you need
pip install geniustechspace-core
pip install geniustechspace-idp
pip install geniustechspace-notification
```

### TypeScript

```bash
# Install only what you need
npm install @geniustechspace/core
npm install @geniustechspace/idp
npm install @geniustechspace/notification
```

### Java

```xml
<dependencies>
  <!-- Install only what you need -->
  <dependency>
    <groupId>com.geniustechspace</groupId>
    <artifactId>api-contracts-core</artifactId>
    <version>0.1.0</version>
  </dependency>
  <dependency>
    <groupId>com.geniustechspace</groupId>
    <artifactId>api-contracts-idp</artifactId>
    <version>0.1.0</version>
  </dependency>
  <dependency>
    <groupId>com.geniustechspace</groupId>
    <artifactId>api-contracts-notification</artifactId>
    <version>0.1.0</version>
  </dependency>
</dependencies>
```

---

## 🎯 Roadmap

- [x] Core infrastructure types (tenant, context, errors)
- [x] Multi-language client generation
- [x] Rust as primary language
- [ ] Complete IDP service definitions
- [ ] Common business types
- [ ] Service templates and generators
- [ ] Advanced streaming patterns
- [ ] GraphQL gateway support
- [ ] Automated SDK publishing

---

## 📊 Performance

### Targets

- **Latency**: p95 < 100ms, p99 < 500ms
- **Throughput**: 10,000+ RPS per service
- **Availability**: 99.95% uptime SLA
- **Scalability**: Horizontal scaling supported

### Benchmarks

Run benchmarks:
```bash
cd clients/rust
cargo bench
```

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/geniustechspace/api-contracts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/geniustechspace/api-contracts/discussions)
- **Email**: dev@geniustechspace.com

---

## 📄 License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Buf](https://buf.build) - Protocol Buffer tooling
- [gRPC](https://grpc.io) - High-performance RPC framework
- [Tonic](https://github.com/hyperium/tonic) - Rust gRPC implementation
- [Prost](https://github.com/tokio-rs/prost) - Rust Protocol Buffer implementation

---

<div align="center">

**Built with ❤️ by GeniusTechSpace**

⭐ Star us on GitHub — it helps!

[Website](https://geniustechspace.com) •
[Blog](https://blog.geniustechspace.com) •
[Twitter](https://twitter.com/geniustechspace)

</div>
