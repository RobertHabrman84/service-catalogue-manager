-- ============================================
-- HOTFIX: Add missing columns to ServicePrerequisite table
-- Version: v2.9.10
-- Date: 2026-01-29
-- ============================================
-- This script adds missing columns to the ServicePrerequisite table
-- to fix import errors related to invalid column names.
-- ============================================

USE [ServiceCatalogueManager];
GO

-- Check if table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ServicePrerequisite')
BEGIN
    PRINT 'ERROR: Table ServicePrerequisite does not exist!';
    RETURN;
END
GO

PRINT 'Starting ServicePrerequisite table update...';
GO

-- ============================================
-- 1. Add PrerequisiteName column (if missing)
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'PrerequisiteName')
BEGIN
    PRINT 'Adding column: PrerequisiteName...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD PrerequisiteName NVARCHAR(MAX) NOT NULL DEFAULT 'Unknown';
    
    -- Update existing rows to copy from PrerequisiteDescription if needed
    UPDATE dbo.ServicePrerequisite
    SET PrerequisiteName = LEFT(PrerequisiteDescription, 200)
    WHERE PrerequisiteName = 'Unknown';
    
    PRINT '✓ Column PrerequisiteName added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column PrerequisiteName already exists.';
END
GO

-- ============================================
-- 2. Ensure PrerequisiteDescription has DEFAULT
-- ============================================
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'PrerequisiteDescription')
BEGIN
    -- Check if column allows NULL
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') 
               AND name = 'PrerequisiteDescription' AND is_nullable = 1)
    BEGIN
        PRINT 'Updating PrerequisiteDescription to NOT NULL with DEFAULT...';
        
        -- First, update any NULL values
        UPDATE dbo.ServicePrerequisite
        SET PrerequisiteDescription = ''
        WHERE PrerequisiteDescription IS NULL;
        
        -- Then alter the column
        ALTER TABLE dbo.ServicePrerequisite 
            ALTER COLUMN PrerequisiteDescription NVARCHAR(MAX) NOT NULL;
        
        PRINT '✓ Column PrerequisiteDescription updated successfully.';
    END
    ELSE
    BEGIN
        PRINT '○ Column PrerequisiteDescription already NOT NULL.';
    END
END
GO

-- ============================================
-- 3. Add Description column (if missing)
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'Description')
BEGIN
    PRINT 'Adding column: Description...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD [Description] NVARCHAR(MAX) NULL;
    
    PRINT '✓ Column Description added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column Description already exists.';
END
GO

-- ============================================
-- 4. Add RequirementLevelID column (if missing)
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'RequirementLevelID')
BEGIN
    PRINT 'Adding column: RequirementLevelID...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD RequirementLevelID INT NULL;
    
    PRINT '✓ Column RequirementLevelID added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column RequirementLevelID already exists.';
END
GO

-- ============================================
-- 5. Add Foreign Key for RequirementLevelID (if missing)
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ServicePrerequisite_LU_RequirementLevel')
    AND EXISTS (SELECT * FROM sys.tables WHERE name = 'LU_RequirementLevel')
    AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'RequirementLevelID')
BEGIN
    PRINT 'Adding Foreign Key: FK_ServicePrerequisite_LU_RequirementLevel...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD CONSTRAINT FK_ServicePrerequisite_LU_RequirementLevel 
        FOREIGN KEY (RequirementLevelID) 
        REFERENCES dbo.LU_RequirementLevel(RequirementLevelID)
        ON DELETE SET NULL;
    
    PRINT '✓ Foreign Key FK_ServicePrerequisite_LU_RequirementLevel added successfully.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LU_RequirementLevel')
        PRINT '⚠ WARNING: Table LU_RequirementLevel does not exist. Foreign Key not created.';
    ELSE
        PRINT '○ Foreign Key FK_ServicePrerequisite_LU_RequirementLevel already exists.';
END
GO

-- ============================================
-- 6. Add Audit Columns (CreatedDate, CreatedBy, ModifiedDate, ModifiedBy)
-- ============================================

-- CreatedDate
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'CreatedDate')
BEGIN
    PRINT 'Adding column: CreatedDate...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    
    PRINT '✓ Column CreatedDate added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column CreatedDate already exists.';
END
GO

-- CreatedBy
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'CreatedBy')
BEGIN
    PRINT 'Adding column: CreatedBy...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD CreatedBy NVARCHAR(MAX) NULL;
    
    PRINT '✓ Column CreatedBy added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column CreatedBy already exists.';
END
GO

-- ModifiedDate
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'ModifiedDate')
BEGIN
    PRINT 'Adding column: ModifiedDate...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    
    PRINT '✓ Column ModifiedDate added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column ModifiedDate already exists.';
END
GO

-- ModifiedBy
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'ModifiedBy')
BEGIN
    PRINT 'Adding column: ModifiedBy...';
    ALTER TABLE dbo.ServicePrerequisite 
        ADD ModifiedBy NVARCHAR(MAX) NULL;
    
    PRINT '✓ Column ModifiedBy added successfully.';
END
ELSE
BEGIN
    PRINT '○ Column ModifiedBy already exists.';
END
GO

-- ============================================
-- 7. Add Index on RequirementLevelID (if missing)
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ServicePrerequisite_RequirementLevel' 
    AND object_id = OBJECT_ID('dbo.ServicePrerequisite'))
    AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'RequirementLevelID')
BEGIN
    PRINT 'Creating index: IX_ServicePrerequisite_RequirementLevel...';
    CREATE INDEX IX_ServicePrerequisite_RequirementLevel 
        ON dbo.ServicePrerequisite(RequirementLevelID);
    
    PRINT '✓ Index IX_ServicePrerequisite_RequirementLevel created successfully.';
END
ELSE
BEGIN
    PRINT '○ Index IX_ServicePrerequisite_RequirementLevel already exists.';
END
GO

-- ============================================
-- 8. Verification
-- ============================================
PRINT '';
PRINT '============================================';
PRINT 'VERIFICATION';
PRINT '============================================';
PRINT 'Columns in ServicePrerequisite table:';

SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    CASE WHEN c.IS_NULLABLE = 'YES' THEN 'NULL' ELSE 'NOT NULL' END AS NULLABLE,
    ISNULL(c.COLUMN_DEFAULT, '') AS [DEFAULT]
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'ServicePrerequisite'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT 'Foreign Keys on ServicePrerequisite table:';

SELECT 
    fk.name AS ForeignKey,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ServicePrerequisite';

PRINT '';
PRINT 'Indexes on ServicePrerequisite table:';

SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'ServicePrerequisite'
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '============================================';
PRINT 'ServicePrerequisite table update completed!';
PRINT '============================================';
GO
