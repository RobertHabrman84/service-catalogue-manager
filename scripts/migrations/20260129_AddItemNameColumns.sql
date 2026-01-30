-- Migration: AddItemNameColumns
-- Date: 2026-01-29
-- Description: Adds ItemName column to ServiceScopeItem and ServiceOutputItem tables

-- Add ItemName to ServiceScopeItem
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceScopeItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    ALTER TABLE dbo.ServiceScopeItem
    ADD ItemName NVARCHAR(500) NOT NULL DEFAULT '';
    
    PRINT 'Added ItemName column to ServiceScopeItem table';
END
ELSE
BEGIN
    PRINT 'ItemName column already exists in ServiceScopeItem table';
END
GO

-- Add ItemName to ServiceOutputItem
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceOutputItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    ALTER TABLE dbo.ServiceOutputItem
    ADD ItemName NVARCHAR(500) NOT NULL DEFAULT '';
    
    PRINT 'Added ItemName column to ServiceOutputItem table';
END
ELSE
BEGIN
    PRINT 'ItemName column already exists in ServiceOutputItem table';
END
GO

PRINT 'Migration AddItemNameColumns completed successfully';
GO
