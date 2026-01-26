-- =============================================================================
-- SERVICE CATALOGUE MANAGER - INDEXES
-- File: 006_indexes.sql
-- Description: Indexes for query optimization
-- =============================================================================

-- =============================================================================
-- SERVICE CATALOG ITEM INDEXES
-- =============================================================================

-- Index for service code lookups (unique)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_ServiceCode')
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServiceCatalogItem_ServiceCode]
ON [dbo].[ServiceCatalogItem] ([ServiceCode])
INCLUDE ([ServiceName], [StatusId], [CategoryId]);
GO

-- Index for status filtering
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_StatusId')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_StatusId]
ON [dbo].[ServiceCatalogItem] ([StatusId])
INCLUDE ([ServiceCode], [ServiceName], [CategoryId], [IsPublic]);
GO

-- Index for category filtering
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_CategoryId')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_CategoryId]
ON [dbo].[ServiceCatalogItem] ([CategoryId])
INCLUDE ([ServiceCode], [ServiceName], [StatusId], [IsPublic]);
GO

-- Index for business unit filtering
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_BusinessUnitId')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_BusinessUnitId]
ON [dbo].[ServiceCatalogItem] ([BusinessUnitId])
INCLUDE ([ServiceCode], [ServiceName], [StatusId]);
GO

-- Index for public services
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_IsPublic')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_IsPublic]
ON [dbo].[ServiceCatalogItem] ([IsPublic], [StatusId])
INCLUDE ([ServiceCode], [ServiceName], [CategoryId]);
GO

-- Index for service owner lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_ServiceOwner')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_ServiceOwner]
ON [dbo].[ServiceCatalogItem] ([ServiceOwner])
INCLUDE ([ServiceCode], [ServiceName], [StatusId]);
GO

-- Index for recent changes (UpdatedAt)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_UpdatedAt')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_UpdatedAt]
ON [dbo].[ServiceCatalogItem] ([UpdatedAt] DESC)
INCLUDE ([ServiceCode], [ServiceName], [StatusId], [UpdatedBy]);
GO

-- Composite index for common filtering
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCatalogItem_Status_Category')
CREATE NONCLUSTERED INDEX [IX_ServiceCatalogItem_Status_Category]
ON [dbo].[ServiceCatalogItem] ([StatusId], [CategoryId], [IsPublic])
INCLUDE ([ServiceCode], [ServiceName], [BusinessUnitId]);
GO

-- =============================================================================
-- SERVICE DEPENDENCY INDEXES
-- =============================================================================

-- Index for finding dependencies of a service
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceDependency_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceDependency_ServiceId]
ON [dbo].[ServiceDependency] ([ServiceId])
INCLUDE ([DependsOnServiceId], [DependencyTypeId], [IsRequired]);
GO

-- Index for finding dependents of a service
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceDependency_DependsOnServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceDependency_DependsOnServiceId]
ON [dbo].[ServiceDependency] ([DependsOnServiceId])
INCLUDE ([ServiceId], [DependencyTypeId], [IsRequired]);
GO

-- =============================================================================
-- USAGE SCENARIO INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UsageScenario_ServiceId')
CREATE NONCLUSTERED INDEX [IX_UsageScenario_ServiceId]
ON [dbo].[UsageScenario] ([ServiceId], [DisplayOrder])
INCLUDE ([Title], [Description]);
GO

-- =============================================================================
-- SERVICE SCOPE INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceScope_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceScope_ServiceId]
ON [dbo].[ServiceScope] ([ServiceId], [IsInScope], [DisplayOrder]);
GO

-- =============================================================================
-- SERVICE PREREQUISITE INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServicePrerequisite_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServicePrerequisite_ServiceId]
ON [dbo].[ServicePrerequisite] ([ServiceId], [IsRequired], [DisplayOrder]);
GO

-- =============================================================================
-- SERVICE TOOL INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceTool_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceTool_ServiceId]
ON [dbo].[ServiceTool] ([ServiceId], [DisplayOrder])
INCLUDE ([Name], [LicenseTypeId], [IsRequired]);
GO

-- =============================================================================
-- SERVICE INPUT/OUTPUT INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceInput_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceInput_ServiceId]
ON [dbo].[ServiceInput] ([ServiceId], [DisplayOrder])
INCLUDE ([Name], [DataTypeId], [IsRequired]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceOutput_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceOutput_ServiceId]
ON [dbo].[ServiceOutput] ([ServiceId], [DisplayOrder])
INCLUDE ([Name], [DataTypeId]);
GO

-- =============================================================================
-- SERVICE INTERACTION INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceInteraction_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceInteraction_ServiceId]
ON [dbo].[ServiceInteraction] ([ServiceId], [Direction])
INCLUDE ([InteractionTypeId], [SystemName]);
GO

-- =============================================================================
-- TIMELINE PHASE INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TimelinePhase_ServiceId')
CREATE NONCLUSTERED INDEX [IX_TimelinePhase_ServiceId]
ON [dbo].[TimelinePhase] ([ServiceId], [PhaseOrder])
INCLUDE ([PhaseName], [StartDate], [EndDate], [Status]);
GO

-- =============================================================================
-- EFFORT ESTIMATION INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EffortEstimation_ServiceId')
CREATE NONCLUSTERED INDEX [IX_EffortEstimation_ServiceId]
ON [dbo].[EffortEstimation] ([ServiceId], [EffortCategoryId])
INCLUDE ([EstimatedHours], [ActualHours]);
GO

-- =============================================================================
-- SERVICE RESPONSIBLE ROLE INDEXES
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceResponsibleRole_ServiceId')
CREATE NONCLUSTERED INDEX [IX_ServiceResponsibleRole_ServiceId]
ON [dbo].[ServiceResponsibleRole] ([ServiceId])
INCLUDE ([RoleId], [PersonName], [PersonEmail]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceResponsibleRole_RoleId')
CREATE NONCLUSTERED INDEX [IX_ServiceResponsibleRole_RoleId]
ON [dbo].[ServiceResponsibleRole] ([RoleId])
INCLUDE ([ServiceId], [PersonName]);
GO

-- =============================================================================
-- LOOKUP TABLE INDEXES
-- =============================================================================

-- All lookup tables get index on Code for fast lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceStatus_Code')
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServiceStatus_Code]
ON [dbo].[ServiceStatus] ([Code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ServiceCategory_Code')
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServiceCategory_Code]
ON [dbo].[ServiceCategory] ([Code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BusinessUnit_Code')
CREATE UNIQUE NONCLUSTERED INDEX [IX_BusinessUnit_Code]
ON [dbo].[BusinessUnit] ([Code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ResponsibleRole_Code')
CREATE UNIQUE NONCLUSTERED INDEX [IX_ResponsibleRole_Code]
ON [dbo].[ResponsibleRole] ([Code]);
GO

-- =============================================================================
-- STATISTICS UPDATE
-- =============================================================================

-- Update statistics on main tables
UPDATE STATISTICS [dbo].[ServiceCatalogItem];
UPDATE STATISTICS [dbo].[ServiceDependency];
UPDATE STATISTICS [dbo].[UsageScenario];
GO

PRINT 'Indexes created successfully.';
