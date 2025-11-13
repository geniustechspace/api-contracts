#!/bin/bash
# validate_structure.sh - Validates that client structure matches proto structure

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Client Structure Validation                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"

# Check Windows compatibility
check_windows_compatibility || exit 1

# Get directories
ROOT_DIR=$(get_root_dir)

cd "$ROOT_DIR"

# Detect proto modules
print_info "Scanning proto/ directory..."
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

for module in "${PROTO_MODULES[@]}"; do
    print_success "Found module: $module"
done

if [ ${#PROTO_MODULES[@]} -eq 0 ]; then
    print_error "No proto modules found in proto/ directory"
    exit 1
fi

echo ""
print_info "Validating client structure..."
echo ""

ERRORS=0
WARNINGS=0

# Function to check if module exists in client
check_client_module() {
    local lang=$1
    local module=$2
    local path=$3
    
    if [ -d "$path" ]; then
        print_success "$lang/$module exists"
        return 0
    else
        print_error "$lang/$module missing"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check for extra client modules
check_extra_modules() {
    local lang=$1
    local base_path=$2
    
    for client_dir in "$base_path"/*; do
        if [ -d "$client_dir" ]; then
            module_name=$(basename "$client_dir")
            
            # Skip special directories and generated dependencies (validate, google, etc.)
            if [[ "$module_name" == "proto" || "$module_name" == "target" || "$module_name" == "node_modules" || "$module_name" == ".venv" || "$module_name" == "packages" || "$module_name" == "com" || "$module_name" == "google" || "$module_name" == "validate" ]]; then
                continue
            fi
            
            # Check if this module has a proto definition
            local has_proto=false
            for proto_module in "${PROTO_MODULES[@]}"; do
                if [ "$proto_module" == "$module_name" ]; then
                    has_proto=true
                    break
                fi
            done
            
            if [ "$has_proto" == "false" ]; then
                print_warning "$lang/$module_name exists but no proto/$module_name found"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    done
}

# Validate Rust
print_info "Rust Workspace:"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "rust" "$module" "clients/rust/$module"
done
check_extra_modules "rust" "clients/rust"

# Validate Go
echo ""
print_info "Go Modules:"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "go" "$module" "clients/go/$module"
done
check_extra_modules "go" "clients/go"

# Validate Python
echo ""
print_info "Python Packages:"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "python" "$module" "clients/python/$module"
    
    # Check for pyproject.toml
    if [ -f "clients/python/$module/pyproject.toml" ]; then
        echo "    ✓ pyproject.toml present"
    else
        print_error "    pyproject.toml missing"
        ERRORS=$((ERRORS + 1))
    fi
done
check_extra_modules "python" "clients/python"

# Validate TypeScript
echo ""
print_info "TypeScript Packages:"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "typescript" "$module" "clients/typescript/packages/$module"
    
    # Check for package.json
    if [ -f "clients/typescript/packages/$module/package.json" ]; then
        echo "    ✓ package.json present"
    else
        print_error "    package.json missing"
        ERRORS=$((ERRORS + 1))
    fi
done
check_extra_modules "typescript" "clients/typescript/packages"

# Validate Java
echo ""
print_info "Java Modules:"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "java" "$module" "clients/java/$module"
    
    # Check for pom.xml
    if [ -f "clients/java/$module/pom.xml" ]; then
        echo "    ✓ pom.xml present"
    else
        print_error "    pom.xml missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Summary
echo ""
echo "════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "All checks passed!"
    print_success "  Client structure matches proto structure"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_warning "Validation completed with warnings"
    print_warning "  $WARNINGS warning(s) - extra client directories without proto definitions"
    print_warning "  Consider removing unused client directories"
    exit 0
else
    print_error "Validation failed"
    print_error "  $ERRORS error(s), $WARNINGS warning(s)"
    exit 1
fi
