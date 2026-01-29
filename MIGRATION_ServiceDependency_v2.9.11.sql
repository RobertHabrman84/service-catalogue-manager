-- ============================================
-- MIGRATION SCRIPT: ServiceDependency Enhancement
-- Version: v2.9.11
-- Date: 2026-01-29
-- Description: Add missing columns to ServiceDependency table
-- ============================================

USE [ServiceCatalogueDB];
GO

PRINT 'Starting ServiceDependency migration...';
GO

-- Add DependencyName column
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('dbo.ServiceDependency') 
               AND name = 'DependencyName')
BEGIN
    ALTER TABLE dbo.ServiceDependency 
    ADD DependencyName NVARCHAR(200) NULL;
    PRINT 'Added column: DependencyName';
END
ELSE
BEGIN
    PRINT 'Column DependencyName already exists - skipping';
END
GO

-- Add DependencyDescription column
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('dbo.ServiceDependency') 
               AND name = 'DependencyDescription')
BEGIN
    ALTER TABLE dbo.ServiceDependency 
    ADD DependencyDescription NVARCHAR(MAX) NULL;
    PRINT 'Added column: DependencyDescription';
END
ELSE
BEGIN
    PRINT 'Column DependencyDescription already exists - skipping';
END
GO

-- Add DependentServiceCode column
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('dbo.ServiceDependency') 
               AND name = 'DependentServiceCode')
BEGIN
    ALTER TABLE dbo.ServiceDependency 
    ADD DependentServiceCode NVARCHAR(50) NULL;
    PRINT 'Added column: DependentServiceCode';
END
ELSE
BEGIN
    PRINT 'Column DependentServiceCode already exists - skipping';
END
GO

PRINT 'ServiceDependency migration completed successfully!';
GO

-- Verify the changes
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServiceDependency'
ORDER BY ORDINAL_POSITION;
GO
