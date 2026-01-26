# Security Architecture

## Overview

Service Catalogue Manager implements a defense-in-depth security strategy with multiple layers of protection.

## Authentication

### Azure AD Integration

- OAuth 2.0 / OpenID Connect
- MSAL.js for frontend authentication
- JWT Bearer tokens for API authentication

```
User → Azure AD → Access Token → API
```

### Token Validation

```csharp
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(configuration.GetSection("AzureAd"));
```

## Authorization

### Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| Reader | View services, export |
| Editor | Create, update services |
| Admin | All operations, delete |
| Owner | Full access, user management |

### Permission Matrix

| Action | Reader | Editor | Admin |
|--------|--------|--------|-------|
| View services | ✓ | ✓ | ✓ |
| Create service | ✗ | ✓ | ✓ |
| Update service | ✗ | ✓ | ✓ |
| Delete service | ✗ | ✗ | ✓ |
| Export PDF | ✓ | ✓ | ✓ |
| Publish UuBookKit | ✗ | ✓ | ✓ |

## Data Protection

### Encryption

| Data State | Method |
|------------|--------|
| At Rest | Azure SQL TDE |
| In Transit | TLS 1.3 |
| Backup | Azure Backup Encryption |

### Sensitive Data

- Connection strings in Azure Key Vault
- No PII stored in logs
- Audit trail for data access

## Network Security

```
Internet → Azure Front Door (WAF) → VNET → Private Endpoints
```

- Web Application Firewall (WAF)
- DDoS Protection
- Private endpoints for database
- Network Security Groups (NSG)

## Input Validation

```csharp
// All inputs validated with FluentValidation
RuleFor(x => x.ServiceCode)
    .NotEmpty()
    .Matches("^[A-Z0-9-]+$")
    .MaximumLength(50);
```

## Security Headers

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Strict-Transport-Security: max-age=31536000
```

## Audit Logging

All operations are logged with:
- User identity
- Timestamp
- Action performed
- IP address
- Request/response summary

## Vulnerability Management

- Snyk for dependency scanning
- SonarCloud for code analysis
- Regular penetration testing
- Security review in PR process

## Incident Response

1. Detection via Azure Monitor alerts
2. Automatic notification to security team
3. Incident classification and triage
4. Containment and remediation
5. Post-incident review

## Compliance

- GDPR compliant data handling
- SOC 2 Type II controls
- ISO 27001 aligned processes
