# Data Model

## Overview

The Service Catalogue Manager data model is designed to comprehensively capture all aspects of service documentation.

## Core Entities

### ServiceCatalogItem
The central entity representing a service in the catalog.

| Column | Type | Description |
|--------|------|-------------|
| Id | int | Primary key |
| ServiceCode | nvarchar(50) | Unique service identifier |
| ServiceName | nvarchar(200) | Display name |
| Version | nvarchar(20) | Semantic version |
| ShortDescription | nvarchar(500) | Brief description |
| LongDescription | nvarchar(max) | Full description |
| StatusId | int | FK to ServiceStatus |
| CategoryId | int | FK to ServiceCategory |
| CreatedAt | datetime2 | Creation timestamp |
| ModifiedAt | datetime2 | Last modification |

### UsageScenario
Describes how a service can be used.

| Column | Type | Description |
|--------|------|-------------|
| Id | int | Primary key |
| ServiceId | int | FK to ServiceCatalogItem |
| Title | nvarchar(200) | Scenario title |
| Description | nvarchar(max) | Detailed description |
| ActorRole | nvarchar(100) | Primary user role |
| Steps | nvarchar(max) | Step-by-step process |

### ServiceDependency
Tracks relationships between services.

| Column | Type | Description |
|--------|------|-------------|
| Id | int | Primary key |
| ServiceId | int | FK to source service |
| DependsOnServiceId | int | FK to target service |
| DependencyTypeId | int | FK to DependencyType |
| IsRequired | bit | Required vs optional |

## Lookup Tables

| Table | Purpose |
|-------|---------|
| LU_ServiceStatus | Draft, Active, Deprecated |
| LU_ServiceCategory | Application, Infrastructure, Data |
| LU_DependencyType | Required, Optional, Recommended |
| LU_CloudProvider | Azure, AWS, GCP, On-Premise |
| LU_ResponsibleRole | Owner, Developer, Approver |

## Entity Relationships

```
ServiceCatalogItem (1) ──── (*) UsageScenario
ServiceCatalogItem (1) ──── (*) ServiceDependency
ServiceCatalogItem (1) ──── (*) ServicePrerequisite
ServiceCatalogItem (1) ──── (*) TimelinePhase
ServiceCatalogItem (1) ──── (*) EffortEstimation
ServiceCatalogItem (*) ──── (1) LU_ServiceStatus
ServiceCatalogItem (*) ──── (1) LU_ServiceCategory
```

## Soft Delete

All main entities support soft delete via `IsDeleted` and `DeletedAt` columns.

## Audit Trail

Automatic tracking of `CreatedAt`, `CreatedBy`, `ModifiedAt`, `ModifiedBy` on all entities.

## Indexes

- `IX_ServiceCatalogItem_ServiceCode` - Unique index on ServiceCode
- `IX_ServiceCatalogItem_Status` - Filter by status
- `IX_ServiceCatalogItem_FullText` - Full-text search index
