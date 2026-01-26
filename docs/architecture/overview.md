# Architecture Overview

## System Architecture

Service Catalogue Manager follows a modern cloud-native architecture pattern with clear separation between frontend, backend, and data layers.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Browser   │  │  Mobile App │  │   CLI Tool  │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼────────────────┼────────────────┼─────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Front Door / CDN                        │
└─────────────────────────────┬───────────────────────────────────┘
                              │
          ┌───────────────────┴───────────────────┐
          ▼                                       ▼
┌─────────────────────┐               ┌─────────────────────┐
│   Static Web App    │               │   Azure Functions   │
│     (Frontend)      │◄─────────────►│     (Backend)       │
│   React + Vite      │   REST API    │   .NET 8 Isolated   │
└─────────────────────┘               └──────────┬──────────┘
                                                 │
          ┌──────────────────────────────────────┼──────────────┐
          │                                      │              │
          ▼                                      ▼              ▼
┌─────────────────┐                  ┌─────────────────┐ ┌─────────────┐
│   Azure SQL     │                  │  Blob Storage   │ │  UuBookKit  │
│   Database      │                  │   (Exports)     │ │   Gateway   │
└─────────────────┘                  └─────────────────┘ └─────────────┘
```

## Components

### Frontend (Static Web App)
- **Technology**: React 18, TypeScript, Vite
- **Hosting**: Azure Static Web Apps
- **Features**: SPA, PWA support, responsive design

### Backend (Azure Functions)
- **Technology**: .NET 8 Isolated Worker
- **Hosting**: Azure Functions Premium Plan
- **Features**: RESTful API, PDF generation, markdown export

### Database (Azure SQL)
- **Technology**: Azure SQL Server
- **Features**: Full-text search, audit logging, soft delete

### Storage (Blob Storage)
- **Purpose**: Export files, cached documents
- **Access**: SAS tokens for secure downloads

## Design Principles

1. **Separation of Concerns**: Clear boundaries between layers
2. **API-First Design**: Backend exposes RESTful APIs
3. **Stateless Services**: No session state in backend
4. **Infrastructure as Code**: All infrastructure defined in Bicep
5. **Security by Default**: Zero-trust architecture

## Scalability

| Component | Scaling Strategy |
|-----------|------------------|
| Frontend | CDN, global distribution |
| Backend | Horizontal scaling (Functions) |
| Database | Vertical scaling, read replicas |
| Storage | Automatic scaling |

## Related Documents

- [Data Model](./data-model.md)
- [Backend Architecture](./backend-architecture.md)
- [Frontend Architecture](./frontend-architecture.md)
- [Security](./security.md)
