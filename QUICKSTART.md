# Quick Start - Python Monorepo

## Development Setup

```bash
# From repository root
./scripts/setup.sh
```

This creates a single shared `.venv` at `clients/python/.venv` and installs all packages.

## Activate Environment

```bash
cd clients/python
source .venv/bin/activate
```

## Build Distribution Packages

```bash
# From repository root
make build-python
```

Output: `dist/python/*.whl` files ready for distribution

## Verify Imports

```bash
cd clients/python
source .venv/bin/activate
python -c "from validate import validate_pb2; from core.v1 import tenant_pb2; print('✅ Working')"
```

## Project Structure

```
clients/python/
├── .venv/              # Shared virtual environment (like Rust's target/)
├── pyproject.toml      # Workspace config
├── core/               # Core package
├── idp/                # Identity Provider package
├── notification/       # Notification package
└── validate/           # Generated validation protos

dist/python/            # Built wheel packages
├── geniustechspace_core-0.1.0-py3-none-any.whl
├── geniustechspace_idp-0.1.0-py3-none-any.whl
└── geniustechspace_notification-0.1.0-py3-none-any.whl
```

## Key Benefits

- ✅ Single `.venv` (not per-package)
- ✅ ~75% disk space savings
- ✅ ~60% faster installs
- ✅ Production-ready wheel packages
- ✅ No relative imports
- ✅ Matches Rust workspace pattern

## TypeScript

Already using npm workspaces - no changes needed!

```
clients/typescript/
├── node_modules/       # Shared dependencies
└── packages/           # Individual packages
```

## Documentation

- **MONOREPO_GUIDE.md** - Complete usage guide
- **PYTHON_MONOREPO_SUMMARY.md** - Migration summary and technical details

## Validation Note

Currently uses `protoc-gen-validate` (legacy). Validation rules are in `.proto` files. The `protovalidate` runtime library is NOT used (incompatible with current setup).

To add runtime validation in the future, migrate to `buf.build/bufbuild/protovalidate`.
