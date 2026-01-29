-- ============================================
-- COMPLETE MIGRATION SCRIPT: Schema Enhancement
-- Version: v2.9.11
-- Date: 2026-01-29
-- Description: Add all missing columns to match C# entities
-- ============================================

USE [ServiceCatalogueDB];
GO

PRINT '=== Starting Complete Schema Migration v2.9.11 ===';
GO

-- ============================================
-- 1. ServiceDependency
-- ============================================
PRINT 'Updating ServiceDependency...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceDependency') AND name = 'DependencyName')
BEGIN
    ALTER TABLE dbo.ServiceDependency ADD DependencyName NVARCHAR(200) NULL;
    PRINT '  ✓ Added DependencyName';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceDependency') AND name = 'DependencyDescription')
BEGIN
    ALTER TABLE dbo.ServiceDependency ADD DependencyDescription NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added DependencyDescription';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceDependency') AND name = 'DependentServiceCode')
BEGIN
    ALTER TABLE dbo.ServiceDependency ADD DependentServiceCode NVARCHAR(50) NULL;
    PRINT '  ✓ Added DependentServiceCode';
END
GO

-- ============================================
-- 2. ServiceLicense
-- ============================================
PRINT 'Updating ServiceLicense...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceLicense') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.ServiceLicense ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END
GO

-- ============================================
-- 3. LU_ServiceCategory
-- ============================================
PRINT 'Updating LU_ServiceCategory...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ServiceCategory') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_ServiceCategory ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END
GO

-- ============================================
-- 4. LU_SizeOption
-- ============================================
PRINT 'Updating LU_SizeOption...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_SizeOption') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_SizeOption ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END
GO

-- ============================================
-- 5. LU_CloudProvider
-- ============================================
PRINT 'Updating LU_CloudProvider...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_CloudProvider') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_CloudProvider ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_CloudProvider') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_CloudProvider ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END
GO

-- ============================================
-- 6. LU_DependencyType
-- ============================================
PRINT 'Updating LU_DependencyType...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_DependencyType') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_DependencyType ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_DependencyType') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_DependencyType ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 7. LU_PrerequisiteCategory
-- ============================================
PRINT 'Updating LU_PrerequisiteCategory...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_PrerequisiteCategory') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_PrerequisiteCategory ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_PrerequisiteCategory') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_PrerequisiteCategory ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_PrerequisiteCategory') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_PrerequisiteCategory ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 8. LU_LicenseType
-- ============================================
PRINT 'Updating LU_LicenseType...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_LicenseType') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_LicenseType ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_LicenseType') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_LicenseType ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_LicenseType') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_LicenseType ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 9. LU_ToolCategory
-- ============================================
PRINT 'Updating LU_ToolCategory...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ToolCategory') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_ToolCategory ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ToolCategory') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_ToolCategory ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ToolCategory') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_ToolCategory ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 10. LU_ScopeType
-- ============================================
PRINT 'Updating LU_ScopeType...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ScopeType') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_ScopeType ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ScopeType') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_ScopeType ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_ScopeType') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_ScopeType ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 11. LU_InteractionLevel
-- ============================================
PRINT 'Updating LU_InteractionLevel...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_InteractionLevel') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_InteractionLevel ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_InteractionLevel') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_InteractionLevel ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 12. LU_RequirementLevel
-- ============================================
PRINT 'Updating LU_RequirementLevel...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_RequirementLevel') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.LU_RequirementLevel ADD Description NVARCHAR(MAX) NULL;
    PRINT '  ✓ Added Description';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_RequirementLevel') AND name = 'IsActive')
BEGIN
    ALTER TABLE dbo.LU_RequirementLevel ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT '  ✓ Added IsActive';
END
GO

-- ============================================
-- 13. LU_Role
-- ============================================
PRINT 'Updating LU_Role...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LU_Role') AND name = 'SortOrder')
BEGIN
    ALTER TABLE dbo.LU_Role ADD SortOrder INT NOT NULL DEFAULT 0;
    PRINT '  ✓ Added SortOrder';
END
GO

-- ============================================
-- 14. LU_EffortCategory (NEW TABLE)
-- ============================================
PRINT 'Creating LU_EffortCategory...';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LU_EffortCategory')
BEGIN
    CREATE TABLE dbo.LU_EffortCategory (
        EffortCategoryID INT IDENTITY(1,1) PRIMARY KEY,
        CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
        CategoryName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        SortOrder INT NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1
    );
    PRINT '  ✓ Created LU_EffortCategory table';
END
ELSE
BEGIN
    PRINT '  → LU_EffortCategory already exists';
END
GO

PRINT '';
PRINT '=== Migration v2.9.11 Complete! ===';
PRINT '';
PRINT 'Summary:';
PRINT '  - ServiceDependency: +3 columns';
PRINT '  - ServiceLicense: +1 column';
PRINT '  - 12 Lookup tables: +Description/SortOrder/IsActive';
PRINT '  - LU_EffortCategory: NEW TABLE';
GO
