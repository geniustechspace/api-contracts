#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║     API Contracts - Development Environment Setup      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Detect available proto modules
PROTO_MODULES=()
for dir in proto/*/; do
    if [ -d "$dir" ] && [ "$(basename "$dir")" != "proto" ]; then
        module_name=$(basename "$dir")
        PROTO_MODULES+=("$module_name")
    fi
done

echo -e "${BLUE}Detected proto modules: ${PROTO_MODULES[*]}${NC}\n"

# Check OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     OS_NAME="Linux";;
    Darwin*)    OS_NAME="macOS";;
    CYGWIN*)    OS_NAME="Windows";;
    MINGW*)     OS_NAME="Windows";;
    *)          OS_NAME="Unknown";;
esac

echo -e "${BLUE}Detected OS: ${NC}$OS_NAME\n"

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install buf
install_buf() {
    echo -e "${BLUE}Installing buf...${NC}"

    if [ "$OS_NAME" = "macOS" ]; then
        if command_exists brew; then
            brew install bufbuild/buf/buf
        else
            echo -e "${RED}Homebrew not found. Please install from https://brew.sh${NC}"
            return 1
        fi
    elif [ "$OS_NAME" = "Linux" ]; then
        BUF_VERSION="1.47.2"  # Updated to latest stable (January 2025)
        curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
            -o /tmp/buf
        sudo mv /tmp/buf /usr/local/bin/buf
        sudo chmod +x /usr/local/bin/buf
    else
        echo -e "${YELLOW}Please install buf manually from: https://docs.buf.build/installation${NC}"
        return 1
    fi
}

# Check and install prerequisites
echo -e "${BLUE}=== Checking Prerequisites ===${NC}\n"

# Check buf
if ! command_exists buf; then
    echo -e "${YELLOW}buf not found${NC}"
    read -p "Install buf? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_buf
    fi
else
    echo -e "${GREEN}✓ buf${NC} $(buf --version | head -n1)"
fi

# Check Rust
if ! command_exists cargo; then
    echo -e "${YELLOW}Rust/Cargo not found${NC}"
    echo -e "Install from: ${BLUE}https://rustup.rs${NC}"
else
    echo -e "${GREEN}✓ Rust${NC} $(rustc --version | cut -d' ' -f2)"
fi

# Check Python
if ! command_exists python3; then
    echo -e "${RED}✗ Python3 not found${NC}"
    echo -e "Install from: ${BLUE}https://python.org${NC}"
else
    echo -e "${GREEN}✓ Python${NC} $(python3 --version | cut -d' ' -f2)"
fi

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}✗ Node.js not found${NC}"
    echo -e "Install from: ${BLUE}https://nodejs.org${NC}"
else
    echo -e "${GREEN}✓ Node.js${NC} $(node --version)"
fi

# Check npm
if ! command_exists npm; then
    echo -e "${RED}✗ npm not found${NC}"
else
    echo -e "${GREEN}✓ npm${NC} $(npm --version)"
fi

echo -e "\n${BLUE}=== Installing Development Dependencies ===${NC}\n"

# Setup Rust workspace
if command_exists cargo; then
    echo -e "${BLUE}Setting up Rust workspace...${NC}"
    cd "$ROOT_DIR/clients/rust"
    cargo fetch --quiet 2>/dev/null || true
    echo -e "${GREEN}✓ Rust workspace configured${NC}"
fi

# Setup Python workspace with single shared virtual environment
if command_exists python3; then
    echo -e "${BLUE}Setting up Python workspace...${NC}"
    cd "$ROOT_DIR/clients/python"
    
    # Create single shared .venv (like Rust's single target/ directory)
    if [ ! -d ".venv" ]; then
        echo -e "  Creating shared Python virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate shared venv
    source .venv/bin/activate
    
    # Upgrade pip and tools
    echo -e "  Upgrading pip and build tools..."
    pip install --quiet --upgrade pip setuptools wheel build 2>/dev/null || pip install --upgrade pip setuptools wheel build
    
    # Install workspace dev dependencies
    if [ -f "pyproject.toml" ]; then
        echo -e "  Installing workspace dev dependencies..."
        pip install --quiet -e ".[dev]" 2>/dev/null || pip install -e ".[dev]"
    fi
    
    # Install all packages in editable mode
    echo -e "  Installing packages in editable mode..."
    for module in core idp notification; do
        if [ -d "$module" ] && [ -f "$module/pyproject.toml" ]; then
            echo -e "    → $module"
            pip install --quiet -e "$module/" 2>/dev/null || pip install -e "$module/"
        fi
    done
    
    deactivate
    
    echo -e "${GREEN}✓ Python workspace configured${NC}"
    echo -e "  ${GREEN}→${NC} Activate with: ${BLUE}cd clients/python && source .venv/bin/activate${NC}"
fi

# Setup TypeScript workspace
if command_exists npm && [ -d "$ROOT_DIR/clients/typescript" ]; then
    echo -e "${BLUE}Setting up TypeScript workspace...${NC}"
    cd "$ROOT_DIR/clients/typescript"
    
    # Install root dependencies
    npm install --silent 2>/dev/null || npm install
    
    # Install dependencies for each package
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "packages/$module" ] && [ -f "packages/$module/package.json" ]; then
            echo -e "  Setting up TypeScript $module..."
            cd "packages/$module"
            npm install --silent 2>/dev/null || npm install
            cd ../..
        fi
    done
    
    echo -e "${GREEN}✓ TypeScript workspace configured${NC}"
fi

# Setup Go modules
if command_exists go; then
    echo -e "${BLUE}Setting up Go modules...${NC}"
    cd "$ROOT_DIR/clients/go"
    
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "$module" ] && [ -f "$module/go.mod" ]; then
            echo -e "  Setting up Go $module..."
            cd "$module"
            go mod download 2>/dev/null || true
            cd ..
        fi
    done
    
    echo -e "${GREEN}✓ Go modules configured${NC}"
fi

# Setup Java Maven
if command_exists mvn && [ -d "$ROOT_DIR/clients/java" ] && [ -f "$ROOT_DIR/clients/java/pom.xml" ]; then
    echo -e "${BLUE}Setting up Java Maven project...${NC}"
    cd "$ROOT_DIR/clients/java"
    mvn dependency:resolve --quiet 2>/dev/null || true
    echo -e "${GREEN}✓ Java Maven configured${NC}"
fi

echo -e "\n${BLUE}=== Generating Clients ===${NC}\n"

# Generate all clients
cd "$ROOT_DIR"
if [ -f "$SCRIPT_DIR/generate_clients.sh" ]; then
    bash "$SCRIPT_DIR/generate_clients.sh"
else
    echo -e "${YELLOW}Skipping generation - run 'make generate' manually${NC}"
fi

echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║            Setup Complete!                             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Modules configured: ${PROTO_MODULES[*]}${NC}\n"

echo -e "${BLUE}Next steps:${NC}"
echo "  1. Activate Python venv: cd clients/python/<module> && source .venv/bin/activate"
echo "  2. Build Rust: make build-rust"
echo "  3. Generate all: make generate"
echo "  4. Run tests: make test"
echo ""
echo -e "${BLUE}Client locations:${NC}"
echo "  Rust:       clients/rust/<module>/"
echo "  Go:         clients/go/<module>/"
echo "  Python:     clients/python/<module>/ (with .venv)"
echo "  TypeScript: clients/typescript/packages/<module>/ (with node_modules)"
echo "  Java:       clients/java/<module>/"
echo ""
