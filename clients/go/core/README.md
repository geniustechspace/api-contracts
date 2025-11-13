# GeniusTechSpace Core API - Go

Core API contracts for GeniusTechSpace platform in Go.

## Installation

```bash
go get github.com/geniustechspace/api-contracts/gen/go/core
```

## Usage

```go
import (
    corev1 "github.com/geniustechspace/api-contracts/gen/go/core/v1"
)

func main() {
    ctx := &corev1.TenantContext{
        TenantId:       "tenant-123",
        OrganizationId: "org-456",
        WorkspaceId:    "workspace-789",
        Environment:    corev1.Environment_ENVIRONMENT_PRODUCTION,
    }
}
```

## License

MIT
