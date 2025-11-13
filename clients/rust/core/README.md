# GeniusTechSpace Core API

Core API contracts for GeniusTechSpace platform, providing fundamental multitenancy primitives and tenant management.

## Features

- **Multitenancy Support**: Tenant context, organization hierarchy, workspace isolation
- **Compliance Built-in**: GDPR, HIPAA, SOC 2, PCI DSS compliance settings
- **Resource Management**: Per-tenant quotas and limits
- **Audit Logging**: Configurable audit settings

## Installation

```toml
[dependencies]
geniustechspace-core = "0.1.0"
```

## Usage

```rust
use geniustechspace_core::core::v1::{TenantContext, TenantInfo};

// Create tenant context for all API calls
let context = TenantContext {
    tenant_id: "tenant-123".to_string(),
    organization_id: "org-456".to_string(),
    workspace_id: "workspace-789".to_string(),
    environment: Environment::Production.into(),
};
```

## License

MIT
