# Contributing to API Contracts

Thank you for your interest in contributing to GeniusTechSpace API Contracts! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Proto Style Guide](#proto-style-guide)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/api-contracts.git
   cd api-contracts
   ```
3. **Run setup**:
   ```bash
   ./scripts/setup.sh
   ```
4. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Process

### Adding a New Service

1. Create proto directory: `proto/SERVICE_NAME/v1/`
2. Define your service in `service.proto`
3. Define messages in separate files (e.g., `types.proto`, `requests.proto`)
4. Update client configurations
5. Generate and test clients
6. Submit PR

### Modifying Existing Services

1. Check if change is breaking using `buf breaking`
2. If breaking, create new version (`v2/`)
3. Update documentation
4. Generate clients
5. Update examples
6. Submit PR

## Proto Style Guide

### File Organization

```
proto/SERVICE_NAME/v1/
├── service.proto      # Service definition
├── types.proto        # Message types
├── requests.proto     # Request messages
└── responses.proto    # Response messages
```

### Naming Conventions

- **Package names**: `geniustechspace.SERVICE.v1`
- **Service names**: PascalCase (e.g., `UserService`)
- **RPC names**: PascalCase (e.g., `GetUser`)
- **Message names**: PascalCase (e.g., `UserProfile`)
- **Field names**: snake_case (e.g., `user_id`)
- **Enum names**: SCREAMING_SNAKE_CASE (e.g., `USER_STATUS_ACTIVE`)

### Documentation

All proto elements must have documentation:

```protobuf
// UserService manages user profiles and accounts.
// Provides CRUD operations and search functionality.
service UserService {
  // Get user profile by ID.
  // Returns USER_NOT_FOUND if user doesn't exist.
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/v1/users/{user_id}"
    };
  }
}
```

### Field Numbers

- Reserve `1-15` for frequently used fields (1-byte encoding)
- Use `16+` for less frequently used fields
- Never reuse field numbers
- Reserve deprecated field numbers:
  ```protobuf
  reserved 2, 15, 9 to 11;
  reserved "old_field_name";
  ```

## Submitting Changes

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:

```
feat(auth): add MFA support
fix(payments): correct currency conversion
docs(readme): update installation instructions
```

### Pull Request Process

1. **Update documentation** for any user-facing changes
2. **Add tests** if applicable
3. **Run linters**: `buf lint`
4. **Check for breaking changes**: `buf breaking --against '.git#branch=main'`
5. **Generate clients**: `./scripts/generate_clients.sh`
6. **Create PR** with clear description
7. **Respond to feedback** from reviewers

### PR Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] New feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentation update

## Testing

Describe how changes were tested

## Checklist

- [ ] Proto files documented
- [ ] Clients generated successfully
- [ ] Tests pass
- [ ] No breaking changes (or version bumped)
- [ ] Documentation updated
```

## Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Creating a Release

1. **Update version** in relevant files
2. **Update CHANGELOG.md**
3. **Create and push tag**:
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0"
   git push origin v0.2.0
   ```
4. **CI automatically**:
   - Builds clients
   - Runs tests
   - Publishes packages
   - Creates GitHub release

## Questions?

- Open an [issue](https://github.com/geniustechspace/api-contracts/issues)
- Start a [discussion](https://github.com/geniustechspace/api-contracts/discussions)
- Email: dev@geniustechspace.com

Thank you for contributing! 🎉
