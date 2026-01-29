-- ============================================
-- VERIFICATION SCRIPT
-- Check if all database fixes have been applied
-- ============================================

PRINT '============================================';
PRINT 'Database Schema Verification';
PRINT 'Checking if all missing columns were added';
PRINT '============================================';
PRINT '';

-- ============================================
-- Check ServiceInput table
-- ============================================
PRINT 'Checking ServiceInput table...';

DECLARE @ServiceInputColumns TABLE (ColumnName NVARCHAR(128));
INSERT INTO @ServiceInputColumns VALUES 
    ('InputId'), ('ServiceId'), ('ParameterName'), ('ParameterDescription'),
    ('RequirementLevelId'), ('DataType'), ('DefaultValue'), ('SortOrder'),
    ('InputName'), ('Description'), ('ExampleValue'),
    ('CreatedBy'), ('CreatedDate'), ('ModifiedBy'), ('ModifiedDate');

SELECT 
    c.ColumnName,
    CASE 
        WHEN sc.COLUMN_NAME IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END AS Status
FROM @ServiceInputColumns c
LEFT JOIN INFORMATION_SCHEMA.COLUMNS sc 
    ON sc.TABLE_NAME = 'ServiceInput' 
    AND sc.COLUMN_NAME = c.ColumnName
ORDER BY 
    CASE WHEN sc.COLUMN_NAME IS NULL THEN 0 ELSE 1 END,
    c.ColumnName;

PRINT '';
PRINT '--------------------------------------------';

-- ============================================
-- Check all tables for audit columns
-- ============================================
PRINT '';
PRINT 'Checking audit columns across all tables...';
PRINT '';

SELECT 
    t.TABLE_NAME as TableName,
    CASE WHEN c1.COLUMN_NAME IS NOT NULL THEN '✓' ELSE '✗' END as CreatedBy,
    CASE WHEN c2.COLUMN_NAME IS NOT NULL THEN '✓' ELSE '✗' END as CreatedDate,
    CASE WHEN c3.COLUMN_NAME IS NOT NULL THEN '✓' ELSE '✗' END as ModifiedBy,
    CASE WHEN c4.COLUMN_NAME IS NOT NULL THEN '✓' ELSE '✗' END as ModifiedDate,
    CASE 
        WHEN c1.COLUMN_NAME IS NOT NULL 
         AND c2.COLUMN_NAME IS NOT NULL 
         AND c3.COLUMN_NAME IS NOT NULL 
         AND c4.COLUMN_NAME IS NOT NULL 
        THEN '✓ COMPLETE'
        ELSE '✗ INCOMPLETE'
    END as Status
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c1 ON t.TABLE_NAME = c1.TABLE_NAME AND c1.COLUMN_NAME = 'CreatedBy'
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c2 ON t.TABLE_NAME = c2.TABLE_NAME AND c2.COLUMN_NAME = 'CreatedDate'
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c3 ON t.TABLE_NAME = c3.TABLE_NAME AND c3.COLUMN_NAME = 'ModifiedBy'
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c4 ON t.TABLE_NAME = c4.TABLE_NAME AND c4.COLUMN_NAME = 'ModifiedDate'
WHERE t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME IN (
    'ServiceInput',
    'UsageScenario',
    'ServiceDependency',
    'ServiceScopeCategory',
    'ServiceScopeItem',
    'ServicePrerequisite',
    'CloudProviderCapability',
    'ServiceToolFramework',
    'ServiceLicense',
    'ServiceInteraction',
    'CustomerRequirement',
    'AccessRequirement',
    'StakeholderInvolvement',
    'ServiceOutputCategory',
    'ServiceOutputItem',
    'TimelinePhase',
    'PhaseDurationBySize',
    'ServiceSizeOption',
    'SizingCriteria',
    'SizingCriteriaValue',
    'SizingParameter',
    'SizingParameterValue',
    'EffortEstimationItem',
    'TechnicalComplexityAddition',
    'ScopeDependency',
    'SizingExample',
    'SizingExampleCharacteristic',
    'ServiceResponsibleRole',
    'ServiceTeamAllocation',
    'ServiceMultiCloudConsideration'
  )
ORDER BY Status, TableName;

PRINT '';
PRINT '--------------------------------------------';
PRINT '';

-- ============================================
-- Summary
-- ============================================
PRINT 'Summary:';

DECLARE @TotalTables INT;
DECLARE @CompleteTables INT;

SELECT @TotalTables = COUNT(DISTINCT t.TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME IN (
    'ServiceInput', 'UsageScenario', 'ServiceDependency', 'ServiceScopeCategory',
    'ServiceScopeItem', 'ServicePrerequisite', 'CloudProviderCapability', 
    'ServiceToolFramework', 'ServiceLicense', 'ServiceInteraction',
    'CustomerRequirement', 'AccessRequirement', 'StakeholderInvolvement',
    'ServiceOutputCategory', 'ServiceOutputItem', 'TimelinePhase',
    'PhaseDurationBySize', 'ServiceSizeOption', 'SizingCriteria',
    'SizingCriteriaValue', 'SizingParameter', 'SizingParameterValue',
    'EffortEstimationItem', 'TechnicalComplexityAddition', 'ScopeDependency',
    'SizingExample', 'SizingExampleCharacteristic', 'ServiceResponsibleRole',
    'ServiceTeamAllocation', 'ServiceMultiCloudConsideration'
  );

SELECT @CompleteTables = COUNT(*)
FROM (
    SELECT t.TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES t
    INNER JOIN INFORMATION_SCHEMA.COLUMNS c1 ON t.TABLE_NAME = c1.TABLE_NAME AND c1.COLUMN_NAME = 'CreatedBy'
    INNER JOIN INFORMATION_SCHEMA.COLUMNS c2 ON t.TABLE_NAME = c2.TABLE_NAME AND c2.COLUMN_NAME = 'CreatedDate'
    INNER JOIN INFORMATION_SCHEMA.COLUMNS c3 ON t.TABLE_NAME = c3.TABLE_NAME AND c3.COLUMN_NAME = 'ModifiedBy'
    INNER JOIN INFORMATION_SCHEMA.COLUMNS c4 ON t.TABLE_NAME = c4.TABLE_NAME AND c4.COLUMN_NAME = 'ModifiedDate'
    WHERE t.TABLE_TYPE = 'BASE TABLE'
      AND t.TABLE_NAME IN (
        'ServiceInput', 'UsageScenario', 'ServiceDependency', 'ServiceScopeCategory',
        'ServiceScopeItem', 'ServicePrerequisite', 'CloudProviderCapability', 
        'ServiceToolFramework', 'ServiceLicense', 'ServiceInteraction',
        'CustomerRequirement', 'AccessRequirement', 'StakeholderInvolvement',
        'ServiceOutputCategory', 'ServiceOutputItem', 'TimelinePhase',
        'PhaseDurationBySize', 'ServiceSizeOption', 'SizingCriteria',
        'SizingCriteriaValue', 'SizingParameter', 'SizingParameterValue',
        'EffortEstimationItem', 'TechnicalComplexityAddition', 'ScopeDependency',
        'SizingExample', 'SizingExampleCharacteristic', 'ServiceResponsibleRole',
        'ServiceTeamAllocation', 'ServiceMultiCloudConsideration'
      )
) AS CompleteTables;

PRINT 'Total tables checked: ' + CAST(@TotalTables AS NVARCHAR(10));
PRINT 'Tables with complete audit columns: ' + CAST(@CompleteTables AS NVARCHAR(10));
PRINT '';

IF @CompleteTables = @TotalTables
BEGIN
    PRINT '✓✓✓ ALL FIXES APPLIED SUCCESSFULLY! ✓✓✓';
END
ELSE
BEGIN
    PRINT '✗✗✗ SOME FIXES ARE MISSING! ✗✗✗';
    PRINT 'Please run the db_structure.sql script to apply all fixes.';
END

PRINT '';
PRINT '============================================';
PRINT 'Verification Complete';
PRINT '============================================';
GO
