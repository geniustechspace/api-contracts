# Scripts & Client Structure Summary

## ✅ Scripts Overview

All scripts in `/scripts/` are now **self-discovering** and **cross-platform compatible**. They automatically detect proto modules and adapt to package additions/deletions.

### 🔍 Self-Discovery Feature

All scripts now automatically discover packages by scanning the `proto/` directory. **No manual updates needed** when adding or removing packages!

- **Package Discovery**: Scripts scan `proto/` and process all top-level directories
- **Automatic Adaptation**: Add a new proto module → all scripts automatically include it
- **No Hardcoding**: Package lists are never hardcoded in scripts
- **Shared Utilities**: Common `common.sh` provides reusable functions for all scripts

### 💻 Cross-Platform Support

Scripts are designed to work on:
- ✅ **Linux** (all distributions with Bash)
- ✅ **macOS** (native Bash support)
- ✅ **Windows** (requires Git Bash, WSL, or Cygwin)

Windows users will receive helpful instructions if running in an incompatible environment.

### Available Scripts

1. **`common.sh`** - Shared utility library (sourced by other scripts)
   - `discover_proto_modules()` - Auto-discovers packages from proto directory
   - `detect_platform()` - Detects OS (Linux/macOS/Windows)
   - `check_windows_compatibility()` - Validates Windows environment
   - Color output functions: `print_success`, `print_error`, `print_warning`, `print_info`
   - Common checks: `command_exists()`, `get_root_dir()`

2. **`setup.sh`** - Complete development environment setup
   - ✨ **Auto-detects** proto modules - no configuration needed
   - Sets up Python virtual environments (`.venv` in Python workspace)
   - Installs npm dependencies (`node_modules` in TypeScript workspace)
   - Configures all 5 languages: Rust, Go, Python, TypeScript, Java
   - Cross-platform with Windows compatibility checks
   - Usage: `make setup` or `./scripts/setup.sh`

3. **`generate_clients.sh`** - Master generation script
   - ✨ **Auto-discovers** modules to generate
   - Generates all clients using buf
   - Calls language-specific scripts (no code duplication)
   - Shows progress for each language
   - Usage: `make generate`

4. **`generate_rust.sh`** - Rust client generation
   - ✨ **Auto-discovers** Rust packages from proto modules
   - Generates proto code via build.rs
   - Builds workspace with cargo
   - Runs tests and linters (clippy, cargo fmt)
   - Usage: `make generate-rust`

5. **`generate_python.sh`** - Python client generation
   - ✨ **Auto-discovers** Python packages from proto modules
   - Generates proto code with buf
   - Installs discovered packages in development mode
   - Formats with black (if available)
   - Usage: `make generate-python`

6. **`generate_ts.sh`** - TypeScript client generation
   - ✨ **Auto-discovers** TypeScript packages from proto modules
   - Generates proto code with buf
   - Installs npm dependencies
   - Builds and type-checks packages
   - Formats with prettier (if available)
   - Usage: `make generate-ts`

7. **`build_python.py`** - Python distribution builder
   - ✨ **Auto-discovers** packages from proto directory
   - Creates wheel (.whl) files for distribution
   - No hardcoded package lists
   - Usage: `make build-python`

8. **`validate_structure.sh`** - Structure validation
   - ✨ **Auto-discovers** proto modules to validate
   - Validates clients match proto modules
   - Checks for missing/extra client directories
   - Verifies package files (pyproject.toml, package.json, pom.xml)
   - Usage: `make validate-structure`

### Note on Go and Java

Go and Java don't have dedicated generation scripts because they only need `buf generate`:
- **Go**: Uses `buf generate` directly (handled by Makefile)
- **Java**: Uses `buf generate` directly (handled by Makefile)

These languages don't require additional post-generation steps like building or formatting that Python, Rust, and TypeScript need. The generation is automatically managed by `buf.gen.yaml` configuration.

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

## 🆕 Adding a New Package

Thanks to self-discovery, adding a new package is simple:

1. **Create the proto directory**:
   ```bash
   mkdir -p proto/my-new-service/v1
   # Add your .proto files
   ```

2. **That's it!** Scripts will automatically:
   - Detect the new package in `proto/my-new-service`
   - Generate clients for all languages
   - Set up build configurations
   - Validate the structure

3. **Run generation**:
   ```bash
   make generate           # Automatically includes my-new-service
   make validate-structure # Verifies all clients were created
   ```

No need to update any scripts or configuration files! The discovery mechanism handles everything.

## 🗑️ Removing a Package

To remove a package:

1. **Delete the proto directory**:
   ```bash
   rm -rf proto/old-service
   ```

2. **Clean up client directories** (optional):
   ```bash
   rm -rf clients/*/old-service
   # Or run validate-structure to see what needs cleanup
   ```

3. Scripts will automatically skip the removed package on next run.

## 🔍 How Self-Discovery Works

All scripts use the `discover_proto_modules()` function from `common.sh`:

```bash
# Discovery happens automatically
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

# Example output: (core idp)
# Scripts iterate over discovered modules:
for module in "${PROTO_MODULES[@]}"; do
    # Process each module
done
```

The function:
1. Scans `proto/` directory
2. Returns all subdirectories (except hidden ones)
3. Scripts use this list for all operations
4. No hardcoded package names anywhere!

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

## 💻 Platform-Specific Notes

### Linux & macOS

All scripts work natively on Linux and macOS:

```bash
# Direct script execution
./scripts/setup.sh
./scripts/generate_clients.sh

# Or via Makefile
make setup
make generate
```

### Windows

Scripts require a Unix-like environment on Windows. Choose one of:

#### Option 1: Git Bash (Recommended)
- Comes with Git for Windows
- Download: https://git-scm.com/downloads
- Most convenient option for developers
- Scripts will detect and work automatically

#### Option 2: Windows Subsystem for Linux (WSL)
```powershell
# In PowerShell (Admin)
wsl --install
```
Then run scripts from WSL terminal.

#### Option 3: Cygwin
- Download from: https://www.cygwin.com/
- Select bash package during installation

### Platform Detection

Scripts automatically detect your platform and provide helpful messages:

```bash
$ ./scripts/setup.sh
⚠ Detected Windows platform
  These scripts require a Unix-like environment.
  Please use one of the following:
    • Git Bash (recommended, comes with Git for Windows)
    • Windows Subsystem for Linux (WSL)
    • Cygwin
```

## ✅ Current Status

- ✅ All scripts updated and working
- ✅ **Self-discovery implemented** - scripts auto-detect packages
- ✅ **Cross-platform support** - Linux, macOS, Windows (with Git Bash/WSL)
- ✅ **Code reuse** - common.sh eliminates duplication
- ✅ Scripts integrated with Makefile
- ✅ All external dependencies included
- ✅ Python: .venv support added
- ✅ TypeScript: node_modules support added
- ✅ Structure validation script created
- ⚠️ Warning: Extra client directories for `notification` (no proto files)
