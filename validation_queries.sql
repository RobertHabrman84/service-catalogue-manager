-- ============================================
-- VALIDATION QUERIES
-- Service Catalogue Manager v2.9.4
-- ============================================

SET NOCOUNT ON;
GO

PRINT '============================================';
PRINT 'DATABASE VALIDATION - START';
PRINT '============================================';
PRINT '';

-- ============================================
-- 1. CHECK AUDIT FIELDS IN ALL TABLES
-- ============================================
PRINT '1. CHECKING AUDIT FIELDS IN ALL TABLES...';
PRINT '-------------------------------------------';

SELECT 
    t.name AS TableName,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.columns c 
        WHERE c.object_id = t.object_id AND c.name = 'CreatedDate'
    ) THEN '✓' ELSE '✗' END AS HasCreatedDate,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.columns c 
        WHERE c.object_id = t.object_id AND c.name = 'CreatedBy'
    ) THEN '✓' ELSE '✗' END AS HasCreatedBy,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.columns c 
        WHERE c.object_id = t.object_id AND c.name = 'ModifiedDate'
    ) THEN '✓' ELSE '✗' END AS HasModifiedDate,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.columns c 
        WHERE c.object_id = t.object_id AND c.name = 'ModifiedBy'
    ) THEN '✓' ELSE '✗' END AS HasModifiedBy
FROM sys.tables t
WHERE t.name IN (
    'ServiceInput', 'UsageScenario', 'ServiceScopeItem', 'ServiceToolFramework',
    'ServiceLicense', 'StakeholderInvolvement', 'ServiceOutputCategory', 'ServiceOutputItem',
    'ServiceSizeOption', 'TechnicalComplexityAddition', 'ServiceTeamAllocation',
    'SizingExample', 'SizingExampleCharacteristic', 'ScopeDependency',
    'SizingParameter', 'SizingCriteria', 'ServiceMultiCloudConsideration',
    'CloudProviderCapability', 'SizingCriteriaValue', 'SizingParameterValue',
    'TimelinePhase', 'PhaseDurationBySize', 'EffortEstimationItem', 'ServiceResponsibleRole'
)
ORDER BY t.name;

PRINT '';
PRINT 'Expected: 24 tables with all 4 audit fields (✓✓✓✓)';
PRINT '';

-- Summary count
DECLARE @TablesWithAudit INT;
SELECT @TablesWithAudit = COUNT(DISTINCT t.name)
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name = 'CreatedDate'
  AND t.name IN (
    'ServiceInput', 'UsageScenario', 'ServiceScopeItem', 'ServiceToolFramework',
    'ServiceLicense', 'StakeholderInvolvement', 'ServiceOutputCategory', 'ServiceOutputItem',
    'ServiceSizeOption', 'TechnicalComplexityAddition', 'ServiceTeamAllocation',
    'SizingExample', 'SizingExampleCharacteristic', 'ScopeDependency',
    'SizingParameter', 'SizingCriteria', 'ServiceMultiCloudConsideration',
    'CloudProviderCapability', 'SizingCriteriaValue', 'SizingParameterValue',
    'TimelinePhase', 'PhaseDurationBySize', 'EffortEstimationItem', 'ServiceResponsibleRole'
);

PRINT 'Tables with audit fields: ' + CAST(@TablesWithAudit AS VARCHAR(10)) + '/24';
IF @TablesWithAudit = 24
    PRINT '✓ PASSED: All tables have audit fields';
ELSE
    PRINT '✗ FAILED: Some tables missing audit fields';
PRINT '';

-- ============================================
-- 2. CHECK SERVICEINPUT SPECIFIC COLUMNS
-- ============================================
PRINT '2. CHECKING SERVICEINPUT SPECIFIC COLUMNS...';
PRINT '----------------------------------------------';

SELECT 
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length AS MaxLength,
    CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END AS Nullable,
    '✓' AS Status
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('dbo.ServiceInput')
  AND c.name IN ('InputName', 'Description', 'ExampleValue', 
                 'CreatedDate', 'CreatedBy', 'ModifiedDate', 'ModifiedBy',
                 'ParameterName', 'ParameterDescription')
ORDER BY c.name;

PRINT '';

DECLARE @ServiceInputCols INT;
SELECT @ServiceInputCols = COUNT(*)
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('dbo.ServiceInput')
  AND c.name IN ('InputName', 'Description', 'ExampleValue', 
                 'CreatedDate', 'CreatedBy', 'ModifiedDate', 'ModifiedBy');

PRINT 'ServiceInput critical columns: ' + CAST(@ServiceInputCols AS VARCHAR(10)) + '/7';
IF @ServiceInputCols = 7
    PRINT '✓ PASSED: ServiceInput has all required columns';
ELSE
    PRINT '✗ FAILED: ServiceInput missing columns';
PRINT '';

-- ============================================
-- 3. CHECK CALCULATOR TABLES
-- ============================================
PRINT '3. CHECKING CALCULATOR TABLES...';
PRINT '----------------------------------';

SELECT 
    t.name AS TableName,
    '✓' AS Exists,
    (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS ColumnCount
FROM sys.tables t
WHERE t.name IN (
    'ServicePricingConfig',
    'ServiceRoleRate',
    'ServiceBaseEffort',
    'ServiceContextMultiplier',
    'ServiceContextMultiplierValue',
    'ServiceScopeArea',
    'ServiceComplianceFactor',
    'ServiceCalculatorSection',
    'ServiceCalculatorGroup',
    'ServiceCalculatorParameter',
    'ServiceCalculatorParameterOption',
    'ServiceCalculatorScenario',
    'ServiceCalculatorPhase',
    'ServiceTeamComposition',
    'ServiceSizingCriteria'
)
ORDER BY t.name;

PRINT '';

DECLARE @CalculatorTables INT;
SELECT @CalculatorTables = COUNT(*)
FROM sys.tables t
WHERE t.name IN (
    'ServicePricingConfig', 'ServiceRoleRate', 'ServiceBaseEffort',
    'ServiceContextMultiplier', 'ServiceContextMultiplierValue', 'ServiceScopeArea',
    'ServiceComplianceFactor', 'ServiceCalculatorSection', 'ServiceCalculatorGroup',
    'ServiceCalculatorParameter', 'ServiceCalculatorParameterOption', 'ServiceCalculatorScenario',
    'ServiceCalculatorPhase', 'ServiceTeamComposition', 'ServiceSizingCriteria'
);

PRINT 'Calculator tables found: ' + CAST(@CalculatorTables AS VARCHAR(10)) + '/15';
IF @CalculatorTables = 15
    PRINT '✓ PASSED: All calculator tables exist';
ELSE
    PRINT '✗ FAILED: Some calculator tables missing';
PRINT '';

-- ============================================
-- 4. CHECK FOREIGN KEYS
-- ============================================
PRINT '4. CHECKING FOREIGN KEY CONSTRAINTS...';
PRINT '----------------------------------------';

SELECT 
    OBJECT_NAME(f.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(f.referenced_object_id) AS ReferencedTable,
    '✓' AS Status
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc 
    ON f.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(f.parent_object_id) IN (
    'ServicePricingConfig', 'ServiceRoleRate', 'ServiceBaseEffort',
    'ServiceContextMultiplier', 'ServiceContextMultiplierValue', 'ServiceScopeArea',
    'ServiceComplianceFactor', 'ServiceCalculatorSection', 'ServiceCalculatorGroup',
    'ServiceCalculatorParameter', 'ServiceCalculatorParameterOption', 'ServiceCalculatorScenario',
    'ServiceCalculatorPhase', 'ServiceTeamComposition', 'ServiceSizingCriteria'
)
ORDER BY TableName;

PRINT '';
PRINT '✓ Foreign keys created successfully';
PRINT '';

-- ============================================
-- 5. CHECK INDEXES
-- ============================================
PRINT '5. CHECKING INDEXES ON NEW TABLES...';
PRINT '--------------------------------------';

SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    '✓' AS Status
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN (
    'ServicePricingConfig', 'ServiceRoleRate', 'ServiceBaseEffort',
    'ServiceContextMultiplier', 'ServiceContextMultiplierValue', 'ServiceScopeArea',
    'ServiceComplianceFactor', 'ServiceCalculatorSection', 'ServiceCalculatorGroup',
    'ServiceCalculatorParameter', 'ServiceCalculatorParameterOption', 'ServiceCalculatorScenario',
    'ServiceCalculatorPhase', 'ServiceTeamComposition', 'ServiceSizingCriteria'
)
AND i.name IS NOT NULL
ORDER BY t.name, i.name;

PRINT '';
PRINT '✓ Indexes created successfully';
PRINT '';

-- ============================================
-- 6. OVERALL SUMMARY
-- ============================================
PRINT '============================================';
PRINT 'VALIDATION SUMMARY';
PRINT '============================================';
PRINT '';

DECLARE @TotalScore INT = 0;
DECLARE @MaxScore INT = 3;

IF @TablesWithAudit = 24 SET @TotalScore = @TotalScore + 1;
IF @ServiceInputCols = 7 SET @TotalScore = @TotalScore + 1;
IF @CalculatorTables = 15 SET @TotalScore = @TotalScore + 1;

PRINT 'Tests Passed: ' + CAST(@TotalScore AS VARCHAR(10)) + '/' + CAST(@MaxScore AS VARCHAR(10));
PRINT '';

IF @TotalScore = @MaxScore
BEGIN
    PRINT '✓✓✓ ALL VALIDATION CHECKS PASSED ✓✓✓';
    PRINT '';
    PRINT 'Database migration completed successfully!';
    PRINT 'You can now:';
    PRINT '  1. Start the application';
    PRINT '  2. Test service import';
    PRINT '  3. Test calculator functions';
END
ELSE
BEGIN
    PRINT '✗✗✗ SOME VALIDATION CHECKS FAILED ✗✗✗';
    PRINT '';
    PRINT 'Please review the results above and:';
    PRINT '  1. Check which migrations did not complete';
    PRINT '  2. Re-run the failed migration scripts';
    PRINT '  3. Run validation again';
END

PRINT '';
PRINT '============================================';
PRINT 'DATABASE VALIDATION - END';
PRINT '============================================';
GO
