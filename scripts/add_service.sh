#!/bin/bash
# =============================================================================
# add_service.sh - Interactive Service Template Generator
# =============================================================================
# This script provides an interactive way to add new service packages to the
# proto directory. It creates the directory structure, generates proto files
# from templates, and sets up initial README documentation.
#
# Usage:
#   ./scripts/add_service.sh
#   make add-service
#
# Features:
# - Interactive prompts for service details
# - Input validation
# - Template-based proto file generation
# - Automatic directory structure creation
# - README generation
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check for Windows compatibility
check_windows_compatibility() {
    local platform=$(detect_platform)
    if [ "$platform" == "Windows" ]; then
        print_warning "Detected Windows platform"
        print_info "  These scripts require a Unix-like environment."
        print_info "  Please use one of the following:"
        print_info "    • Git Bash (recommended, comes with Git for Windows)"
        print_info "    • Windows Subsystem for Linux (WSL)"
        print_info "    • Cygwin"
        return 1
    fi
    return 0
}

check_windows_compatibility || exit 1

ROOT_DIR=$(get_root_dir)
TEMPLATES_DIR="$ROOT_DIR/templates/service"
PROTO_DIR="$ROOT_DIR/proto"

# =============================================================================
# Validation Functions
# =============================================================================

validate_service_name() {
    local name="$1"
    
    # Check if empty
    if [ -z "$name" ]; then
        print_error "Service name cannot be empty"
        return 1
    fi
    
    # Check format: lowercase letters, numbers, hyphens only
    if ! [[ "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        print_error "Service name must start with a letter and contain only lowercase letters, numbers, and hyphens"
        return 1
    fi
    
    # Check if already exists
    if [ -d "$PROTO_DIR/$name" ]; then
        print_error "Service '$name' already exists in proto/"
        return 1
    fi
    
    # Check reserved names
    local reserved_names=("core" "common" "google" "grpc" "validate")
    for reserved in "${reserved_names[@]}"; do
        if [ "$name" == "$reserved" ]; then
            print_error "Service name '$name' is reserved"
            return 1
        fi
    done
    
    return 0
}

validate_version() {
    local version="$1"
    
    # Check format: v followed by number
    if ! [[ "$version" =~ ^v[0-9]+$ ]]; then
        print_error "Version must be in format 'v1', 'v2', etc."
        return 1
    fi
    
    return 0
}

# =============================================================================
# String Transformation Functions
# =============================================================================

# Convert kebab-case to TitleCase
to_title_case() {
    local input="$1"
    echo "$input" | sed -E 's/(^|-)([a-z])/\U\2/g'
}

# Convert kebab-case to UPPER_CASE
to_upper_case() {
    local input="$1"
    echo "$input" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

# Convert kebab-case to lowercase
to_lower_case() {
    local input="$1"
    echo "$input" | tr '[:upper:]' '[:lower:]'
}

# Convert kebab-case to snake_case
to_snake_case() {
    local input="$1"
    echo "$input" | tr '-' '_'
}

# =============================================================================
# Template Processing
# =============================================================================

process_template() {
    local template_file="$1"
    local output_file="$2"
    local service_name="$3"
    local service_description="$4"
    local version="$5"
    local entity_name="$6"
    
    # Calculate derived values
    local service_name_title=$(to_title_case "$service_name")
    local service_name_upper=$(to_upper_case "$service_name")
    local service_name_lower=$(to_lower_case "$service_name")
    local service_file=$(to_snake_case "$service_name")
    local entity_name_lower=$(to_lower_case "$entity_name")
    local entity_name_upper=$(to_upper_case "$entity_name")
    local message_prefix=$(to_title_case "$service_name")
    local service_description_lower=$(echo "$service_description" | awk '{print tolower($0)}')
    
    # Read template and replace placeholders
    cat "$template_file" | \
        sed "s|{{SERVICE_NAME}}|$service_name|g" | \
        sed "s|{{SERVICE_NAME_TITLE}}|$service_name_title|g" | \
        sed "s|{{SERVICE_NAME_UPPER}}|$service_name_upper|g" | \
        sed "s|{{SERVICE_NAME_LOWER}}|$service_name_lower|g" | \
        sed "s|{{SERVICE_FILE}}|$service_file|g" | \
        sed "s|{{SERVICE_DESCRIPTION}}|$service_description|g" | \
        sed "s|{{SERVICE_DESCRIPTION_LOWER}}|$service_description_lower|g" | \
        sed "s|{{VERSION}}|$version|g" | \
        sed "s|{{ENTITY_NAME}}|$entity_name|g" | \
        sed "s|{{ENTITY_NAME_LOWER}}|$entity_name_lower|g" | \
        sed "s|{{ENTITY_NAME_UPPER}}|$entity_name_upper|g" | \
        sed "s|{{MESSAGE_PREFIX}}|$message_prefix|g" \
        > "$output_file"
}

# =============================================================================
# Main Interactive Flow
# =============================================================================

main() {
    print_section "Service Template Generator"
    
    # Check if templates exist
    if [ ! -d "$TEMPLATES_DIR" ]; then
        print_error "Templates directory not found: $TEMPLATES_DIR"
        print_info "Please ensure templates/service/ directory exists"
        exit 1
    fi
    
    print_info "This tool will help you create a new service package in the proto directory."
    print_info "You'll be prompted for service details, and proto files will be generated from templates."
    echo ""
    
    # Prompt for service name
    while true; do
        read -p "$(echo -e ${BLUE}Service name${NC}) (lowercase, e.g., 'user-management', 'notification'): " SERVICE_NAME
        if validate_service_name "$SERVICE_NAME"; then
            break
        fi
        echo ""
    done
    
    # Prompt for service description
    read -p "$(echo -e ${BLUE}Service description${NC}) (brief, e.g., 'User management and authentication'): " SERVICE_DESCRIPTION
    if [ -z "$SERVICE_DESCRIPTION" ]; then
        SERVICE_DESCRIPTION="Service for $SERVICE_NAME"
    fi
    
    # Prompt for version
    while true; do
        read -p "$(echo -e ${BLUE}API version${NC}) (default: v1): " VERSION
        VERSION=${VERSION:-v1}
        if validate_version "$VERSION"; then
            break
        fi
        echo ""
    done
    
    # Prompt for main entity name
    read -p "$(echo -e ${BLUE}Main entity name${NC}) (TitleCase, e.g., 'User', 'Notification', default: '$(to_title_case $SERVICE_NAME)'): " ENTITY_NAME
    if [ -z "$ENTITY_NAME" ]; then
        ENTITY_NAME=$(to_title_case "$SERVICE_NAME")
    fi
    
    echo ""
    print_section "Summary"
    echo "Service Name:    $SERVICE_NAME"
    echo "Description:     $SERVICE_DESCRIPTION"
    echo "Version:         $VERSION"
    echo "Entity Name:     $ENTITY_NAME"
    echo "Location:        proto/$SERVICE_NAME/$VERSION/"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Proceed with creation?${NC}) (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        print_warning "Cancelled by user"
        exit 0
    fi
    
    # Create directory structure
    print_section "Creating Directory Structure"
    
    local service_dir="$PROTO_DIR/$SERVICE_NAME"
    local version_dir="$service_dir/$VERSION"
    
    mkdir -p "$version_dir"
    print_success "Created $service_dir"
    print_success "Created $version_dir"
    
    # Generate README
    print_section "Generating Documentation"
    
    local readme_template="$TEMPLATES_DIR/README.md.template"
    local readme_output="$service_dir/README.md"
    
    if [ -f "$readme_template" ]; then
        process_template "$readme_template" "$readme_output" "$SERVICE_NAME" "$SERVICE_DESCRIPTION" "$VERSION" "$ENTITY_NAME"
        print_success "Generated README.md"
    else
        print_warning "README template not found, skipping"
    fi
    
    # Generate proto file
    print_section "Generating Proto Files"
    
    local proto_template="$TEMPLATES_DIR/service.proto.template"
    local service_file=$(to_snake_case "$SERVICE_NAME")
    local proto_output="$version_dir/${service_file}.proto"
    
    if [ -f "$proto_template" ]; then
        process_template "$proto_template" "$proto_output" "$SERVICE_NAME" "$SERVICE_DESCRIPTION" "$VERSION" "$ENTITY_NAME"
        print_success "Generated ${service_file}.proto"
    else
        print_error "Proto template not found: $proto_template"
        exit 1
    fi
    
    # Summary
    print_section "Success!"
    echo ""
    print_success "Service package '$SERVICE_NAME' created successfully!"
    echo ""
    
    # Automatically sync workspace configurations
    print_info "Synchronizing workspace configurations..."
    if [ -f "$SCRIPT_DIR/sync_workspaces.sh" ]; then
        bash "$SCRIPT_DIR/sync_workspaces.sh"
    else
        print_warning "sync_workspaces.sh not found - run 'make sync-workspaces' manually"
    fi
    echo ""
    
    print_info "Next steps:"
    echo "  1. Review and customize the generated proto files:"
    echo "     - $readme_output"
    echo "     - $proto_output"
    echo ""
    echo "  2. Generate clients for all languages:"
    echo "     make generate"
    echo ""
    echo "  3. Lint proto files:"
    echo "     make lint"
    echo ""
    echo "  4. Validate structure:"
    echo "     make validate-structure"
    echo ""
    print_info "The service will be automatically discovered by all scripts and workflows."
    print_info "Workspace configurations have been synchronized!"
    echo ""
}

# Run main function
main
