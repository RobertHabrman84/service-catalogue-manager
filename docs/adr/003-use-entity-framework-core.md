# ADR-003: Use Entity Framework Core

## Status

Accepted

## Date

2025-01-15

## Context

We need to choose a data access technology for the Service Catalogue Manager. Requirements include:

- Support for Azure SQL Database
- Complex data model with many relationships
- LINQ support for type-safe queries
- Migration support for schema changes
- Good performance for our expected load
- Developer productivity

## Decision

We will use **Entity Framework Core 8** as our ORM with:

- **Code-First** approach with migrations
- **Repository pattern** for abstraction
- **Unit of Work** for transaction management
- **Specification pattern** for complex queries

## Consequences

### Positive

- Strong LINQ support for type-safe queries
- Automatic change tracking
- Migration support for schema versioning
- Good integration with .NET ecosystem
- Supports complex relationships (1:N, N:N)
- Lazy/eager loading options
- Good tooling (dotnet ef CLI)
- Active development and community

### Negative

- Learning curve for complex scenarios
- Can generate inefficient queries if not careful
- Memory overhead for change tracking
- Abstraction may hide SQL issues
- Complex mapping for legacy databases

### Neutral

- Requires understanding of ORM patterns
- Need to monitor generated SQL in development

## Alternatives Considered

### Alternative 1: Dapper

Micro-ORM with better performance for simple queries. However, requires writing SQL manually, no change tracking, and more boilerplate code. Would slow down development for our complex data model.

### Alternative 2: Raw ADO.NET

Maximum control and performance. However, significant boilerplate, no automatic mapping, error-prone, and slower development. Overkill for our performance needs.

### Alternative 3: NHibernate

Mature ORM with powerful mapping. However, more complex configuration, smaller community than EF Core, and team has more EF experience.

## Implementation Details

### DbContext Configuration

```csharp
services.AddDbContext<ServiceCatalogDbContext>(options =>
    options.UseSqlServer(connectionString)
           .EnableSensitiveDataLogging(isDevelopment)
           .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking));
```

### Performance Considerations

- Use `AsNoTracking()` for read-only queries
- Use `Include()` strategically to avoid N+1
- Index frequently queried columns
- Use projections for list queries

## Related Decisions

- [ADR-002](./002-use-azure-functions-for-backend.md) - Backend technology

## References

- [EF Core Documentation](https://docs.microsoft.com/ef/core/)
- [EF Core Performance](https://docs.microsoft.com/ef/core/performance/)
