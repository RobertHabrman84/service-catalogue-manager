# Troubleshooting Guide

## Common Issues

### Authentication Issues

#### "401 Unauthorized" Error

**Symptoms**: API returns 401, user cannot login

**Solutions**:
1. Check token expiration
2. Verify Azure AD app registration
3. Confirm correct tenant ID
4. Clear browser cache and cookies

```bash
# Verify token
jwt decode <token>
```

#### MSAL Redirect Loop

**Symptoms**: Page keeps redirecting after login

**Solutions**:
1. Check redirect URI configuration
2. Verify popup/redirect mode
3. Clear session storage

### Database Issues

#### Connection Timeout

**Symptoms**: "A connection was successfully established with the server, but then an error occurred"

**Solutions**:
1. Check connection string
2. Verify firewall rules
3. Confirm SQL Server is running
4. Check connection pool settings

```bash
# Test connection
sqlcmd -S <server> -U <user> -P <password> -Q "SELECT 1"
```

#### Migration Failures

**Symptoms**: "The migration has already been applied"

**Solutions**:
```bash
# Check migration status
dotnet ef migrations list

# Remove last migration
dotnet ef migrations remove

# Force migration
dotnet ef database update --force
```

### API Issues

#### CORS Errors

**Symptoms**: "Access-Control-Allow-Origin" error in browser

**Solutions**:
1. Add origin to allowed list in host.json
2. Check for trailing slashes in URLs
3. Verify request headers

```json
// host.json
{
  "extensions": {
    "http": {
      "cors": {
        "origins": ["http://localhost:5173"]
      }
    }
  }
}
```

#### 500 Internal Server Error

**Symptoms**: Generic error response

**Solutions**:
1. Check Application Insights logs
2. Review Function App logs
3. Verify environment variables

```bash
# View logs
func azure functionapp logs <app-name>
```

### Frontend Issues

#### Blank Page After Deployment

**Symptoms**: White screen, no console errors

**Solutions**:
1. Check base URL configuration
2. Verify build output
3. Check staticwebapp.config.json routing

#### State Not Updating

**Symptoms**: UI doesn't reflect changes

**Solutions**:
1. Check Redux DevTools
2. Verify action dispatch
3. Review reducer logic

### Performance Issues

#### Slow API Responses

**Symptoms**: Requests taking > 2 seconds

**Solutions**:
1. Check database query performance
2. Review N+1 queries
3. Add missing indexes
4. Enable response caching

```sql
-- Find slow queries
SELECT TOP 10 
    total_elapsed_time / execution_count AS avg_time,
    SUBSTRING(st.text, 1, 100) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_time DESC;
```

## Logging

### View Logs

```bash
# Azure Functions
az monitor app-insights query --app <app> --analytics-query "traces | take 100"

# Local development
func start --verbose
```

### Log Levels

| Level | When to Use |
|-------|-------------|
| Debug | Development only |
| Information | Important events |
| Warning | Unexpected but handled |
| Error | Failures |
| Critical | System failures |

## Support

### Contact

- Development Team: dev-team@example.com
- On-call: oncall@example.com
- Slack: #service-catalogue-support

### Escalation

1. Check this guide
2. Search existing issues
3. Contact development team
4. Create incident if critical
