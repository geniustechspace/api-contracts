# Versioning Decision: Directory-Based vs Buf-Only

## Problem Statement

> **Question**: Is directory-based proto versioning (v1/, v2/, etc.) really necessary for this project?
> Isn't buf and buf.gen versioning strategy and policies enough?

## Answer: Both Are Necessary ✅

**TL;DR**: Directory-based versioning is NOT redundant. Buf versioning and directory versioning serve fundamentally different purposes and are both essential for enterprise API management.

## Quick Comparison

| What You Need | Directory Versioning (v1/, v2/) | Buf Versioning (SemVer) |
|---------------|--------------------------------|------------------------|
| Support multiple API versions simultaneously | ✅ YES | ❌ NO |
| Allow gradual client migration | ✅ YES | ❌ NO |
| Prevent breaking existing clients | ✅ YES | ❌ NO |
| Track module releases | ❌ NO | ✅ YES |
| Manage dependencies | ❌ NO | ✅ YES |
| Reproducible builds | ❌ NO | ✅ YES |

## The Problem with Buf-Only Versioning

If we remove directory versioning and rely only on Buf versioning:

### ❌ Problem 1: Breaking Changes Break Clients

**Without directory versioning:**
```
You: Release v2.0.0 with breaking changes
Client: Their code immediately breaks
Result: Forced upgrade, coordination nightmare
```

**With directory versioning:**
```
You: Create proto/service/v2/ alongside v1/
Client: Still using v1, nothing breaks
Result: Client upgrades when ready
```

### ❌ Problem 2: Can't Run Multiple Versions

**Without directory versioning:**
```go
// Service can only implement ONE version
type Server struct {
    UserServiceServer  // Which version? No way to tell!
}
```

**With directory versioning:**
```go
// Service implements BOTH versions during migration
type Server struct {
    v1.UserServiceServer
    v2.UserServiceServer
}
```

### ❌ Problem 3: No Clear Migration Path

**Buf versioning only:**
```
v1.0.0 → v2.0.0 (breaking)
Problem: All clients must upgrade immediately or break
```

**Directory versioning:**
```
proto/v1/ (stable) + proto/v2/ (new) → Gradual migration over months
```

## What Buf Versioning Actually Does

Buf versioning (SemVer) handles:

1. **Module Publishing**: Publishing releases to Buf Schema Registry (BSR)
2. **Dependency Management**: Other modules depend on specific versions
3. **Breaking Change Detection**: CI fails on accidental breaking changes within a version
4. **Build Reproducibility**: Lock files ensure consistent dependencies

**What Buf versioning does NOT do:**
- ❌ Enable multiple API versions to coexist
- ❌ Provide migration paths for breaking changes
- ❌ Allow clients to choose their API version

## Real-World Example

### Scenario: Need to change User message structure

**Approach 1: Buf versioning only** ❌
```protobuf
// proto/user/service.proto
package user;  // No version in package

message User {
  string id = 1;
  string full_name = 2;  // CHANGED from first_name + last_name
}
```

Release as v2.0.0:
- ❌ All existing clients break
- ❌ Must coordinate simultaneous upgrade
- ❌ No way to support old clients

**Approach 2: Directory + Buf versioning** ✅
```protobuf
// proto/user/v1/service.proto (unchanged)
package user.v1;

message User {
  string id = 1;
  string first_name = 2;
  string last_name = 3;
}

// proto/user/v2/service.proto (new)
package user.v2;

message User {
  string id = 1;
  string full_name = 2;  // New structure
}
```

Release as v2.0.0:
- ✅ Old clients continue using v1
- ✅ New clients adopt v2 at their pace
- ✅ Service supports both during migration
- ✅ Smooth, coordinated migration

## Industry Standard

Every major API uses directory versioning:

**Google Cloud APIs:**
```
google/cloud/vision/v1/
google/cloud/vision/v2/
google/spanner/admin/database/v1/
```

**Kubernetes:**
```
k8s.io/api/apps/v1/
k8s.io/api/batch/v1/
k8s.io/api/core/v1/
```

**Stripe API:**
```
Uses API version headers (2023-10-16, 2024-01-01)
Still maintains multiple versions simultaneously
```

**gRPC:**
```
grpc/health/v1/
```

## Buf Recommendation

From Buf documentation:

> "For API versioning, use package versioning (v1, v2). This is separate from module versioning in BSR. Package versioning enables multiple API versions to coexist, while module versioning tracks releases."

Source: [Buf Best Practices - Versioning](https://buf.build/docs/best-practices/versioning-modules)

## Our Decision: Keep Both

### Directory Versioning (v1/, v2/)

**Use for**: API evolution
- Create v2 for breaking changes
- Support multiple versions simultaneously
- Gradual client migration

### Buf Versioning (SemVer)

**Use for**: Module releases
- Tag releases: v1.0.0, v1.1.0, v2.0.0
- Publish to BSR
- Manage dependencies

### Together They Provide:

1. ✅ **Backward Compatibility**: Old clients never break
2. ✅ **Forward Evolution**: New features in v2 without affecting v1
3. ✅ **Smooth Migration**: Clients upgrade at their own pace
4. ✅ **Clear Semantics**: Package names reflect API version
5. ✅ **Build Safety**: Buf prevents accidental breaking changes
6. ✅ **Dependency Management**: Buf handles module dependencies
7. ✅ **Industry Standard**: Follows best practices from Google, gRPC, Kubernetes

## Configuration

Our `buf.yaml` enforces directory versioning:

```yaml
lint:
  use:
    - PACKAGE_VERSION_SUFFIX     # Requires v1, v2 in package names
    - PACKAGE_DIRECTORY_MATCH    # Directory must match package
```

This ensures:
- Package names must include version (e.g., `core.v1`)
- Directory structure must match (e.g., `proto/core/v1/`)
- Consistency across entire codebase

## Conclusion

**Directory-based versioning is NOT redundant.**

It's a critical part of our API strategy that:
- Enables API evolution without breaking clients
- Follows industry best practices
- Complements (not replaces) Buf versioning
- Is explicitly recommended by Buf documentation
- Used by all major gRPC APIs (Google, Kubernetes, etc.)

**Decision: Keep directory-based versioning (v1/, v2/) + Buf versioning (SemVer)**

## Further Reading

- [Detailed Versioning Strategy](standards/versioning.md)
- [Quick Versioning Guide](architecture/versioning-strategy.md)
- [Buf Best Practices](https://buf.build/docs/best-practices/versioning-modules)
- [Google API Design Guide - Versioning](https://cloud.google.com/apis/design/versioning)
- [Protocol Buffers Best Practices](https://protobuf.dev/programming-guides/api/)

## Questions?

If you have questions about versioning strategy:
1. Read [versioning-strategy.md](architecture/versioning-strategy.md) for quick overview
2. Read [versioning.md](standards/versioning.md) for comprehensive guide
3. Open a discussion in GitHub Discussions
4. Contact the API team

---

**Status**: ✅ Decision Final - Keep directory-based versioning  
**Date**: November 2025  
**Rationale**: Necessary for API evolution, not redundant with Buf versioning
