# API Versioning Strategy

## Executive Summary

**Recommendation: Keep directory-based versioning (v1/, v2/) in addition to Buf versioning.**

While Buf provides powerful versioning capabilities through the Buf Schema Registry (BSR), directory-based versioning serves a different and complementary purpose. Both are necessary for a complete enterprise API management strategy.

## Background

This document evaluates whether directory-based proto versioning (`proto/core/v1/`, `proto/core/v2/`) is necessary given Buf's built-in versioning strategies and policies.

## Understanding the Two Types of Versioning

### 1. Directory-Based Versioning (API Versioning)

**Purpose**: API evolution and breaking change management

**Example**:
```
proto/
├── core/v1/          # Stable, never changes
│   └── user.proto    # package core.v1;
└── core/v2/          # New version with breaking changes
    └── user.proto    # package core.v2;
```

**What it provides**:
- Multiple API versions can coexist simultaneously
- Clients can choose which version to use
- Breaking changes don't affect existing clients
- Clear migration path between versions
- Package names in code reflect versions (e.g., `core.v1` vs `core.v2`)

### 2. Buf Versioning (Module/Dependency Versioning)

**Purpose**: Module publication and dependency management

**What Buf provides**:
- **BSR (Buf Schema Registry)**: Version control for published proto modules
- **Semantic Versioning**: Tracks changes using SemVer (1.0.0, 1.1.0, 2.0.0)
- **Breaking Change Detection**: Automatically detects backward-incompatible changes
- **Dependency Management**: Manages dependencies between proto modules
- **Build Reproducibility**: Lock files ensure consistent builds

**Example** (buf.yaml):
```yaml
version: v2
modules:
  - path: proto
    name: buf.build/geniustechspace/api-contracts
```

## Key Differences

| Aspect | Directory-Based (v1/, v2/) | Buf Versioning (BSR) |
|--------|---------------------------|----------------------|
| **Scope** | Individual API versions | Entire module releases |
| **Granularity** | Per service/package | Per repository/module |
| **Purpose** | API evolution | Dependency management |
| **Coexistence** | Multiple versions at runtime | Single version in codebase |
| **Client Impact** | Clients choose version | Clients pin dependency version |
| **Breaking Changes** | New directory (v2) | New major version (2.0.0) |
| **Use Case** | Long-term API compatibility | Build reproducibility |

## Why Directory-Based Versioning is Still Necessary

### 1. **Runtime Coexistence**

Directory-based versioning allows multiple API versions to exist simultaneously in the same codebase and run in the same service:

```go
// Both versions available at runtime
import corev1 "github.com/example/api/core/v1"
import corev2 "github.com/example/api/core/v2"

// Service implements both
type Server struct {
    corev1.UnimplementedUserServiceServer
    corev2.UnimplementedUserServiceServer
}
```

**Buf versioning cannot provide this** - you get one version per build.

### 2. **Gradual Client Migration**

With directory versioning:
- Old clients continue using v1 indefinitely
- New clients adopt v2 at their own pace
- No forced upgrades or breaking changes
- Services support both versions during migration period

Example migration timeline:
```
Year 1: Launch v1
Year 2: Launch v2, both v1 and v2 supported
Year 3-5: Gradual client migration from v1 to v2
Year 6: Deprecate v1 (with advance notice)
```

### 3. **Clear Package Naming**

Directory structure provides clear package names in generated code:

```protobuf
// proto/core/v1/user.proto
package core.v1;

// proto/core/v2/user.proto  
package core.v2;
```

Generated code:
```rust
use api_contracts::core::v1::User as UserV1;
use api_contracts::core::v2::User as UserV2;
```

This makes version explicit in code and prevents accidental mixing of versions.

### 4. **Protobuf Best Practice**

Directory-based versioning is the recommended approach in the Protocol Buffers ecosystem:

- **Google APIs**: Uses directory versioning extensively (google/cloud/vision/v1, google/cloud/vision/v2)
- **gRPC**: Recommends package versioning for API evolution
- **Industry Standard**: Most major gRPC APIs use this pattern
- **Buf Recommendation**: Buf docs recommend combining both approaches

### 5. **Breaking Change Management**

When you need breaking changes:

**Without directory versioning**:
```
❌ Problem: Must force all clients to upgrade
❌ Risk: Client code breaks
❌ Process: Coordination nightmare
```

**With directory versioning**:
```
✅ Solution: Create v2 alongside v1
✅ Safety: No client breaks
✅ Process: Smooth migration
```

## What Buf Versioning Provides (That's Different)

Buf versioning handles:

1. **Module Publishing**: Publishing versioned releases to BSR
   ```bash
   buf push --tag v1.2.3
   ```

2. **Dependency Management**: Other modules depend on specific versions
   ```yaml
   deps:
     - buf.build/geniustechspace/api-contracts:v1.2.3
   ```

3. **Breaking Change Detection**: CI fails on accidental breaking changes
   ```bash
   buf breaking --against '.git#tag=v1.2.0'
   ```

4. **Reproducible Builds**: Lock file ensures same dependencies
   ```yaml
   # buf.lock
   version: v2
   deps:
     - name: buf.build/googleapis/googleapis
       commit: abc123...
   ```

## Recommended Strategy: Use Both

### Directory Versioning (v1/, v2/) - For API Evolution

Use when:
- ✅ Making breaking changes to existing APIs
- ✅ Need to support multiple API versions simultaneously
- ✅ Clients need time to migrate between versions
- ✅ Creating major new API surfaces

**Process**:
1. Start with v1: `proto/service/v1/`
2. Maintain v1 as stable (only non-breaking additions)
3. When breaking changes needed: Create v2: `proto/service/v2/`
4. Support both v1 and v2 in parallel
5. Eventually deprecate v1 (with long notice period)

### Buf Versioning (SemVer) - For Module Publishing

Use for:
- ✅ Publishing releases to BSR
- ✅ Dependency management between modules
- ✅ CI/CD versioning and tagging
- ✅ Client library versioning

**Process**:
1. Tag releases: `v1.0.0`, `v1.1.0`, `v2.0.0`
2. Push to BSR: `buf push --tag v1.1.0`
3. Clients depend on specific versions
4. SemVer indicates compatibility:
   - Patch (1.0.1): Bug fixes only
   - Minor (1.1.0): New features, backward compatible
   - Major (2.0.0): Breaking changes (likely includes new v2 directory)

## Version Mapping Example

```
Repository State          Buf Version    Notes
─────────────────────────────────────────────────────────────
proto/core/v1/            v1.0.0        Initial release
proto/core/v1/            v1.1.0        Added new fields (non-breaking)
proto/core/v1/            v1.2.0        Added new service (non-breaking)
proto/core/v1/            v1.2.1        Bug fix in docs
proto/core/v1/ + v2/      v2.0.0        Breaking changes → new v2 directory
proto/core/v1/ + v2/      v2.1.0        Added features to v2
proto/core/v1/ + v2/      v2.1.1        Bug fix in v2
```

## Migration Path for Breaking Changes

### Scenario: Need to change User message structure

**Step 1: Create v2 directory**
```bash
mkdir -p proto/core/v2
cp proto/core/v1/user.proto proto/core/v2/user.proto
```

**Step 2: Make breaking changes in v2**
```protobuf
// proto/core/v2/user.proto
package core.v2;

message User {
  string id = 1;
  string full_name = 2;  // CHANGED: was first_name + last_name
  string email = 3;
  // Breaking: removed deprecated fields
}
```

**Step 3: Keep v1 stable**
```protobuf
// proto/core/v1/user.proto (unchanged)
package core.v1;

message User {
  string id = 1;
  string first_name = 2;
  string last_name = 3;
  string email = 4;
}
```

**Step 4: Update service to support both**
```go
// Service implements both versions
type UserService struct {
    v1.UnimplementedUserServiceServer
    v2.UnimplementedUserServiceServer
}
```

**Step 5: Tag as major version**
```bash
git tag v2.0.0
buf push --tag v2.0.0
```

## buf.yaml Configuration

Our current configuration correctly enforces versioning:

```yaml
lint:
  use:
    - PACKAGE_VERSION_SUFFIX    # Enforces v1, v2 in package names
    - PACKAGE_DIRECTORY_MATCH   # Package must match directory
```

This ensures:
- Package names must end with version suffix (v1, v2)
- Directory structure must match package names
- Consistency across entire codebase

## Common Misconceptions

### ❌ Misconception 1: "Buf versioning replaces directory versioning"

**Reality**: They serve different purposes. Buf versions the module release, directory versions the API contract.

### ❌ Misconception 2: "Directory versioning is redundant"

**Reality**: It's essential for supporting multiple API versions simultaneously in production.

### ❌ Misconception 3: "We can just use buf breaking to prevent issues"

**Reality**: `buf breaking` prevents *accidental* breaking changes. Sometimes you *need* breaking changes - that's when you create v2.

### ❌ Misconception 4: "Directory versioning is just for backward compatibility"

**Reality**: It's also about forward evolution - letting you experiment with v2 while v1 remains stable.

## Best Practices

### DO ✅

1. **Use directory versioning (v1/, v2/)** for API evolution
2. **Use Buf versioning (SemVer)** for module releases
3. **Never break v1** - make v2 instead
4. **Support multiple versions** during migration periods
5. **Deprecate old versions** with plenty of notice (6-12 months)
6. **Document version differences** clearly
7. **Use buf breaking** to prevent accidental breaking changes in same version

### DON'T ❌

1. **Don't make breaking changes** to existing versions
2. **Don't force immediate migration** - give clients time
3. **Don't create v2 prematurely** - only when truly needed
4. **Don't support versions forever** - have sunset plans
5. **Don't mix versions** in the same package name
6. **Don't rely only on Buf versioning** for API evolution

## Conclusion

**Keep directory-based versioning (v1/, v2/).** It is not redundant - it serves a fundamentally different purpose than Buf versioning:

- **Directory versioning**: API contract evolution (v1 vs v2 APIs)
- **Buf versioning**: Module release management (v1.2.3 vs v1.2.4)

Both are necessary for a robust enterprise API strategy. They complement each other:
- Buf ensures safe, reproducible builds and dependency management
- Directory versioning ensures smooth API evolution without breaking clients

This combination provides:
1. ✅ Backward compatibility through parallel version support
2. ✅ Clear migration paths for breaking changes
3. ✅ Industry-standard API evolution patterns
4. ✅ Safe dependency management via Buf
5. ✅ Flexibility to evolve APIs without disruption

## References

- [Buf Best Practices](https://buf.build/docs/best-practices/versioning-modules)
- [Google API Design Guide - Versioning](https://cloud.google.com/apis/design/versioning)
- [Protocol Buffers Style Guide](https://protobuf.dev/programming-guides/style/)
- [Semantic Versioning 2.0.0](https://semver.org/)

## Related Documentation

- [API Design Standards](README.md)
- [Breaking Change Detection](../../guides/breaking-changes.md)
- [Migration Guide](../../guides/version-migration.md)
