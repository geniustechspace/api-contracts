# Scripts Directory

This directory contains self-discovering, cross-platform scripts for managing the API contracts repository.

## ✨ Key Features

- **🔍 Self-Discovery**: Scripts automatically detect packages by scanning `proto/` directory
- **💻 Cross-Platform**: Works on Linux, macOS, and Windows (with Git Bash/WSL)
- **♻️ Code Reuse**: Common utilities eliminate duplication
- **🎯 Zero Configuration**: Add/remove packages without updating scripts

## 📁 Scripts

### Core Utilities

- **`common.sh`** - Shared functions library
  - Package discovery from proto directory
  - Platform detection
  - Color output helpers
  - Command existence checks

### Main Scripts

- **`setup.sh`** - One-time environment setup
  - Installs dependencies
  - Configures all languages
  - Creates virtual environments
  
- **`generate_clients.sh`** - Generate all clients
  - Runs buf generate
  - Calls language-specific scripts
  - Auto-discovers packages

- **`generate_python.sh`** - Python client generation
- **`generate_rust.sh`** - Rust client generation
- **`generate_ts.sh`** - TypeScript client generation

### Utilities

- **`build_python.py`** - Build Python wheels
- **`validate_structure.sh`** - Validate client structure
- **`test_discovery.sh`** - Test self-discovery functionality

## 🚀 Quick Start

```bash
# Setup environment (first time only)
make setup

# Generate all clients
make generate

# Validate structure
make validate-structure
```

## 🆕 Adding a Package

Simply create a new directory in `proto/`:

```bash
mkdir -p proto/my-service/v1
# Add your .proto files
make generate  # Automatically includes my-service
```

No script changes needed! Discovery is automatic.

## 🔧 How It Works

All scripts use the `discover_proto_modules()` function:

```bash
# From common.sh
source scripts/common.sh
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

# Iterate over discovered modules
for module in "${PROTO_MODULES[@]}"; do
    # Process each module
    echo "Processing $module"
done
```

## 💻 Platform Support

### Linux & macOS
Scripts work natively with bash.

### Windows
Requires a Unix-like environment:
- **Git Bash** (recommended) - https://git-scm.com/downloads
- **WSL** (Windows Subsystem for Linux)
- **Cygwin** - https://www.cygwin.com/

## 🧪 Testing

Run the self-discovery test:

```bash
./scripts/test_discovery.sh
```

This verifies:
- Platform detection
- Root directory detection
- Module discovery
- Command checks
- Color output

## 📖 Documentation

See [SCRIPTS_SUMMARY.md](../SCRIPTS_SUMMARY.md) for detailed documentation.

## 🛠️ Development

When adding new scripts:

1. Source `common.sh` for utilities
2. Use `discover_proto_modules()` instead of hardcoding packages
3. Add platform compatibility checks
4. Follow the existing error handling patterns
5. Use color output functions for consistency

Example:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_windows_compatibility || exit 1

ROOT_DIR=$(get_root_dir)
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

print_section "My Script"
print_info "Discovered modules: ${PROTO_MODULES[*]}"

for module in "${PROTO_MODULES[@]}"; do
    print_info "Processing $module..."
    # Your code here
done

print_success "Done!"
```

## ⚠️ Important Notes

- All scripts use `set -e` for fail-fast behavior
- Use `ERRORS=$((ERRORS + 1))` instead of `((ERRORS++))` to avoid `set -e` issues
- Always use `print_*` functions for consistent output
- Test scripts on multiple platforms when possible
