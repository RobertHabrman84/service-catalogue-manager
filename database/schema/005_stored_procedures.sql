-- =============================================================================
-- SERVICE CATALOGUE MANAGER - STORED PROCEDURES
-- File: 005_stored_procedures.sql
-- Description: Stored procedures for complex operations
-- =============================================================================

-- =============================================================================
-- PROCEDURE: Get Service with All Details
-- Purpose: Retrieves a service with all related data in one call
-- =============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetServiceDetails]
    @ServiceId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Main service data
    SELECT 
        sc.*,
        ss.[Name] AS StatusName,
        cat.[Name] AS CategoryName,
        bu.[Name] AS BusinessUnitName
    FROM [dbo].[ServiceCatalogItem] sc
    LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
    LEFT JOIN [dbo].[ServiceCategory] cat ON sc.CategoryId = cat.Id
    LEFT JOIN [dbo].[BusinessUnit] bu ON sc.BusinessUnitId = bu.Id
    WHERE sc.Id = @ServiceId;
    
    -- Usage scenarios
    SELECT * FROM [dbo].[UsageScenario] WHERE ServiceId = @ServiceId ORDER BY DisplayOrder;
    
    -- Dependencies
    SELECT 
        sd.*,
        tgt.ServiceCode AS DependsOnServiceCode,
        tgt.ServiceName AS DependsOnServiceName,
        dt.[Name] AS DependencyTypeName
    FROM [dbo].[ServiceDependency] sd
    LEFT JOIN [dbo].[ServiceCatalogItem] tgt ON sd.DependsOnServiceId = tgt.Id
    LEFT JOIN [dbo].[DependencyType] dt ON sd.DependencyTypeId = dt.Id
    WHERE sd.ServiceId = @ServiceId;
    
    -- Scope items
    SELECT * FROM [dbo].[ServiceScope] WHERE ServiceId = @ServiceId ORDER BY IsInScope DESC, DisplayOrder;
    
    -- Prerequisites
    SELECT * FROM [dbo].[ServicePrerequisite] WHERE ServiceId = @ServiceId ORDER BY DisplayOrder;
    
    -- Tools
    SELECT * FROM [dbo].[ServiceTool] WHERE ServiceId = @ServiceId ORDER BY DisplayOrder;
    
    -- Inputs
    SELECT 
        si.*,
        dt.[Name] AS DataTypeName
    FROM [dbo].[ServiceInput] si
    LEFT JOIN [dbo].[DataType] dt ON si.DataTypeId = dt.Id
    WHERE si.ServiceId = @ServiceId
    ORDER BY si.DisplayOrder;
    
    -- Outputs
    SELECT 
        so.*,
        dt.[Name] AS DataTypeName
    FROM [dbo].[ServiceOutput] so
    LEFT JOIN [dbo].[DataType] dt ON so.DataTypeId = dt.Id
    WHERE so.ServiceId = @ServiceId
    ORDER BY so.DisplayOrder;
    
    -- Interactions
    SELECT 
        si.*,
        it.[Name] AS InteractionTypeName
    FROM [dbo].[ServiceInteraction] si
    LEFT JOIN [dbo].[InteractionType] it ON si.InteractionTypeId = it.Id
    WHERE si.ServiceId = @ServiceId;
    
    -- Timeline
    SELECT * FROM [dbo].[TimelinePhase] WHERE ServiceId = @ServiceId ORDER BY PhaseOrder;
    
    -- Effort estimation
    SELECT 
        ee.*,
        ec.[Name] AS EffortCategoryName
    FROM [dbo].[EffortEstimation] ee
    LEFT JOIN [dbo].[EffortCategory] ec ON ee.EffortCategoryId = ec.Id
    WHERE ee.ServiceId = @ServiceId;
    
    -- Responsible roles
    SELECT 
        sr.*,
        rr.[Name] AS RoleName
    FROM [dbo].[ServiceResponsibleRole] sr
    LEFT JOIN [dbo].[ResponsibleRole] rr ON sr.RoleId = rr.Id
    WHERE sr.ServiceId = @ServiceId;
END;
GO

-- =============================================================================
-- PROCEDURE: Search Services
-- Purpose: Full-text search across services
-- =============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_SearchServices]
    @SearchTerm NVARCHAR(500),
    @CategoryId INT = NULL,
    @StatusId INT = NULL,
    @BusinessUnitId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Get total count
    SELECT COUNT(*) AS TotalCount
    FROM [dbo].[ServiceCatalogItem] sc
    WHERE (@SearchTerm IS NULL OR @SearchTerm = ''
           OR sc.ServiceCode LIKE '%' + @SearchTerm + '%'
           OR sc.ServiceName LIKE '%' + @SearchTerm + '%'
           OR sc.ShortDescription LIKE '%' + @SearchTerm + '%'
           OR sc.LongDescription LIKE '%' + @SearchTerm + '%')
      AND (@CategoryId IS NULL OR sc.CategoryId = @CategoryId)
      AND (@StatusId IS NULL OR sc.StatusId = @StatusId)
      AND (@BusinessUnitId IS NULL OR sc.BusinessUnitId = @BusinessUnitId);
    
    -- Get paginated results
    SELECT 
        sc.Id,
        sc.ServiceCode,
        sc.ServiceName,
        sc.ShortDescription,
        sc.Version,
        ss.[Code] AS StatusCode,
        ss.[Name] AS StatusName,
        cat.[Name] AS CategoryName,
        bu.[Name] AS BusinessUnitName,
        sc.ServiceOwner,
        sc.IsPublic,
        sc.UpdatedAt,
        sc.CreatedAt
    FROM [dbo].[ServiceCatalogItem] sc
    LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
    LEFT JOIN [dbo].[ServiceCategory] cat ON sc.CategoryId = cat.Id
    LEFT JOIN [dbo].[BusinessUnit] bu ON sc.BusinessUnitId = bu.Id
    WHERE (@SearchTerm IS NULL OR @SearchTerm = ''
           OR sc.ServiceCode LIKE '%' + @SearchTerm + '%'
           OR sc.ServiceName LIKE '%' + @SearchTerm + '%'
           OR sc.ShortDescription LIKE '%' + @SearchTerm + '%'
           OR sc.LongDescription LIKE '%' + @SearchTerm + '%')
      AND (@CategoryId IS NULL OR sc.CategoryId = @CategoryId)
      AND (@StatusId IS NULL OR sc.StatusId = @StatusId)
      AND (@BusinessUnitId IS NULL OR sc.BusinessUnitId = @BusinessUnitId)
    ORDER BY sc.ServiceName
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================================
-- PROCEDURE: Clone Service
-- Purpose: Creates a copy of an existing service
-- =============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_CloneService]
    @SourceServiceId INT,
    @NewServiceCode NVARCHAR(50),
    @NewServiceName NVARCHAR(200),
    @CreatedBy NVARCHAR(255),
    @NewServiceId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Clone main service record
        INSERT INTO [dbo].[ServiceCatalogItem] (
            ServiceCode, ServiceName, ShortDescription, LongDescription,
            StatusId, CategoryId, BusinessUnitId, Version,
            ServiceOwner, ServiceOwnerEmail, TechnicalContact, TechnicalContactEmail,
            DocumentationUrl, IsPublic, Notes, CreatedBy
        )
        SELECT 
            @NewServiceCode, @NewServiceName, ShortDescription, LongDescription,
            (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'DRAFT'),
            CategoryId, BusinessUnitId, '1.0.0',
            ServiceOwner, ServiceOwnerEmail, TechnicalContact, TechnicalContactEmail,
            DocumentationUrl, 0, Notes, @CreatedBy
        FROM [dbo].[ServiceCatalogItem]
        WHERE Id = @SourceServiceId;
        
        SET @NewServiceId = SCOPE_IDENTITY();
        
        -- Clone usage scenarios
        INSERT INTO [dbo].[UsageScenario] (ServiceId, Title, Description, ActorRole, Preconditions, Steps, ExpectedOutcome, DisplayOrder)
        SELECT @NewServiceId, Title, Description, ActorRole, Preconditions, Steps, ExpectedOutcome, DisplayOrder
        FROM [dbo].[UsageScenario] WHERE ServiceId = @SourceServiceId;
        
        -- Clone scope items
        INSERT INTO [dbo].[ServiceScope] (ServiceId, ScopeCategoryId, Item, Description, IsInScope, DisplayOrder)
        SELECT @NewServiceId, ScopeCategoryId, Item, Description, IsInScope, DisplayOrder
        FROM [dbo].[ServiceScope] WHERE ServiceId = @SourceServiceId;
        
        -- Clone prerequisites
        INSERT INTO [dbo].[ServicePrerequisite] (ServiceId, Name, Description, IsRequired, DisplayOrder)
        SELECT @NewServiceId, Name, Description, IsRequired, DisplayOrder
        FROM [dbo].[ServicePrerequisite] WHERE ServiceId = @SourceServiceId;
        
        -- Clone tools
        INSERT INTO [dbo].[ServiceTool] (ServiceId, Name, Description, Url, Version, LicenseTypeId, IsRequired, DisplayOrder)
        SELECT @NewServiceId, Name, Description, Url, Version, LicenseTypeId, IsRequired, DisplayOrder
        FROM [dbo].[ServiceTool] WHERE ServiceId = @SourceServiceId;
        
        -- Clone inputs
        INSERT INTO [dbo].[ServiceInput] (ServiceId, Name, DataTypeId, Format, Description, IsRequired, SampleValue, DisplayOrder)
        SELECT @NewServiceId, Name, DataTypeId, Format, Description, IsRequired, SampleValue, DisplayOrder
        FROM [dbo].[ServiceInput] WHERE ServiceId = @SourceServiceId;
        
        -- Clone outputs
        INSERT INTO [dbo].[ServiceOutput] (ServiceId, Name, DataTypeId, Format, Description, SampleValue, DisplayOrder)
        SELECT @NewServiceId, Name, DataTypeId, Format, Description, SampleValue, DisplayOrder
        FROM [dbo].[ServiceOutput] WHERE ServiceId = @SourceServiceId;
        
        COMMIT TRANSACTION;
        
        SELECT @NewServiceId AS NewServiceId, 'Service cloned successfully' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- =============================================================================
-- PROCEDURE: Update Service Status
-- Purpose: Updates service status with validation
-- =============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateServiceStatus]
    @ServiceId INT,
    @NewStatusCode NVARCHAR(50),
    @UpdatedBy NVARCHAR(255),
    @Comment NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewStatusId INT;
    DECLARE @OldStatusCode NVARCHAR(50);
    
    -- Get new status ID
    SELECT @NewStatusId = Id FROM [dbo].[ServiceStatus] WHERE [Code] = @NewStatusCode;
    
    IF @NewStatusId IS NULL
    BEGIN
        RAISERROR('Invalid status code: %s', 16, 1, @NewStatusCode);
        RETURN;
    END;
    
    -- Get current status
    SELECT @OldStatusCode = ss.[Code]
    FROM [dbo].[ServiceCatalogItem] sc
    INNER JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id
    WHERE sc.Id = @ServiceId;
    
    -- Update status
    UPDATE [dbo].[ServiceCatalogItem]
    SET StatusId = @NewStatusId,
        UpdatedAt = GETUTCDATE(),
        UpdatedBy = @UpdatedBy
    WHERE Id = @ServiceId;
    
    -- Log the change (if audit table exists)
    -- INSERT INTO [dbo].[ServiceAuditLog] ...
    
    SELECT 
        @ServiceId AS ServiceId,
        @OldStatusCode AS OldStatus,
        @NewStatusCode AS NewStatus,
        'Status updated successfully' AS Message;
END;
GO

-- =============================================================================
-- PROCEDURE: Get Dashboard Statistics
-- Purpose: Returns statistics for the dashboard
-- =============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetDashboardStatistics]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Total counts by status
    SELECT 
        ss.[Code] AS StatusCode,
        ss.[Name] AS StatusName,
        ss.ColorCode,
        COUNT(sc.Id) AS ServiceCount
    FROM [dbo].[ServiceStatus] ss
    LEFT JOIN [dbo].[ServiceCatalogItem] sc ON ss.Id = sc.StatusId
    WHERE ss.IsActive = 1
    GROUP BY ss.Id, ss.[Code], ss.[Name], ss.ColorCode, ss.DisplayOrder
    ORDER BY ss.DisplayOrder;
    
    -- Total counts by category
    SELECT 
        cat.[Code] AS CategoryCode,
        cat.[Name] AS CategoryName,
        cat.ColorCode,
        COUNT(sc.Id) AS ServiceCount
    FROM [dbo].[ServiceCategory] cat
    LEFT JOIN [dbo].[ServiceCatalogItem] sc ON cat.Id = sc.CategoryId
    WHERE cat.IsActive = 1
    GROUP BY cat.Id, cat.[Code], cat.[Name], cat.ColorCode, cat.DisplayOrder
    ORDER BY cat.DisplayOrder;
    
    -- Recent activity (last 30 days)
    SELECT 
        CAST(COALESCE(sc.UpdatedAt, sc.CreatedAt) AS DATE) AS ActivityDate,
        COUNT(*) AS ChangeCount
    FROM [dbo].[ServiceCatalogItem] sc
    WHERE COALESCE(sc.UpdatedAt, sc.CreatedAt) >= DATEADD(DAY, -30, GETUTCDATE())
    GROUP BY CAST(COALESCE(sc.UpdatedAt, sc.CreatedAt) AS DATE)
    ORDER BY ActivityDate;
    
    -- Summary totals
    SELECT 
        COUNT(*) AS TotalServices,
        SUM(CASE WHEN ss.[Code] = 'ACTIVE' THEN 1 ELSE 0 END) AS ActiveServices,
        SUM(CASE WHEN sc.IsPublic = 1 THEN 1 ELSE 0 END) AS PublicServices,
        COUNT(DISTINCT sc.BusinessUnitId) AS BusinessUnits
    FROM [dbo].[ServiceCatalogItem] sc
    LEFT JOIN [dbo].[ServiceStatus] ss ON sc.StatusId = ss.Id;
END;
GO

PRINT 'Stored procedures created successfully.';
