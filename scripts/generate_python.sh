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

print_section "Generating Python Clients"
print_info "Discovered modules: ${PROTO_MODULES[*]}"
echo ""

cd "$ROOT_DIR"

# Check prerequisites
if ! command_exists python3; then
    print_error "python3 is not installed"
    exit 1
fi

print_success "python3 found"

# Generate Python code using buf with dependencies
# Generates validate protos (needed by generated code) + protovalidate runtime (pip installed)
print_info "Generating Python proto code..."
buf generate --include-imports

# The generated validate module is kept as-is (needed for imports in generated code)
# Runtime validation uses protovalidate from PyPI

# Build Python packages (only for discovered proto modules)
if [ ${#PROTO_MODULES[@]} -eq 0 ]; then
    print_warning "No proto modules found to build"
else
    cd "$PYTHON_DIR"
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "$module" ] && [ -f "$module/pyproject.toml" ]; then
            echo ""
            print_info "Building $module..."
            cd "$module"
            
            # Install in development mode
            if python3 -m pip install -e . --quiet 2>/dev/null; then
                print_success "$module installed in development mode"
            else
                print_warning "Failed to install $module in development mode"
            fi
            
            cd "$PYTHON_DIR"
        else
            print_warning "Skipping $module - directory or pyproject.toml not found"
        fi
    done
fi

# Format code with black if available
if command_exists black; then
    echo ""
    print_info "Formatting Python code with black..."
    if black "$PYTHON_DIR" --quiet 2>/dev/null; then
        print_success "Code formatted with black"
    else
        print_warning "Black formatting had issues"
    fi
fi

echo ""
print_success "Python clients generated successfully!"
