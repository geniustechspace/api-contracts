#!/bin/bash
# validate_structure.sh - Validates that client structure matches proto structure

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Client Structure Validation                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Detect proto modules
echo -e "${BLUE}Scanning proto/ directory...${NC}"
PROTO_MODULES=()
for dir in proto/*/; do
    if [ -d "$dir" ] && [ "$(basename "$dir")" != "proto" ]; then
        module_name=$(basename "$dir")
        PROTO_MODULES+=("$module_name")
        echo -e "  ${GREEN}✓${NC} Found module: $module_name"
    fi
done

if [ ${#PROTO_MODULES[@]} -eq 0 ]; then
    echo -e "${RED}✗ No proto modules found in proto/ directory${NC}"
    exit 1
fi

echo -e "\n${BLUE}Validating client structure...${NC}\n"

ERRORS=0
WARNINGS=0

# Function to check if module exists in client
check_client_module() {
    local lang=$1
    local module=$2
    local path=$3
    
    if [ -d "$path" ]; then
        echo -e "  ${GREEN}✓${NC} $lang/$module exists"
        return 0
    else
        echo -e "  ${RED}✗${NC} $lang/$module missing"
        ((ERRORS++))
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
                echo -e "  ${YELLOW}⚠${NC}  $lang/$module_name exists but no proto/$module_name found"
                ((WARNINGS++))
            fi
        fi
    done
}

# Validate Rust
echo -e "${BLUE}Rust Workspace:${NC}"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "rust" "$module" "clients/rust/$module"
done
check_extra_modules "rust" "clients/rust"

# Validate Go
echo -e "\n${BLUE}Go Modules:${NC}"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "go" "$module" "clients/go/$module"
done
check_extra_modules "go" "clients/go"

# Validate Python
echo -e "\n${BLUE}Python Packages:${NC}"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "python" "$module" "clients/python/$module"
    
    # Check for pyproject.toml
    if [ -f "clients/python/$module/pyproject.toml" ]; then
        echo -e "    ${GREEN}✓${NC} pyproject.toml present"
    else
        echo -e "    ${RED}✗${NC} pyproject.toml missing"
        ((ERRORS++))
    fi
done
check_extra_modules "python" "clients/python"

# Validate TypeScript
echo -e "\n${BLUE}TypeScript Packages:${NC}"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "typescript" "$module" "clients/typescript/packages/$module"
    
    # Check for package.json
    if [ -f "clients/typescript/packages/$module/package.json" ]; then
        echo -e "    ${GREEN}✓${NC} package.json present"
    else
        echo -e "    ${RED}✗${NC} package.json missing"
        ((ERRORS++))
    fi
done
check_extra_modules "typescript" "clients/typescript/packages"

# Validate Java
echo -e "\n${BLUE}Java Modules:${NC}"
for module in "${PROTO_MODULES[@]}"; do
    check_client_module "java" "$module" "clients/java/$module"
    
    # Check for pom.xml
    if [ -f "clients/java/$module/pom.xml" ]; then
        echo -e "    ${GREEN}✓${NC} pom.xml present"
    else
        echo -e "    ${RED}✗${NC} pom.xml missing"
        ((ERRORS++))
    fi
done

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e "${GREEN}  Client structure matches proto structure${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation completed with warnings${NC}"
    echo -e "${YELLOW}  $WARNINGS warning(s) - extra client directories without proto definitions${NC}"
    echo -e "${YELLOW}  Consider removing unused client directories${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed${NC}"
    echo -e "${RED}  $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
fi
