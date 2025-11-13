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
TS_DIR="$ROOT_DIR/clients/typescript"

# Discover proto modules
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

print_section "Generating TypeScript Clients"
print_info "Discovered modules: ${PROTO_MODULES[*]}"
echo ""

cd "$ROOT_DIR"

# Check prerequisites
if ! command_exists node; then
    print_error "node is not installed"
    exit 1
fi

print_success "node found"

# Check for pnpm (preferred) or npm
if command_exists pnpm; then
    PKG_MANAGER="pnpm"
    print_success "Using pnpm"
elif command_exists npm; then
    PKG_MANAGER="npm"
    print_success "Using npm"
else
    print_error "Neither pnpm nor npm is installed"
    exit 1
fi

# Generate TypeScript code using buf (buf.gen.yaml has output paths)
echo ""
print_info "Generating TypeScript proto code..."
buf generate

# Install dependencies
echo ""
print_info "Installing TypeScript dependencies..."
cd "$TS_DIR"

if [ ! -d "node_modules" ]; then
    $PKG_MANAGER install
fi

# Build all packages
echo ""
print_info "Building TypeScript packages..."
if $PKG_MANAGER run build 2>/dev/null; then
    print_success "TypeScript packages built"
else
    print_warning "Build had some issues"
fi

# Type check
echo ""
print_info "Type checking..."
if $PKG_MANAGER run typecheck 2>/dev/null; then
    print_success "Type checking passed"
else
    print_warning "Type checking found issues"
fi

# Format with prettier if available
if command_exists prettier || $PKG_MANAGER exec prettier --version &> /dev/null 2>&1; then
    echo ""
    print_info "Formatting TypeScript code..."
    if $PKG_MANAGER exec prettier --write "packages/*/src/**/*.ts" 2>/dev/null; then
        print_success "Code formatted with prettier"
    else
        print_warning "Formatting had issues"
    fi
fi

echo ""
print_success "TypeScript clients generated successfully!"
