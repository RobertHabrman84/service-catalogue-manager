-- Verification Script: Check ItemName columns exist
-- Run this after applying the migration to verify success

PRINT '═══════════════════════════════════════════════════════════════';
PRINT '          MIGRATION VERIFICATION: AddItemNameColumns            ';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

-- Check ServiceScopeItem
PRINT 'Checking ServiceScopeItem table...';
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceScopeItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    PRINT '✓ SUCCESS: ItemName column exists in ServiceScopeItem';
    SELECT 
        COLUMN_NAME, 
        DATA_TYPE, 
        CHARACTER_MAXIMUM_LENGTH, 
        IS_NULLABLE,
        COLUMN_DEFAULT
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ServiceScopeItem' AND COLUMN_NAME = 'ItemName';
END
ELSE
BEGIN
    PRINT '✗ ERROR: ItemName column NOT found in ServiceScopeItem';
END
PRINT '';

-- Check ServiceOutputItem
PRINT 'Checking ServiceOutputItem table...';
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceOutputItem' 
    AND COLUMN_NAME = 'ItemName'
)
BEGIN
    PRINT '✓ SUCCESS: ItemName column exists in ServiceOutputItem';
    SELECT 
        COLUMN_NAME, 
        DATA_TYPE, 
        CHARACTER_MAXIMUM_LENGTH, 
        IS_NULLABLE,
        COLUMN_DEFAULT
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ServiceOutputItem' AND COLUMN_NAME = 'ItemName';
END
ELSE
BEGIN
    PRINT '✗ ERROR: ItemName column NOT found in ServiceOutputItem';
END
PRINT '';

-- Summary
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '                    VERIFICATION SUMMARY                        ';
PRINT '═══════════════════════════════════════════════════════════════';

DECLARE @ScopeItemCheck INT = 0;
DECLARE @OutputItemCheck INT = 0;

SELECT @ScopeItemCheck = COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ServiceScopeItem' AND COLUMN_NAME = 'ItemName';

SELECT @OutputItemCheck = COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ServiceOutputItem' AND COLUMN_NAME = 'ItemName';

IF @ScopeItemCheck = 1 AND @OutputItemCheck = 1
BEGIN
    PRINT '✓ ALL CHECKS PASSED: Migration successful!';
    PRINT '';
    PRINT 'Next steps:';
    PRINT '  1. Restart the application';
    PRINT '  2. Test import functionality';
    PRINT '  3. Verify no SQL errors in logs';
END
ELSE
BEGIN
    PRINT '✗ MIGRATION INCOMPLETE: Please review and reapply';
    PRINT '';
    PRINT 'Missing columns:';
    IF @ScopeItemCheck = 0 PRINT '  - ServiceScopeItem.ItemName';
    IF @OutputItemCheck = 0 PRINT '  - ServiceOutputItem.ItemName';
END

PRINT '═══════════════════════════════════════════════════════════════';
