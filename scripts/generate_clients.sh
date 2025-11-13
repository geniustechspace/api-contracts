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
PYTHON_DIR="$ROOT_DIR/clients/python"

# Discover proto modules
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

print_section "Generating All API Clients"
print_info "Discovered modules: ${PROTO_MODULES[*]}"
echo ""

cd "$ROOT_DIR"

# Check prerequisites
print_info "Checking prerequisites..."
if ! command_exists buf; then
    print_error "buf is not installed"
    echo "Install it from: https://docs.buf.build/installation"
    exit 1
fi

print_success "buf found"
echo ""

# Generate with buf
print_info "Generating code with buf..."
buf generate

# Clean up Python validate directory (we use protovalidate from PyPI)
if [ -d "$PYTHON_DIR/validate" ]; then
    print_info "Cleaning up Python validate directory (using protovalidate from PyPI)..."
    rm -rf "$PYTHON_DIR/validate"
fi

echo ""
print_section "Running Language-Specific Scripts"

# List of language generation scripts to run
LANGUAGE_SCRIPTS=(
    "generate_rust.sh:Rust"
    "generate_python.sh:Python"
    "generate_ts.sh:TypeScript"
)

# Run each language generation script
for script_info in "${LANGUAGE_SCRIPTS[@]}"; do
    IFS=':' read -r script_name language_name <<< "$script_info"
    
    if [ -f "$SCRIPT_DIR/$script_name" ]; then
        echo ""
        print_info "Generating $language_name clients..."
        if bash "$SCRIPT_DIR/$script_name"; then
            print_success "$language_name generation completed"
        else
            print_error "$language_name generation failed"
            exit 1
        fi
    else
        print_warning "$script_name not found, skipping $language_name"
    fi
done

echo ""
print_section "All Clients Generated Successfully"
print_success "Generated clients for all languages"
print_info "Modules processed: ${PROTO_MODULES[*]}"
