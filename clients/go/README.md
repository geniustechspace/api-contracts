# GeniusTechSpace API Contracts - Go Client

Go client library for GeniusTechSpace API contracts.

## Installation

```bash
go get github.com/geniustechspace/api-contracts/gen/go@latest
```

## Usage

```go
package main

import (
    "context"
    "log"
    
    "google.golang.org/grpc"
    authv1 "github.com/geniustechspace/api-contracts/gen/go/idp/v1/auth"
)

func main() {
    // Connect to service
    conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
    if err != nil {
        log.Fatalf("Failed to connect: %v", err)
    }
    defer conn.Close()
    
    // Create client
    client := authv1.NewAuthServiceClient(conn)
    
    // Make request
    ctx := context.Background()
    resp, err := client.SignIn(ctx, &authv1.SignInRequest{
        TenantId: "tenant-123",
        Email:    "user@example.com",
        Password: "secure-password",
    })
    
    if err != nil {
        log.Fatalf("SignIn failed: %v", err)
    }
    
    log.Printf("Token: %s", resp.AccessToken)
}
```
