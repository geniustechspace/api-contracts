# Service Generator Quick Start

## TL;DR

Create a new service in 2 minutes:

```bash
make add-service
```

Answer 4 questions, and you're done! ✨

## Questions You'll Be Asked

1. **Service name** (e.g., `billing`, `user-management`)
   - Lowercase, hyphens allowed
   - Must be unique
   
2. **Description** (e.g., "Billing and subscription management")
   - Brief description of what the service does
   
3. **Version** (default: `v1`)
   - Just press Enter for new services
   
4. **Entity name** (e.g., `Subscription`, `User`)
   - Main resource type in TitleCase

## What You Get

✅ Complete proto file with:
- CRUD operations (Create, Read, Update, Delete, List)
- Health check endpoint
- Multitenancy support
- Input validation
- Pagination
- Error handling

✅ Documentation:
- README with usage examples
- Service documentation
- Message type reference

✅ Auto-integration:
- Build scripts automatically discover it
- No configuration needed

## Example

```bash
$ make add-service

Service name: inventory
Description: Inventory and warehouse management
Version: v1
Entity name: Product

✓ Created proto/inventory/v1/inventory.proto
✓ Service ready to use!
```

## Next Steps

After creation:

```bash
# 1. Review generated files
cat proto/<service-name>/README.md
cat proto/<service-name>/v1/<service>.proto

# 2. Customize as needed
vim proto/<service-name>/v1/<service>.proto

# 3. Generate clients
make generate

# 4. Lint and validate
make lint
make validate-structure
```

## Full Documentation

See [docs/guides/adding-new-services.md](guides/adding-new-services.md) for:
- Detailed walkthrough
- Customization examples
- Best practices
- Troubleshooting

## Common Service Examples

### Billing Service
```
Name: billing
Description: Billing and subscription management
Entity: Subscription
```

### User Management
```
Name: user-management  
Description: User management and authentication
Entity: User
```

### Notification Service
```
Name: notification
Description: Push notification and email delivery
Entity: Notification
```

### Inventory
```
Name: inventory
Description: Inventory and warehouse management
Entity: Product
```

## Tips

✅ **Do:**
- Use kebab-case: `user-management`
- Be descriptive: `order-processing`
- Start with v1

❌ **Don't:**
- Use uppercase: `USER-MANAGEMENT`
- Use abbreviations: `usr`, `notif`
- Skip validation

## Need Help?

- **Full Guide**: [docs/guides/adding-new-services.md](guides/adding-new-services.md)
- **Templates**: [templates/README.md](../templates/README.md)
- **Scripts**: [SCRIPTS_SUMMARY.md](../SCRIPTS_SUMMARY.md)
