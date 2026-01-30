-- Migration Rollback: AddItemNameColumns
-- Date: 2026-01-29
-- Description: Removes ItemName column from ServiceScopeItem and ServiceOutputItem tables

-- Remove ItemName from ServiceScopeItem
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceScopeItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    ALTER TABLE dbo.ServiceScopeItem
    DROP COLUMN ItemName;
    
    PRINT 'Removed ItemName column from ServiceScopeItem table';
END
ELSE
BEGIN
    PRINT 'ItemName column does not exist in ServiceScopeItem table';
END
GO

-- Remove ItemName from ServiceOutputItem
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceOutputItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    ALTER TABLE dbo.ServiceOutputItem
    DROP COLUMN ItemName;
    
    PRINT 'Removed ItemName column from ServiceOutputItem table';
END
ELSE
BEGIN
    PRINT 'ItemName column does not exist in ServiceOutputItem table';
END
GO

PRINT 'Migration rollback AddItemNameColumns completed successfully';
GO
