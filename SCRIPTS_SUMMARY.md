# Scripts & Client Structure Summary

## ✅ Scripts Overview

All scripts in `/scripts/` are now up-to-date and integrated with the Makefile.

### Available Scripts

1. **`setup.sh`** - Complete development environment setup
   - Detects proto modules automatically
   - Sets up Python virtual environments (`.venv` in each package)
   - Installs npm dependencies (`node_modules` in TypeScript workspace)
   - Configures all 5 languages: Rust, Go, Python, TypeScript, Java
   - Usage: `make setup` or `./scripts/setup.sh`

2. **`generate_clients.sh`** - Master generation script
   - Generates all clients using buf
   - Calls language-specific scripts
   - Usage: `make generate`

3. **`generate_rust.sh`** - Rust client generation
   - Generates proto code
   - Builds workspace with cargo
   - Runs tests and linters
   - Usage: `make generate-rust`

4. **`generate_python.sh`** - Python client generation
   - Generates proto code
   - Installs packages in development mode
   - Formats with black
   - Usage: `make generate-python`

5. **`generate_ts.sh`** - TypeScript client generation
   - Generates proto code
   - Installs npm dependencies
   - Builds packages
   - Usage: `make generate-ts`

6. **`validate_structure.sh`** - Structure validation
   - Validates clients match proto modules
   - Checks for missing/extra client directories
   - Verifies package files (pyproject.toml, package.json, pom.xml)
   - Usage: `make validate-structure`

## 📦 Client Structure

### Principle: Proto → Client Mapping

**Each top-level directory in `proto/` becomes a separate installable package**

```
proto/
├── core/       → clients/*/core/       (geniustechspace-core)
├── idp/        → clients/*/idp/        (geniustechspace-idp)
└── notification/ → clients/*/notification/ (geniustechspace-notification)
```

### Current Structure

Based on validation, you currently have:
- ✅ **proto/core** → Clients exist for all languages
- ✅ **proto/idp** → Clients exist for all languages
- ⚠️ **proto/notification** → No proto files, but client directories exist (should be removed or proto files added)

## 🦀 Rust (Cargo Workspace)

```
clients/rust/
├── Cargo.toml          # Workspace configuration
├── core/               # geniustechspace-core crate
│   ├── Cargo.toml
│   └── src/lib.rs
├── idp/                # geniustechspace-idp crate
│   ├── Cargo.toml
│   └── src/lib.rs
└── proto/              # Generated proto files
    └── core.v1.rs
```

**Dependencies**: Managed in workspace Cargo.toml
- tonic 0.12 (gRPC)
- prost 0.13 (Protocol Buffers)
- serde 1.0 (Serialization)
- validator 0.18 (Validation)

## 🐍 Python Packages

```
clients/python/
├── core/
│   ├── pyproject.toml
│   ├── .venv/          # Virtual environment (created by setup.sh)
│   ├── __init__.py
│   └── v1/
│       ├── __init__.py
│       ├── tenant_pb2.py
│       └── tenant_pb2_grpc.py
├── idp/
│   ├── pyproject.toml
│   ├── .venv/          # Virtual environment
│   ├── __init__.py
│   └── v1/
│       └── __init__.py
└── notification/
    ├── pyproject.toml
    ├── .venv/
    └── __init__.py
```

**Dependencies** (in each pyproject.toml):
- grpcio >= 1.68.0
- grpcio-tools >= 1.68.0
- protobuf >= 5.28.0
- pydantic >= 2.10.0

**Setup**: `setup.sh` creates `.venv` and installs all dependencies including dev tools (pytest, mypy, black, isort)

## 📘 TypeScript (NPM Workspace)

```
clients/typescript/
├── package.json        # Workspace root
├── node_modules/       # Root dependencies (created by setup.sh)
└── packages/
    ├── core/
    │   ├── package.json
    │   ├── node_modules/  # Package dependencies
    │   └── v1/
    │       └── tenant.ts
    ├── idp/
    │   ├── package.json
    │   ├── node_modules/
    │   └── v1/
    └── notification/
        ├── package.json
        └── node_modules/
```

**Dependencies** (in each package.json):
- @grpc/grpc-js ^1.12.2
- @grpc/proto-loader ^0.7.13
- protobufjs ^7.4.0
- typescript ^5.7.2 (dev)

**Setup**: `setup.sh` runs `npm install` at root and for each package

## 🐹 Go Modules

```
clients/go/
├── core/
│   ├── go.mod
│   ├── go.sum
│   └── v1/
│       └── tenant.pb.go
├── idp/
│   ├── go.mod
│   ├── go.sum
│   └── v1/
└── notification/
    ├── go.mod
    └── go.sum
```

**Dependencies** (in each go.mod):
- google.golang.org/grpc v1.68.1
- google.golang.org/protobuf v1.35.2
- github.com/envoyproxy/protoc-gen-validate v1.1.0

**Setup**: `setup.sh` runs `go mod download` for each module

## ☕ Java (Maven Multi-Module)

```
clients/java/
├── pom.xml             # Parent POM
├── core/
│   ├── pom.xml
│   └── src/
│       └── main/java/com/geniustechspace/api/core/
├── idp/
│   ├── pom.xml
│   └── src/
└── notification/
    └── pom.xml
```

**Dependencies** (in parent pom.xml):
- protobuf-java 4.28.3
- grpc-java 1.68.1

**Setup**: `setup.sh` runs `mvn dependency:resolve`

## 🔧 Makefile Integration

All scripts are integrated into the Makefile:

```bash
make setup              # Runs scripts/setup.sh
make generate           # Runs scripts/generate_clients.sh
make generate-rust      # Runs scripts/generate_rust.sh
make generate-python    # Runs scripts/generate_python.sh
make generate-ts        # Runs scripts/generate_ts.sh
make validate-structure # Runs scripts/validate_structure.sh
```

## 🎯 Workflow

### Initial Setup
```bash
make setup              # Sets up all environments (Python .venv, npm node_modules, etc.)
```

### Generate Clients
```bash
make generate           # Generates all clients from proto files
```

### Validate Structure
```bash
make validate-structure # Checks that clients match proto modules
```

### Development
```bash
# Python
cd clients/python/core
source .venv/bin/activate
pip install -e .

# TypeScript
cd clients/typescript
npm install
npm run build

# Rust
cd clients/rust
cargo build --workspace
```

## 📋 Recommendations

1. **Remove unused notification clients** if you don't have `proto/notification`:
   ```bash
   rm -rf clients/*/notification
   # Or create proto/notification/ if you need it
   ```

2. **Always run validation** after structural changes:
   ```bash
   make validate-structure
   ```

3. **Use setup script** when onboarding new developers:
   ```bash
   make setup
   ```

4. **Keep scripts and Makefile in sync** - All generation should go through make commands

## ✅ Current Status

- ✅ All scripts updated and working
- ✅ Scripts integrated with Makefile
- ✅ All external dependencies included
- ✅ Python: .venv support added
- ✅ TypeScript: node_modules support added
- ✅ Structure validation script created
- ⚠️ Warning: Extra client directories for `notification` (no proto files)
