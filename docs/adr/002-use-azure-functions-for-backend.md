# ADR-002: Use Azure Functions for Backend

## Status

Accepted

## Date

2025-01-15

## Context

We need to choose a backend technology for the Service Catalogue Manager API. Requirements include:

- RESTful API endpoints
- Serverless or easily scalable architecture
- Integration with Azure services (SQL, Blob Storage, Azure AD)
- Cost-effective for variable workloads
- Support for long-running operations (PDF generation)
- .NET ecosystem preference

## Decision

We will use **Azure Functions** with **.NET 8 Isolated Worker** runtime for our backend API.

Key technology choices:
- **Azure Functions v4** with isolated worker model
- **.NET 8** for latest features and performance
- **Entity Framework Core 8** for data access
- **Azure API Management** for API gateway (optional)

## Consequences

### Positive

- Pay-per-execution pricing reduces costs for variable workloads
- Automatic scaling based on demand
- Native integration with Azure services
- Isolated worker provides better dependency isolation
- Can use latest .NET features without runtime constraints
- Easy deployment via Azure DevOps pipelines
- Built-in monitoring via Application Insights

### Negative

- Cold start latency for infrequently used functions
- Maximum execution time limits (Premium plan needed for long operations)
- More complex local development setup
- Vendor lock-in to Azure platform
- Function-based architecture different from traditional controllers

### Neutral

- Requires Azure subscription
- Different testing patterns than traditional web APIs

## Alternatives Considered

### Alternative 1: ASP.NET Core Web API with App Service

Traditional web API approach with more control. However, requires managing scaling manually or configuring auto-scale rules. Higher base cost for always-on instances.

### Alternative 2: Azure Container Apps

Container-based serverless with more flexibility. However, more complex deployment, overkill for our requirements, and team has less container experience.

### Alternative 3: AWS Lambda with .NET

Similar serverless approach on AWS. However, organization is Azure-focused, and integration with Azure AD and other Azure services would be more complex.

## Related Decisions

- [ADR-001](./001-use-react-for-frontend.md) - Frontend technology
- [ADR-003](./003-use-entity-framework-core.md) - Data access

## References

- [Azure Functions .NET Isolated](https://docs.microsoft.com/azure/azure-functions/dotnet-isolated-process-guide)
- [Azure Functions Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
