# Service Catalogue Manager - Documentation

Welcome to the Service Catalogue Manager documentation.

## Quick Links

| Section | Description |
|---------|-------------|
| [Architecture](./architecture/overview.md) | System architecture and design |
| [API Reference](./api/README.md) | API endpoints and examples |
| [Development Guide](./guides/development-setup.md) | Getting started guide |
| [ADR](./adr/README.md) | Architecture Decision Records |

## Overview

Service Catalogue Manager is an enterprise-grade application for managing, documenting, and publishing cloud service catalogs. It provides:

- **Service Management**: Create, update, and organize service definitions
- **Documentation Export**: Generate PDF and Markdown documentation
- **UuBookKit Integration**: Publish to Unicorn Universe documentation platform
- **Multi-cloud Support**: Track cloud provider capabilities

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18, TypeScript, Vite, TailwindCSS |
| Backend | Azure Functions (.NET 8), Entity Framework Core |
| Database | Azure SQL Server |
| Authentication | Azure AD / MSAL |
| CI/CD | Azure DevOps Pipelines |

## Documentation Structure

```
docs/
├── architecture/      # System architecture docs
│   ├── diagrams/     # Architecture diagrams
├── guides/           # Development & deployment guides
├── api/              # API reference documentation
│   └── examples/     # API usage examples
└── adr/              # Architecture Decision Records
```

## Getting Started

1. Read the [Development Setup Guide](./guides/development-setup.md)
2. Review the [Architecture Overview](./architecture/overview.md)
3. Explore the [API Documentation](./api/README.md)

## Contributing

See [Contributing Guide](./guides/contributing.md) for how to contribute to this project.
