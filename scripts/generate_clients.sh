#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Generating All API Clients ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
if ! command -v buf &> /dev/null; then
    echo -e "${RED}Error: buf is not installed${NC}"
    echo "Install it from: https://docs.buf.build/installation"
    exit 1
fi

echo -e "${GREEN}✓ buf found${NC}\n"

# Generate with buf
echo -e "${BLUE}Generating code with buf...${NC}"
buf generate

# Clean up Python validate directory (we use protovalidate from PyPI)
PYTHON_DIR="$ROOT_DIR/clients/python"
if [ -d "$PYTHON_DIR/validate" ]; then
    echo -e "${BLUE}Cleaning up Python validate directory (using protovalidate from PyPI)...${NC}"
    rm -rf "$PYTHON_DIR/validate"
fi

echo -e "\n${BLUE}Running language-specific scripts...${NC}\n"

# Run Rust generation
if [ -f "$SCRIPT_DIR/generate_rust.sh" ]; then
    echo -e "${BLUE}Generating Rust clients...${NC}"
    bash "$SCRIPT_DIR/generate_rust.sh"
else
    echo -e "${RED}Warning: generate_rust.sh not found${NC}"
fi

# Run Python generation
if [ -f "$SCRIPT_DIR/generate_python.sh" ]; then
    echo -e "\n${BLUE}Generating Python clients...${NC}"
    bash "$SCRIPT_DIR/generate_python.sh"
else
    echo -e "${RED}Warning: generate_python.sh not found${NC}"
fi

# Run TypeScript generation
if [ -f "$SCRIPT_DIR/generate_ts.sh" ]; then
    echo -e "\n${BLUE}Generating TypeScript clients...${NC}"
    bash "$SCRIPT_DIR/generate_ts.sh"
else
    echo -e "${RED}Warning: generate_ts.sh not found${NC}"
fi

echo -e "\n${GREEN}=== All clients generated successfully! ===${NC}"
