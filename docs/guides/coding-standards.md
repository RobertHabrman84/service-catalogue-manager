# Coding Standards

## General Principles

1. **Readability First**: Code is read more often than written
2. **Consistency**: Follow established patterns
3. **KISS**: Keep It Simple, Stupid
4. **DRY**: Don't Repeat Yourself
5. **SOLID**: Follow SOLID principles

## C# / .NET Standards

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Class | PascalCase | `ServiceCatalogService` |
| Interface | IPascalCase | `IServiceCatalogService` |
| Method | PascalCase | `GetServiceById` |
| Property | PascalCase | `ServiceName` |
| Parameter | camelCase | `serviceId` |
| Private field | _camelCase | `_repository` |
| Constant | PascalCase | `MaxRetryCount` |

### Code Structure

```csharp
public class ServiceCatalogService : IServiceCatalogService
{
    private readonly IRepository _repository;
    private readonly ILogger<ServiceCatalogService> _logger;

    public ServiceCatalogService(
        IRepository repository,
        ILogger<ServiceCatalogService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<ServiceDto> GetByIdAsync(int id)
    {
        // Implementation
    }
}
```

### Async/Await

- Always use async/await for I/O operations
- Suffix async methods with `Async`
- Don't use `.Result` or `.Wait()`

## TypeScript/React Standards

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Component | PascalCase | `ServiceCard` |
| Hook | useCamelCase | `useServiceCatalog` |
| Function | camelCase | `handleSubmit` |
| Variable | camelCase | `serviceList` |
| Constant | UPPER_SNAKE | `API_BASE_URL` |
| Type/Interface | PascalCase | `ServiceCatalogItem` |

### Component Structure

```tsx
import { FC, useState } from 'react';

interface ServiceCardProps {
  service: Service;
  onEdit: (id: number) => void;
}

export const ServiceCard: FC<ServiceCardProps> = ({ service, onEdit }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const handleClick = () => {
    onEdit(service.id);
  };

  return (
    <div className="service-card">
      {/* JSX */}
    </div>
  );
};
```

### State Management

- Use Redux Toolkit for global state
- Use local state for component-specific state
- Avoid prop drilling beyond 2 levels

## SQL Standards

```sql
-- Use meaningful aliases
SELECT 
    s.ServiceCode,
    s.ServiceName,
    st.StatusName
FROM dbo.ServiceCatalogItem s
INNER JOIN dbo.LU_ServiceStatus st ON s.StatusId = st.Id
WHERE s.IsDeleted = 0
ORDER BY s.ServiceName;
```

## Git Commit Messages

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
- `feat(api): add export to PDF endpoint`
- `fix(ui): resolve pagination bug`
- `docs: update API documentation`

## Code Review Checklist

- [ ] Follows naming conventions
- [ ] Has unit tests
- [ ] No hardcoded values
- [ ] Error handling in place
- [ ] Logging for important operations
- [ ] No security vulnerabilities
- [ ] Documentation updated
