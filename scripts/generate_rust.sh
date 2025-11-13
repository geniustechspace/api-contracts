#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Check Windows compatibility
check_windows_compatibility || exit 1

# Get directories
ROOT_DIR=$(get_root_dir)
RUST_DIR="$ROOT_DIR/clients/rust"

# Discover proto modules
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

print_section "Generating Rust Clients"
print_info "Discovered modules: ${PROTO_MODULES[*]}"
echo ""

cd "$ROOT_DIR"

# Check prerequisites
if ! command_exists cargo; then
    print_error "cargo is not installed"
    exit 1
fi

print_success "cargo found"

# NOTE: Rust code generation is handled by build.rs during cargo build
# The build.rs script uses tonic-build to compile proto files
print_info "Generating Rust proto code..."
print_success "Code will be generated during cargo build via build.rs"

# Build all Rust clients
echo ""
print_info "Building Rust workspace..."
cd "$RUST_DIR"

# Update Cargo workspace if needed
print_info "Updating dependencies..."
cargo update

# Build all clients (this triggers build.rs which generates the proto code)
print_info "Building all clients..."
cargo build --workspace

# Run tests if they exist
if cargo test --workspace --no-run &> /dev/null; then
    echo ""
    print_info "Running tests..."
    cargo test --workspace
fi

# Format code
if command_exists cargo-fmt || cargo fmt --version &> /dev/null 2>&1; then
    echo ""
    print_info "Formatting code..."
    cargo fmt --all
fi

# Run clippy if available
if command_exists cargo-clippy || cargo clippy --version &> /dev/null 2>&1; then
    echo ""
    print_info "Running clippy..."
    if cargo clippy --workspace --all-targets -- -D warnings; then
        print_success "Clippy checks passed"
    else
        print_warning "Clippy warnings found"
    fi
fi

echo ""
print_success "Rust clients generated and built successfully!"
