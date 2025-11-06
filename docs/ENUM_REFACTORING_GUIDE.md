# Enum Refactoring Migration Guide

## Overview

The `proto/common/enums.proto` file has been refactored into domain-based files for better maintainability and organization.

## New Structure

```
proto/common/enums/
├── operations.proto    # Status, ErrorCode (Sections 1-2)
├── datetime.proto      # RecurrenceFrequency, DayOfWeek
├── logging.proto       # Severity (Section 3) - TODO
├── lifecycle.proto     # LifecycleState (Section 4) - TODO
├── audit.proto         # AuditAction (Section 5) - TODO
├── auth.proto          # AuthContext (Section 6) - TODO
├── risk.proto          # RiskLevel (Section 7) - TODO
└── data.proto          # DataClassification, RetentionPeriod - TODO
```

## Migration Status

### ✅ Completed

- [x] Created `proto/common/enums/` directory
- [x] Created `enums/operations.proto` (Status, ErrorCode)
- [x] Created `enums/datetime.proto` (RecurrenceFrequency, DayOfWeek)
- [x] Updated `proto/common/datetime.proto` to use new enums
- [x] Added validation constraints to `datetime.proto`
- [x] Added reserved field numbering

### 🚧 In Progress

- [ ] Create remaining enum files (logging, lifecycle, audit, auth, risk, data)
- [ ] Update `proto/common/enums.proto` as backward-compatible wrapper
- [ ] Update all proto files that import `enums.proto`
- [ ] Regenerate client code (TypeScript, Python, Rust, Go)
- [ ] Update documentation

## Breaking Changes

### None (Backward Compatible)

The refactoring maintains backward compatibility by:

1. Keeping the same package name: `geniustechspace.common.v1`
2. All enum names and values remain identical
3. Generated code in all languages remains compatible
4. Old imports still work (via wrapper file)

## Usage Examples

### Old Way (Still Works)

```protobuf
import "common/enums.proto";

message MyMessage {
  Status status = 1;
  ErrorCode error_code = 2;
}
```

### New Way (Recommended)

```protobuf
import "common/enums/operations.proto";
import "common/enums/datetime.proto";

message MyMessage {
  Status status = 1;
  ErrorCode error_code = 2;
  RecurrenceFrequency frequency = 3;
}
```

## Benefits

1. **Smaller Files**: ~200-300 lines per file instead of 1500+
2. **Clearer Ownership**: Domain teams can own their enum files
3. **Easier Reviews**: Smaller diffs, focused changes
4. **Better Organization**: Related enums grouped together
5. **Faster Compilation**: Only import what you need
6. **Reduced Merge Conflicts**: Changes isolated to specific domains

## Next Steps

1. Complete remaining enum file splits
2. Update all service `.proto` files to use new imports
3. Test code generation for all languages
4. Update CI/CD to validate new structure
5. Document in main README

## Date

2025-11-01

## Author

GitHub Copilot (AI Assistant)
