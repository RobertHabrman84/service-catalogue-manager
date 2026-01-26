-- =============================================================================
-- SERVICE CATALOGUE MANAGER - DATABASE FUNCTIONS
-- File: 007_functions.sql
-- Description: User-defined functions for common operations
-- =============================================================================

-- =============================================================================
-- FUNCTION: Get Service Status by Code
-- Purpose: Returns status ID for a given status code
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetStatusId]
(
    @StatusCode NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @StatusId INT;
    SELECT @StatusId = Id FROM [dbo].[ServiceStatus] WHERE [Code] = @StatusCode;
    RETURN @StatusId;
END;
GO

-- =============================================================================
-- FUNCTION: Get Category by Code
-- Purpose: Returns category ID for a given category code
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetCategoryId]
(
    @CategoryCode NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @CategoryId INT;
    SELECT @CategoryId = Id FROM [dbo].[ServiceCategory] WHERE [Code] = @CategoryCode;
    RETURN @CategoryId;
END;
GO

-- =============================================================================
-- FUNCTION: Get Service Dependency Count
-- Purpose: Returns the number of dependencies for a service
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetDependencyCount]
(
    @ServiceId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM [dbo].[ServiceDependency] WHERE ServiceId = @ServiceId;
    RETURN ISNULL(@Count, 0);
END;
GO

-- =============================================================================
-- FUNCTION: Get Service Dependent Count
-- Purpose: Returns the number of services that depend on this service
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetDependentCount]
(
    @ServiceId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM [dbo].[ServiceDependency] WHERE DependsOnServiceId = @ServiceId;
    RETURN ISNULL(@Count, 0);
END;
GO

-- =============================================================================
-- FUNCTION: Check if Service Can Be Deleted
-- Purpose: Returns 1 if service can be safely deleted, 0 otherwise
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_CanDeleteService]
(
    @ServiceId INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @CanDelete BIT = 1;
    
    -- Check if other services depend on this one
    IF EXISTS (SELECT 1 FROM [dbo].[ServiceDependency] WHERE DependsOnServiceId = @ServiceId)
    BEGIN
        SET @CanDelete = 0;
    END;
    
    RETURN @CanDelete;
END;
GO

-- =============================================================================
-- FUNCTION: Get Service Full Name
-- Purpose: Returns formatted service name with code
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetServiceFullName]
(
    @ServiceId INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @FullName NVARCHAR(300);
    
    SELECT @FullName = CONCAT('[', ServiceCode, '] ', ServiceName)
    FROM [dbo].[ServiceCatalogItem]
    WHERE Id = @ServiceId;
    
    RETURN @FullName;
END;
GO

-- =============================================================================
-- FUNCTION: Calculate Total Effort Hours
-- Purpose: Calculates total estimated hours for a service
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetTotalEffortHours]
(
    @ServiceId INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalHours DECIMAL(10, 2);
    
    SELECT @TotalHours = SUM(EstimatedHours)
    FROM [dbo].[EffortEstimation]
    WHERE ServiceId = @ServiceId;
    
    RETURN ISNULL(@TotalHours, 0);
END;
GO

-- =============================================================================
-- FUNCTION: Get Timeline Duration (days)
-- Purpose: Calculates total duration of all timeline phases
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetTimelineDuration]
(
    @ServiceId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT;
    
    SELECT @Duration = SUM(DurationDays)
    FROM [dbo].[TimelinePhase]
    WHERE ServiceId = @ServiceId;
    
    RETURN ISNULL(@Duration, 0);
END;
GO

-- =============================================================================
-- FUNCTION: Is Service Active
-- Purpose: Returns 1 if service is in ACTIVE status
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_IsServiceActive]
(
    @ServiceId INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsActive BIT = 0;
    
    IF EXISTS (
        SELECT 1 
        FROM [dbo].[ServiceCatalogItem] sc
        INNER JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
        WHERE sc.Id = @ServiceId AND ss.[Code] = 'ACTIVE'
    )
    BEGIN
        SET @IsActive = 1;
    END;
    
    RETURN @IsActive;
END;
GO

-- =============================================================================
-- TABLE-VALUED FUNCTION: Get Service Hierarchy
-- Purpose: Returns service with all its dependencies recursively
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetServiceHierarchy]
(
    @ServiceId INT,
    @MaxDepth INT = 5
)
RETURNS @Hierarchy TABLE
(
    Level INT,
    ServiceId INT,
    ServiceCode NVARCHAR(50),
    ServiceName NVARCHAR(200),
    ParentServiceId INT,
    DependencyType NVARCHAR(50),
    IsRequired BIT
)
AS
BEGIN
    ;WITH ServiceCTE AS
    (
        -- Anchor: Start with the specified service
        SELECT 
            0 AS Level,
            sc.Id AS ServiceId,
            sc.ServiceCode,
            sc.ServiceName,
            CAST(NULL AS INT) AS ParentServiceId,
            CAST(NULL AS NVARCHAR(50)) AS DependencyType,
            CAST(NULL AS BIT) AS IsRequired
        FROM [dbo].[ServiceCatalogItem] sc
        WHERE sc.Id = @ServiceId
        
        UNION ALL
        
        -- Recursive: Get dependencies
        SELECT 
            cte.Level + 1,
            dep.Id,
            dep.ServiceCode,
            dep.ServiceName,
            sd.ServiceId,
            dt.[Code],
            sd.IsRequired
        FROM ServiceCTE cte
        INNER JOIN [dbo].[ServiceDependency] sd ON cte.ServiceId = sd.ServiceId
        INNER JOIN [dbo].[ServiceCatalogItem] dep ON sd.DependsOnServiceId = dep.Id
        LEFT JOIN [dbo].[DependencyType] dt ON sd.DependencyTypeId = dt.Id
        WHERE cte.Level < @MaxDepth
    )
    INSERT INTO @Hierarchy
    SELECT DISTINCT Level, ServiceId, ServiceCode, ServiceName, ParentServiceId, DependencyType, IsRequired
    FROM ServiceCTE;
    
    RETURN;
END;
GO

-- =============================================================================
-- TABLE-VALUED FUNCTION: Get Services by Owner
-- Purpose: Returns all services owned by a specific person
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetServicesByOwner]
(
    @OwnerEmail NVARCHAR(255)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sc.Id,
        sc.ServiceCode,
        sc.ServiceName,
        sc.ShortDescription,
        ss.[Name] AS StatusName,
        cat.[Name] AS CategoryName,
        sc.Version,
        sc.UpdatedAt
    FROM [dbo].[ServiceCatalogItem] sc
    LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
    LEFT JOIN [dbo].[ServiceCategory] cat ON sc.CategoryId = cat.Id
    WHERE sc.ServiceOwnerEmail = @OwnerEmail
       OR sc.TechnicalContactEmail = @OwnerEmail
);
GO

-- =============================================================================
-- FUNCTION: Format Service Version
-- Purpose: Formats version string consistently
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_FormatVersion]
(
    @Major INT,
    @Minor INT,
    @Patch INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CONCAT(@Major, '.', @Minor, '.', @Patch);
END;
GO

-- =============================================================================
-- FUNCTION: Get Next Service Code
-- Purpose: Generates next service code based on category prefix
-- =============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetNextServiceCode]
(
    @CategoryCode NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @NextCode NVARCHAR(50);
    DECLARE @Prefix NVARCHAR(10) = LEFT(@CategoryCode, 3);
    DECLARE @MaxNumber INT;
    
    SELECT @MaxNumber = MAX(
        TRY_CAST(SUBSTRING(ServiceCode, 5, 10) AS INT)
    )
    FROM [dbo].[ServiceCatalogItem]
    WHERE ServiceCode LIKE @Prefix + '-%';
    
    SET @MaxNumber = ISNULL(@MaxNumber, 0) + 1;
    SET @NextCode = @Prefix + '-' + RIGHT('0000' + CAST(@MaxNumber AS NVARCHAR), 4);
    
    RETURN @NextCode;
END;
GO

PRINT 'Database functions created successfully.';
