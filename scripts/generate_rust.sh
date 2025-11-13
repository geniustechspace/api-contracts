#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Generating Rust Clients ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
RUST_DIR="$ROOT_DIR/clients/rust"

cd "$ROOT_DIR"

# Check prerequisites
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ cargo found${NC}"

# NOTE: Rust code generation is handled by build.rs during cargo build
# The build.rs script uses tonic-build to compile proto files
echo -e "${BLUE}Generating Rust proto code...${NC}"
echo -e "${GREEN}✓ Code will be generated during cargo build via build.rs${NC}"

# Build all Rust clients
echo -e "\n${BLUE}Building Rust workspace...${NC}"
cd "$RUST_DIR"

# Update Cargo workspace if needed
echo -e "${BLUE}Updating dependencies...${NC}"
cargo update

# Build all clients (this triggers build.rs which generates the proto code)
echo -e "${BLUE}Building all clients...${NC}"
cargo build --workspace

# Run tests if they exist
if cargo test --workspace --no-run &> /dev/null; then
    echo -e "\n${BLUE}Running tests...${NC}"
    cargo test --workspace
fi

# Format code
if command -v cargo-fmt &> /dev/null || cargo fmt --version &> /dev/null; then
    echo -e "\n${BLUE}Formatting code...${NC}"
    cargo fmt --all
fi

# Run clippy if available
if command -v cargo-clippy &> /dev/null || cargo clippy --version &> /dev/null; then
    echo -e "\n${BLUE}Running clippy...${NC}"
    cargo clippy --workspace --all-targets -- -D warnings || echo -e "${RED}Clippy warnings found${NC}"
fi

echo -e "\n${GREEN}✓ Rust clients generated and built successfully!${NC}"
