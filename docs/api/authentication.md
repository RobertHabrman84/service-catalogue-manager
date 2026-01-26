# API Authentication

## Overview

The API uses Azure AD OAuth 2.0 for authentication with JWT Bearer tokens.

## Authentication Flow

```
1. User → Azure AD (login)
2. Azure AD → User (access token)
3. User → API (request + token)
4. API → Validates token
5. API → User (response)
```

## Obtaining Access Token

### Interactive (Browser)

Use MSAL.js for browser-based applications:

```javascript
import { PublicClientApplication } from '@azure/msal-browser';

const msalConfig = {
  auth: {
    clientId: '<client-id>',
    authority: 'https://login.microsoftonline.com/<tenant-id>',
    redirectUri: 'http://localhost:5173'
  }
};

const pca = new PublicClientApplication(msalConfig);

const loginRequest = {
  scopes: ['api://<api-client-id>/access_as_user']
};

const response = await pca.loginPopup(loginRequest);
const accessToken = response.accessToken;
```

### Client Credentials (Service)

For service-to-service communication:

```bash
curl -X POST https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token \
  -d "client_id=<client-id>" \
  -d "client_secret=<client-secret>" \
  -d "scope=api://<api-client-id>/.default" \
  -d "grant_type=client_credentials"
```

## Using Access Token

Include token in Authorization header:

```http
GET /api/services HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1...
```

## Token Validation

The API validates:
- Token signature
- Issuer (iss)
- Audience (aud)
- Expiration (exp)
- Required scopes

## Scopes

| Scope | Description |
|-------|-------------|
| `access_as_user` | Basic API access |
| `Services.Read` | Read services |
| `Services.Write` | Create/update services |
| `Services.Delete` | Delete services |
| `Export.Execute` | Export operations |

## Error Responses

### 401 Unauthorized

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or missing token"
  }
}
```

### 403 Forbidden

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions"
  }
}
```

## Token Refresh

Access tokens expire after 1 hour. Use refresh tokens to obtain new access tokens:

```javascript
const response = await pca.acquireTokenSilent({
  scopes: ['api://<api-client-id>/access_as_user'],
  account: accounts[0]
});
```

## Security Best Practices

1. Never expose tokens in URLs
2. Store tokens securely
3. Use HTTPS only
4. Implement token refresh
5. Validate tokens server-side
