# Common Types

Shared business types and primitives used across all services.

## Overview

The `common` module provides standardized types for frequently used concepts such as:

- **Pagination**: Standard pagination patterns for list/search APIs
- **Types**: Common data types (email, phone, address)
- **Enums**: Common enumerations
- **Search & Filtering**: Search and filter patterns
- **Money**: Currency and monetary amount types
- **Geography**: Location and geographic types
- **DateTime**: Temporal types and time ranges

## Packages

### `common.v1`

Current stable version containing:

- `pagination.proto` - Pagination request/response types
- `types.proto` - Common data types (email, phone, address, etc.)
- `enums.proto` - Common enumerations (coming soon)
- `search.proto` - Search and filtering patterns (coming soon)
- `money.proto` - Currency and monetary types (coming soon)
- `geography.proto` - Geographic types (coming soon)
- `datetime.proto` - Temporal types (coming soon)

## Usage

### Rust
```rust
use geniustechspace_common::common::v1::{PaginationRequest, EmailAddress};
```

### Go
```go
import commonv1 "github.com/geniustechspace/api-contracts/gen/go/common/v1"
```

### Python
```python
from geniustechspace_common.common.v1 import pagination_pb2, types_pb2
```

### TypeScript
```typescript
import { PaginationRequest, EmailAddress } from '@geniustechspace/common';
```

## Design Principles

1. **Reusability**: Types should be generic enough for multiple use cases
2. **Validation**: All types include validation rules
3. **Documentation**: Comprehensive inline documentation
4. **Compatibility**: Backward-compatible evolution only
5. **Standards**: Follow industry standards (E.164 for phone, ISO for country codes)
