#!/bin/bash
# common.sh - Shared utility functions for all scripts
# This script provides common functionality to avoid code duplication

# Colors for output
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export NC='\033[0m' # No Color

# Get the root directory of the repository
# This should be called from scripts in the scripts/ directory
get_root_dir() {
    # Get the directory of the calling script
    local caller_script="${BASH_SOURCE[1]}"
    if [ -z "$caller_script" ]; then
        # Fallback: use current working directory's parent if we're in scripts/
        if [[ "$(basename $(pwd))" == "scripts" ]]; then
            dirname "$(pwd)"
        else
            pwd
        fi
    else
        local script_dir="$(cd "$(dirname "$caller_script")" && pwd)"
        dirname "$script_dir"
    fi
}

# Discover proto modules by scanning the proto/ directory
# Returns an array of module names
discover_proto_modules() {
    local root_dir="$1"
    local modules=()
    
    if [ ! -d "$root_dir/proto" ]; then
        echo "" # Return empty if proto dir doesn't exist
        return
    fi
    
    for dir in "$root_dir/proto"/*/; do
        if [ -d "$dir" ]; then
            local module_name=$(basename "$dir")
            # Skip hidden directories and the proto directory itself
            if [[ "$module_name" != "proto" && ! "$module_name" =~ ^\. ]]; then
                modules+=("$module_name")
            fi
        fi
    done
    
    echo "${modules[@]}"
}

# Print a colored section header
print_section() {
    local message="$1"
    echo -e "\n${BLUE}=== $message ===${NC}\n"
}

# Print a success message
print_success() {
    local message="$1"
    echo -e "${GREEN}✓ $message${NC}"
}

# Print an error message
print_error() {
    local message="$1"
    echo -e "${RED}✗ $message${NC}"
}

# Print a warning message
print_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠ $message${NC}"
}

# Print an info message
print_info() {
    local message="$1"
    echo -e "${BLUE}$message${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check platform and return platform name
detect_platform() {
    local os="$(uname -s)"
    case "$os" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*)    echo "Windows";;
        MINGW*)     echo "Windows";;
        MSYS*)      echo "Windows";;
        *)          echo "Unknown";;
    esac
}

# Check if running on Windows and provide helpful message
check_windows_compatibility() {
    local platform=$(detect_platform)
    if [ "$platform" = "Windows" ]; then
        print_warning "Detected Windows platform"
        print_info "These scripts require a Unix-like environment."
        print_info "Please use one of the following:"
        print_info "  • Git Bash (recommended, comes with Git for Windows)"
        print_info "  • Windows Subsystem for Linux (WSL)"
        print_info "  • Cygwin"
        echo ""
        
        # Check if running in Git Bash or WSL
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
            print_success "Running in compatible environment"
        else
            print_error "Not running in a compatible Unix environment"
            print_info "Download Git Bash from: https://git-scm.com/downloads"
            return 1
        fi
    fi
    return 0
}

# Export functions so they can be used in other scripts
export -f get_root_dir
export -f discover_proto_modules
export -f print_section
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f command_exists
export -f detect_platform
export -f check_windows_compatibility
