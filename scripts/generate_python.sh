#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Generating Python Clients ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PYTHON_DIR="$ROOT_DIR/clients/python"

cd "$ROOT_DIR"

# Check prerequisites
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ python3 found${NC}"

# Generate Python code using buf with dependencies
# Generates validate protos (needed by generated code) + protovalidate runtime (pip installed)
echo -e "${BLUE}Generating Python proto code...${NC}"
buf generate --include-imports

# The generated validate module is kept as-is (needed for imports in generated code)
# Runtime validation uses protovalidate from PyPI

# Build all Python packages
cd "$PYTHON_DIR"
for package in */; do
    if [ -d "$package" ] && [ -f "$package/pyproject.toml" ]; then
        package_name=$(basename "$package")
        echo -e "\n${BLUE}Building $package_name...${NC}"
        cd "$package"
        
        # Install in development mode
        python3 -m pip install -e . --quiet || echo -e "${RED}Warning: Failed to install $package_name${NC}"
        
        cd "$PYTHON_DIR"
    fi
done

# Format code with black if available
if command -v black &> /dev/null; then
    echo -e "\n${BLUE}Formatting Python code with black...${NC}"
    black "$PYTHON_DIR" || echo -e "${RED}Black formatting had issues${NC}"
fi

echo -e "\n${GREEN}✓ Python clients generated successfully!${NC}"
