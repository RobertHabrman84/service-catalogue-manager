-- ================================================
-- SQL Script to Verify Imported Data in MSSQL
-- ================================================
-- This script checks if JSON import data was saved

USE ServiceCatalogueManager;
GO

PRINT '================================================';
PRINT 'Service Catalogue Manager - Data Verification';
PRINT '================================================';
PRINT '';

-- 1. Check ServiceCatalogItem table
PRINT '1. SERVICE CATALOG ITEMS:';
PRINT '-------------------------';
SELECT 
    ServiceId,
    ServiceCode,
    ServiceName,
    Version,
    SUBSTRING(Description, 1, 50) + '...' as Description,
    CategoryId,
    IsActive,
    CreatedDate,
    ModifiedDate
FROM ServiceCatalogItem
ORDER BY CreatedDate DESC;

PRINT '';
PRINT CONCAT('Total Services: ', (SELECT COUNT(*) FROM ServiceCatalogItem));
PRINT '';

-- 2. Check related data for most recent service
DECLARE @LatestServiceId INT;
DECLARE @LatestServiceCode NVARCHAR(50);

SELECT TOP 1 
    @LatestServiceId = ServiceId,
    @LatestServiceCode = ServiceCode
FROM ServiceCatalogItem
ORDER BY CreatedDate DESC;

IF @LatestServiceId IS NOT NULL
BEGIN
    PRINT '';
    PRINT '2. RELATED DATA FOR LATEST SERVICE:';
    PRINT '-----------------------------------';
    PRINT CONCAT('Service ID: ', @LatestServiceId);
    PRINT CONCAT('Service Code: ', @LatestServiceCode);
    PRINT '';
    
    -- Usage Scenarios
    PRINT CONCAT('  Usage Scenarios: ', (SELECT COUNT(*) FROM UsageScenario WHERE ServiceId = @LatestServiceId));
    
    -- Service Inputs
    PRINT CONCAT('  Service Inputs: ', (SELECT COUNT(*) FROM ServiceInput WHERE ServiceId = @LatestServiceId));
    
    -- Output Categories and Items
    DECLARE @OutputCategoriesCount INT = (SELECT COUNT(*) FROM ServiceOutputCategory WHERE ServiceId = @LatestServiceId);
    DECLARE @OutputItemsCount INT = (
        SELECT COUNT(*) 
        FROM ServiceOutputItem oi
        INNER JOIN ServiceOutputCategory oc ON oi.OutputCategoryId = oc.OutputCategoryId
        WHERE oc.ServiceId = @LatestServiceId
    );
    PRINT CONCAT('  Output Categories: ', @OutputCategoriesCount);
    PRINT CONCAT('  Output Items: ', @OutputItemsCount);
    
    -- Prerequisites
    PRINT CONCAT('  Prerequisites: ', (SELECT COUNT(*) FROM ServicePrerequisite WHERE ServiceId = @LatestServiceId));
    
    -- Dependencies
    PRINT CONCAT('  Dependencies: ', (SELECT COUNT(*) FROM ServiceDependency WHERE ServiceId = @LatestServiceId));
    
    -- Scope Categories and Items
    DECLARE @ScopeCategoriesCount INT = (SELECT COUNT(*) FROM ServiceScopeCategory WHERE ServiceId = @LatestServiceId);
    DECLARE @ScopeItemsCount INT = (
        SELECT COUNT(*) 
        FROM ServiceScopeItem si
        INNER JOIN ServiceScopeCategory sc ON si.ScopeCategoryId = sc.ScopeCategoryId
        WHERE sc.ServiceId = @LatestServiceId
    );
    PRINT CONCAT('  Scope Categories: ', @ScopeCategoriesCount);
    PRINT CONCAT('  Scope Items: ', @ScopeItemsCount);
    
    -- Licenses
    PRINT CONCAT('  Licenses: ', (SELECT COUNT(*) FROM ServiceLicense WHERE ServiceId = @LatestServiceId));
    
    -- Tools
    PRINT CONCAT('  Tools/Frameworks: ', (SELECT COUNT(*) FROM ServiceToolFramework WHERE ServiceId = @LatestServiceId));
    
    -- Timeline Phases
    PRINT CONCAT('  Timeline Phases: ', (SELECT COUNT(*) FROM TimelinePhase WHERE ServiceId = @LatestServiceId));
    
    -- Size Options
    PRINT CONCAT('  Size Options: ', (SELECT COUNT(*) FROM ServiceSizeOption WHERE ServiceId = @LatestServiceId));
    
    -- Effort Estimations
    PRINT CONCAT('  Effort Estimations: ', (SELECT COUNT(*) FROM EffortEstimationItem WHERE ServiceId = @LatestServiceId));
    
    -- Interaction
    PRINT CONCAT('  Stakeholder Interaction: ', (SELECT COUNT(*) FROM ServiceInteraction WHERE ServiceId = @LatestServiceId));
    
    -- Responsible Roles
    PRINT CONCAT('  Responsible Roles: ', (SELECT COUNT(*) FROM ServiceResponsibleRole WHERE ServiceId = @LatestServiceId));
    
    -- Multi-Cloud Considerations
    PRINT CONCAT('  Multi-Cloud Considerations: ', (SELECT COUNT(*) FROM ServiceMultiCloudConsideration WHERE ServiceId = @LatestServiceId));
    
    PRINT '';
END
ELSE
BEGIN
    PRINT 'No services found in database.';
END

-- 3. Show detailed view of latest service
IF @LatestServiceId IS NOT NULL
BEGIN
    PRINT '';
    PRINT '3. DETAILED DATA SAMPLES:';
    PRINT '-------------------------';
    
    -- Usage Scenarios
    IF EXISTS (SELECT 1 FROM UsageScenario WHERE ServiceId = @LatestServiceId)
    BEGIN
        PRINT '';
        PRINT '  Usage Scenarios:';
        SELECT TOP 3
            ScenarioNumber,
            ScenarioTitle,
            SUBSTRING(ScenarioDescription, 1, 60) + '...' as Description
        FROM UsageScenario
        WHERE ServiceId = @LatestServiceId
        ORDER BY SortOrder;
    END
    
    -- Service Inputs
    IF EXISTS (SELECT 1 FROM ServiceInput WHERE ServiceId = @LatestServiceId)
    BEGIN
        PRINT '';
        PRINT '  Service Inputs:';
        SELECT TOP 3
            ParameterName,
            DataType,
            SUBSTRING(ParameterDescription, 1, 60) + '...' as Description
        FROM ServiceInput
        WHERE ServiceId = @LatestServiceId
        ORDER BY SortOrder;
    END
    
    -- Prerequisites
    IF EXISTS (SELECT 1 FROM ServicePrerequisite WHERE ServiceId = @LatestServiceId)
    BEGIN
        PRINT '';
        PRINT '  Prerequisites:';
        SELECT TOP 3
            PrerequisiteName,
            SUBSTRING(PrerequisiteDescription, 1, 60) + '...' as Description
        FROM ServicePrerequisite
        WHERE ServiceId = @LatestServiceId
        ORDER BY SortOrder;
    END
END

-- 4. Database summary
PRINT '';
PRINT '4. DATABASE SUMMARY:';
PRINT '-------------------';
PRINT CONCAT('  Total Services: ', (SELECT COUNT(*) FROM ServiceCatalogItem));
PRINT CONCAT('  Total Categories: ', (SELECT COUNT(*) FROM LU_ServiceCategory));
PRINT CONCAT('  Total Usage Scenarios: ', (SELECT COUNT(*) FROM UsageScenario));
PRINT CONCAT('  Total Service Inputs: ', (SELECT COUNT(*) FROM ServiceInput));
PRINT CONCAT('  Total Prerequisites: ', (SELECT COUNT(*) FROM ServicePrerequisite));
PRINT CONCAT('  Total Dependencies: ', (SELECT COUNT(*) FROM ServiceDependency));
PRINT CONCAT('  Total Tools: ', (SELECT COUNT(*) FROM ServiceToolFramework));
PRINT '';

-- 5. Check if specific test service exists
DECLARE @TestServiceCode NVARCHAR(50) = 'TEST-SERVICE-001';

PRINT '';
PRINT '5. TEST SERVICE CHECK:';
PRINT '---------------------';
IF EXISTS (SELECT 1 FROM ServiceCatalogItem WHERE ServiceCode = @TestServiceCode)
BEGIN
    PRINT CONCAT('✓ Test service "', @TestServiceCode, '" found in database');
    
    SELECT 
        ServiceId,
        ServiceCode,
        ServiceName,
        CreatedDate
    FROM ServiceCatalogItem
    WHERE ServiceCode = @TestServiceCode;
END
ELSE
BEGIN
    PRINT CONCAT('✗ Test service "', @TestServiceCode, '" NOT found in database');
END

PRINT '';
PRINT '================================================';
PRINT 'Verification Complete';
PRINT '================================================';
GO
