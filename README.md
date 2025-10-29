# API Contracts Mono-Repo

Enterprise-standard mono-repository serving as the single source of truth for all API contracts across the platform. Supports multi-language client generation (Rust, Python, TypeScript) with full CI/CD automation.

## Overview

This repository contains:
- **Protocol Buffer Definitions**: Versioned API contracts using proto3
- **Multi-Language Clients**: Auto-generated clients for Rust, Python, and TypeScript
- **CI/CD Automation**: GitHub Actions workflows for automatic client publishing
- **Shared Types**: Common types and metadata standards across all services

## Repository Structure

```
api-contracts/
├── proto/              # Protocol Buffer definitions
│   ├── common/        # Shared types and metadata
│   ├── auth/v1/       # Authentication service v1
│   └── accounts/v1/   # Accounts service v1
├── rust/              # Rust client crates
├── python/            # Python client packages
├── ts/                # TypeScript client packages
└── scripts/           # Client generation scripts
```

## Services

### Common Types (`proto/common/`)
- **Metadata**: Standard metadata fields (created_at, updated_at, created_by, updated_by)
- **JsonValue**: Flexible JSON wrapper for dynamic fields
- Uses Google well-known types (Timestamp, Struct)

### Auth Service (`proto/auth/v1/`)
- `Register`: User registration with email/password
- `Login`: User authentication returning JWT tokens

### Accounts Service (`proto/accounts/v1/`)
- `CreateAccount`: Create new account with metadata
- `GetAccount`: Retrieve account by ID

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

## Client Generation

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

### Generate Per Service
```bash
# Generate only auth clients
./scripts/generate_rust.sh auth
./scripts/generate_python.sh auth
./scripts/generate_ts.sh auth

# Generate only accounts clients
./scripts/generate_rust.sh accounts
./scripts/generate_python.sh accounts
./scripts/generate_ts.sh accounts
```

## Building Clients

### Rust
```bash
cd rust
cargo build --workspace
cargo test --workspace
```

### Python
```bash
cd python/auth_client
pip install -e .

cd ../accounts_client
pip install -e .
```

### TypeScript
```bash
cd ts/auth-client
npm install
npm run build

cd ../accounts-client
npm install
npm run build
```

## Using Clients

### Rust Example
```rust
use auth_client::auth::v1::{RegisterRequest, LoginRequest};
use auth_client::auth::v1::auth_service_client::AuthServiceClient;

#[tokio::main]
async fn main() -> Result> {
    let mut client = AuthServiceClient::connect("http://[::1]:50051").await?;
    
    let request = tonic::Request::new(RegisterRequest {
        email: "user@example.com".to_string(),
        password: "secure_password".to_string(),
        full_name: "John Doe".to_string(),
    });
    
    let response = client.register(request).await?;
    println!("User registered: {:?}", response);
    Ok(())
}
```

### Python Example
```python
import grpc
from auth_client.auth.v1 import auth_pb2, auth_pb2_grpc

def main():
    channel = grpc.insecure_channel('localhost:50051')
    stub = auth_pb2_grpc.AuthServiceStub(channel)
    
    request = auth_pb2.RegisterRequest(
        email='user@example.com',
        password='secure_password',
        full_name='John Doe'
    )
    
    response = stub.Register(request)
    print(f"User registered: {response}")

if __name__ == '__main__':
    main()
```

### TypeScript Example
```typescript
import { AuthServiceClient } from './auth-client';
import { RegisterRequest } from './auth-client/auth/v1/auth';

const client = new AuthServiceClient('localhost:50051');

const request: RegisterRequest = {
  email: 'user@example.com',
  password: 'secure_password',
  fullName: 'John Doe'
};

client.register(request)
  .then(response => console.log('User registered:', response))
  .catch(error => console.error('Error:', error));
```

## CI/CD

### Automated Publishing

Clients are automatically published when version tags are pushed:

```bash
# Tag format: --v
git tag auth-rust-v0.1.0
git push origin auth-rust-v0.1.0
```

**Tag Patterns:**
- Rust: `<service>-rust-v*` → publishes to crates.io
- Python: `<service>-python-v*` → publishes to PyPI
- TypeScript: `<service>-ts-v*` → publishes to npm

### Workflows

- **rust-client.yml**: Builds and publishes Rust crates
- **python-client.yml**: Builds and publishes Python packages
- **ts-client.yml**: Builds and publishes TypeScript packages

Each workflow:
1. Checks out repository
2. Installs language toolchain and protoc
3. Generates clients from proto files
4. Runs tests
5. Publishes on version tag

## Versioning Strategy

### Proto Files
- Services are versioned in directories: `/proto/<service>/v1/`
- Breaking changes require new version: `v2/`, `v3/`, etc.
- Non-breaking changes increment within version

### Clients
- Each service client has independent versioning
- Semantic versioning: `MAJOR.MINOR.PATCH`
- Version tags trigger automated publishing

## Development Workflow

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
