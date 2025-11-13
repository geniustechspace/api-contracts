# Versioning Strategy: Directory-Based + Buf Versioning

## Quick Answer

**Q: Is directory-based versioning (v1/, v2/) necessary when we have Buf versioning?**

**A: Yes, both are necessary. They solve different problems:**

| Concern | Solution |
|---------|----------|
| API evolution with breaking changes | Directory versioning (v1/, v2/) |
| Module publishing and dependencies | Buf versioning (SemVer) |
| Running multiple API versions simultaneously | Directory versioning |
| Reproducible builds | Buf versioning |
| Client migration paths | Directory versioning |
| CI/CD release management | Buf versioning |

## Two-Minute Explanation

### Directory Versioning = API Contract Versions

Think of it like software versions - Windows 10 and Windows 11 can coexist because they're different products:

```
proto/
├── user/v1/service.proto  ← "Windows 10" - stable, never changes
└── user/v2/service.proto  ← "Windows 11" - new features, breaking changes
```

**Benefits**:
- Old clients keep working (using v1)
- New clients get new features (using v2)  
- Service supports both during migration
- No forced upgrades

### Buf Versioning = Release Versions

Think of it like app updates - Chrome 120.0.1, Chrome 120.0.2:

```bash
git tag v1.5.0     # Module release version
buf push --tag v1.5.0
```

**Benefits**:
- Tracks changes over time
- Manages dependencies
- Ensures reproducible builds
- Enables breaking change detection

## Real-World Example

### Timeline of API Evolution

**Month 1: Initial Release**
```
proto/user/v1/          → Buf version v1.0.0
```
All clients use v1.

**Month 6: Add New Field (Non-Breaking)**
```
proto/user/v1/          → Buf version v1.1.0
  - Added: User.phone_number
```
v1 clients automatically get new field (backward compatible).

**Month 12: Breaking Change Needed**
```
proto/user/v1/          → Still at v1.1.0 (stable)
proto/user/v2/          → New Buf version v2.0.0
  - Changed: User.name → User.full_name
  - Removed: User.legacy_id
```

Now:
- Old clients: Still use v1 (nothing breaks)
- New clients: Can adopt v2 (better API)
- Service: Supports both v1 and v2

**Months 12-24: Migration Period**
```
proto/user/v1/          → Still supported
proto/user/v2/          → v2.1.0, v2.1.1, v2.2.0...
```
Clients gradually migrate from v1 to v2.

**Month 24: Deprecate v1**
```
proto/user/v2/          → v2.5.0 (only v2 now)
```
v1 removed after all clients migrated.

## Why Not Just Buf Versioning?

### Problem: Can't Run Two Versions Simultaneously

**With only Buf versioning:**
```rust
// Can only depend on ONE version at a time
dependencies = [
    "api-contracts:v1.0.0"  // OR
    "api-contracts:v2.0.0"  // Can't have both
]
```

**With directory versioning:**
```rust
// Can use both versions in same codebase
use api_contracts::user::v1::UserClient as UserClientV1;
use api_contracts::user::v2::UserClient as UserClientV2;

// Service supports both
impl UserServiceV1 for Server { ... }
impl UserServiceV2 for Server { ... }
```

### Problem: Forced Migration

**Without directory versioning:**
1. You release breaking change in v2.0.0
2. All clients must upgrade immediately
3. If they don't, their code breaks
4. Coordination nightmare

**With directory versioning:**
1. You create v2 alongside v1
2. v1 clients keep working (no changes needed)
3. v2 clients can upgrade when ready
4. Smooth, gradual migration

## Industry Standard

This approach is used by all major APIs:

**Google Cloud APIs:**
```
google/cloud/vision/v1/
google/cloud/vision/v2/
```

**Kubernetes APIs:**
```
k8s.io/api/apps/v1/
k8s.io/api/apps/v1beta1/
```

**gRPC Health Check:**
```
grpc/health/v1/
```

## Our Configuration

We enforce this in `buf.yaml`:

```yaml
lint:
  use:
    - PACKAGE_VERSION_SUFFIX     # Requires v1, v2 in package names
    - PACKAGE_DIRECTORY_MATCH    # Directory must match package
```

This means:
- ✅ `proto/user/v1/` with `package user.v1` - Valid
- ✅ `proto/user/v2/` with `package user.v2` - Valid
- ❌ `proto/user/` with `package user` - Invalid (no version)

## When to Create a New Version

### Create v2 when:
- ✅ Removing fields
- ✅ Changing field types
- ✅ Renaming messages/fields
- ✅ Changing service method signatures
- ✅ Major API redesign

### Don't create v2 for:
- ❌ Adding new fields (backward compatible)
- ❌ Adding new services (backward compatible)
- ❌ Adding new enums (backward compatible)
- ❌ Bug fixes in implementation (not proto change)

## Summary

**Directory versioning (v1/, v2/):**
- Purpose: API evolution
- Benefit: Multiple versions coexist
- When: Breaking changes needed

**Buf versioning (v1.2.3):**
- Purpose: Release management  
- Benefit: Dependency tracking
- When: Every release

**Together:** Complete versioning strategy for enterprise APIs.

## Decision: Keep Both ✅

Directory-based versioning stays. It's not redundant - it's essential for API evolution without breaking clients.

## Next Steps

1. Continue using directory versioning for new services
2. Use Buf versioning for module releases
3. Follow versioning guidelines in [versioning.md](../standards/versioning.md)
4. Document version changes in CHANGELOG.md

## Related Documentation

- [Detailed Versioning Strategy](../standards/versioning.md)
- [Breaking Change Guide](../guides/breaking-changes.md)
- [API Evolution Guide](../guides/api-evolution.md)
