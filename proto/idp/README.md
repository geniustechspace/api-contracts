# Identity Provider (IDP) Services

Complete identity and access management system.

## Structure

### Authentication (`auth/`)
- User authentication (login, logout)
- Multi-factor authentication (MFA)
- Single sign-on (SSO)
- OAuth 2.0 / OpenID Connect
- Session management

### User Management (`user/`)
- User CRUD operations
- Profile management
- Password management
- Email verification

### Organization Management (`organization/`)
- Organization hierarchy
- Organization settings
- Member management

### Role-Based Access Control (`role/`)
- Role definitions
- Role assignment
- Permission management

### Permissions (`permission/`)
- Fine-grained permissions
- Resource-based access control
- Dynamic authorization

### Sessions (`session/`)
- Session lifecycle
- Session validation
- Device management

## Security

All IDP services enforce strict security:
- TLS required for all connections
- Token-based authentication
- Rate limiting
- Audit logging
