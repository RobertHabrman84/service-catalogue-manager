-- ============================================
-- CREATE CALCULATOR TABLES
-- Service Catalogue Manager v2.9.3
-- Generated: 2026-01-29
-- ============================================

SET NOCOUNT ON;
GO

-- ============================================
-- ServicePricingConfig
-- ============================================
IF OBJECT_ID('dbo.ServicePricingConfig', 'U') IS NOT NULL DROP TABLE dbo.ServicePricingConfig;
GO

CREATE TABLE dbo.ServicePricingConfig (
    PricingConfigID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    Margin DECIMAL(5,2) NOT NULL DEFAULT 15.00,
    RiskPremium DECIMAL(5,2) NOT NULL DEFAULT 5.00,
    Contingency DECIMAL(5,2) NOT NULL DEFAULT 5.00,
    Discount DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    HoursPerDay INT NOT NULL DEFAULT 8,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServicePricingConfig_Service ON dbo.ServicePricingConfig(ServiceID);
GO

-- ============================================
-- ServiceRoleRate
-- ============================================
IF OBJECT_ID('dbo.ServiceRoleRate', 'U') IS NOT NULL DROP TABLE dbo.ServiceRoleRate;
GO

CREATE TABLE dbo.ServiceRoleRate (
    RoleRateID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RoleCode NVARCHAR(50) NOT NULL,
    RoleName NVARCHAR(200) NOT NULL,
    DailyRate DECIMAL(10,2) NOT NULL,
    IsPrimary BIT NOT NULL DEFAULT 0,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceRoleRate_Service ON dbo.ServiceRoleRate(ServiceID);
GO

-- ============================================
-- ServiceBaseEffort
-- ============================================
IF OBJECT_ID('dbo.ServiceBaseEffort', 'U') IS NOT NULL DROP TABLE dbo.ServiceBaseEffort;
GO

CREATE TABLE dbo.ServiceBaseEffort (
    BaseEffortID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    EffortCode NVARCHAR(50) NOT NULL,
    Label NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Hours INT NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceBaseEffort_Service ON dbo.ServiceBaseEffort(ServiceID);
GO

-- ============================================
-- ServiceContextMultiplier
-- ============================================
IF OBJECT_ID('dbo.ServiceContextMultiplierValue', 'U') IS NOT NULL DROP TABLE dbo.ServiceContextMultiplierValue;
IF OBJECT_ID('dbo.ServiceContextMultiplier', 'U') IS NOT NULL DROP TABLE dbo.ServiceContextMultiplier;
GO

CREATE TABLE dbo.ServiceContextMultiplier (
    MultiplierID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    MultiplierCode NVARCHAR(50) NOT NULL,
    MultiplierName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceContextMultiplier_Service ON dbo.ServiceContextMultiplier(ServiceID);
GO

-- ============================================
-- ServiceContextMultiplierValue
-- ============================================
CREATE TABLE dbo.ServiceContextMultiplierValue (
    ValueID INT IDENTITY(1,1) PRIMARY KEY,
    MultiplierID INT NOT NULL REFERENCES dbo.ServiceContextMultiplier(MultiplierID) ON DELETE CASCADE,
    ValueCode NVARCHAR(50) NOT NULL,
    ValueLabel NVARCHAR(200) NOT NULL,
    MultiplierValue DECIMAL(5,2) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceContextMultiplierValue_Multiplier ON dbo.ServiceContextMultiplierValue(MultiplierID);
GO

-- ============================================
-- ServiceScopeArea
-- ============================================
IF OBJECT_ID('dbo.ServiceScopeArea', 'U') IS NOT NULL DROP TABLE dbo.ServiceScopeArea;
GO

CREATE TABLE dbo.ServiceScopeArea (
    ScopeAreaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    AreaCode NVARCHAR(50) NOT NULL,
    AreaName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Category NVARCHAR(100) NULL,
    Hours INT NOT NULL,
    IsRequired BIT NOT NULL DEFAULT 0,
    RequiresAreaCodes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceScopeArea_Service ON dbo.ServiceScopeArea(ServiceID);
GO

-- ============================================
-- ServiceComplianceFactor
-- ============================================
IF OBJECT_ID('dbo.ServiceComplianceFactor', 'U') IS NOT NULL DROP TABLE dbo.ServiceComplianceFactor;
GO

CREATE TABLE dbo.ServiceComplianceFactor (
    FactorID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    FactorCode NVARCHAR(50) NOT NULL,
    FactorLabel NVARCHAR(200) NOT NULL,
    Hours INT NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceComplianceFactor_Service ON dbo.ServiceComplianceFactor(ServiceID);
GO

-- ============================================
-- ServiceCalculatorSection
-- ============================================
IF OBJECT_ID('dbo.ServiceCalculatorParameterOption', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorParameterOption;
IF OBJECT_ID('dbo.ServiceCalculatorParameter', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorParameter;
IF OBJECT_ID('dbo.ServiceCalculatorGroup', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorGroup;
IF OBJECT_ID('dbo.ServiceCalculatorSection', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorSection;
GO

CREATE TABLE dbo.ServiceCalculatorSection (
    SectionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SectionCode NVARCHAR(50) NOT NULL,
    SectionLabel NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorSection_Service ON dbo.ServiceCalculatorSection(ServiceID);
GO

-- ============================================
-- ServiceCalculatorGroup
-- ============================================
CREATE TABLE dbo.ServiceCalculatorGroup (
    GroupID INT IDENTITY(1,1) PRIMARY KEY,
    SectionID INT NOT NULL REFERENCES dbo.ServiceCalculatorSection(SectionID) ON DELETE CASCADE,
    GroupTitle NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorGroup_Section ON dbo.ServiceCalculatorGroup(SectionID);
GO

-- ============================================
-- ServiceCalculatorParameter
-- ============================================
CREATE TABLE dbo.ServiceCalculatorParameter (
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    GroupID INT NOT NULL REFERENCES dbo.ServiceCalculatorGroup(GroupID) ON DELETE CASCADE,
    ParameterCode NVARCHAR(50) NOT NULL,
    ParameterLabel NVARCHAR(200) NOT NULL,
    IsRequired BIT NOT NULL DEFAULT 0,
    DefaultValue NVARCHAR(200) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorParameter_Group ON dbo.ServiceCalculatorParameter(GroupID);
GO

-- ============================================
-- ServiceCalculatorParameterOption
-- ============================================
CREATE TABLE dbo.ServiceCalculatorParameterOption (
    OptionID INT IDENTITY(1,1) PRIMARY KEY,
    ParameterID INT NOT NULL REFERENCES dbo.ServiceCalculatorParameter(ParameterID) ON DELETE CASCADE,
    OptionValue NVARCHAR(200) NOT NULL,
    OptionLabel NVARCHAR(200) NOT NULL,
    SizeImpact NVARCHAR(10) NULL,
    ComplexityHours INT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorParameterOption_Parameter ON dbo.ServiceCalculatorParameterOption(ParameterID);
GO

-- ============================================
-- ServiceCalculatorScenario
-- ============================================
IF OBJECT_ID('dbo.ServiceCalculatorScenario', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorScenario;
GO

CREATE TABLE dbo.ServiceCalculatorScenario (
    ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScenarioCode NVARCHAR(50) NOT NULL,
    ScenarioName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ParameterValuesJson NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorScenario_Service ON dbo.ServiceCalculatorScenario(ServiceID);
GO

-- ============================================
-- ServiceCalculatorPhase
-- ============================================
IF OBJECT_ID('dbo.ServiceCalculatorPhase', 'U') IS NOT NULL DROP TABLE dbo.ServiceCalculatorPhase;
GO

CREATE TABLE dbo.ServiceCalculatorPhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseCode NVARCHAR(50) NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    DurationSmall NVARCHAR(50) NULL,
    DurationMedium NVARCHAR(50) NULL,
    DurationLarge NVARCHAR(50) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceCalculatorPhase_Service ON dbo.ServiceCalculatorPhase(ServiceID);
GO

-- ============================================
-- ServiceTeamComposition
-- ============================================
IF OBJECT_ID('dbo.ServiceTeamComposition', 'U') IS NOT NULL DROP TABLE dbo.ServiceTeamComposition;
GO

CREATE TABLE dbo.ServiceTeamComposition (
    CompositionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeCode NVARCHAR(10) NOT NULL,
    RoleCode NVARCHAR(50) NOT NULL,
    FteAllocation DECIMAL(3,2) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceTeamComposition_Service ON dbo.ServiceTeamComposition(ServiceID);
GO

-- ============================================
-- ServiceSizingCriteria
-- ============================================
IF OBJECT_ID('dbo.ServiceSizingCriteria', 'U') IS NOT NULL DROP TABLE dbo.ServiceSizingCriteria;
GO

CREATE TABLE dbo.ServiceSizingCriteria (
    SizingCriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeCode NVARCHAR(10) NOT NULL,
    Duration NVARCHAR(100) NULL,
    Effort NVARCHAR(100) NULL,
    Description NVARCHAR(MAX) NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceSizingCriteria_Service ON dbo.ServiceSizingCriteria(ServiceID);
GO

PRINT 'All calculator tables created successfully!';
GO
