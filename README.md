# API Contracts Mono-Repo

<div align="center">

[![CI/CD](https://github.com/geniustechspace/api-contracts/workflows/CI/badge.svg)](https://github.com/geniustechspace/api-contracts/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Buf](https://img.shields.io/badge/buf-v1.28.1-blue.svg)](https://buf.build)

**Enterprise-standard mono-repository serving as the single source of truth for all API contracts across the GeniusTechSpace platform.**

[Quick Start](#quick-start) • [Services](#services) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## 🎯 Overview

This repository contains:

- **🔷 Protocol Buffer Definitions**: Versioned API contracts using proto3 with comprehensive documentation
- **📦 Multi-Language Clients**: Auto-generated clients for Rust, Python, and TypeScript
- **🚀 CI/CD Automation**: GitHub Actions workflows for linting, testing, and publishing
- **🏗️ Shared Types**: Common types and metadata standards ensuring consistency
- **📚 Documentation**: Auto-generated API documentation from proto files
- **✅ Quality Assurance**: Breaking change detection, linting, and automated testing

## 📁 Repository Structure

```
api-contracts/
├── proto/                          # Protocol Buffer definitions
│   ├── common/                     # Shared types (Metadata, Address, PhoneNumber, etc.)
│   ├── accounts/                   # Account management
│   │   ├── auth/v1/               # Authentication & authorization
│   │   └── user/v1/               # User profile management
│   ├── organizations/v1/           # Organization & team management
│   ├── notifications/v1/           # Notification service
│   ├── payments/v1/                # Payment processing
│   ├── audit/v1/                   # Audit logging & compliance
│   └── webhooks/v1/                # Webhook subscriptions
├── rust/                           # Rust client crates
│   ├── auth-client/
│   ├── user-client/
│   ├── organizations-client/
│   └── [other services]/
├── python/                         # Python client packages
│   ├── auth_client/
│   ├── user_client/
│   └── [other services]/
├── ts/                             # TypeScript client packages
│   └── packages/
│       ├── auth-client/
│       ├── user-client/
│       └── [other services]/
├── scripts/                        # Client generation scripts
│   ├── generate_clients.sh        # Generate all clients
│   ├── generate_rust.sh
│   ├── generate_python.sh
│   ├── generate_ts.sh
│   └── setup.sh                    # Development environment setup
├── .github/workflows/              # CI/CD automation
│   ├── ci.yml                      # Continuous integration
│   ├── release.yml                 # Release automation
│   └── docs.yml                    # Documentation generation
├── buf.yaml                        # Buf configuration
├── buf.gen.yaml                    # Code generation config
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Protocol Buffers**: `protoc` >= 3.20
- **Buf**: >= 1.28.0 (recommended)
- **Rust**: >= 1.75 (optional, for Rust clients)
- **Python**: >= 3.8 (optional, for Python clients)
- **Node.js**: >= 16 (optional, for TypeScript clients)

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/geniustechspace/api-contracts.git
cd api-contracts

# Run setup script (installs dependencies and generates clients)
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Manual Setup

```bash
# Install Buf (macOS)
brew install bufbuild/buf/buf

# Install Buf (Linux)
BUF_VERSION="1.28.1"
curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
    -o /tmp/buf && sudo mv /tmp/buf /usr/local/bin/buf && sudo chmod +x /usr/local/bin/buf

# Generate all clients
buf generate

# Or generate specific language clients
./scripts/generate_rust.sh
./scripts/generate_python.sh
./scripts/generate_ts.sh
```

## 📚 Services

### 🔐 Authentication Service (`accounts/auth/v1`)

Complete authentication and authorization system with:

- **User Registration**: Email/password with validation
- **Login/Logout**: JWT-based authentication
- **Token Management**: Access tokens, refresh tokens, token verification
- **Multi-Factor Authentication (MFA)**: TOTP, SMS, Email, Backup codes
- **Session Management**: Track and manage user sessions across devices
- **Password Management**: Change password, reset password flows
- **Security**: Rate limiting, IP tracking, device fingerprinting

**Key RPCs**: `Register`, `Login`, `RefreshToken`, `Logout`, `VerifyToken`, `EnableMfa`, `ChangePassword`

### 👤 User Service (`accounts/user/v1`)

Comprehensive user profile and account management:

- **Profile Management**: Get, update, delete user profiles
- **Avatar Management**: Upload and update user avatars
- **Email Verification**: Request and verify email addresses
- **User Search**: Advanced search and filtering
- **User Listing**: Paginated user lists with filters

**Key RPCs**: `GetUser`, `UpdateUser`, `DeleteUser`, `ListUsers`, `SearchUsers`, `VerifyEmail`

### 🏢 Organizations Service (`organizations/v1`)

Multi-tenant organization and team management:

- **Organization CRUD**: Create, read, update, delete organizations
- **Member Management**: Add, remove, update member roles
- **Role-Based Access**: Owner, Admin, Member, Viewer roles
- **Invitations**: Invite users to organizations with role assignment
- **Organization Settings**: Customizable organization preferences

**Key RPCs**: `CreateOrganization`, `UpdateOrganization`, `AddMember`, `RemoveMember`, `InviteMember`

### 🔔 Notifications Service (`notifications/v1`)

Multi-channel notification system:

- **Delivery Channels**: In-app, Email, SMS, Push notifications
- **Notification Types**: Info, Success, Warning, Error, System
- **Priority Levels**: Low, Normal, High, Urgent
- **Preferences**: Per-user, per-category notification settings
- **Quiet Hours**: Do-not-disturb configuration
- **Push Subscriptions**: Device registration for push notifications

**Key RPCs**: `SendNotification`, `ListNotifications`, `MarkAsRead`, `UpdatePreferences`

### 💳 Payments Service (`payments/v1`)

Enterprise payment processing:

- **Payment Processing**: Create, capture, cancel, refund payments
- **Payment Methods**: Cards, Bank accounts, Digital wallets, Crypto
- **Multi-Currency**: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY
- **Payment Status Tracking**: Pending, Authorized, Succeeded, Failed, Refunded
- **Secure Storage**: PCI-compliant payment method storage
- **Provider Integration**: Ready for Stripe, PayPal, etc.

**Key RPCs**: `CreatePayment`, `CapturePayment`, `RefundPayment`, `AddPaymentMethod`

### 📋 Audit Service (`audit/v1`)

Compliance and security audit logging:

- **Event Tracking**: CRUD operations, security events, access logs
- **Severity Levels**: Debug, Info, Warning, Error, Critical
- **Change Tracking**: Before/after states for all modifications
- **Advanced Search**: Full-text search across audit logs
- **Export**: CSV, JSON, PDF export for compliance
- **Analytics**: Event statistics and time-series data

**Key RPCs**: `CreateAuditLog`, `ListAuditLogs`, `SearchAuditLogs`, `ExportAuditLogs`

### 🔗 Webhooks Service (`webhooks/v1`)

Event-driven webhook system:

- **Webhook Management**: CRUD operations for webhook subscriptions
- **Event Types**: User, Payment, Organization, Notification events
- **Delivery Tracking**: Success/failure tracking with retry logic
- **Testing**: Test webhook endpoints before going live
- **Security**: HMAC signature verification
- **Retry Configuration**: Customizable backoff and retry strategies

**Key RPCs**: `CreateWebhook`, `TestWebhook`, `ListDeliveries`, `RetryDelivery`

### 🛠️ Common Types (`common`)

Shared types used across all services:

- **Metadata**: Standard audit fields (created_at, updated_at, created_by, updated_by)
- **Address**: Physical/mailing address with country code
- **PhoneNumber**: International phone numbers with E.164 format
- **Pagination**: Request/response types for paginated lists
- **JsonValue**: Flexible JSON wrapper for dynamic fields

## Prerequisites

### For Development

- Protocol Buffer Compiler (`protoc`) >= 3.20
- Rust >= 1.70 (with `cargo`)
- Python >= 3.8 (with `pip`)
- Node.js >= 16 (with `npm`)

### Tool Installation

**macOS**

```bash
brew install protobuf
```

**Ubuntu/Debian**

```bash
apt-get install -y protobuf-compiler
```

**Rust Tools**

```bash
cargo install protoc-gen-tonic
```

**Python Tools**

```bash
pip install grpcio-tools
```

**TypeScript Tools**

```bash
npm install -g ts-proto
```

## 🔧 Client Generation

### Generate All Clients

```bash
./scripts/generate_clients.sh
```

### Generate Per Language

```bash
# Rust clients only
./scripts/generate_rust.sh

# Python clients only
./scripts/generate_python.sh

# TypeScript clients only
./scripts/generate_ts.sh
```

## 📦 Installation & Usage

### Rust

**Installation**

```bash
# Add to Cargo.toml
[dependencies]
auth-client = "0.1"
user-client = "0.1"
organizations-client = "0.1"
```

**Usage Example**

```rust
use auth_client::geniustechspace::accounts::auth::v1::{
    RegisterRequest, LoginRequest, auth_service_client::AuthServiceClient
};
use tonic::Request;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to auth service
    let mut client = AuthServiceClient::connect("http://localhost:50051").await?;

    // Register new user
    let register_request = Request::new(RegisterRequest {
        email: "user@example.com".into(),
        password: "SecurePass123!".into(),
        full_name: "John Doe".into(),
        phone: None,
        metadata: std::collections::HashMap::new(),
    });

    let response = client.register(register_request).await?;
    let user = response.into_inner();

    println!("User registered! ID: {}", user.user_id);
    println!("Access token: {}", user.access_token);

    // Login
    let login_request = Request::new(LoginRequest {
        email: "user@example.com".into(),
        password: "SecurePass123!".into(),
        device_id: Some("device123".into()),
        ip_address: Some("192.168.1.1".into()),
    });

    let login_response = client.login(login_request).await?;
    println!("Login successful!");

    Ok(())
}
```

### Python

**Installation**

```bash
pip install auth-client user-client organizations-client
```

**Usage Example**

```python
import grpc
from auth_client import auth_pb2, auth_pb2_grpc

async def main():
    # Create channel
    channel = grpc.aio.insecure_channel('localhost:50051')
    stub = auth_pb2_grpc.AuthServiceStub(channel)

    # Register new user
    register_request = auth_pb2.RegisterRequest(
        email='user@example.com',
        password='SecurePass123!',
        full_name='John Doe'
    )

    try:
        response = await stub.Register(register_request)
        print(f"User registered! ID: {response.user_id}")
        print(f"Access token: {response.access_token}")

        # Login
        login_request = auth_pb2.LoginRequest(
            email='user@example.com',
            password='SecurePass123!'
        )

        login_response = await stub.Login(login_request)
        print(f"Login successful! Token: {login_response.access_token}")

    except grpc.aio.AioRpcError as e:
        print(f"RPC failed: {e.code()} - {e.details()}")
    finally:
        await channel.close()

if __name__ == '__main__':
    import asyncio
    asyncio.run(main())
```

### TypeScript

**Installation**

```bash
npm install @geniustechspace/auth-client
npm install @geniustechspace/user-client
npm install @geniustechspace/organizations-client
```

**Usage Example**

```typescript
import { AuthServiceClient } from '@geniustechspace/auth-client';
import { RegisterRequest, LoginRequest } from '@geniustechspace/auth-client';

async function main() {
    // Create client
    const client = new AuthServiceClient('http://localhost:50051');

    // Register new user
    const registerRequest: RegisterRequest = {
        email: 'user@example.com',
        password: 'SecurePass123!',
        fullName: 'John Doe',
        phone: undefined,
        metadata: {}
    };

    try {
        const registerResponse = await client.register(registerRequest);
        console.log(`User registered! ID: ${registerResponse.userId}`);
        console.log(`Access token: ${registerResponse.accessToken}`);

        // Login
        const loginRequest: LoginRequest = {
            email: 'user@example.com',
            password: 'SecurePass123!',
            deviceId: 'device123',
            ipAddress: '192.168.1.1'
        };

        const loginResponse = await client.login(loginRequest);
        console.log(`Login successful! Token: ${loginResponse.accessToken}`);

    } catch (error) {
        console.error('RPC failed:', error);
    }
}

main()
from auth_client.auth.v1 import auth_pb2, auth_pb2_grpc

.catch(err => console.error('Error:', err));
}

main();
```

## 🔄 CI/CD Pipeline

### Automated Workflows

#### **Continuous Integration** (`ci.yml`)

Runs on every push and pull request:

- ✅ Lint proto files with `buf lint`
- ✅ Check for breaking changes (PRs only)
- ✅ Generate clients for all languages
- ✅ Build and test Rust clients
- ✅ Build and test Python clients
- ✅ Build and test TypeScript clients
- ✅ Run Clippy (Rust linter)
- ✅ Upload build artifacts

#### **Release Automation** (`release.yml`)

Triggers on version tags (e.g., `v1.0.0`):

- 📦 Create GitHub release
- 🚀 Publish Rust crates to crates.io
- 🚀 Publish Python packages to PyPI
- 🚀 Publish TypeScript packages to NPM
- 📝 Generate release notes

#### **Documentation** (`docs.yml`)

Generates and deploys documentation:

- 📚 Generate API docs from proto files
- 🌐 Deploy to GitHub Pages
- 🔄 Auto-update on proto changes

### Publishing

**Manual Release**

```bash
# Create and push a version tag
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

**Automated Release**

GitHub Actions automatically:

1. Detects the version tag
2. Builds all clients
3. Runs tests
4. Publishes to package registries
5. Creates GitHub release

## 📋 Versioning Strategy

### Proto Versioning

- **Directory Structure**: Services are versioned in `/proto/<service>/v1/`, `/proto/<service>/v2/`
- **Breaking Changes**: Require new version directory (v2, v3, etc.)
- **Non-Breaking Changes**: Can be added to existing version
- **Buf Breaking Check**: Automatically detects breaking changes in PRs

### Client Versioning

- **Semantic Versioning**: `MAJOR.MINOR.PATCH`
  - **MAJOR**: Breaking changes
  - **MINOR**: New features (backward compatible)
  - **PATCH**: Bug fixes
- **Independent Versioning**: Each service client versioned independently
- **Tag Format**: `v<major>.<minor>.<patch>` (e.g., `v0.1.0`)

## 🛠️ Development Workflow

### Adding a New Service

1. **Create proto directory structure**:

   ```bash
   mkdir -p proto/my-service/v1
   ```

2. **Define service proto**:

   ```protobuf
   // proto/my-service/v1/service.proto
   syntax = "proto3";

   package geniustechspace.myservice.v1;

   import "google/api/annotations.proto";
   import "common/types.proto";

   service MyService {
     rpc GetResource(GetResourceRequest) returns (GetResourceResponse) {
       option (google.api.http) = {
         get: "/v1/resources/{resource_id}"
       };
     }
   }
   ```

3. **Add to client workspaces**:

   - Update `rust/Cargo.toml`
   - Create `python/my_service_client/`
   - Create `ts/packages/my-service-client/`

4. **Generate clients**:

   ```bash
   ./scripts/generate_clients.sh
   ```

5. **Test and commit**:

   ```bash
   git add proto/my-service/
   git commit -m "feat: add my-service proto definitions"
   git push
   ```

### Making Changes

1. **Create feature branch**:

   ```bash
   git checkout -b feature/add-new-rpc
   ```

2. **Modify proto files**
3. **Regenerate clients**: `./scripts/generate_clients.sh`
4. **Test changes**
5. **Create pull request**
6. **CI checks breaking changes automatically**
7. **Merge after approval**

## 🧪 Testing

### Run All Tests

```bash
# Rust
cd rust && cargo test --workspace

# Python
cd python && pytest

# TypeScript
cd ts && pnpm test
```

### Lint Proto Files

```bash
buf lint
```

### Check Breaking Changes

```bash
buf breaking --against '.git#branch=main'
```

## 📚 Documentation

- **Proto Documentation**: Auto-generated markdown in `docs/`
- **API Reference**: Available at your GitHub Pages URL
- **Examples**: See `examples/` directory for language-specific examples
- **Contributing Guide**: See `CONTRIBUTING.md`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure CI passes
6. Submit a pull request

### Code Style

- **Proto**: Follow [Buf Style Guide](https://buf.build/docs/best-practices/style-guide)
- **Rust**: Use `rustfmt` and `clippy`
- **Python**: Use `black` and `flake8`
- **TypeScript**: Use `prettier` and `eslint`

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/geniustechspace/api-contracts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/geniustechspace/api-contracts/discussions)
- **Email**: dev@geniustechspace.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Buf](https://buf.build) for excellent Protocol Buffer tooling
- [gRPC](https://grpc.io) for the RPC framework
- [Tonic](https://github.com/hyperium/tonic) for Rust gRPC implementation
- The open-source community

---

<div align="center">

**Built with ❤️ by GeniusTechSpace**

[Website](https://geniustechspace.com) • [Blog](https://blog.geniustechspace.com) • [Twitter](https://twitter.com/geniustechspace)

</div>

1. **Define/Update Proto**: Edit `.proto` files in `proto/` directory
2. **Generate Clients**: Run `./scripts/generate_clients.sh`
3. **Test Locally**: Build and test clients in each language
4. **Commit Changes**: Commit proto changes and generated code
5. **Tag Release**: Push version tag to trigger publishing
6. **Publish**: CI/CD automatically publishes to package registries

## Adding New Services

1. Create proto directory structure:

```bash
mkdir -p proto/newservice/v1
```

2. Define service proto:

```protobuf
// proto/newservice/v1/newservice.proto
syntax = "proto3";
package newservice.v1;
// ... service definition
```

3. Update generation scripts to include new service

4. Create client directories:

```bash
mkdir -p rust/newservice-client
mkdir -p python/newservice_client
mkdir -p ts/newservice-client
```

5. Run client generation and test

## Future Extensions

The repository structure supports:

- **OpenAPI/REST**: Add `/openapi/` for REST specifications
- **JSON Schema**: Add `/jsonschema/` for validation schemas
- **GraphQL**: Add `/graphql/` for GraphQL schemas
- **Additional Languages**: Extend scripts for Go, Java, C#, etc.

## Proto Style Guide

- Use `snake_case` for field names
- Use `PascalCase` for message names
- Use `PascalCase` for service names
- Include comprehensive field documentation
- Always use `google.api.http` annotations for REST mapping
- Include metadata in response messages

## Troubleshooting

### protoc not found

```bash
# Install protocol buffer compiler
brew install protobuf  # macOS
apt-get install protobuf-compiler  # Ubuntu
```

### Generation script fails

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Ensure all dependencies installed
./scripts/generate_clients.sh --check-deps
```

### Client build fails

- Ensure proto files are valid: `protoc --proto_path=proto --lint proto/**/*.proto`
- Regenerate clients: `./scripts/generate_clients.sh`
- Check dependency versions in Cargo.toml/pyproject.toml/package.json

## Contributing

1. Create feature branch from `main`
2. Make proto changes with documentation
3. Generate and test all clients
4. Submit PR with proto and generated code changes
5. Ensure CI passes before merging

## License

MIT License - See LICENSE file for details

## Support

- **Issues**: GitHub Issues
- **Documentation**: `/docs` directory (coming soon)
- **Discussions**: GitHub Discussions

```

```
