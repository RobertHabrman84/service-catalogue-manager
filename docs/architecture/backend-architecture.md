# Backend Architecture

## Overview

The backend is built using Azure Functions with .NET 8 Isolated Worker runtime.

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| .NET | 8.0 | Runtime |
| Azure Functions | 4.x | Serverless hosting |
| Entity Framework Core | 8.x | ORM |
| AutoMapper | 12.x | Object mapping |
| FluentValidation | 11.x | Input validation |
| QuestPDF | 2024.x | PDF generation |

## Project Structure

```
ServiceCatalogueManager.Api/
├── Functions/
│   ├── ServiceCatalog/
│   ├── Lookup/
│   ├── Export/
│   ├── Health/
│   └── UuBookKit/
├── Services/
│   ├── Interfaces/
│   └── Implementations/
├── Data/
│   ├── DbContext/
│   ├── Entities/
│   └── Repositories/
├── Models/
│   ├── DTOs/
│   ├── Requests/
│   └── Responses/
├── Validators/
├── Mappers/
├── Middleware/
├── Templates/
│   ├── Pdf/
│   ├── Markdown/
│   └── UuBookKit/
└── Configuration/
```

## Architecture Layers

```
┌─────────────────────────────────────────┐
│            Functions Layer              │
│   (HTTP Triggers, Service Bus, etc.)    │
├─────────────────────────────────────────┤
│            Service Layer                │
│     (Business Logic, Validation)        │
├─────────────────────────────────────────┤
│          Repository Layer               │
│      (Data Access, Queries)             │
├─────────────────────────────────────────┤
│          Data Layer                     │
│   (DbContext, Entities, Migrations)     │
└─────────────────────────────────────────┘
```

## Dependency Injection

```csharp
// Program.cs
var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((context, services) =>
    {
        services.AddDbContext<ServiceCatalogDbContext>();
        services.AddScoped<IServiceCatalogService, ServiceCatalogService>();
        services.AddScoped<IExportService, ExportService>();
        services.AddAutoMapper(typeof(MappingProfile));
        services.AddValidatorsFromAssemblyContaining<CreateServiceValidator>();
    })
    .Build();
```

## Error Handling

```csharp
// Global exception middleware
public class ExceptionMiddleware : IFunctionsWorkerMiddleware
{
    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        try { await next(context); }
        catch (ValidationException ex) { /* 400 */ }
        catch (NotFoundException ex) { /* 404 */ }
        catch (Exception ex) { /* 500 */ }
    }
}
```

## Validation

```csharp
public class CreateServiceValidator : AbstractValidator<CreateServiceRequest>
{
    public CreateServiceValidator()
    {
        RuleFor(x => x.ServiceCode)
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(50);
    }
}
```

## Database Access

- Repository pattern with generic base repository
- Unit of Work for transaction management
- Specification pattern for complex queries
- Async/await throughout

## Export Services

| Format | Implementation |
|--------|----------------|
| PDF | QuestPDF with custom templates |
| Markdown | String templates |
| UuBookKit | Uu5 string generation |

## Configuration

```json
// local.settings.json
{
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "DatabaseConnection": "Server=...",
    "AzureAd:TenantId": "...",
    "AzureAd:ClientId": "..."
  }
}
```
