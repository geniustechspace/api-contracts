pub mod accounts {
    pub mod v1 {
        tonic::include_proto!("accounts.v1");
    }
}

pub mod common {
    tonic::include_proto!("common");
}

// Re-export commonly used types
pub use accounts::v1::*;
pub use common::*;