#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Generating TypeScript Clients ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TS_DIR="$ROOT_DIR/clients/typescript"

cd "$ROOT_DIR"

# Check prerequisites
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: node is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ node found${NC}"

# Check for pnpm (preferred) or npm
if command -v pnpm &> /dev/null; then
    PKG_MANAGER="pnpm"
    echo -e "${GREEN}✓ Using pnpm${NC}"
elif command -v npm &> /dev/null; then
    PKG_MANAGER="npm"
    echo -e "${GREEN}✓ Using npm${NC}"
else
    echo -e "${RED}Error: Neither pnpm nor npm is installed${NC}"
    exit 1
fi

# Generate TypeScript code using buf (buf.gen.yaml has output paths)
echo -e "${BLUE}Generating TypeScript proto code...${NC}"
buf generate

# Install dependencies
echo -e "\n${BLUE}Installing TypeScript dependencies...${NC}"
cd "$TS_DIR"

if [ ! -d "node_modules" ]; then
    $PKG_MANAGER install
fi

# Build all packages
echo -e "\n${BLUE}Building TypeScript packages...${NC}"
$PKG_MANAGER run build || echo -e "${RED}Build had some issues${NC}"

# Type check
echo -e "\n${BLUE}Type checking...${NC}"
$PKG_MANAGER run typecheck || echo -e "${RED}Type checking found issues${NC}"

# Format with prettier if available
if command -v prettier &> /dev/null || $PKG_MANAGER exec prettier --version &> /dev/null 2>&1; then
    echo -e "\n${BLUE}Formatting TypeScript code...${NC}"
    $PKG_MANAGER exec prettier --write "packages/*/src/**/*.ts" || echo -e "${RED}Formatting had issues${NC}"
fi

echo -e "\n${GREEN}✓ TypeScript clients generated successfully!${NC}"
