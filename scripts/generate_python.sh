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
PYTHON_DIR="$ROOT_DIR/python"

cd "$ROOT_DIR"

# Check prerequisites
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ python3 found${NC}"

# Check for grpcio-tools
if ! python3 -c "import grpc_tools" &> /dev/null; then
    echo -e "${BLUE}Installing grpcio-tools...${NC}"
    python3 -m pip install grpcio-tools
fi

# Create proto output directory if it doesn't exist
mkdir -p "$PYTHON_DIR/proto"

# Generate Python code using buf
echo -e "${BLUE}Generating Python proto code...${NC}"
buf generate --template buf.gen.yaml --path proto

# Function to build a Python package
build_python_package() {
    local package_dir=$1
    local package_name=$(basename "$package_dir")

    if [ ! -d "$package_dir" ]; then
        echo -e "${RED}Package directory not found: $package_dir${NC}"
        return 1
    fi

    echo -e "\n${BLUE}Building $package_name...${NC}"
    cd "$package_dir"

    # Create src directory if it doesn't exist
    mkdir -p src/${package_name//-/_}

    # Copy generated files to src
    if [ -d "$PYTHON_DIR/proto" ]; then
        cp -r "$PYTHON_DIR/proto/"* "src/${package_name//-/_}/" 2>/dev/null || true
    fi

    # Create __init__.py if it doesn't exist
    touch "src/${package_name//-/_}/__init__.py"

    # Install in development mode
    if [ -f "pyproject.toml" ]; then
        python3 -m pip install -e . || echo -e "${RED}Warning: Failed to install $package_name${NC}"
    fi

    cd "$PYTHON_DIR"
}

# Build all Python packages
cd "$PYTHON_DIR"
for package in */; do
    if [ -f "$package/pyproject.toml" ]; then
        build_python_package "$PYTHON_DIR/$package"
    fi
done

# Format code with black if available
if command -v black &> /dev/null; then
    echo -e "\n${BLUE}Formatting Python code with black...${NC}"
    black "$PYTHON_DIR" || echo -e "${RED}Black formatting had issues${NC}"
fi

echo -e "\n${GREEN}✓ Python clients generated successfully!${NC}"
