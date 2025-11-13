#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║     API Contracts - Development Environment Setup      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Check Windows compatibility
check_windows_compatibility || exit 1

# Get directories
ROOT_DIR=$(get_root_dir)

cd "$ROOT_DIR"

# Detect available proto modules
PROTO_MODULES=($(discover_proto_modules "$ROOT_DIR"))

print_info "Detected proto modules: ${PROTO_MODULES[*]}"
echo ""

# Detect OS
OS_NAME=$(detect_platform)
print_info "Detected OS: $OS_NAME"
echo ""

# Function to install buf
install_buf() {
    print_info "Installing buf..."

    if [ "$OS_NAME" = "macOS" ]; then
        if command_exists brew; then
            brew install bufbuild/buf/buf
        else
            print_error "Homebrew not found. Please install from https://brew.sh"
            return 1
        fi
    elif [ "$OS_NAME" = "Linux" ]; then
        BUF_VERSION="1.47.2"  # Updated to latest stable (January 2025)
        curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
            -o /tmp/buf
        sudo mv /tmp/buf /usr/local/bin/buf
        sudo chmod +x /usr/local/bin/buf
    else
        print_warning "Please install buf manually from: https://docs.buf.build/installation"
        return 1
    fi
}

# Check and install prerequisites
print_section "Checking Prerequisites"

# Check buf
if ! command_exists buf; then
    print_warning "buf not found"
    read -p "Install buf? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_buf
    fi
else
    print_success "buf $(buf --version | head -n1)"
fi

# Check Rust
if ! command_exists cargo; then
    print_warning "Rust/Cargo not found"
    print_info "Install from: https://rustup.rs"
else
    print_success "Rust $(rustc --version | cut -d' ' -f2)"
fi

# Check Python
if ! command_exists python3; then
    print_error "Python3 not found"
    print_info "Install from: https://python.org"
else
    print_success "Python $(python3 --version | cut -d' ' -f2)"
fi

# Check Node.js
if ! command_exists node; then
    print_error "Node.js not found"
    print_info "Install from: https://nodejs.org"
else
    print_success "Node.js $(node --version)"
fi

# Check npm
if ! command_exists npm; then
    print_error "npm not found"
else
    print_success "npm $(npm --version)"
fi

print_section "Installing Development Dependencies"

# Setup Rust workspace
if command_exists cargo; then
    print_info "Setting up Rust workspace..."
    cd "$ROOT_DIR/clients/rust"
    cargo fetch --quiet 2>/dev/null || true
    print_success "Rust workspace configured"
fi

# Setup Python workspace with single shared virtual environment
if command_exists python3; then
    print_info "Setting up Python workspace..."
    cd "$ROOT_DIR/clients/python"
    
    # Create single shared .venv (like Rust's single target/ directory)
    if [ ! -d ".venv" ]; then
        print_info "  Creating shared Python virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate shared venv
    source .venv/bin/activate
    
    # Upgrade pip and tools
    print_info "  Upgrading pip and build tools..."
    pip install --quiet --upgrade pip setuptools wheel build 2>/dev/null || pip install --upgrade pip setuptools wheel build
    
    # Install workspace dev dependencies
    if [ -f "pyproject.toml" ]; then
        print_info "  Installing workspace dev dependencies..."
        pip install --quiet -e ".[dev]" 2>/dev/null || pip install -e ".[dev]"
    fi
    
    # Install all packages in editable mode (auto-discover from proto modules)
    print_info "  Installing packages in editable mode..."
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "$module" ] && [ -f "$module/pyproject.toml" ]; then
            print_info "    → $module"
            pip install --quiet -e "$module/" 2>/dev/null || pip install -e "$module/"
        fi
    done
    
    deactivate
    
    print_success "Python workspace configured"
    print_info "  → Activate with: cd clients/python && source .venv/bin/activate"
fi

# Setup TypeScript workspace
if command_exists npm && [ -d "$ROOT_DIR/clients/typescript" ]; then
    print_info "Setting up TypeScript workspace..."
    cd "$ROOT_DIR/clients/typescript"
    
    # Install root dependencies
    npm install --silent 2>/dev/null || npm install
    
    # Install dependencies for each package (auto-discover from proto modules)
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "packages/$module" ] && [ -f "packages/$module/package.json" ]; then
            print_info "  Setting up TypeScript $module..."
            cd "packages/$module"
            npm install --silent 2>/dev/null || npm install
            cd ../..
        fi
    done
    
    print_success "TypeScript workspace configured"
fi

# Setup Go modules
if command_exists go; then
    print_info "Setting up Go modules..."
    cd "$ROOT_DIR/clients/go"
    
    for module in "${PROTO_MODULES[@]}"; do
        if [ -d "$module" ] && [ -f "$module/go.mod" ]; then
            print_info "  Setting up Go $module..."
            cd "$module"
            go mod download 2>/dev/null || true
            cd ..
        fi
    done
    
    print_success "Go modules configured"
fi

# Setup Java Maven
if command_exists mvn && [ -d "$ROOT_DIR/clients/java" ] && [ -f "$ROOT_DIR/clients/java/pom.xml" ]; then
    print_info "Setting up Java Maven project..."
    cd "$ROOT_DIR/clients/java"
    mvn dependency:resolve --quiet 2>/dev/null || true
    print_success "Java Maven configured"
fi

print_section "Generating Clients"

# Generate all clients
cd "$ROOT_DIR"
if [ -f "$SCRIPT_DIR/generate_clients.sh" ]; then
    bash "$SCRIPT_DIR/generate_clients.sh"
else
    print_warning "Skipping generation - run 'make generate' manually"
fi

echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║            Setup Complete!                             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_info "Modules configured: ${PROTO_MODULES[*]}"
echo ""

print_info "Next steps:"
echo "  1. Activate Python venv: cd clients/python/<module> && source .venv/bin/activate"
echo "  2. Build Rust: make build-rust"
echo "  3. Generate all: make generate"
echo "  4. Run tests: make test"
echo ""
print_info "Client locations:"
echo "  Rust:       clients/rust/<module>/"
echo "  Go:         clients/go/<module>/"
echo "  Python:     clients/python/<module>/ (with .venv)"
echo "  TypeScript: clients/typescript/packages/<module>/ (with node_modules)"
echo "  Java:       clients/java/<module>/"
echo ""
