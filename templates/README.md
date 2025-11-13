# Service Templates

This directory contains templates for creating new service packages in the proto directory.

## Overview

The templates provide a standardized starting point for new services, ensuring consistency across all service definitions in the repository.

## Template Files

### `service/README.md.template`

Template for the service README documentation. Includes:
- Service overview and description
- File listing
- Usage examples
- Service and message type documentation
- Versioning information
- Generated client information

### `service/service.proto.template`

Template for the main service proto file. Includes:
- Complete gRPC service definition
- CRUD operations (Create, Read, Update, Delete, List)
- Health check endpoint
- Standard message types with validation rules
- Enterprise multitenancy support
- Error handling integration
- Pagination support

## Template Variables

The following variables are replaced during generation:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SERVICE_NAME}}` | Service name (kebab-case) | `user-management` |
| `{{SERVICE_NAME_TITLE}}` | Service name (TitleCase) | `UserManagement` |
| `{{SERVICE_NAME_UPPER}}` | Service name (UPPER_CASE) | `USER_MANAGEMENT` |
| `{{SERVICE_NAME_LOWER}}` | Service name (lowercase) | `usermanagement` |
| `{{SERVICE_FILE}}` | Proto file name (snake_case) | `user_management` |
| `{{SERVICE_DESCRIPTION}}` | Service description | `User management and authentication` |
| `{{SERVICE_DESCRIPTION_LOWER}}` | Description in lowercase | `user management and authentication` |
| `{{VERSION}}` | API version | `v1` |
| `{{ENTITY_NAME}}` | Main entity name (TitleCase) | `User` |
| `{{ENTITY_NAME_LOWER}}` | Entity name (lowercase) | `user` |
| `{{ENTITY_NAME_UPPER}}` | Entity name (UPPER_CASE) | `USER` |
| `{{MESSAGE_PREFIX}}` | Prefix for messages (TitleCase) | `UserManagement` |

## Usage

### Using the Interactive Script

The easiest way to create a new service is using the interactive script:

```bash
# From repository root
make add-service

# Or directly
./scripts/add_service.sh
```

The script will prompt you for:
1. **Service name** - Lowercase with hyphens (e.g., `user-management`)
2. **Service description** - Brief description (e.g., `User management and authentication`)
3. **API version** - Defaults to `v1`
4. **Main entity name** - TitleCase (e.g., `User`)

### Manual Template Usage

If you prefer to use templates manually:

1. Copy template files to your service directory:
   ```bash
   cp templates/service/README.md.template proto/my-service/README.md
   cp templates/service/service.proto.template proto/my-service/v1/my_service.proto
   ```

2. Replace template variables manually or use `sed`:
   ```bash
   sed -i 's/{{SERVICE_NAME}}/my-service/g' proto/my-service/README.md
   # ... replace other variables
   ```

## Template Features

### Enterprise Integration

All templates include:
- **Multitenancy** - Integration with `core.v1.TenantContext`
- **Error Handling** - Standard error responses via `core.v1.ErrorResponse`
- **Validation** - Input validation using `validate/validate.proto`
- **Pagination** - List operations with pagination support
- **Audit Trail** - Timestamps for created/updated/deleted
- **Soft Deletes** - Delete operations with recovery capability

### CRUD Operations

Default CRUD operations included:
- **Create** - Create a new entity
- **Get** - Retrieve entity by ID
- **List** - List entities with pagination and filtering
- **Update** - Update existing entity
- **Delete** - Soft delete an entity
- **HealthCheck** - Service health monitoring

### Validation Rules

Templates include sensible validation rules:
- Required fields marked with `min_len: 1`
- String length constraints (e.g., `max_len: 255`)
- Enum validations for status fields
- Custom validation rules as needed

## Customizing Templates

### Modifying Existing Templates

To customize the templates:

1. Edit files in `templates/service/`
2. Update template variables as needed
3. Test with `make add-service`

### Adding New Templates

To add additional template files:

1. Create new `.template` file in `templates/service/`
2. Use template variables from the table above
3. Update `scripts/add_service.sh` to process the new template

Example:
```bash
# In add_service.sh, add processing for new template
process_template "$TEMPLATES_DIR/health.proto.template" \
                "$version_dir/health.proto" \
                "$SERVICE_NAME" "$SERVICE_DESCRIPTION" "$VERSION" "$ENTITY_NAME"
```

## Best Practices

### Naming Conventions

- **Service names**: Use kebab-case (e.g., `user-management`, `billing`)
- **Entity names**: Use TitleCase (e.g., `User`, `Subscription`)
- **Proto files**: Use snake_case (e.g., `user_management.proto`)
- **Package names**: Use lowercase (e.g., `package billing.v1`)

### Service Design

When customizing generated services:

1. **Keep it focused** - Each service should have a single responsibility
2. **Use core types** - Import from `core/v1/` for common types
3. **Add validation** - Always validate inputs with `validate.proto`
4. **Document thoroughly** - Add comments for all messages and fields
5. **Version carefully** - Use `v1`, `v2`, etc. for breaking changes

### File Organization

Standard structure:
```
proto/
└── my-service/
    ├── README.md           # Service documentation
    └── v1/
        ├── my_service.proto    # Main service definition
        ├── types.proto         # Custom types (if needed)
        └── events.proto        # Event definitions (if needed)
```

## Examples

### Creating a User Management Service

```bash
make add-service

# Prompts:
# Service name: user-management
# Description: User management and authentication
# Version: v1 (default)
# Entity name: User
```

This generates:
- `proto/user-management/README.md`
- `proto/user-management/v1/user_management.proto`

With service: `UserManagementService`
And entity: `User` with standard CRUD operations

### Creating a Notification Service

```bash
make add-service

# Prompts:
# Service name: notification
# Description: Push notification and email delivery
# Version: v1 (default)
# Entity name: Notification
```

This generates:
- `proto/notification/README.md`
- `proto/notification/v1/notification.proto`

With service: `NotificationService`
And entity: `Notification` with standard CRUD operations

## Integration with Build System

After creating a new service:

1. **Generate clients**:
   ```bash
   make generate
   ```

2. **Lint proto files**:
   ```bash
   make lint
   ```

3. **Validate structure**:
   ```bash
   make validate-structure
   ```

4. **Build clients**:
   ```bash
   make build
   ```

The build system automatically discovers new services through the scripts' discovery mechanism.

## Troubleshooting

### Template Not Found

If you get "Template not found" errors:
```bash
# Verify templates exist
ls -la templates/service/

# Should show:
# README.md.template
# service.proto.template
```

### Variable Not Replaced

If template variables appear in generated files:
- Check variable spelling in template
- Verify `process_template()` function in `scripts/add_service.sh`
- Ensure sed commands handle all variables

### Service Not Discovered

If new service isn't picked up by scripts:
```bash
# Test discovery manually
source scripts/common.sh
discover_proto_modules "$(pwd)"

# Should list your new service
```

## See Also

- [scripts/add_service.sh](../scripts/add_service.sh) - Service generator script
- [scripts/common.sh](../scripts/common.sh) - Common utilities
- [SCRIPTS_SUMMARY.md](../SCRIPTS_SUMMARY.md) - Complete scripts documentation
- [proto/core/](../proto/core/) - Core types for all services
