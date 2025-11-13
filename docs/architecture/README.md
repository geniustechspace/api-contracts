# Architecture Documentation

This directory contains architectural documentation for the GeniusTechSpace API Contracts repository.

## Documents

### [Monorepo Structure](monorepo-structure.md)
Details on how the monorepo is organized for proto definitions and multi-language clients.

### [Client Generation](client-generation.md)
How client code is generated from proto files for each supported language.

### [Versioning Strategy](versioning-strategy.md)
API versioning approach and backward compatibility guarantees.

### [Multitenancy Architecture](multitenancy-architecture.md)
Deep dive into the multitenancy model and tenant isolation.

## Key Architectural Decisions

### 1. Proto-First Design
All APIs are defined using Protocol Buffers (proto3) as the source of truth. Client code is generated from these definitions, ensuring consistency across all languages.

### 2. Multi-Language Support
The repository generates clients for:
1. **Rust** (primary) - High-performance services
2. **Go** - Backend microservices
3. **Python** - ML/Data services and tooling
4. **TypeScript** - Web clients and Node.js services
5. **Java** - Enterprise integration

### 3. Modular Package Structure
Each proto module (core, idp, notification, etc.) becomes a separate, independently installable package in each language. This allows consumers to install only what they need.

### 4. Workspace-Based Monorepos
Each language uses its native workspace/monorepo tooling:
- Rust: Cargo workspace
- Go: Go modules with separate go.mod per package
- Python: pip-installable packages with pyproject.toml
- TypeScript: npm workspaces
- Java: Maven multi-module project

### 5. Strict Versioning
- Proto packages use directory-based versioning (v1, v2, etc.)
- Clients use semantic versioning
- Breaking changes require a new major version or proto package

### 6. Enterprise Standards
- Comprehensive documentation requirements
- Input validation on all fields
- Standardized error handling
- Audit logging built-in
- Compliance support (GDPR, HIPAA, SOC 2, PCI DSS)

## Directory Structure

```
api-contracts/
├── proto/                    # Proto definitions (source of truth)
│   ├── core/v1/             # Core infrastructure types
│   ├── common/v1/           # Common business types
│   ├── idp/v1/              # Identity Provider
│   └── [services]/v1/       # Business services
│
├── clients/                 # Generated clients
│   ├── rust/                # Rust workspace
│   ├── go/                  # Go modules
│   ├── python/              # Python packages
│   ├── typescript/          # TypeScript/npm workspace
│   └── java/                # Maven multi-module
│
├── docs/                    # Documentation
├── scripts/                 # Build and automation scripts
└── tests/                   # Integration tests
```

## Build Pipeline

```
Proto Files → buf lint → buf generate → Multi-language Clients → Tests → Publish
```

## Related Documentation

- [Monorepo Guide](../../MONOREPO_GUIDE.md)
- [Contributing Guide](../../CONTRIBUTING.md)
- [Multi-Package Architecture](../../clients/MULTI_PACKAGE_ARCHITECTURE.md)
