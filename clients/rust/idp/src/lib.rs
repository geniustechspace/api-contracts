//! # GeniusTechSpace IDP (Identity Provider) API
//!
//! Identity and access management API contracts for authentication,
//! user management, organizations, and RBAC.

pub mod idp {
    pub mod v1 {
        pub mod auth {
            // Authentication services
        }

        pub mod user {
            // User management
        }

        pub mod organization {
            // Organization management
        }

        pub mod role {
            // Role management
        }

        pub mod permission {
            // Permission management
        }

        pub mod session {
            // Session management
        }
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_module_structure() {
        // Verify module structure compiles correctly
        // Actual tests will be added once proto code is generated
    }
}
