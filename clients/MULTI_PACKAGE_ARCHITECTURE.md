# 📦 Multi-Package Architecture

This project uses a **modular, multi-package architecture** where each API module (core, idp, notification, common) is a **separate, independently installable library** in each language.

## 🎯 Architecture Overview

```
api-contracts/
├── proto/                          # Proto definitions
│   ├── core/v1/                   → Core multitenancy + common types
│   ├── idp/v1/                    → Identity & auth
│   └── notification/v1/           → Notifications
│
├── clients/
│   ├── rust/                      # Cargo Workspace
│   │   ├── Cargo.toml            # Workspace root
│   │   ├── core/                 # geniustechspace-core (includes common)
│   │   ├── idp/                  # geniustechspace-idp
│   │   └── notification/         # geniustechspace-notification
│   │
│   ├── go/                        # Go Modules
│   │   ├── core/go.mod           # github.com/.../core (includes common)
│   │   ├── idp/go.mod            # github.com/.../idp
│   │   └── notification/go.mod   # github.com/.../notification
│   │
│   ├── python/                    # Python Packages
│   │   ├── core/pyproject.toml   # geniustechspace-core (includes common)
│   │   ├── idp/pyproject.toml    # geniustechspace-idp
│   │   └── notification/pyproject.toml
│   │
│   ├── typescript/                # NPM Workspace
│   │   ├── package.json          # Workspace root
│   │   └── packages/
│   │       ├── core/             # @geniustechspace/core (includes common)
│   │       ├── idp/              # @geniustechspace/idp
│   │       └── notification/     # @geniustechspace/notification
│   │
│   └── java/                      # Maven Multi-Module
│       ├── pom.xml               # Parent POM
│       ├── core/pom.xml          # api-contracts-core (includes common)
│       ├── idp/pom.xml           # api-contracts-idp
│       └── notification/pom.xml
```

## 🦀 Rust (Cargo Workspace)

### Structure
- **Workspace root**: `clients/rust/Cargo.toml`
- **Independent crates**: Each module is a separate crate
- **Core includes common types**: Pagination, errors, metadata in core crate
- **Shared dependencies**: Defined in workspace `[workspace.dependencies]`

### Installation
```toml
[dependencies]
# Install only what you need
geniustechspace-core = "0.1.0"
geniustechspace-idp = "0.1.0"
```

### Usage
```rust
use geniustechspace_core::core::v1::TenantContext;
use geniustechspace_idp::idp::v1::auth::LoginRequest;
```

### Build Commands
```bash
# Build specific crate
cargo build --package geniustechspace-core

# Build entire workspace
cargo build --workspace

# Test all crates
cargo test --workspace

# Publish individual crates
cargo publish --package geniustechspace-core
```

## 🐹 Go (Separate Modules)

### Structure
- **Independent modules**: Each has its own `go.mod`
- **Module path**: `github.com/geniustechspace/api-contracts/gen/go/{module}`
- **Core includes common types**: Pagination, errors, metadata in core module
- **Local development**: Uses `replace` directives for inter-module deps

### Installation
```bash
# Install only what you need
go get github.com/geniustechspace/api-contracts/gen/go/core
go get github.com/geniustechspace/api-contracts/gen/go/idp
```

### Usage
```go
import (
    corev1 "github.com/geniustechspace/api-contracts/gen/go/core/v1"
    authv1 "github.com/geniustechspace/api-contracts/gen/go/idp/v1/auth"
)
```

### Build Commands
```bash
# Work with specific module
cd clients/go/core
go build ./...
go test ./...

# Update all modules
cd clients/go
for dir in */; do (cd "$dir" && go mod tidy); done
```

## 🐍 Python (Separate Packages)

### Structure
- **Independent packages**: Each has its own `pyproject.toml`
- **Package name**: `geniustechspace-{module}`
- **Core includes common types**: Pagination, errors, metadata in core package
- **Inter-package deps**: Listed in `dependencies`

### Installation
```bash
# Install only what you need
pip install geniustechspace-core
pip install geniustechspace-idp
```

### Usage
```python
from geniustechspace_core.core.v1 import tenant_pb2
from geniustechspace_idp.idp.v1.auth import auth_pb2
```

### Build Commands
```bash
# Build specific package
cd clients/python/core
pip install -e .

# Build all packages (development)
cd clients/python
for dir in */; do (cd "$dir" && pip install -e .); done

# Publish
cd clients/python/core
python -m build
python -m twine upload dist/*
```

## 📘 TypeScript (NPM Workspace)

### Structure
- **NPM workspace**: Root `package.json` defines workspace
- **Scoped packages**: `@geniustechspace/{module}`
- **Core includes common types**: Pagination, errors, metadata in core package
- **Workspace members**: All packages in `packages/`

### Installation
```bash
# Install only what you need
npm install @geniustechspace/core
npm install @geniustechspace/idp
```

### Usage
```typescript
import { TenantContext } from '@geniustechspace/core';
import { LoginRequest } from '@geniustechspace/idp';
```

### Build Commands
```bash
# Install all workspace dependencies
cd clients/typescript
npm install

# Build all packages
npm run build --workspaces

# Build specific package
npm run build --workspace=packages/core

# Publish
npm publish --workspace=packages/core
```

## ☕ Java (Maven Multi-Module)

### Structure
- **Parent POM**: `clients/java/pom.xml`
- **Child modules**: Each has its own `pom.xml`
- **Core includes common types**: Pagination, errors, metadata in core module
- **Artifacts**: `com.geniustechspace:api-contracts-{module}`

### Installation
```xml
<dependencies>
  <!-- Install only what you need -->
  <dependency>
    <groupId>com.geniustechspace</groupId>
    <artifactId>api-contracts-core</artifactId>
    <version>0.1.0-SNAPSHOT</version>
  </dependency>
</dependencies>
```

### Usage
```java
import com.geniustechspace.api.core.v1.TenantProto.TenantContext;
import com.geniustechspace.api.idp.v1.auth.AuthProto.LoginRequest;
```

### Build Commands
```bash
# Build all modules
cd clients/java
mvn clean install

# Build specific module
mvn clean install -pl core

# Deploy to repository
mvn deploy
```

## 🎨 Benefits of Multi-Package Architecture

### ✅ Modularity
- **Install only what you need**: Don't pull in IDP code if you only need core
- **Smaller dependencies**: Faster builds, smaller binaries
- **Clear boundaries**: Each module has well-defined scope

### ✅ Independent Versioning
- **Semantic versioning per module**: Update core without touching IDP
- **Breaking changes isolated**: Changes in one module don't affect others
- **Flexible release cadence**: Release modules independently

### ✅ Team Scalability
- **Ownership per module**: Teams can own specific modules
- **Parallel development**: Work on different modules simultaneously
- **Isolated testing**: Test modules independently

### ✅ Dependency Management
- **Minimize coupling**: Modules only depend on what they need
- **Clear dependency graph**: Core is base, others depend on it
- **Easier maintenance**: Changes are localized

## 📊 Module Dependencies

```
core            (includes common types - base package)
   ↑
   |
   ├─── idp              (depends on core)
   ├─── notification     (depends on core)
   └─── [future modules] (depends on core)
```

**Note**: Common types (pagination, errors, metadata) are part of the `core` package since they're foundational and used across all services.

## 🚀 Getting Started

### For Users (Consuming APIs)
1. Identify which module(s) you need
2. Install only those packages
3. Use them in your code

### For Contributors (Developing APIs)
1. Add proto files to appropriate module in `proto/`
2. Run `make generate` to generate code for all languages
3. Code is organized into separate packages automatically
4. Test and build specific modules

## 🛠️ Common Commands

```bash
# Generate all clients
make generate

# Lint proto files
make lint

# Build all Rust crates
cd clients/rust && cargo build --workspace

# Test all Go modules
cd clients/go && for d in */; do (cd "$d" && go test ./...); done

# Build all TypeScript packages
cd clients/typescript && npm run build --workspaces

# Build all Java modules
cd clients/java && mvn clean install
```

## 📝 Publishing Checklist

Before publishing a module:
- [ ] Update version in package manifest
- [ ] Update CHANGELOG for the module
- [ ] Run tests: `make test`
- [ ] Build locally: module-specific build command
- [ ] Tag release: `git tag {module}/v{version}`
- [ ] Publish to registry (crates.io, npm, PyPI, Maven Central)
- [ ] Update documentation

## 🔗 Related Documentation

- [Architecture Overview](../docs/architecture/README.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [API Documentation](../docs/api/README.md)
