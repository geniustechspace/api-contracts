# GeniusTechSpace API Contracts - Rust Client

Rust client library for GeniusTechSpace API contracts.

## Features

- **Type-safe**: Full Rust type system leveraging
- **Async**: Built on Tokio and Tonic for high performance
- **Validation**: Request/response validation with validator crate
- **Serialization**: JSON support via serde
- **Documentation**: Comprehensive inline documentation

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
geniustechspace-api-contracts = "0.1"
tonic = "0.11"
tokio = { version = "1", features = ["full"] }
```

## Usage

### Client Example

```rust
use geniustechspace_api_contracts::idp::auth::v1::*;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to service
    let mut client = AuthServiceClient::connect("http://[::1]:50051").await?;
    
    // Create request with tenant context
    let request = tonic::Request::new(SignInRequest {
        tenant_id: "tenant-123".into(),
        email: "user@example.com".into(),
        password: "secure-password".into(),
    });
    
    // Make request
    let response = client.sign_in(request).await?;
    
    println!("Token: {}", response.into_inner().access_token);
    
    Ok(())
}
```

## Features

- `client` (default): Include gRPC client implementations
- `server`: Include gRPC server traits
- `tokio`: Include Tokio runtime

## Documentation

[View full documentation](https://docs.rs/geniustechspace-api-contracts)
