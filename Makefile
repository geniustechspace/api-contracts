# =============================================================================
# Makefile - Enterprise API Contracts
# =============================================================================
# This Makefile provides commands for managing the API contracts repository:
# - Code generation for multiple languages
# - Linting and validation
# - Building and testing clients
# - Documentation generation
#
# Rust is the PRIMARY language for this project.
# =============================================================================

.PHONY: help setup install clean generate lint format test build check breaking deps update-deps validate
.DEFAULT_GOAL := help

# =============================================================================
# Help
# =============================================================================

help: ## Show this help message
	@echo "Enterprise API Contracts - Available Commands"
	@echo ""
	@echo "🚀 Setup:"
	@echo "  make setup          - Initialize development environment"
	@echo "  make install        - Install all dependencies (buf, rust, go, python, node)"
	@echo "  make deps           - Download proto dependencies"
	@echo "  make update-deps    - Update proto dependencies"
	@echo ""
	@echo "🔨 Generation:"
	@echo "  make generate       - Generate all clients (rust, go, python, typescript, java)"
	@echo "  make generate-rust  - Generate Rust client only (PRIMARY)"
	@echo "  make generate-go    - Generate Go client only"
	@echo "  make generate-python - Generate Python client only"
	@echo "  make generate-ts    - Generate TypeScript client only"
	@echo "  make generate-java  - Generate Java client only"
	@echo "  make generate-docs  - Generate documentation only"
	@echo ""
	@echo "✅ Quality:"
	@echo "  make lint           - Lint proto files"
	@echo "  make format         - Format proto files"
	@echo "  make validate       - Run all validation checks"
	@echo "  make breaking       - Check for breaking changes"
	@echo "  make check          - Run lint + breaking"
	@echo ""
	@echo "🏗️  Build:"
	@echo "  make build          - Build all clients"
	@echo "  make build-rust     - Build Rust client (PRIMARY)"
	@echo "  make build-go       - Build Go client"
	@echo "  make build-python   - Build Python client"
	@echo "  make build-ts       - Build TypeScript client"
	@echo "  make build-java     - Build Java client"
	@echo ""
	@echo "🧪 Test:"
	@echo "  make test           - Run all tests"
	@echo "  make test-rust      - Test Rust client"
	@echo "  make test-go        - Test Go client"
	@echo "  make test-python    - Test Python client"
	@echo "  make test-ts        - Test TypeScript client"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean          - Clean generated files"
	@echo "  make clean-all      - Clean everything (including dependencies)"
	@echo ""

# =============================================================================
# Setup & Installation
# =============================================================================

setup: ## Initialize development environment
	@echo "🚀 Setting up development environment..."
	@chmod +x scripts/*.sh
	@if [ -f scripts/setup.sh ]; then \
		./scripts/setup.sh; \
	else \
		echo "⚠️  Setup script not found"; \
		exit 1; \
	fi

install: ## Install all required dependencies
	@echo "📦 Installing dependencies..."
	@echo ""
	@echo "Checking for buf..."
	@command -v buf >/dev/null 2>&1 || \
		(echo "❌ buf not found. Installing..." && \
		curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$$(uname -s)-$$(uname -m)" \
		-o /tmp/buf && sudo mv /tmp/buf /usr/local/bin/buf && sudo chmod +x /usr/local/bin/buf)
	@echo "✅ buf installed: $$(buf --version)"
	@echo ""
	@echo "Checking for Rust..."
	@command -v cargo >/dev/null 2>&1 || \
		(echo "❌ Rust not found. Install from https://rustup.rs" && exit 1)
	@echo "✅ Rust installed: $$(rustc --version)"
	@echo ""
	@echo "✅ All core dependencies installed!"

deps: ## Download proto dependencies
	@echo "📥 Downloading proto dependencies..."
	@buf dep update proto

update-deps: ## Update proto dependencies
	@echo "🔄 Updating proto dependencies..."
	@buf dep update proto

# =============================================================================
# Code Generation
# =============================================================================

generate: ## Generate all clients
	@echo "🔨 Generating all clients..."
	@if [ -z "$$(find proto -name '*.proto' 2>/dev/null | grep -v '.gitkeep')" ]; then \
		echo "⚠️  No proto files found. Add proto files to proto/ directory first."; \
		echo "   Example: Create proto/core/v1/tenant.proto"; \
	else \
		if [ -f scripts/generate_clients.sh ]; then \
			./scripts/generate_clients.sh; \
		else \
			buf generate && echo "✅ All clients generated successfully!"; \
		fi \
	fi

generate-rust: ## Generate Rust client only (PRIMARY)
	@echo "🦀 Generating Rust client..."
	@if [ -f scripts/generate_rust.sh ]; then \
		./scripts/generate_rust.sh; \
	else \
		buf generate; \
	fi

generate-go: ## Generate Go client only
	@echo "🐹 Generating Go client..."
	@buf generate

generate-python: ## Generate Python client only
	@echo "🐍 Generating Python client..."
	@if [ -f scripts/generate_python.sh ]; then \
		./scripts/generate_python.sh; \
	else \
		buf generate; \
	fi

generate-ts: ## Generate TypeScript client only
	@echo "📘 Generating TypeScript client..."
	@if [ -f scripts/generate_ts.sh ]; then \
		./scripts/generate_ts.sh; \
	else \
		buf generate; \
	fi

generate-java: ## Generate Java client only
	@echo "☕ Generating Java client..."
	@buf generate

generate-docs: ## Generate documentation only
	@echo "📚 Generating documentation..."
	@buf generate --include-imports

# =============================================================================
# Quality Checks
# =============================================================================

lint: ## Lint proto files
	@echo "🔍 Linting proto files..."
	@if [ -z "$$(find proto -name '*.proto' 2>/dev/null | grep -v '.gitkeep')" ]; then \
		echo "⚠️  No proto files to lint"; \
	else \
		buf lint proto && echo "✅ Lint passed!"; \
	fi

format: ## Format proto files
	@echo "🎨 Formatting proto files..."
	@if [ -z "$$(find proto -name '*.proto' 2>/dev/null | grep -v '.gitkeep')" ]; then \
		echo "⚠️  No proto files to format"; \
	else \
		buf format -w proto && echo "✅ Files formatted!"; \
	fi

breaking: ## Check for breaking changes against main branch
	@echo "🔍 Checking for breaking changes..."
	@if [ -z "$$(find proto -name '*.proto' 2>/dev/null | grep -v '.gitkeep')" ]; then \
		echo "⚠️  No proto files to check"; \
	else \
		buf breaking proto --against '.git#branch=main,subdir=proto' || \
		(echo "⚠️  Breaking changes detected or no baseline found" && exit 0); \
	fi

validate: lint breaking validate-structure ## Run all validation checks

validate-structure: ## Validate client structure matches proto structure
	@echo "🔍 Validating client structure..."
	@if [ -f scripts/validate_structure.sh ]; then \
		./scripts/validate_structure.sh; \
	else \
		echo "⚠️  Validation script not found"; \
	fi

check: validate ## Alias for validate

# =============================================================================
# Build
# =============================================================================

build: generate build-rust ## Build all clients (Rust is primary)

build-rust: ## Build Rust client (PRIMARY)
	@echo "🦀 Building Rust client..."
	@if [ -f "clients/rust/Cargo.toml" ]; then \
		cd clients/rust && cargo build --release && echo "✅ Rust build complete!"; \
	else \
		echo "⚠️  Rust client not found. Run 'make setup' first."; \
	fi

build-go: ## Build Go client
	@echo "🐹 Building Go client..."
	@if [ -f "clients/go/go.mod" ]; then \
		cd clients/go && go build ./... && echo "✅ Go build complete!"; \
	else \
		echo "⚠️  Go client not found. Run 'make setup' first."; \
	fi

build-python: ## Build Python distribution packages (.whl files)
	@echo "🐍 Building Python distribution packages..."
	@if [ -f "scripts/build_python.py" ]; then \
		python3 scripts/build_python.py; \
	else \
		echo "⚠️  Build script not found."; \
		exit 1; \
	fi

dist-python: build-python ## Alias for build-python

build-ts: ## Build TypeScript client
	@echo "📘 Building TypeScript client..."
	@if [ -f "clients/typescript/package.json" ]; then \
		cd clients/typescript && npm install && npm run build && echo "✅ TypeScript build complete!"; \
	else \
		echo "⚠️  TypeScript client not found. Run 'make setup' first."; \
	fi

build-java: ## Build Java client
	@echo "☕ Building Java client..."
	@if [ -f "clients/java/pom.xml" ]; then \
		cd clients/java && mvn clean install && echo "✅ Java build complete!"; \
	else \
		echo "⚠️  Java client not found or Maven not configured."; \
	fi

# =============================================================================
# Test
# =============================================================================

test: test-rust ## Run tests (Rust is primary)

test-rust: ## Test Rust client (PRIMARY)
	@echo "🦀 Testing Rust client..."
	@if [ -f "clients/rust/Cargo.toml" ]; then \
		cd clients/rust && cargo test && echo "✅ Rust tests passed!"; \
	else \
		echo "⚠️  Rust client not found."; \
	fi

test-go: ## Test Go client
	@echo "🐹 Testing Go client..."
	@if [ -f "clients/go/go.mod" ]; then \
		cd clients/go && go test ./... && echo "✅ Go tests passed!"; \
	else \
		echo "⚠️  Go client not found."; \
	fi

test-python: ## Test Python client
	@echo "🐍 Testing Python client..."
	@if [ -f "clients/python/pyproject.toml" ]; then \
		cd clients/python && python3 -m pytest && echo "✅ Python tests passed!"; \
	else \
		echo "⚠️  Python client not found."; \
	fi

test-ts: ## Test TypeScript client
	@echo "📘 Testing TypeScript client..."
	@if [ -f "clients/typescript/package.json" ]; then \
		cd clients/typescript && npm test && echo "✅ TypeScript tests passed!"; \
	else \
		echo "⚠️  TypeScript client not found."; \
	fi

# =============================================================================
# Clean
# =============================================================================

clean: ## Clean generated files
	@echo "🧹 Cleaning generated files..."
	@rm -rf clients/rust/proto clients/rust/target
	@rm -rf clients/go/*/ clients/go/*.go
	@rm -rf clients/python/proto clients/python/dist clients/python/build clients/python/*.egg-info
	@rm -rf clients/typescript/proto clients/typescript/dist clients/typescript/node_modules
	@rm -rf clients/java/target
	@rm -rf docs/api/*.md docs/api/*.html docs/openapi/
	@echo "✅ Clean complete!"

clean-all: clean ## Clean everything including dependencies
	@echo "🧹 Deep cleaning..."
	@rm -rf clients/rust/Cargo.lock
	@rm -rf clients/typescript/package-lock.json
	@rm -rf clients/go/go.sum
	@echo "✅ Deep clean complete!"

# =============================================================================
# CI/CD
# =============================================================================

ci: deps lint breaking generate build test ## Run full CI pipeline
	@echo "✅ CI pipeline complete!"
