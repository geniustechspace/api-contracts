# GeniusTechSpace Python Clients - Monorepo

Monorepo workspace for Python client packages (similar to Rust Cargo workspace).

## Structure

- Single `.venv` for all packages
- Individual packages: validate, core, idp, notification  
- Build wheel packages for production distribution

## Setup

```bash
make setup  # Creates shared .venv and installs all packages
```

## Development

```bash
source .venv/bin/activate
# All packages available without relative imports
```

## Build for Production

```bash
make build-python  # Creates .whl files in dist/
```
