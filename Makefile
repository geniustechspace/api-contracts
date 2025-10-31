# Makefile for API Contracts

.PHONY: help setup generate generate-rust generate-python generate-ts lint test clean build install

# Default target
help:
	@echo "API Contracts - Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Initialize development environment"
	@echo "  make install        - Install all dependencies"
	@echo ""
	@echo "Generation:"
	@echo "  make generate       - Generate all clients"
	@echo "  make generate-rust  - Generate Rust clients only"
	@echo "  make generate-python - Generate Python clients only"
	@echo "  make generate-ts    - Generate TypeScript clients only"
	@echo ""
	@echo "Quality:"
	@echo "  make lint           - Lint proto files"
	@echo "  make test           - Run all tests"
	@echo "  make check-breaking - Check for breaking changes"
	@echo ""
	@echo "Build:"
	@echo "  make build          - Build all clients"
	@echo "  make build-rust     - Build Rust clients"
	@echo "  make build-python   - Build Python clients"
	@echo "  make build-ts       - Build TypeScript clients"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean          - Clean generated files"
	@echo "  make fmt            - Format code"

# Setup
setup:
	@echo "Setting up development environment..."
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

install:
	@echo "Installing dependencies..."
	@command -v buf > /dev/null || (echo "Installing buf..." && brew install bufbuild/buf/buf)
	@command -v cargo > /dev/null || (echo "Install Rust from https://rustup.rs" && exit 1)
	@command -v python3 > /dev/null || (echo "Install Python from https://python.org" && exit 1)
	@command -v node > /dev/null || (echo "Install Node.js from https://nodejs.org" && exit 1)

# Generation
generate:
	@echo "Generating all clients..."
	@buf generate
	@./scripts/generate_clients.sh

generate-rust:
	@echo "Generating Rust clients..."
	@./scripts/generate_rust.sh

generate-python:
	@echo "Generating Python clients..."
	@./scripts/generate_python.sh

generate-ts:
	@echo "Generating TypeScript clients..."
	@./scripts/generate_ts.sh

# Quality
lint:
	@echo "Linting proto files..."
	@buf lint

test:
	@echo "Running tests..."
	@cd rust && cargo test --workspace
	@cd python && pytest || echo "No Python tests configured"
	@cd ts && pnpm test || echo "No TypeScript tests configured"

check-breaking:
	@echo "Checking for breaking changes..."
	@buf breaking --against '.git#branch=main'

# Build
build: build-rust build-python build-ts

build-rust:
	@echo "Building Rust clients..."
	@cd rust && cargo build --workspace --release

build-python:
	@echo "Building Python clients..."
	@for dir in python/*/; do \
		if [ -f "$$dir/pyproject.toml" ]; then \
			cd "$$dir" && python3 -m build && cd -; \
		fi; \
	done

build-ts:
	@echo "Building TypeScript clients..."
	@cd ts && pnpm build

# Maintenance
clean:
	@echo "Cleaning generated files..."
	@rm -rf rust/proto rust/target
	@rm -rf python/proto python/*/dist python/*/*.egg-info
	@rm -rf ts/proto ts/node_modules ts/*/dist
	@rm -rf docs/generated

fmt:
	@echo "Formatting code..."
	@cd rust && cargo fmt --all
	@cd python && black . || echo "black not installed"
	@cd ts && pnpm exec prettier --write "packages/*/src/**/*.ts" || echo "prettier not installed"

# Docker support
docker-build:
	@docker build -t api-contracts-builder -f Dockerfile .

docker-generate:
	@docker run --rm -v $(PWD):/workspace api-contracts-builder make generate
