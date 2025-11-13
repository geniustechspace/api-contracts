#!/bin/bash
# test_discovery.sh - Test script to verify self-discovery functionality

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Testing Self-Discovery Functionality               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Platform detection
print_section "Test 1: Platform Detection"
PLATFORM=$(detect_platform)
print_info "Detected platform: $PLATFORM"
if [ -n "$PLATFORM" ]; then
    print_success "Platform detection works"
else
    print_error "Platform detection failed"
    exit 1
fi

# Test 2: Root directory detection
print_section "Test 2: Root Directory Detection"
ROOT_DIR=$(get_root_dir)
print_info "Root directory: $ROOT_DIR"
if [ -d "$ROOT_DIR/proto" ]; then
    print_success "Root directory correctly identified"
else
    print_error "Root directory detection failed"
    exit 1
fi

# Test 3: Proto module discovery
print_section "Test 3: Proto Module Discovery"
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))
print_info "Discovered ${#PROTO_MODULES[@]} module(s): ${PROTO_MODULES[*]}"
if [ ${#PROTO_MODULES[@]} -gt 0 ]; then
    print_success "Module discovery works"
    for module in "${PROTO_MODULES[@]}"; do
        print_info "  → $module"
    done
else
    print_warning "No modules found (proto/ directory may be empty)"
fi

# Test 4: Command existence checks
print_section "Test 4: Command Existence Checks"
test_commands=("bash" "ls" "pwd")
for cmd in "${test_commands[@]}"; do
    if command_exists "$cmd"; then
        print_success "$cmd found"
    else
        print_error "$cmd not found"
    fi
done

# Test 5: Color output
print_section "Test 5: Color Output Functions"
print_success "This is a success message"
print_error "This is an error message"
print_warning "This is a warning message"
print_info "This is an info message"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║     All Tests Completed                                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
print_success "Self-discovery functionality is working correctly!"
print_info "Scripts are ready to use"
