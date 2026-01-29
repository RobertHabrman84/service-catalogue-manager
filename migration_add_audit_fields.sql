-- ============================================
-- MIGRATION SCRIPT - Add Missing Columns
-- Service Catalogue Manager v2.9.3
-- Generated: 2026-01-29
-- ============================================

SET NOCOUNT ON;
GO

-- ============================================
-- 1. ADD AUDIT FIELDS TO EXISTING TABLES
-- ============================================

-- Add audit fields to ServiceInput
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceInput') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceInput_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceInput_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceInput';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceInput';
END
GO

-- Add audit fields to UsageScenario
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.UsageScenario') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.UsageScenario ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_UsageScenario_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_UsageScenario_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to UsageScenario';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in UsageScenario';
END
GO

-- Add audit fields to ServiceScopeItem
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceScopeItem') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceScopeItem ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceScopeItem_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceScopeItem_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceScopeItem';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceScopeItem';
END
GO

-- Add audit fields to ServiceToolFramework
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceToolFramework') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceToolFramework ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceToolFramework_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceToolFramework_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceToolFramework';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceToolFramework';
END
GO

-- Add audit fields to ServiceLicense
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceLicense') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceLicense ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceLicense_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceLicense_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceLicense';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceLicense';
END
GO

-- Add audit fields to StakeholderInvolvement
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.StakeholderInvolvement') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.StakeholderInvolvement ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_StakeholderInvolvement_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_StakeholderInvolvement_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to StakeholderInvolvement';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in StakeholderInvolvement';
END
GO

-- Add audit fields to ServiceOutputCategory
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceOutputCategory') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceOutputCategory ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceOutputCategory_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceOutputCategory_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceOutputCategory';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceOutputCategory';
END
GO

-- Add audit fields to ServiceOutputItem
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceOutputItem') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceOutputItem ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceOutputItem_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceOutputItem_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceOutputItem';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceOutputItem';
END
GO

-- Add audit fields to ServiceSizeOption
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceSizeOption') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceSizeOption ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceSizeOption_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceSizeOption_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceSizeOption';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceSizeOption';
END
GO

-- Add audit fields to TechnicalComplexityAddition
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.TechnicalComplexityAddition') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.TechnicalComplexityAddition ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_TechnicalComplexityAddition_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_TechnicalComplexityAddition_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to TechnicalComplexityAddition';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in TechnicalComplexityAddition';
END
GO

-- Add audit fields to ServiceTeamAllocation
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceTeamAllocation') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceTeamAllocation ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceTeamAllocation_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceTeamAllocation_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceTeamAllocation';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceTeamAllocation';
END
GO

-- Add audit fields to SizingExample
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingExample') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingExample ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingExample_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingExample_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingExample';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingExample';
END
GO

-- Add audit fields to SizingExampleCharacteristic
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingExampleCharacteristic') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingExampleCharacteristic ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingExampleCharacteristic_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingExampleCharacteristic_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingExampleCharacteristic';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingExampleCharacteristic';
END
GO

-- Add audit fields to ScopeDependency
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ScopeDependency') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ScopeDependency ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ScopeDependency_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ScopeDependency_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ScopeDependency';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ScopeDependency';
END
GO

-- Add audit fields to SizingParameter
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingParameter') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingParameter ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingParameter_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingParameter_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingParameter';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingParameter';
END
GO

-- Add audit fields to SizingCriteria
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingCriteria') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingCriteria ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingCriteria_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingCriteria_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingCriteria';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingCriteria';
END
GO

-- Add audit fields to ServiceMultiCloudConsideration
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceMultiCloudConsideration') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceMultiCloudConsideration ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceMultiCloudConsideration_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceMultiCloudConsideration_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceMultiCloudConsideration';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceMultiCloudConsideration';
END
GO

-- Add audit fields to CloudProviderCapability
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.CloudProviderCapability') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.CloudProviderCapability ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_CloudProviderCapability_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_CloudProviderCapability_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to CloudProviderCapability';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in CloudProviderCapability';
END
GO

-- Add audit fields to SizingCriteriaValue
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingCriteriaValue') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingCriteriaValue ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingCriteriaValue_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingCriteriaValue_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingCriteriaValue';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingCriteriaValue';
END
GO

-- Add audit fields to SizingParameterValue
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SizingParameterValue') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.SizingParameterValue ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingParameterValue_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_SizingParameterValue_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to SizingParameterValue';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in SizingParameterValue';
END
GO

-- Add audit fields to TimelinePhase
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.TimelinePhase') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.TimelinePhase ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_TimelinePhase_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_TimelinePhase_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to TimelinePhase';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in TimelinePhase';
END
GO

-- Add audit fields to PhaseDurationBySize
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PhaseDurationBySize') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.PhaseDurationBySize ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_PhaseDurationBySize_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_PhaseDurationBySize_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to PhaseDurationBySize';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in PhaseDurationBySize';
END
GO

-- Add audit fields to EffortEstimationItem
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.EffortEstimationItem') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.EffortEstimationItem ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_EffortEstimationItem_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_EffortEstimationItem_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to EffortEstimationItem';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in EffortEstimationItem';
END
GO

-- Add audit fields to ServiceResponsibleRole
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceResponsibleRole') AND name = 'CreatedDate')
BEGIN
    ALTER TABLE dbo.ServiceResponsibleRole ADD
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceResponsibleRole_CreatedDate DEFAULT GETUTCDATE(),
        CreatedBy NVARCHAR(200) NULL,
        ModifiedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceResponsibleRole_ModifiedDate DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(200) NULL;
    PRINT 'Audit fields added to ServiceResponsibleRole';
END
ELSE
BEGIN
    PRINT 'Audit fields already exist in ServiceResponsibleRole';
END
GO

-- ============================================
-- 2. ADD SERVICEINPUT SPECIFIC COLUMNS
-- ============================================

-- Add InputName to ServiceInput
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceInput') AND name = 'InputName')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD InputName NVARCHAR(200) NOT NULL DEFAULT '';
    PRINT 'InputName added to ServiceInput';
END
ELSE
BEGIN
    PRINT 'InputName already exists in ServiceInput';
END
GO

-- Add Description to ServiceInput
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceInput') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD Description NVARCHAR(MAX) NULL;
    PRINT 'Description added to ServiceInput';
END
ELSE
BEGIN
    PRINT 'Description already exists in ServiceInput';
END
GO

-- Add ExampleValue to ServiceInput
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ServiceInput') AND name = 'ExampleValue')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD ExampleValue NVARCHAR(MAX) NULL;
    PRINT 'ExampleValue added to ServiceInput';
END
ELSE
BEGIN
    PRINT 'ExampleValue already exists in ServiceInput';
END
GO

-- ============================================
-- MIGRATION COMPLETED
-- ============================================
PRINT 'Migration completed successfully!';
GO