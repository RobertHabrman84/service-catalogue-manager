# Service Catalog Import Feature

## Overview

This feature enables automated import of service catalog items from structured JSON files into the Service Catalogue Manager database.

## Fáze 1: JSON Schema Design & Validation ✅

### Components Created

#### 1. JSON Schema (`/schemas/service-import-schema.json`)
- Complete JSON Schema v7 specification
- Defines structure for all 38 database tables
- Includes validation rules and constraints
- Supports all service catalog data types

#### 2. Import Models (`/src/backend/ServiceCatalogueManager.Api/Models/Import/`)
- `ImportServiceModel.cs` - Main import model
- `UsageScenarioImportModel.cs` - Usage scenarios
- `DependencyImportModels.cs` - Dependencies (prerequisite, triggers, parallel)
- `ScopeImportModels.cs` - In-scope and out-of-scope items
- `PrerequisiteImportModels.cs` - Prerequisites (organizational, technical, documentation)
- `ToolsImportModels.cs` - Tools and environment
- `LicenseImportModels.cs` - License requirements
- `StakeholderImportModels.cs` - Stakeholder interaction
- `ServiceInputImportModel.cs` - Service input parameters
- `OutputImportModels.cs` - Service outputs
- `TimelineImportModels.cs` - Timeline phases
- `SizeOptionImportModel.cs` - Size options (S/M/L/XL/XXL)
- `SizingImportModels.cs` - Sizing criteria, parameters, examples
- `ResponsibleRoleImportModel.cs` - Responsible roles
- `MultiCloudConsiderationImportModel.cs` - Multi-cloud considerations
- `ImportResult.cs` - Import result models

#### 3. Service Interfaces (`/src/backend/ServiceCatalogueManager.Api/Services/Import/`)
- `ILookupResolverService.cs` - Resolves lookup table IDs
- `IImportValidationService.cs` - Validates import data
- `IImportOrchestrationService.cs` - Orchestrates import process

### Features

#### JSON Schema Validation
- Validates required fields
- Enforces data types (string, number, boolean, array, object)
- Validates enums (e.g., size codes, requirement levels)
- Pattern matching (e.g., service code format ID0XX)
- String length constraints
- Number range constraints

#### Import Model Validation
- C# Data Annotations validation
- Required field validation
- String length validation
- Regular expression validation
- Custom business rule validation (to be implemented)

### Database Mapping

| JSON Section | C# Model | Database Tables |
|--------------|----------|-----------------|
| Basic Info | `ImportServiceModel` | `ServiceCatalogItem` |
| Usage Scenarios | `UsageScenarioImportModel` | `UsageScenario` |
| Dependencies | `DependencyImportModel` | `ServiceDependency` |
| Scope | `ScopeImportModel` | `ServiceScopeCategory`, `ServiceScopeItem` |
| Prerequisites | `PrerequisiteImportModel` | `ServicePrerequisite` |
| Tools | `ToolItemImportModel` | `ServiceToolFramework` |
| Licenses | `LicenseItemImportModel` | `ServiceLicense` |
| Interaction | `StakeholderInteractionImportModel` | `ServiceInteraction`, `StakeholderInvolvement` |
| Inputs | `ServiceInputImportModel` | `ServiceInput` |
| Outputs | `OutputCategoryImportModel` | `ServiceOutputCategory`, `ServiceOutputItem` |
| Timeline | `TimelinePhaseImportModel` | `TimelinePhase` |
| Size Options | `SizeOptionImportModel` | `ServiceSizeOption` + 10 related tables |
| Roles | `ResponsibleRoleImportModel` | `ServiceResponsibleRole` |
| Multi-Cloud | `MultiCloudConsiderationImportModel` | `ServiceMultiCloudConsideration` |

### Next Steps (Fáze 2)

1. **PDF Extraction Tool**
   - Python script with Claude API integration
   - Automated extraction of structured data from PDFs
   - JSON generation from PDF content

2. **Lookup Resolution Service Implementation**
   - Resolve category paths to IDs
   - Resolve enum values to lookup table IDs
   - Caching mechanism for performance

3. **Validation Service Implementation**
   - Business rules validation
   - Lookup reference validation
   - Duplicate detection
   - Cross-reference validation

4. **Import Orchestration Service Implementation**
   - Transaction management
   - Entity mapping
   - Database insertion in correct order
   - Error handling and rollback

5. **Azure Function API Endpoints**
   - POST `/api/services/import` - Single import
   - POST `/api/services/import/bulk` - Bulk import
   - POST `/api/services/import/validate` - Validation only

## Usage Example

### JSON Import File Structure

```json
{
  "serviceCode": "ID001",
  "serviceName": "Enterprise Scale Landing Zone Design",
  "version": "v1.0",
  "category": "Services/Architecture/Technical Architecture",
  "description": "Comprehensive design and documentation of enterprise-grade landing zones...",
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Greenfield Cloud Adoption",
      "scenarioDescription": "Organizations beginning their cloud journey...",
      "sortOrder": 1
    }
  ],
  "dependencies": {
    "prerequisite": [
      {
        "serviceName": "Enterprise Scale Landing Zone Assessment",
        "serviceCode": "ID002",
        "requirementLevel": "REQUIRED",
        "notes": "Initial assessment required before design"
      }
    ]
  },
  "sizeOptions": [
    {
      "sizeCode": "S",
      "description": "Single cloud, 1-2 regions, up to 15 subscriptions",
      "duration": "4-6 weeks",
      "durationInDays": 30,
      "effort": {
        "hoursMin": 160,
        "hoursMax": 240,
        "currency": "USD"
      },
      "complexity": "LOW"
    }
  ]
}
```

### Validation Flow

```
JSON File
    ↓
JSON Schema Validation
    ↓
C# Model Binding & Validation
    ↓
Business Rules Validation
    ↓
Lookup Resolution Validation
    ↓
Duplicate Detection
    ↓
✅ Valid → Ready for Import
❌ Invalid → Return Validation Errors
```

## Testing

### Unit Tests (To be implemented in Fáze 1)
- Model validation tests
- JSON schema validation tests
- Service interface mock tests

### Integration Tests (To be implemented in Fáze 5)
- End-to-end import tests
- Bulk import tests
- Error scenario tests

## Status

✅ **Fáze 1 Complete** - JSON Schema Design & Validation
- JSON Schema created
- All import models created
- Service interfaces defined
- Ready for implementation

⏳ **Next: Fáze 2** - PDF Extraction Tool
