-- ============================================
-- Service Catalog Database Structure
-- Generic structure for all service catalog items
-- Version: 1.1.0 - Fixed GO separators and hierarchical inserts
-- ============================================

-- ============================================
-- CLEANUP - Drop existing tables
-- ============================================
IF OBJECT_ID('dbo.ServiceMultiCloudConsideration', 'U') IS NOT NULL DROP TABLE dbo.ServiceMultiCloudConsideration;
IF OBJECT_ID('dbo.ServiceTeamAllocation', 'U') IS NOT NULL DROP TABLE dbo.ServiceTeamAllocation;
IF OBJECT_ID('dbo.ServiceResponsibleRole', 'U') IS NOT NULL DROP TABLE dbo.ServiceResponsibleRole;
IF OBJECT_ID('dbo.SizingExampleCharacteristic', 'U') IS NOT NULL DROP TABLE dbo.SizingExampleCharacteristic;
IF OBJECT_ID('dbo.SizingExample', 'U') IS NOT NULL DROP TABLE dbo.SizingExample;
IF OBJECT_ID('dbo.ScopeDependency', 'U') IS NOT NULL DROP TABLE dbo.ScopeDependency;
IF OBJECT_ID('dbo.TechnicalComplexityAddition', 'U') IS NOT NULL DROP TABLE dbo.TechnicalComplexityAddition;
IF OBJECT_ID('dbo.EffortEstimationItem', 'U') IS NOT NULL DROP TABLE dbo.EffortEstimationItem;
IF OBJECT_ID('dbo.SizingParameterValue', 'U') IS NOT NULL DROP TABLE dbo.SizingParameterValue;
IF OBJECT_ID('dbo.SizingParameter', 'U') IS NOT NULL DROP TABLE dbo.SizingParameter;
IF OBJECT_ID('dbo.SizingCriteriaValue', 'U') IS NOT NULL DROP TABLE dbo.SizingCriteriaValue;
IF OBJECT_ID('dbo.SizingCriteria', 'U') IS NOT NULL DROP TABLE dbo.SizingCriteria;
IF OBJECT_ID('dbo.ServiceSizeOption', 'U') IS NOT NULL DROP TABLE dbo.ServiceSizeOption;
IF OBJECT_ID('dbo.PhaseDurationBySize', 'U') IS NOT NULL DROP TABLE dbo.PhaseDurationBySize;
IF OBJECT_ID('dbo.TimelinePhase', 'U') IS NOT NULL DROP TABLE dbo.TimelinePhase;
IF OBJECT_ID('dbo.ServiceOutputItem', 'U') IS NOT NULL DROP TABLE dbo.ServiceOutputItem;
IF OBJECT_ID('dbo.ServiceOutputCategory', 'U') IS NOT NULL DROP TABLE dbo.ServiceOutputCategory;
IF OBJECT_ID('dbo.ServiceInput', 'U') IS NOT NULL DROP TABLE dbo.ServiceInput;
IF OBJECT_ID('dbo.StakeholderInvolvement', 'U') IS NOT NULL DROP TABLE dbo.StakeholderInvolvement;
IF OBJECT_ID('dbo.AccessRequirement', 'U') IS NOT NULL DROP TABLE dbo.AccessRequirement;
IF OBJECT_ID('dbo.CustomerRequirement', 'U') IS NOT NULL DROP TABLE dbo.CustomerRequirement;
IF OBJECT_ID('dbo.ServiceInteraction', 'U') IS NOT NULL DROP TABLE dbo.ServiceInteraction;
IF OBJECT_ID('dbo.ServiceLicense', 'U') IS NOT NULL DROP TABLE dbo.ServiceLicense;
IF OBJECT_ID('dbo.ServiceToolFramework', 'U') IS NOT NULL DROP TABLE dbo.ServiceToolFramework;
IF OBJECT_ID('dbo.CloudProviderCapability', 'U') IS NOT NULL DROP TABLE dbo.CloudProviderCapability;
IF OBJECT_ID('dbo.ServicePrerequisite', 'U') IS NOT NULL DROP TABLE dbo.ServicePrerequisite;
IF OBJECT_ID('dbo.ServiceScopeItem', 'U') IS NOT NULL DROP TABLE dbo.ServiceScopeItem;
IF OBJECT_ID('dbo.ServiceScopeCategory', 'U') IS NOT NULL DROP TABLE dbo.ServiceScopeCategory;
IF OBJECT_ID('dbo.ServiceDependency', 'U') IS NOT NULL DROP TABLE dbo.ServiceDependency;
IF OBJECT_ID('dbo.UsageScenario', 'U') IS NOT NULL DROP TABLE dbo.UsageScenario;
IF OBJECT_ID('dbo.ServiceCatalogItem', 'U') IS NOT NULL DROP TABLE dbo.ServiceCatalogItem;

-- Lookup tables
IF OBJECT_ID('dbo.LU_Role', 'U') IS NOT NULL DROP TABLE dbo.LU_Role;
IF OBJECT_ID('dbo.LU_SizeOption', 'U') IS NOT NULL DROP TABLE dbo.LU_SizeOption;
IF OBJECT_ID('dbo.LU_CloudProvider', 'U') IS NOT NULL DROP TABLE dbo.LU_CloudProvider;
IF OBJECT_ID('dbo.LU_DependencyType', 'U') IS NOT NULL DROP TABLE dbo.LU_DependencyType;
IF OBJECT_ID('dbo.LU_PrerequisiteCategory', 'U') IS NOT NULL DROP TABLE dbo.LU_PrerequisiteCategory;
IF OBJECT_ID('dbo.LU_LicenseType', 'U') IS NOT NULL DROP TABLE dbo.LU_LicenseType;
IF OBJECT_ID('dbo.LU_ToolCategory', 'U') IS NOT NULL DROP TABLE dbo.LU_ToolCategory;
IF OBJECT_ID('dbo.LU_ScopeType', 'U') IS NOT NULL DROP TABLE dbo.LU_ScopeType;
IF OBJECT_ID('dbo.LU_InteractionLevel', 'U') IS NOT NULL DROP TABLE dbo.LU_InteractionLevel;
IF OBJECT_ID('dbo.LU_RequirementLevel', 'U') IS NOT NULL DROP TABLE dbo.LU_RequirementLevel;
IF OBJECT_ID('dbo.LU_ServiceCategory', 'U') IS NOT NULL DROP TABLE dbo.LU_ServiceCategory;

-- Drop views if exist
IF OBJECT_ID('dbo.vw_ServiceOverview', 'V') IS NOT NULL DROP VIEW dbo.vw_ServiceOverview;
IF OBJECT_ID('dbo.vw_ServiceDependencies', 'V') IS NOT NULL DROP VIEW dbo.vw_ServiceDependencies;
IF OBJECT_ID('dbo.vw_ServiceSizing', 'V') IS NOT NULL DROP VIEW dbo.vw_ServiceSizing;
IF OBJECT_ID('dbo.vw_ServiceScope', 'V') IS NOT NULL DROP VIEW dbo.vw_ServiceScope;
GO

-- ============================================
-- LOOKUP TABLES
-- ============================================

-- Service Categories (e.g., Services / Architecture / Technical Architecture)
CREATE TABLE dbo.LU_ServiceCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(200) NOT NULL,
    ParentCategoryID INT NULL,
    CategoryPath NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- Add self-referencing FK after table creation
ALTER TABLE dbo.LU_ServiceCategory 
ADD CONSTRAINT FK_LU_ServiceCategory_Parent 
FOREIGN KEY (ParentCategoryID) REFERENCES dbo.LU_ServiceCategory(CategoryID);
GO

-- Size Options (S, M, L, XL, etc.)
CREATE TABLE dbo.LU_SizeOption (
    SizeOptionID INT IDENTITY(1,1) PRIMARY KEY,
    SizeCode NVARCHAR(10) NOT NULL UNIQUE,
    SizeName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- Cloud Providers
CREATE TABLE dbo.LU_CloudProvider (
    CloudProviderID INT IDENTITY(1,1) PRIMARY KEY,
    ProviderCode NVARCHAR(20) NOT NULL UNIQUE,
    ProviderName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- Dependency Types (Prerequisite, Triggers for, Parallel)
CREATE TABLE dbo.LU_DependencyType (
    DependencyTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL
);
GO

-- Prerequisite Categories (Organizational, Technical, Documentation)
CREATE TABLE dbo.LU_PrerequisiteCategory (
    PrerequisiteCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL
);
GO

-- License Types (Required by Customer, Recommended/Optional, Provided by Service Provider)
CREATE TABLE dbo.LU_LicenseType (
    LicenseTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL
);
GO

-- Tool Categories (Cloud Platforms, Design & Documentation, IaC, Assessment & Analysis)
CREATE TABLE dbo.LU_ToolCategory (
    ToolCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL
);
GO

-- Scope Type (In Scope, Out of Scope)
CREATE TABLE dbo.LU_ScopeType (
    ScopeTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(20) NOT NULL UNIQUE,
    TypeName NVARCHAR(50) NOT NULL
);
GO

-- Interaction Level (HIGH, MEDIUM, LOW)
CREATE TABLE dbo.LU_InteractionLevel (
    InteractionLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

-- Requirement Level (Required, Recommended, Optional)
CREATE TABLE dbo.LU_RequirementLevel (
    RequirementLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

-- Roles
CREATE TABLE dbo.LU_Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode NVARCHAR(50) NOT NULL UNIQUE,
    RoleName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- ============================================
-- MAIN SERVICE CATALOG ITEM TABLE
-- ============================================

CREATE TABLE dbo.ServiceCatalogItem (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceCode NVARCHAR(50) NOT NULL UNIQUE,
    ServiceName NVARCHAR(200) NOT NULL,
    Version NVARCHAR(20) NOT NULL DEFAULT 'v1.0',
    CategoryID INT NOT NULL REFERENCES dbo.LU_ServiceCategory(CategoryID),
    Description NVARCHAR(MAX) NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(100) NULL
);
GO

CREATE INDEX IX_ServiceCatalogItem_Category ON dbo.ServiceCatalogItem(CategoryID);
GO

CREATE INDEX IX_ServiceCatalogItem_Active ON dbo.ServiceCatalogItem(IsActive);
GO

-- ============================================
-- USAGE SCENARIOS
-- ============================================

CREATE TABLE dbo.UsageScenario (
    ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScenarioNumber INT NOT NULL,
    ScenarioTitle NVARCHAR(200) NOT NULL,
    ScenarioDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_UsageScenario_Service ON dbo.UsageScenario(ServiceID);
GO

-- ============================================
-- DEPENDENCIES
-- ============================================

CREATE TABLE dbo.ServiceDependency (
    DependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    DependencyTypeID INT NOT NULL REFERENCES dbo.LU_DependencyType(DependencyTypeID),
    DependentServiceID INT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID),
    DependentServiceName NVARCHAR(200) NOT NULL,
    RequirementLevelID INT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceDependency_Service ON dbo.ServiceDependency(ServiceID);
GO

CREATE INDEX IX_ServiceDependency_Type ON dbo.ServiceDependency(DependencyTypeID);
GO

-- ============================================
-- SCOPE (IN SCOPE / OUT OF SCOPE)
-- ============================================

CREATE TABLE dbo.ServiceScopeCategory (
    ScopeCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeTypeID INT NOT NULL REFERENCES dbo.LU_ScopeType(ScopeTypeID),
    CategoryNumber INT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceScopeCategory_Service ON dbo.ServiceScopeCategory(ServiceID);
GO

CREATE TABLE dbo.ServiceScopeItem (
    ScopeItemID INT IDENTITY(1,1) PRIMARY KEY,
    ScopeCategoryID INT NOT NULL REFERENCES dbo.ServiceScopeCategory(ScopeCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceScopeItem_Category ON dbo.ServiceScopeItem(ScopeCategoryID);
GO

-- ============================================
-- PREREQUISITES
-- ============================================

CREATE TABLE dbo.ServicePrerequisite (
    PrerequisiteID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PrerequisiteCategoryID INT NOT NULL REFERENCES dbo.LU_PrerequisiteCategory(PrerequisiteCategoryID),
    PrerequisiteDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServicePrerequisite_Service ON dbo.ServicePrerequisite(ServiceID);
GO

-- ============================================
-- REQUIRED TOOLS & FRAMEWORKS
-- ============================================

CREATE TABLE dbo.CloudProviderCapability (
    CapabilityID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CloudProviderID INT NOT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),
    CapabilityType NVARCHAR(100) NOT NULL,
    CapabilityName NVARCHAR(200) NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_CloudProviderCapability_Service ON dbo.CloudProviderCapability(ServiceID);
GO

CREATE TABLE dbo.ServiceToolFramework (
    ToolFrameworkID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ToolCategoryID INT NOT NULL REFERENCES dbo.LU_ToolCategory(ToolCategoryID),
    ToolName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceToolFramework_Service ON dbo.ServiceToolFramework(ServiceID);
GO

-- ============================================
-- LICENSES
-- ============================================

CREATE TABLE dbo.ServiceLicense (
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    LicenseTypeID INT NOT NULL REFERENCES dbo.LU_LicenseType(LicenseTypeID),
    LicenseDescription NVARCHAR(MAX) NOT NULL,
    CloudProviderID INT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceLicense_Service ON dbo.ServiceLicense(ServiceID);
GO

-- ============================================
-- INTERACTION REQUIREMENTS
-- ============================================

CREATE TABLE dbo.ServiceInteraction (
    InteractionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    InteractionLevelID INT NOT NULL REFERENCES dbo.LU_InteractionLevel(InteractionLevelID),
    Notes NVARCHAR(MAX) NULL
);
GO

CREATE UNIQUE INDEX IX_ServiceInteraction_Service ON dbo.ServiceInteraction(ServiceID);
GO

CREATE TABLE dbo.CustomerRequirement (
    RequirementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RequirementDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_CustomerRequirement_Service ON dbo.CustomerRequirement(ServiceID);
GO

CREATE TABLE dbo.AccessRequirement (
    AccessRequirementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RequirementDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_AccessRequirement_Service ON dbo.AccessRequirement(ServiceID);
GO

CREATE TABLE dbo.StakeholderInvolvement (
    InvolvementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    StakeholderRole NVARCHAR(200) NOT NULL,
    InvolvementDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_StakeholderInvolvement_Service ON dbo.StakeholderInvolvement(ServiceID);
GO

-- ============================================
-- SERVICE INPUTS (PARAMETERS)
-- ============================================

CREATE TABLE dbo.ServiceInput (
    InputID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterName NVARCHAR(200) NOT NULL,
    ParameterDescription NVARCHAR(MAX) NOT NULL,
    RequirementLevelID INT NOT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    DataType NVARCHAR(50) NULL,
    DefaultValue NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceInput_Service ON dbo.ServiceInput(ServiceID);
GO

-- ============================================
-- SERVICE OUTPUTS
-- ============================================

CREATE TABLE dbo.ServiceOutputCategory (
    OutputCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CategoryNumber INT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceOutputCategory_Service ON dbo.ServiceOutputCategory(ServiceID);
GO

CREATE TABLE dbo.ServiceOutputItem (
    OutputItemID INT IDENTITY(1,1) PRIMARY KEY,
    OutputCategoryID INT NOT NULL REFERENCES dbo.ServiceOutputCategory(OutputCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceOutputItem_Category ON dbo.ServiceOutputItem(OutputCategoryID);
GO

-- ============================================
-- TIMELINE & PHASES
-- ============================================

CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_TimelinePhase_Service ON dbo.TimelinePhase(ServiceID);
GO

-- ============================================
-- SIZE OPTIONS
-- ============================================

CREATE TABLE dbo.ServiceSizeOption (
    ServiceSizeID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ScopeDescription NVARCHAR(MAX) NULL,
    DurationMin NVARCHAR(50) NULL,
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL,
    EffortHoursMin INT NULL,
    EffortHoursMax INT NULL,
    EffortDisplay NVARCHAR(100) NULL,
    TeamSizeMin INT NULL,
    TeamSizeMax INT NULL,
    TeamSizeDisplay NVARCHAR(100) NULL,
    Complexity NVARCHAR(50) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceSizeOption_Service ON dbo.ServiceSizeOption(ServiceID);
GO

-- Phase Duration per Size
CREATE TABLE dbo.PhaseDurationBySize (
    PhaseDurationID INT IDENTITY(1,1) PRIMARY KEY,
    PhaseID INT NOT NULL REFERENCES dbo.TimelinePhase(PhaseID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    DurationMin NVARCHAR(50) NULL,
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL
);
GO

CREATE INDEX IX_PhaseDurationBySize_Phase ON dbo.PhaseDurationBySize(PhaseID);
GO

-- ============================================
-- SIZING CRITERIA
-- ============================================

CREATE TABLE dbo.SizingCriteria (
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CriteriaName NVARCHAR(200) NOT NULL,
    CriteriaType NVARCHAR(50) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_SizingCriteria_Service ON dbo.SizingCriteria(ServiceID);
GO

CREATE TABLE dbo.SizingCriteriaValue (
    CriteriaValueID INT IDENTITY(1,1) PRIMARY KEY,
    CriteriaID INT NOT NULL REFERENCES dbo.SizingCriteria(CriteriaID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    CriteriaValue NVARCHAR(500) NOT NULL,
    Notes NVARCHAR(500) NULL
);
GO

CREATE INDEX IX_SizingCriteriaValue_Criteria ON dbo.SizingCriteriaValue(CriteriaID);
GO

-- ============================================
-- SIZING PARAMETERS (Scale & Technical Parameters)
-- ============================================

CREATE TABLE dbo.SizingParameter (
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterCategory NVARCHAR(50) NOT NULL,
    ParameterName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_SizingParameter_Service ON dbo.SizingParameter(ServiceID);
GO

CREATE TABLE dbo.SizingParameterValue (
    ParameterValueID INT IDENTITY(1,1) PRIMARY KEY,
    ParameterID INT NOT NULL REFERENCES dbo.SizingParameter(ParameterID) ON DELETE CASCADE,
    ValueCondition NVARCHAR(500) NOT NULL,
    ResultSize NVARCHAR(50) NULL,
    HoursAdjustment INT NULL,
    AdjustmentDisplay NVARCHAR(100) NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_SizingParameterValue_Parameter ON dbo.SizingParameterValue(ParameterID);
GO

-- ============================================
-- EFFORT ESTIMATION
-- ============================================

CREATE TABLE dbo.EffortEstimationItem (
    EstimationItemID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,
    BaseHours INT NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_EffortEstimationItem_Service ON dbo.EffortEstimationItem(ServiceID);
GO

CREATE TABLE dbo.TechnicalComplexityAddition (
    ComplexityAdditionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    AdditionName NVARCHAR(200) NOT NULL,
    Condition NVARCHAR(500) NOT NULL,
    HoursAdded INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_TechnicalComplexityAddition_Service ON dbo.TechnicalComplexityAddition(ServiceID);
GO

-- ============================================
-- SCOPE DEPENDENCIES
-- ============================================

CREATE TABLE dbo.ScopeDependency (
    ScopeDependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,
    RequiredAreas NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ScopeDependency_Service ON dbo.ScopeDependency(ServiceID);
GO

-- ============================================
-- SIZING EXAMPLES
-- ============================================

CREATE TABLE dbo.SizingExample (
    ExampleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ExampleTitle NVARCHAR(200) NOT NULL,
    Scenario NVARCHAR(MAX) NOT NULL,
    Deliverables NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_SizingExample_Service ON dbo.SizingExample(ServiceID);
GO

CREATE TABLE dbo.SizingExampleCharacteristic (
    CharacteristicID INT IDENTITY(1,1) PRIMARY KEY,
    ExampleID INT NOT NULL REFERENCES dbo.SizingExample(ExampleID) ON DELETE CASCADE,
    CharacteristicDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_SizingExampleCharacteristic_Example ON dbo.SizingExampleCharacteristic(ExampleID);
GO

-- ============================================
-- RESPONSIBLE ROLES
-- ============================================

CREATE TABLE dbo.ServiceResponsibleRole (
    ServiceRoleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    IsPrimaryOwner BIT NOT NULL DEFAULT 0,
    Responsibility NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceResponsibleRole_Service ON dbo.ServiceResponsibleRole(ServiceID);
GO

-- ============================================
-- TEAM ALLOCATION
-- ============================================

CREATE TABLE dbo.ServiceTeamAllocation (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    FTEAllocation DECIMAL(3,2) NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceTeamAllocation_Service ON dbo.ServiceTeamAllocation(ServiceID);
GO

-- ============================================
-- MULTI-CLOUD CONSIDERATIONS
-- ============================================

CREATE TABLE dbo.ServiceMultiCloudConsideration (
    ConsiderationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ConsiderationTitle NVARCHAR(200) NOT NULL,
    ConsiderationDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
GO

CREATE INDEX IX_ServiceMultiCloudConsideration_Service ON dbo.ServiceMultiCloudConsideration(ServiceID);
GO

-- ============================================
-- INSERT LOOKUP DATA
-- ============================================

-- Size Options
INSERT INTO dbo.LU_SizeOption (SizeCode, SizeName, SortOrder)
VALUES 
    ('XS', 'Extra Small', 1),
    ('S', 'Small', 2),
    ('M', 'Medium', 3),
    ('L', 'Large', 4),
    ('XL', 'Extra Large', 5);
GO

-- Cloud Providers
INSERT INTO dbo.LU_CloudProvider (ProviderCode, ProviderName)
VALUES 
    ('AWS', 'Amazon Web Services'),
    ('AZURE', 'Microsoft Azure'),
    ('GCP', 'Google Cloud Platform'),
    ('MULTI', 'Multi-Cloud');
GO

-- Dependency Types
INSERT INTO dbo.LU_DependencyType (TypeCode, TypeName, Description)
VALUES 
    ('PREREQUISITE', 'Prerequisite Services', 'Services that must be completed before this service'),
    ('TRIGGERS', 'Triggers For', 'Services that this service triggers or enables'),
    ('PARALLEL', 'Can Run In Parallel', 'Services that can be executed in parallel with this service');
GO

-- Prerequisite Categories
INSERT INTO dbo.LU_PrerequisiteCategory (CategoryCode, CategoryName)
VALUES 
    ('ORGANIZATIONAL', 'Organizational Prerequisites'),
    ('TECHNICAL', 'Technical Prerequisites'),
    ('DOCUMENTATION', 'Documentation Prerequisites');
GO

-- License Types
INSERT INTO dbo.LU_LicenseType (TypeCode, TypeName)
VALUES 
    ('REQUIRED_CUSTOMER', 'Required by Customer'),
    ('RECOMMENDED', 'Recommended/Optional'),
    ('PROVIDED', 'Provided by Service Provider');
GO

-- Tool Categories
INSERT INTO dbo.LU_ToolCategory (CategoryCode, CategoryName)
VALUES 
    ('CLOUD_PLATFORM', 'Cloud Platforms'),
    ('DESIGN_DOC', 'Design & Documentation Tools'),
    ('IAC', 'Infrastructure as Code Reference'),
    ('ASSESSMENT', 'Assessment & Analysis Tools');
GO

-- Scope Types
INSERT INTO dbo.LU_ScopeType (TypeCode, TypeName)
VALUES 
    ('IN_SCOPE', 'In Scope'),
    ('OUT_SCOPE', 'Out of Scope');
GO

-- Interaction Levels
INSERT INTO dbo.LU_InteractionLevel (LevelCode, LevelName, SortOrder)
VALUES 
    ('HIGH', 'High', 1),
    ('MEDIUM', 'Medium', 2),
    ('LOW', 'Low', 3);
GO

-- Requirement Levels
INSERT INTO dbo.LU_RequirementLevel (LevelCode, LevelName, SortOrder)
VALUES 
    ('REQUIRED', 'Required', 1),
    ('RECOMMENDED', 'Recommended', 2),
    ('OPTIONAL', 'Optional', 3);
GO

-- Roles
INSERT INTO dbo.LU_Role (RoleCode, RoleName, Description)
VALUES 
    ('CLOUD_ARCHITECT', 'Cloud Architect', 'Overall architecture design, technical leadership'),
    ('SECURITY_ARCHITECT', 'Security Architect', 'Security architecture design, compliance mapping'),
    ('NETWORK_ARCHITECT', 'Network Architect', 'Network topology design, connectivity patterns'),
    ('PROJECT_MANAGER', 'Project Manager', 'Timeline management, resource coordination'),
    ('SOLUTION_ARCHITECT', 'Solution Architect', 'Solution design and integration'),
    ('DATA_ARCHITECT', 'Data Architect', 'Data architecture and modeling'),
    ('DEVOPS_ENGINEER', 'DevOps Engineer', 'CI/CD and automation design');
GO

-- Service Categories (hierarchical) - using subqueries to avoid IDENTITY value assumptions
-- First insert root category
INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('SERVICES', 'Services', NULL, 'Services', 1);
GO

-- Insert child categories using subquery to get parent ID
INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('ARCHITECTURE', 'Architecture', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'SERVICES'), 
        'Services / Architecture', 1);
GO

INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('ASSESSMENT', 'Assessment', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'SERVICES'), 
        'Services / Assessment', 2);
GO

INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('MIGRATION', 'Migration', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'SERVICES'), 
        'Services / Migration', 3);
GO

INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('OPERATIONS', 'Operations', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'SERVICES'), 
        'Services / Operations', 4);
GO

-- Insert grandchild categories
INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('TECH_ARCH', 'Technical Architecture', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'ARCHITECTURE'), 
        'Services / Architecture / Technical Architecture', 1);
GO

INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES ('SOLUTION_ARCH', 'Solution Architecture', 
        (SELECT CategoryID FROM dbo.LU_ServiceCategory WHERE CategoryCode = 'ARCHITECTURE'), 
        'Services / Architecture / Solution Architecture', 2);
GO

-- ============================================
-- VIEWS FOR EASIER DATA ACCESS
-- ============================================

-- View: Complete Service Overview
CREATE VIEW dbo.vw_ServiceOverview AS
SELECT 
    s.ServiceID,
    s.ServiceCode,
    s.ServiceName,
    s.Version,
    c.CategoryPath AS Category,
    s.Description,
    s.Notes,
    s.IsActive,
    s.CreatedDate,
    s.ModifiedDate,
    (SELECT COUNT(*) FROM dbo.UsageScenario WHERE ServiceID = s.ServiceID) AS UsageScenarioCount,
    (SELECT COUNT(*) FROM dbo.ServiceDependency WHERE ServiceID = s.ServiceID) AS DependencyCount,
    (SELECT COUNT(*) FROM dbo.ServiceInput WHERE ServiceID = s.ServiceID) AS InputCount,
    (SELECT COUNT(*) FROM dbo.ServiceOutputCategory WHERE ServiceID = s.ServiceID) AS OutputCategoryCount
FROM dbo.ServiceCatalogItem s
JOIN dbo.LU_ServiceCategory c ON s.CategoryID = c.CategoryID;
GO

-- View: Service Dependencies with Details
CREATE VIEW dbo.vw_ServiceDependencies AS
SELECT 
    sd.DependencyID,
    s.ServiceCode,
    s.ServiceName,
    dt.TypeName AS DependencyType,
    sd.DependentServiceName,
    ds.ServiceCode AS DependentServiceCode,
    rl.LevelName AS RequirementLevel,
    sd.Notes
FROM dbo.ServiceDependency sd
JOIN dbo.ServiceCatalogItem s ON sd.ServiceID = s.ServiceID
JOIN dbo.LU_DependencyType dt ON sd.DependencyTypeID = dt.DependencyTypeID
LEFT JOIN dbo.ServiceCatalogItem ds ON sd.DependentServiceID = ds.ServiceID
LEFT JOIN dbo.LU_RequirementLevel rl ON sd.RequirementLevelID = rl.RequirementLevelID;
GO

-- View: Service Sizing Summary
CREATE VIEW dbo.vw_ServiceSizing AS
SELECT 
    s.ServiceCode,
    s.ServiceName,
    so.SizeCode,
    so.SizeName,
    sso.ScopeDescription,
    sso.DurationDisplay,
    sso.EffortDisplay,
    sso.TeamSizeDisplay,
    sso.Complexity
FROM dbo.ServiceSizeOption sso
JOIN dbo.ServiceCatalogItem s ON sso.ServiceID = s.ServiceID
JOIN dbo.LU_SizeOption so ON sso.SizeOptionID = so.SizeOptionID;
GO

-- View: Complete Scope Items
CREATE VIEW dbo.vw_ServiceScope AS
SELECT 
    s.ServiceCode,
    s.ServiceName,
    st.TypeName AS ScopeType,
    sc.CategoryNumber,
    sc.CategoryName,
    si.ItemDescription,
    sc.SortOrder AS CategoryOrder,
    si.SortOrder AS ItemOrder
FROM dbo.ServiceScopeItem si
JOIN dbo.ServiceScopeCategory sc ON si.ScopeCategoryID = sc.ScopeCategoryID
JOIN dbo.ServiceCatalogItem s ON sc.ServiceID = s.ServiceID
JOIN dbo.LU_ScopeType st ON sc.ScopeTypeID = st.ScopeTypeID;
GO

PRINT 'Service Catalog Database Structure v1.1.0 created successfully.';
PRINT 'Fixed: Explicit GO batch separators and hierarchical category inserts.';
GO
