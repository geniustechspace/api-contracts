# Local Development Guide - Self-Discovery

This repository uses **automatic module discovery** for both CI/CD workflows and local development. No manual configuration is needed when adding new proto modules.

## 🎯 Overview

All build tools, scripts, and workflows automatically discover proto modules by scanning the `proto/` directory. This ensures consistency between local development and CI/CD.

## 📦 Module Structure

Each proto module lives in its own directory:

```
proto/
├── core/           # Core multitenancy, context, errors
│   └── v1/*.proto
└── idp/            # Identity provider (placeholder)
    └── README.md
```

Generated clients are organized by module:

```
clients/
├── rust/
│   ├── core/       # Rust core package
│   └── idp/        # Rust idp package
├── python/
│   ├── core/       # Python core package
│   └── idp/        # Python idp package
├── typescript/packages/
│   ├── core/       # TypeScript core package
│   └── idp/        # TypeScript idp package
├── go/
│   ├── core/       # Go core module
│   └── idp/        # Go idp module
└── java/
    ├── core/       # Java core module
    └── idp/        # Java idp module
```

## 🔍 How Self-Discovery Works

### 1. Scripts (Local Development)

All scripts in `scripts/` use the `discover_proto_modules()` function from `common.sh`:

```bash
# From scripts/common.sh
discover_proto_modules() {
    local root_dir="$1"
    local modules=()
    
    for dir in "$root_dir/proto"/*/; do
        if [ -d "$dir" ]; then
            local module_name=$(basename "$dir")
            if [[ "$module_name" != "proto" && ! "$module_name" =~ ^\. ]]; then
                modules+=("$module_name")
            fi
        fi
    done
    
    echo "${modules[@]}"
}
```

### 2. GitHub Workflows (CI/CD)

Workflows use a `discover-modules` job that scans `proto/`:

```yaml
discover-modules:
  steps:
    - run: |
        modules=$(find proto -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | jq -R -s -c 'split("\n") | map(select(length > 0)) | sort')
        echo "modules=$modules" >> $GITHUB_OUTPUT
```

### 3. Makefile

The Makefile delegates to discovery-enabled scripts:

```makefile
generate:
    @./scripts/generate_clients.sh  # Uses module discovery

validate-structure:
    @./scripts/validate_structure.sh  # Validates discovered modules

build-python:
    @python3 scripts/build_python.py  # Discovers and builds all modules
```

## 🚀 Adding a New Module

### Step 1: Create Proto Directory

```bash
# Create your module directory
mkdir -p proto/notification/v1

# Add your proto files
cat > proto/notification/v1/email.proto << 'EOF'
syntax = "proto3";
package notification.v1;

message EmailRequest {
  string to = 1;
  string subject = 2;
  string body = 3;
}
EOF
```

### Step 2: Generate Clients

```bash
# All clients will be automatically generated for the new module
make generate
```

That's it! No other changes needed. The new module will be:
- ✅ Automatically discovered by all scripts
- ✅ Automatically built in CI/CD workflows
- ✅ Automatically validated for structure
- ✅ Generated for all languages (Rust, Python, TypeScript, Go, Java)

### Step 3: Add Client Directories (if needed)

If `buf generate` doesn't create the client directories automatically, create them:

```bash
# Rust
mkdir -p clients/rust/notification/src
# Add Cargo.toml and lib.rs

# Python
mkdir -p clients/python/notification
# Add pyproject.toml and __init__.py

# TypeScript
mkdir -p clients/typescript/packages/notification
# Add package.json and tsconfig.json

# Go
mkdir -p clients/go/notification
# Add go.mod

# Java
mkdir -p clients/java/notification
# Add pom.xml
```

Then update workspace configs:

```bash
# Rust: clients/rust/Cargo.toml
# Add "notification" to members array

# Java: clients/java/pom.xml
# Add <module>notification</module> to modules

# TypeScript: clients/typescript/package.json
# Add "packages/notification" to workspaces array
```

## 🛠️ Local Development Commands

### Generate Clients

```bash
# Generate all clients (auto-discovers modules)
make generate

# Generate specific language
make generate-rust
make generate-python
make generate-ts
make generate-go
make generate-java
```

### Validate Structure

```bash
# Validate that client structure matches proto structure
make validate-structure

# Output shows discovered modules and validates each:
# ✓ rust/core exists
# ✓ rust/idp exists
# ✓ python/core exists
# etc.
```

### Build Clients

```bash
# Build all clients
make build

# Build specific language
make build-rust
make build-python
make build-ts
make build-go
make build-java
```

### Test Discovery

```bash
# Test the self-discovery functionality
./scripts/test_discovery.sh

# Output shows:
# - Platform detection
# - Root directory detection
# - Module discovery results
# - Available commands
```

## 📋 Available Scripts

All scripts automatically discover modules:

| Script | Purpose | Module Discovery |
|--------|---------|-----------------|
| `generate_clients.sh` | Generate all clients | ✅ Auto-discovers |
| `generate_rust.sh` | Generate Rust clients | ✅ Auto-discovers |
| `generate_python.sh` | Generate Python clients | ✅ Auto-discovers |
| `generate_ts.sh` | Generate TypeScript clients | ✅ Auto-discovers |
| `build_python.py` | Build Python wheels | ✅ Auto-discovers |
| `validate_structure.sh` | Validate client structure | ✅ Auto-discovers |
| `test_discovery.sh` | Test discovery functionality | ✅ Tests discovery |

## 🧪 Testing

### Test Module Discovery

```bash
# Run discovery test
./scripts/test_discovery.sh

# Expected output:
# Discovered 2 module(s): core idp
# ✓ Module discovery works
#   → core
#   → idp
```

### Validate Structure

```bash
# Check that all clients have matching structure
make validate-structure

# This validates:
# - Each discovered module has client directories
# - Each client has proper config files (Cargo.toml, pyproject.toml, etc.)
# - No extra client directories without proto definitions
```

## 🔧 Troubleshooting

### Module Not Discovered?

Check these:

1. **Directory exists in proto/**
   ```bash
   ls proto/
   # Should show your module directory
   ```

2. **Not a hidden directory**
   ```bash
   # Directory names starting with . are ignored
   # ✗ proto/.mymodule  (ignored)
   # ✓ proto/mymodule   (discovered)
   ```

3. **Is a directory, not a file**
   ```bash
   # ✗ proto/module.proto  (file, ignored)
   # ✓ proto/module/       (directory, discovered)
   ```

### Validation Shows Warnings?

If `validate_structure.sh` shows warnings about extra directories:

```bash
⚠ rust/notification exists but no proto/notification found
```

This means you have client directories for modules that don't have proto definitions. Either:
- Add proto files to `proto/notification/`, or
- Remove the unused client directories

### CI/CD Not Finding Module?

The CI/CD workflows use the same discovery logic. If local scripts find it, CI/CD will too. Make sure:
- Module directory is committed to git
- Proto files are committed (not just empty directory)
- `.gitignore` doesn't exclude your module

## 🎓 Best Practices

1. **Module Naming**
   - Use lowercase names: `notification`, `billing`, `auth`
   - Use hyphens for multi-word names: `user-service`, `payment-gateway`
   - Avoid dots or special characters

2. **Proto Organization**
   - Use versioned subdirectories: `proto/module/v1/`
   - Group related protos in the same module
   - Keep each module focused on one domain

3. **Client Structure**
   - Match proto structure in clients
   - Use same module name across all languages
   - Include proper metadata (Cargo.toml, pyproject.toml, etc.)

4. **Testing**
   - Run `make validate-structure` after adding modules
   - Run `./scripts/test_discovery.sh` to verify discovery
   - Test local generation before pushing

## 📚 Related Documentation

- [Scripts README](scripts/README.md) - Detailed script documentation
- [Workflow README](.github/workflows/README.md) - CI/CD documentation
- [QUICKSTART](QUICKSTART.md) - Getting started guide
- [CONTRIBUTING](CONTRIBUTING.md) - Contribution guidelines

## ✅ Summary

**Local development and CI/CD use the same self-discovery strategy:**

1. 🔍 **Scripts discover modules** by scanning `proto/` directory
2. 🔄 **Workflows discover modules** using the same logic
3. 📦 **Each module is a separate package** in each language
4. 🆕 **Adding modules requires no config changes** - just create `proto/[module]/`
5. ✅ **Validation ensures consistency** between proto and client structure

**No manual maintenance needed when adding modules!**
