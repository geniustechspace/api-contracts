
pub mod auth {
    pub mod v1 {
        tonic::include_proto!("auth.v1");
    }
}

pub mod common {
    tonic::include_proto!("common");
}

// Re-export commonly used types
pub use auth::v1::*;
pub use common::*;