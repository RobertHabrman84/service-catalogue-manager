-- =============================================================================
-- SERVICE CATALOGUE MANAGER - DATABASE VIEWS
-- File: 004_views.sql
-- Description: Views for reporting and simplified data access
-- =============================================================================

-- =============================================================================
-- VIEW: Service Catalogue Summary
-- Purpose: Provides a comprehensive summary of all services
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceCatalogueSummary]
AS
SELECT
    sc.Id,
    sc.ServiceCode,
    sc.ServiceName,
    sc.ShortDescription,
    sc.Version,
    ss.[Code] AS StatusCode,
    ss.[Name] AS StatusName,
    ss.ColorCode AS StatusColor,
    cat.[Code] AS CategoryCode,
    cat.[Name] AS CategoryName,
    cat.ColorCode AS CategoryColor,
    bu.[Code] AS BusinessUnitCode,
    bu.[Name] AS BusinessUnitName,
    sc.ServiceOwner,
    sc.ServiceOwnerEmail,
    sc.TechnicalContact,
    sc.TechnicalContactEmail,
    sc.IsPublic,
    sc.CreatedAt,
    sc.UpdatedAt,
    sc.CreatedBy,
    sc.UpdatedBy,
    -- Counts
    (SELECT COUNT(*) FROM [dbo].[ServiceDependency] WHERE ServiceId = sc.Id) AS DependencyCount,
    (SELECT COUNT(*) FROM [dbo].[UsageScenario] WHERE ServiceId = sc.Id) AS ScenarioCount,
    (SELECT COUNT(*) FROM [dbo].[ServiceInput] WHERE ServiceId = sc.Id) AS InputCount,
    (SELECT COUNT(*) FROM [dbo].[ServiceOutput] WHERE ServiceId = sc.Id) AS OutputCount
FROM [dbo].[ServiceCatalogItem] sc
LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
LEFT JOIN [dbo].[ServiceCategory] cat ON sc.CategoryId = cat.Id
LEFT JOIN [dbo].[BusinessUnit] bu ON sc.BusinessUnitId = bu.Id;
GO

-- =============================================================================
-- VIEW: Active Services
-- Purpose: Shows only active and publicly available services
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ActiveServices]
AS
SELECT
    sc.Id,
    sc.ServiceCode,
    sc.ServiceName,
    sc.ShortDescription,
    sc.Version,
    cat.[Name] AS CategoryName,
    bu.[Name] AS BusinessUnitName,
    sc.ServiceOwner,
    sc.ServiceOwnerEmail
FROM [dbo].[ServiceCatalogItem] sc
INNER JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
LEFT JOIN [dbo].[ServiceCategory] cat ON sc.CategoryId = cat.Id
LEFT JOIN [dbo].[BusinessUnit] bu ON sc.BusinessUnitId = bu.Id
WHERE ss.[Code] = 'ACTIVE'
  AND sc.IsPublic = 1;
GO

-- =============================================================================
-- VIEW: Service Dependencies Graph
-- Purpose: Shows service dependencies for graph visualization
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceDependencies]
AS
SELECT
    sd.Id,
    sd.ServiceId AS SourceServiceId,
    src.ServiceCode AS SourceServiceCode,
    src.ServiceName AS SourceServiceName,
    sd.DependsOnServiceId AS TargetServiceId,
    tgt.ServiceCode AS TargetServiceCode,
    tgt.ServiceName AS TargetServiceName,
    dt.[Code] AS DependencyTypeCode,
    dt.[Name] AS DependencyTypeName,
    sd.Description,
    sd.IsRequired
FROM [dbo].[ServiceDependency] sd
INNER JOIN [dbo].[ServiceCatalogItem] src ON sd.ServiceId = src.Id
LEFT JOIN [dbo].[ServiceCatalogItem] tgt ON sd.DependsOnServiceId = tgt.Id
LEFT JOIN [dbo].[DependencyType] dt ON sd.DependencyTypeId = dt.Id;
GO

-- =============================================================================
-- VIEW: Service Interactions
-- Purpose: Shows all service interactions
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceInteractions]
AS
SELECT
    si.Id,
    si.ServiceId,
    sc.ServiceCode,
    sc.ServiceName,
    it.[Code] AS InteractionTypeCode,
    it.[Name] AS InteractionTypeName,
    si.Direction,
    si.SystemName,
    si.Endpoint,
    si.Description,
    si.DataFormat,
    si.AuthenticationType
FROM [dbo].[ServiceInteraction] si
INNER JOIN [dbo].[ServiceCatalogItem] sc ON si.ServiceId = sc.Id
LEFT JOIN [dbo].[InteractionType] it ON si.InteractionTypeId = it.Id;
GO

-- =============================================================================
-- VIEW: Service Statistics by Category
-- Purpose: Aggregated statistics by service category
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceStatsByCategory]
AS
SELECT
    cat.Id AS CategoryId,
    cat.[Code] AS CategoryCode,
    cat.[Name] AS CategoryName,
    cat.ColorCode,
    COUNT(sc.Id) AS TotalServices,
    SUM(CASE WHEN ss.[Code] = 'ACTIVE' THEN 1 ELSE 0 END) AS ActiveServices,
    SUM(CASE WHEN ss.[Code] = 'DRAFT' THEN 1 ELSE 0 END) AS DraftServices,
    SUM(CASE WHEN ss.[Code] = 'DEPRECATED' THEN 1 ELSE 0 END) AS DeprecatedServices,
    SUM(CASE WHEN sc.IsPublic = 1 THEN 1 ELSE 0 END) AS PublicServices
FROM [dbo].[ServiceCategory] cat
LEFT JOIN [dbo].[ServiceCatalogItem] sc ON cat.Id = sc.CategoryId
LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
WHERE cat.IsActive = 1
GROUP BY cat.Id, cat.[Code], cat.[Name], cat.ColorCode;
GO

-- =============================================================================
-- VIEW: Service Statistics by Status
-- Purpose: Aggregated statistics by service status
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceStatsByStatus]
AS
SELECT
    ss.Id AS StatusId,
    ss.[Code] AS StatusCode,
    ss.[Name] AS StatusName,
    ss.ColorCode,
    COUNT(sc.Id) AS ServiceCount,
    ss.DisplayOrder
FROM [dbo].[ServiceStatus] ss
LEFT JOIN [dbo].[ServiceCatalogItem] sc ON ss.Id = sc.StatusId
WHERE ss.IsActive = 1
GROUP BY ss.Id, ss.[Code], ss.[Name], ss.ColorCode, ss.DisplayOrder;
GO

-- =============================================================================
-- VIEW: Service Timeline Overview
-- Purpose: Shows timeline phases for all services
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceTimelines]
AS
SELECT
    tp.Id,
    tp.ServiceId,
    sc.ServiceCode,
    sc.ServiceName,
    tp.PhaseName,
    tp.PhaseOrder,
    tp.StartDate,
    tp.EndDate,
    tp.DurationDays,
    tp.Description,
    tp.Status,
    tp.CompletionPercentage
FROM [dbo].[TimelinePhase] tp
INNER JOIN [dbo].[ServiceCatalogItem] sc ON tp.ServiceId = sc.Id;
GO

-- =============================================================================
-- VIEW: Service Effort Summary
-- Purpose: Aggregated effort estimation by service
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_ServiceEffortSummary]
AS
SELECT
    sc.Id AS ServiceId,
    sc.ServiceCode,
    sc.ServiceName,
    SUM(ee.EstimatedHours) AS TotalEstimatedHours,
    SUM(ee.ActualHours) AS TotalActualHours,
    COUNT(DISTINCT ee.EffortCategoryId) AS CategoryCount,
    MIN(ee.CreatedAt) AS FirstEstimate,
    MAX(ee.UpdatedAt) AS LastUpdate
FROM [dbo].[ServiceCatalogItem] sc
LEFT JOIN [dbo].[EffortEstimation] ee ON sc.Id = ee.ServiceId
GROUP BY sc.Id, sc.ServiceCode, sc.ServiceName;
GO

-- =============================================================================
-- VIEW: Recent Service Changes
-- Purpose: Shows recently modified services
-- =============================================================================
CREATE OR ALTER VIEW [dbo].[vw_RecentServiceChanges]
AS
SELECT TOP 100
    sc.Id,
    sc.ServiceCode,
    sc.ServiceName,
    ss.[Name] AS StatusName,
    sc.UpdatedAt,
    sc.UpdatedBy,
    sc.CreatedAt,
    sc.CreatedBy,
    CASE 
        WHEN sc.UpdatedAt IS NOT NULL THEN 'Updated'
        ELSE 'Created'
    END AS ChangeType
FROM [dbo].[ServiceCatalogItem] sc
LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
ORDER BY COALESCE(sc.UpdatedAt, sc.CreatedAt) DESC;
GO

PRINT 'Database views created successfully.';
