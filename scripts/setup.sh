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
        BUF_VERSION="1.28.1"
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
    echo -e "${GREEN}✓ buf$(nc) $(buf --version | head -n1)"
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

# Check pnpm
if ! command_exists pnpm; then
    echo -e "${YELLOW}pnpm not found (optional)${NC}"
    if command_exists npm; then
        read -p "Install pnpm? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            npm install -g pnpm
        fi
    fi
else
    echo -e "${GREEN}✓ pnpm${NC} $(pnpm --version)"
fi

echo -e "\n${BLUE}=== Installing Development Dependencies ===${NC}\n"

# Install Rust tools
if command_exists cargo; then
    echo -e "${BLUE}Installing Rust tools...${NC}"
    cargo install --quiet protoc-gen-tonic protoc-gen-prost || true
    echo -e "${GREEN}✓ Rust tools installed${NC}"
fi

# Install Python tools
if command_exists python3; then
    echo -e "${BLUE}Installing Python tools...${NC}"
    python3 -m pip install --quiet --upgrade pip
    python3 -m pip install --quiet grpcio-tools black pytest
    echo -e "${GREEN}✓ Python tools installed${NC}"
fi

# Install Node.js dependencies
if command_exists node && [ -d "$ROOT_DIR/ts" ]; then
    echo -e "${BLUE}Installing TypeScript dependencies...${NC}"
    cd "$ROOT_DIR/ts"
    if command_exists pnpm; then
        pnpm install
    else
        npm install
    fi
    echo -e "${GREEN}✓ TypeScript dependencies installed${NC}"
fi

echo -e "\n${BLUE}=== Generating Clients ===${NC}\n"

# Generate all clients
if [ -f "$SCRIPT_DIR/generate_clients.sh" ]; then
    bash "$SCRIPT_DIR/generate_clients.sh"
else
    echo -e "${RED}Warning: generate_clients.sh not found${NC}"
fi

echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║            Setup Complete!                             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review generated clients in rust/, python/, and ts/ directories"
echo "  2. Run tests: ./scripts/test_all.sh"
echo "  3. See README.md for usage examples"
echo ""
