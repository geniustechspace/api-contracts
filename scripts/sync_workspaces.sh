#!/bin/bash
# =============================================================================
# sync_workspaces.sh - Synchronize Workspace Configurations
# =============================================================================
# This script automatically updates workspace configuration files to include
# all proto modules discovered in the proto/ directory.
#
# Updated files:
# - clients/rust/Cargo.toml (workspace members)
# - clients/java/pom.xml (modules)
# - clients/typescript/package.json (workspaces)
#
# Usage:
#   ./scripts/sync_workspaces.sh
#   make sync-workspaces
#
# Exit codes:
#   0 - Changes were made to workspace configurations
#   1 - No changes needed (already up to date)
#   2 - Error occurred during synchronization
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_windows_compatibility || exit 1

ROOT_DIR=$(get_root_dir)
cd "$ROOT_DIR"

# Cleanup function for temp files
cleanup_temp_files() {
    rm -f "${RUST_TEMP:-}" "${JAVA_TEMP:-}" 2>/dev/null
}
trap cleanup_temp_files EXIT

print_section "Synchronizing Workspace Configurations"

# Discover proto modules
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

if [ ${#PROTO_MODULES[@]} -eq 0 ]; then
    print_error "No proto modules found in proto/ directory"
    exit 2
fi

print_info "Discovered modules: ${PROTO_MODULES[*]}"
echo ""

CHANGES_MADE=false

# =============================================================================
# Update Rust Workspace
# =============================================================================
print_info "Updating Rust workspace (Cargo.toml)..."

RUST_CARGO="$ROOT_DIR/clients/rust/Cargo.toml"
if [ -f "$RUST_CARGO" ]; then
    # Create temporary file with updated members
    RUST_TEMP=$(mktemp)
    
    # Read the file and replace the members array
    awk -v modules="${PROTO_MODULES[*]}" '
    BEGIN { in_members = 0; printed_members = 0 }
    /^\[workspace\]/ { in_members = 1; print; next }
    /^members = \[/ && in_members {
        print "members = ["
        split(modules, arr, " ")
        n = length(arr)
        for (i = 1; i <= n; i++) {
            printf "    \"%s\",\n", arr[i]
        }
        print "]"
        printed_members = 1
        # Skip until the closing bracket
        while (getline > 0 && !/^\]/) {}
        next
    }
    /^\[/ && in_members && printed_members { in_members = 0 }
    { print }
    ' "$RUST_CARGO" > "$RUST_TEMP"
    
    if ! diff -q "$RUST_CARGO" "$RUST_TEMP" > /dev/null 2>&1; then
        mv "$RUST_TEMP" "$RUST_CARGO"
        print_success "Rust workspace updated"
        CHANGES_MADE=true
    else
        print_info "Rust workspace already up to date"
    fi
else
    print_warning "Rust Cargo.toml not found"
fi

echo ""

# =============================================================================
# Update Java POM
# =============================================================================
print_info "Updating Java modules (pom.xml)..."

JAVA_POM="$ROOT_DIR/clients/java/pom.xml"
if [ -f "$JAVA_POM" ]; then
    # Create temporary file with updated modules
    JAVA_TEMP=$(mktemp)
    
    # Read the file and replace the modules section
    awk -v modules="${PROTO_MODULES[*]}" '
    /<modules>/ {
        print "    <modules>"
        split(modules, arr, " ")
        n = length(arr)
        for (i = 1; i <= n; i++) {
            printf "        <module>%s</module>\n", arr[i]
        }
        print "    </modules>"
        # Skip until the closing tag
        while (getline > 0 && !/<\/modules>/) {}
        next
    }
    { print }
    ' "$JAVA_POM" > "$JAVA_TEMP"
    
    if ! diff -q "$JAVA_POM" "$JAVA_TEMP" > /dev/null 2>&1; then
        mv "$JAVA_TEMP" "$JAVA_POM"
        print_success "Java modules updated"
        CHANGES_MADE=true
    else
        print_info "Java modules already up to date"
    fi
else
    print_warning "Java pom.xml not found"
fi

echo ""

# =============================================================================
# Update TypeScript Workspaces
# =============================================================================
print_info "Updating TypeScript workspaces (package.json)..."

TS_PACKAGE="$ROOT_DIR/clients/typescript/package.json"
if [ -f "$TS_PACKAGE" ]; then
    # Use Python to update JSON (more reliable than awk for JSON)
    export PROTO_MODULES_STR="${PROTO_MODULES[*]}"
    export TS_PACKAGE_PATH="$TS_PACKAGE"
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

try:
    modules = os.environ.get("PROTO_MODULES_STR", "").split()
    ts_package = os.environ.get("TS_PACKAGE_PATH", "")
    
    with open(ts_package, "r") as f:
        data = json.load(f)
    
    # Update workspaces array, keeping special packages
    special_packages = ["packages/validate", "packages/google"]
    new_workspaces = special_packages + [f"packages/{m}" for m in modules]
    
    # Remove duplicates while preserving order
    seen = set()
    unique_workspaces = []
    for ws in new_workspaces:
        if ws not in seen:
            seen.add(ws)
            unique_workspaces.append(ws)
    
    if data.get("workspaces") != unique_workspaces:
        data["workspaces"] = unique_workspaces
        with open(ts_package, "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
        sys.exit(0)  # Changed
    else:
        sys.exit(1)  # Not changed
except (FileNotFoundError, json.JSONDecodeError, KeyError) as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(2)  # Error
PYTHON_SCRIPT
    
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        print_success "TypeScript workspaces updated"
        CHANGES_MADE=true
    elif [ $exit_code -eq 1 ]; then
        print_info "TypeScript workspaces already up to date"
    else
        print_error "Failed to update TypeScript workspaces"
        exit 2
    fi
else
    print_warning "TypeScript package.json not found"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================
print_section "Synchronization Complete"

if [ "$CHANGES_MADE" = true ]; then
    print_success "Workspace configurations updated"
    print_info "Modules synchronized: ${PROTO_MODULES[*]}"
    echo ""
    print_warning "Run 'git diff' to review changes before committing"
    exit 0  # Changed
else
    print_success "All workspace configurations are already up to date"
    exit 1  # Unchanged
fi
