//! # GeniusTechSpace Core API
//!
//! Core API contracts providing fundamental multitenancy primitives
//! and tenant management for the GeniusTechSpace platform.
//!
//! ## Features
//!
//! - **Multitenancy**: Tenant context, organization hierarchy, workspace isolation
//! - **Compliance**: GDPR, HIPAA, SOC 2, PCI DSS support
//! - **Resource Management**: Per-tenant quotas and limits
//! - **Audit Logging**: Configurable audit settings

// Include generated protobuf code from OUT_DIR
// The build.rs script generates these files during compilation
pub mod core {
    pub mod v1 {
        include!(concat!(env!("OUT_DIR"), "/core.v1.rs"));
    }
}

// Re-export for convenience
pub use core::v1;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_module_exists() {
        // Verify core module exists and can be used
        // This will compile if the proto file was generated correctly
        let _ = v1::TenantContext::default();
    }
}
