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
RUST_DIR="$ROOT_DIR/rust"

cd "$ROOT_DIR"

# Check prerequisites
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ cargo found${NC}"

# Create proto output directory if it doesn't exist
mkdir -p "$RUST_DIR/proto"

# Generate Rust code using buf
echo -e "${BLUE}Generating Rust proto code...${NC}"
buf generate --template buf.gen.yaml --path proto

# Build all Rust clients
echo -e "\n${BLUE}Building Rust workspace...${NC}"
cd "$RUST_DIR"

# Update Cargo workspace if needed
echo -e "${BLUE}Updating dependencies...${NC}"
cargo update

# Build all clients
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
