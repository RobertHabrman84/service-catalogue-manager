-- ============================================
-- Service Catalog Database Structure
-- Generic structure for all service catalog items
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

-- ============================================
-- LOOKUP TABLES
-- ============================================

-- Service Categories (e.g., Services / Architecture / Technical Architecture)
CREATE TABLE dbo.LU_ServiceCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,                                                 -- Category description
    ParentCategoryID INT NULL REFERENCES dbo.LU_ServiceCategory(CategoryID),
    CategoryPath NVARCHAR(500) NULL, -- Full path like "Services / Architecture / Technical Architecture"
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Size Options (S, M, L, XL, etc.)
CREATE TABLE dbo.LU_SizeOption (
    SizeOptionID INT IDENTITY(1,1) PRIMARY KEY,
    SizeCode NVARCHAR(10) NOT NULL UNIQUE,
    SizeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Cloud Providers
CREATE TABLE dbo.LU_CloudProvider (
    CloudProviderID INT IDENTITY(1,1) PRIMARY KEY,
    ProviderCode NVARCHAR(20) NOT NULL UNIQUE,
    ProviderName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Dependency Types (Prerequisite, Triggers for, Parallel)
CREATE TABLE dbo.LU_DependencyType (
    DependencyTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Prerequisite Categories (Organizational, Technical, Documentation)
CREATE TABLE dbo.LU_PrerequisiteCategory (
    PrerequisiteCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- License Types (Required by Customer, Recommended/Optional, Provided by Service Provider)
CREATE TABLE dbo.LU_LicenseType (
    LicenseTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Tool Categories (Cloud Platforms, Design & Documentation, IaC, Assessment & Analysis)
CREATE TABLE dbo.LU_ToolCategory (
    ToolCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Scope Type (In Scope, Out of Scope)
CREATE TABLE dbo.LU_ScopeType (
    ScopeTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(20) NOT NULL UNIQUE,
    TypeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Interaction Level (HIGH, MEDIUM, LOW)
CREATE TABLE dbo.LU_InteractionLevel (
    InteractionLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Requirement Level (Required, Recommended, Optional)
CREATE TABLE dbo.LU_RequirementLevel (
    RequirementLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Roles
CREATE TABLE dbo.LU_Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode NVARCHAR(50) NOT NULL UNIQUE,
    RoleName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Effort Categories
CREATE TABLE dbo.LU_EffortCategory (
    EffortCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- ============================================
-- MAIN SERVICE CATALOG ITEM TABLE
-- ============================================

CREATE TABLE dbo.ServiceCatalogItem (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceCode NVARCHAR(50) NOT NULL UNIQUE,           -- e.g., "ID0XX"
    ServiceName NVARCHAR(200) NOT NULL,                  -- e.g., "Application Landing Zone Design"
    Version NVARCHAR(20) NOT NULL DEFAULT 'v1.0',
    CategoryID INT NOT NULL REFERENCES dbo.LU_ServiceCategory(CategoryID),
    Description NVARCHAR(MAX) NOT NULL,
    Notes NVARCHAR(MAX) NULL,                            -- Additional notes
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(100) NULL
);

CREATE INDEX IX_ServiceCatalogItem_Category ON dbo.ServiceCatalogItem(CategoryID);
CREATE INDEX IX_ServiceCatalogItem_Active ON dbo.ServiceCatalogItem(IsActive);

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

CREATE INDEX IX_UsageScenario_Service ON dbo.UsageScenario(ServiceID);

-- ============================================
-- DEPENDENCIES
-- ============================================

CREATE TABLE dbo.ServiceDependency (
    DependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    DependencyTypeID INT NOT NULL REFERENCES dbo.LU_DependencyType(DependencyTypeID),
    DependencyName NVARCHAR(200) NULL,                                         -- Friendly name for the dependency
    DependencyDescription NVARCHAR(MAX) NULL,                                  -- Detailed description
    DependentServiceID INT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID),  -- NULL if external service
    DependentServiceCode NVARCHAR(50) NULL,                                    -- Service code for lookup/reference
    DependentServiceName NVARCHAR(200) NOT NULL,                               -- Name for display/external services
    RequirementLevelID INT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceDependency_Service ON dbo.ServiceDependency(ServiceID);
CREATE INDEX IX_ServiceDependency_Type ON dbo.ServiceDependency(DependencyTypeID);

-- ============================================
-- SCOPE (IN SCOPE / OUT OF SCOPE)
-- ============================================

-- Scope Categories (e.g., Platform Architecture, Network Architecture, etc.)
CREATE TABLE dbo.ServiceScopeCategory (
    ScopeCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeTypeID INT NOT NULL REFERENCES dbo.LU_ScopeType(ScopeTypeID),
    CategoryNumber INT NULL,                             -- e.g., 1, 2, 3 for numbered categories
    CategoryName NVARCHAR(200) NOT NULL,                 -- e.g., "Platform Architecture"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceScopeCategory_Service ON dbo.ServiceScopeCategory(ServiceID);

-- Scope Items (individual items within each category)
CREATE TABLE dbo.ServiceScopeItem (
    ScopeItemID INT IDENTITY(1,1) PRIMARY KEY,
    ScopeCategoryID INT NOT NULL REFERENCES dbo.ServiceScopeCategory(ScopeCategoryID) ON DELETE CASCADE,
    ItemName NVARCHAR(500) NOT NULL DEFAULT '',
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceScopeItem_Category ON dbo.ServiceScopeItem(ScopeCategoryID);

-- ============================================
-- PREREQUISITES
-- ============================================

CREATE TABLE dbo.ServicePrerequisite (
    PrerequisiteID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PrerequisiteCategoryID INT NOT NULL REFERENCES dbo.LU_PrerequisiteCategory(PrerequisiteCategoryID),
    PrerequisiteName NVARCHAR(MAX) NOT NULL,
    PrerequisiteDescription NVARCHAR(MAX) NOT NULL DEFAULT '',
    Description NVARCHAR(MAX) NULL,
    RequirementLevelID INT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    SortOrder INT NOT NULL DEFAULT 0,
    -- Audit fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(MAX) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(MAX) NULL
);

CREATE INDEX IX_ServicePrerequisite_Service ON dbo.ServicePrerequisite(ServiceID);
CREATE INDEX IX_ServicePrerequisite_RequirementLevel ON dbo.ServicePrerequisite(RequirementLevelID);

-- ============================================
-- REQUIRED TOOLS & FRAMEWORKS
-- ============================================

-- Cloud Provider Capabilities (Reference Architecture, Landing Zone Accelerator, etc.)
CREATE TABLE dbo.CloudProviderCapability (
    CapabilityID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CloudProviderID INT NOT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),
    CapabilityType NVARCHAR(100) NOT NULL,              -- e.g., "Reference Architecture", "Landing Zone Accelerator"
    CapabilityName NVARCHAR(200) NOT NULL,              -- e.g., "AWS Well-Architected Framework"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_CloudProviderCapability_Service ON dbo.CloudProviderCapability(ServiceID);

-- Tools and Frameworks (IaC Frameworks, Module Libraries, etc.)
CREATE TABLE dbo.ServiceToolFramework (
    ToolFrameworkID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ToolCategoryID INT NOT NULL REFERENCES dbo.LU_ToolCategory(ToolCategoryID),
    ToolName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceToolFramework_Service ON dbo.ServiceToolFramework(ServiceID);

-- ============================================
-- LICENSES
-- ============================================

CREATE TABLE dbo.ServiceLicense (
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    LicenseTypeID INT NOT NULL REFERENCES dbo.LU_LicenseType(LicenseTypeID),
    LicenseDescription NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(MAX) NULL,                                                -- Additional description/notes
    CloudProviderID INT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),    -- Optional, if specific to a cloud
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceLicense_Service ON dbo.ServiceLicense(ServiceID);

-- ============================================
-- INTERACTION REQUIREMENTS
-- ============================================

CREATE TABLE dbo.ServiceInteraction (
    InteractionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    InteractionLevelID INT NOT NULL REFERENCES dbo.LU_InteractionLevel(InteractionLevelID),
    Notes NVARCHAR(MAX) NULL
);

CREATE UNIQUE INDEX IX_ServiceInteraction_Service ON dbo.ServiceInteraction(ServiceID);

-- Customer Requirements (Customer Must Provide)
CREATE TABLE dbo.CustomerRequirement (
    RequirementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RequirementDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_CustomerRequirement_Service ON dbo.CustomerRequirement(ServiceID);

-- Access Requirements
CREATE TABLE dbo.AccessRequirement (
    AccessRequirementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RequirementDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_AccessRequirement_Service ON dbo.AccessRequirement(ServiceID);

-- Stakeholder Involvement
CREATE TABLE dbo.StakeholderInvolvement (
    InvolvementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    StakeholderRole NVARCHAR(200) NOT NULL,             -- e.g., "CTO/CIO or delegate"
    InvolvementDescription NVARCHAR(MAX) NOT NULL,      -- e.g., "Kick-off, key decision points, final sign-off"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_StakeholderInvolvement_Service ON dbo.StakeholderInvolvement(ServiceID);

-- ============================================
-- SERVICE INPUTS (PARAMETERS)
-- ============================================

CREATE TABLE dbo.ServiceInput (
    InputID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterName NVARCHAR(200) NOT NULL,
    ParameterDescription NVARCHAR(MAX) NOT NULL,
    RequirementLevelID INT NOT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    DataType NVARCHAR(50) NULL,                         -- e.g., "Text", "Number", "List", "Boolean"
    DefaultValue NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceInput_Service ON dbo.ServiceInput(ServiceID);

-- ============================================
-- SERVICE OUTPUTS
-- ============================================

-- Output Categories (e.g., "Technical Architecture Design Document")
CREATE TABLE dbo.ServiceOutputCategory (
    OutputCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CategoryNumber INT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceOutputCategory_Service ON dbo.ServiceOutputCategory(ServiceID);

-- Output Items (individual deliverables within each category)
CREATE TABLE dbo.ServiceOutputItem (
    OutputItemID INT IDENTITY(1,1) PRIMARY KEY,
    OutputCategoryID INT NOT NULL REFERENCES dbo.ServiceOutputCategory(OutputCategoryID) ON DELETE CASCADE,
    ItemName NVARCHAR(500) NOT NULL DEFAULT '',
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceOutputItem_Category ON dbo.ServiceOutputItem(OutputCategoryID);

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

CREATE INDEX IX_TimelinePhase_Service ON dbo.TimelinePhase(ServiceID);

-- Phase Duration by Size (added as separate table for flexibility)
-- This will be handled through ServiceSizeOption

-- ============================================
-- SIZE OPTIONS
-- ============================================

CREATE TABLE dbo.ServiceSizeOption (
    ServiceSizeID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ScopeDescription NVARCHAR(MAX) NULL,                -- Description of what this size covers
    DurationMin NVARCHAR(50) NULL,                      -- e.g., "2 weeks" or "2-3 weeks"
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL,                 -- e.g., "2-3 weeks"
    EffortHoursMin INT NULL,
    EffortHoursMax INT NULL,
    EffortDisplay NVARCHAR(100) NULL,                   -- e.g., "40-60 hours"
    TeamSizeMin INT NULL,
    TeamSizeMax INT NULL,
    TeamSizeDisplay NVARCHAR(100) NULL,                 -- e.g., "1-2 resources"
    Complexity NVARCHAR(50) NULL,                       -- e.g., "Low", "Medium", "High"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceSizeOption_Service ON dbo.ServiceSizeOption(ServiceID);

-- Phase Duration per Size
CREATE TABLE dbo.PhaseDurationBySize (
    PhaseDurationID INT IDENTITY(1,1) PRIMARY KEY,
    PhaseID INT NOT NULL REFERENCES dbo.TimelinePhase(PhaseID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    DurationMin NVARCHAR(50) NULL,
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL                  -- e.g., "2-3 days"
);

CREATE INDEX IX_PhaseDurationBySize_Phase ON dbo.PhaseDurationBySize(PhaseID);

-- ============================================
-- SIZING CRITERIA
-- ============================================

CREATE TABLE dbo.SizingCriteria (
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CriteriaName NVARCHAR(200) NOT NULL,                -- e.g., "Number of applications"
    CriteriaType NVARCHAR(50) NULL,                     -- e.g., "Scale", "Technical"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_SizingCriteria_Service ON dbo.SizingCriteria(ServiceID);

-- Criteria Values per Size
CREATE TABLE dbo.SizingCriteriaValue (
    CriteriaValueID INT IDENTITY(1,1) PRIMARY KEY,
    CriteriaID INT NOT NULL REFERENCES dbo.SizingCriteria(CriteriaID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    CriteriaValue NVARCHAR(500) NOT NULL,               -- e.g., "1", "2-5", "6+"
    Notes NVARCHAR(500) NULL
);

CREATE INDEX IX_SizingCriteriaValue_Criteria ON dbo.SizingCriteriaValue(CriteriaID);

-- ============================================
-- SIZING PARAMETERS (Scale & Technical Parameters)
-- ============================================

CREATE TABLE dbo.SizingParameter (
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterCategory NVARCHAR(50) NOT NULL,            -- "Scale" or "Technical"
    ParameterName NVARCHAR(200) NOT NULL,               -- e.g., "Number of Applications", "Hybrid Connectivity"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_SizingParameter_Service ON dbo.SizingParameter(ServiceID);

-- Parameter Values (e.g., "1 application: Size S" or "+16 hours")
CREATE TABLE dbo.SizingParameterValue (
    ParameterValueID INT IDENTITY(1,1) PRIMARY KEY,
    ParameterID INT NOT NULL REFERENCES dbo.SizingParameter(ParameterID) ON DELETE CASCADE,
    ValueCondition NVARCHAR(500) NOT NULL,              -- e.g., "1 application", "ExpressRoute/Direct Connect required"
    ResultSize NVARCHAR(50) NULL,                       -- e.g., "Size S", "Size M"
    HoursAdjustment INT NULL,                           -- e.g., 16, -8
    AdjustmentDisplay NVARCHAR(100) NULL,               -- e.g., "+16 hours", "baseline"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_SizingParameterValue_Parameter ON dbo.SizingParameterValue(ParameterID);

-- ============================================
-- EFFORT ESTIMATION
-- ============================================

CREATE TABLE dbo.EffortEstimationItem (
    EstimationItemID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Platform Architecture", "Network Architecture"
    BaseHours INT NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_EffortEstimationItem_Service ON dbo.EffortEstimationItem(ServiceID);

-- Technical Complexity Additions
CREATE TABLE dbo.TechnicalComplexityAddition (
    ComplexityAdditionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    AdditionName NVARCHAR(200) NOT NULL,                -- e.g., "Hybrid connectivity"
    Condition NVARCHAR(500) NOT NULL,                   -- e.g., "On-premises integration required"
    HoursAdded INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_TechnicalComplexityAddition_Service ON dbo.TechnicalComplexityAddition(ServiceID);

-- ============================================
-- SCOPE DEPENDENCIES
-- ============================================

CREATE TABLE dbo.ScopeDependency (
    ScopeDependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Container Platform Design"
    RequiredAreas NVARCHAR(MAX) NOT NULL,               -- e.g., "Compute Architecture, Network Architecture"
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ScopeDependency_Service ON dbo.ScopeDependency(ServiceID);

-- ============================================
-- SIZING EXAMPLES
-- ============================================

CREATE TABLE dbo.SizingExample (
    ExampleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ExampleTitle NVARCHAR(200) NOT NULL,                -- e.g., "Single PaaS Web Application Landing Zone"
    Scenario NVARCHAR(MAX) NOT NULL,
    Deliverables NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_SizingExample_Service ON dbo.SizingExample(ServiceID);

-- Example Characteristics
CREATE TABLE dbo.SizingExampleCharacteristic (
    CharacteristicID INT IDENTITY(1,1) PRIMARY KEY,
    ExampleID INT NOT NULL REFERENCES dbo.SizingExample(ExampleID) ON DELETE CASCADE,
    CharacteristicDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_SizingExampleCharacteristic_Example ON dbo.SizingExampleCharacteristic(ExampleID);

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

CREATE INDEX IX_ServiceResponsibleRole_Service ON dbo.ServiceResponsibleRole(ServiceID);

-- ============================================
-- TEAM ALLOCATION
-- ============================================

CREATE TABLE dbo.ServiceTeamAllocation (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    FTEAllocation DECIMAL(3,2) NOT NULL,                -- e.g., 0.80, 1.00
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceTeamAllocation_Service ON dbo.ServiceTeamAllocation(ServiceID);

-- ============================================
-- MULTI-CLOUD CONSIDERATIONS
-- ============================================

CREATE TABLE dbo.ServiceMultiCloudConsideration (
    ConsiderationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ConsiderationTitle NVARCHAR(200) NOT NULL,          -- e.g., "Design Pattern Abstraction"
    ConsiderationDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE INDEX IX_ServiceMultiCloudConsideration_Service ON dbo.ServiceMultiCloudConsideration(ServiceID);

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

-- Cloud Providers
INSERT INTO dbo.LU_CloudProvider (ProviderCode, ProviderName)
VALUES 
    ('AWS', 'Amazon Web Services'),
    ('AZURE', 'Microsoft Azure'),
    ('GCP', 'Google Cloud Platform'),
    ('MULTI', 'Multi-Cloud');

-- Dependency Types
INSERT INTO dbo.LU_DependencyType (TypeCode, TypeName, Description)
VALUES 
    ('PREREQUISITE', 'Prerequisite Services', 'Services that must be completed before this service'),
    ('TRIGGERS', 'Triggers For', 'Services that this service triggers or enables'),
    ('PARALLEL', 'Can Run In Parallel', 'Services that can be executed in parallel with this service');

-- Prerequisite Categories
INSERT INTO dbo.LU_PrerequisiteCategory (CategoryCode, CategoryName)
VALUES 
    ('ORGANIZATIONAL', 'Organizational Prerequisites'),
    ('TECHNICAL', 'Technical Prerequisites'),
    ('DOCUMENTATION', 'Documentation Prerequisites');

-- License Types
INSERT INTO dbo.LU_LicenseType (TypeCode, TypeName)
VALUES 
    ('REQUIRED_CUSTOMER', 'Required by Customer'),
    ('RECOMMENDED', 'Recommended/Optional'),
    ('PROVIDED', 'Provided by Service Provider');

-- Tool Categories
INSERT INTO dbo.LU_ToolCategory (CategoryCode, CategoryName)
VALUES 
    ('CLOUD_PLATFORM', 'Cloud Platforms'),
    ('DESIGN_DOC', 'Design & Documentation Tools'),
    ('IAC', 'Infrastructure as Code Reference'),
    ('ASSESSMENT', 'Assessment & Analysis Tools');

-- Scope Types
INSERT INTO dbo.LU_ScopeType (TypeCode, TypeName)
VALUES 
    ('IN_SCOPE', 'In Scope'),
    ('OUT_SCOPE', 'Out of Scope');

-- Interaction Levels
INSERT INTO dbo.LU_InteractionLevel (LevelCode, LevelName, SortOrder)
VALUES 
    ('HIGH', 'High', 1),
    ('MEDIUM', 'Medium', 2),
    ('LOW', 'Low', 3);

-- Requirement Levels
INSERT INTO dbo.LU_RequirementLevel (LevelCode, LevelName, SortOrder)
VALUES 
    ('REQUIRED', 'Required', 1),
    ('RECOMMENDED', 'Recommended', 2),
    ('OPTIONAL', 'Optional', 3);

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

-- Service Categories (hierarchical)
INSERT INTO dbo.LU_ServiceCategory (CategoryCode, CategoryName, ParentCategoryID, CategoryPath, SortOrder)
VALUES 
    ('SERVICES', 'Services', NULL, 'Services', 1),
    ('ARCHITECTURE', 'Architecture', 1, 'Services / Architecture', 1),
    ('TECH_ARCH', 'Technical Architecture', 2, 'Services / Architecture / Technical Architecture', 1),
    ('SOLUTION_ARCH', 'Solution Architecture', 2, 'Services / Architecture / Solution Architecture', 2),
    ('ASSESSMENT', 'Assessment', 1, 'Services / Assessment', 2),
    ('MIGRATION', 'Migration', 1, 'Services / Migration', 3),
    ('OPERATIONS', 'Operations', 1, 'Services / Operations', 4);

GO

-- ============================================
-- VIEWS FOR EASIER DATA ACCESS
-- ============================================

-- View: Complete Service Overview
CREATE OR ALTER VIEW dbo.vw_ServiceOverview AS
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
CREATE OR ALTER VIEW dbo.vw_ServiceDependencies AS
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
CREATE OR ALTER VIEW dbo.vw_ServiceSizing AS
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
CREATE OR ALTER VIEW dbo.vw_ServiceScope AS
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

PRINT 'Service Catalog Database Structure created successfully.';
GO
-- ============================================
-- ALTER TABLES - Add Missing Columns
-- Added: 2026-01-29
-- Purpose: Add BaseEntity audit fields and missing columns to match C# entities
-- ============================================

PRINT 'Adding missing BaseEntity audit columns...';
GO

-- ============================================
-- ServiceInput - Add missing columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceInput') AND name = 'InputName')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD InputName NVARCHAR(200) NOT NULL DEFAULT '';
    PRINT 'Added InputName to ServiceInput';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceInput') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD Description NVARCHAR(MAX) NULL;
    PRINT 'Added Description to ServiceInput';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceInput') AND name = 'ExampleValue')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD ExampleValue NVARCHAR(MAX) NULL;
    PRINT 'Added ExampleValue to ServiceInput';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceInput') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceInput ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceInput';
END
GO

-- ============================================
-- UsageScenario - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.UsageScenario') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.UsageScenario ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to UsageScenario';
END
GO

-- ============================================
-- ServiceDependency - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceDependency') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceDependency ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceDependency';
END
GO

-- ============================================
-- ServiceScopeCategory - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceScopeCategory') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceScopeCategory ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceScopeCategory';
END
GO

-- ============================================
-- ServiceScopeItem - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceScopeItem') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceScopeItem ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceScopeItem';
END
GO

-- ============================================
-- ServicePrerequisite - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServicePrerequisite') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServicePrerequisite ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServicePrerequisite';
END
GO

-- ============================================
-- CloudProviderCapability - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CloudProviderCapability') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.CloudProviderCapability ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to CloudProviderCapability';
END
GO

-- ============================================
-- ServiceToolFramework - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceToolFramework') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceToolFramework ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceToolFramework';
END
GO

-- ============================================
-- ServiceLicense - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceLicense') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceLicense ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceLicense';
END
GO

-- ============================================
-- ServiceInteraction - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceInteraction') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceInteraction ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceInteraction';
END
GO

-- ============================================
-- CustomerRequirement - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CustomerRequirement') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.CustomerRequirement ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to CustomerRequirement';
END
GO

-- ============================================
-- AccessRequirement - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AccessRequirement') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.AccessRequirement ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to AccessRequirement';
END
GO

-- ============================================
-- StakeholderInvolvement - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StakeholderInvolvement') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.StakeholderInvolvement ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to StakeholderInvolvement';
END
GO

-- ============================================
-- ServiceOutputCategory - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceOutputCategory') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceOutputCategory ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceOutputCategory';
END
GO

-- ============================================
-- ServiceOutputItem - Add missing ItemName column
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceOutputItem') AND name = 'ItemName')
BEGIN
    ALTER TABLE dbo.ServiceOutputItem ADD ItemName NVARCHAR(200) NOT NULL DEFAULT '';
    PRINT 'Added ItemName to ServiceOutputItem';
END
GO

-- ============================================
-- ServiceOutputItem - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceOutputItem') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceOutputItem ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceOutputItem';
END
GO

-- ============================================
-- TimelinePhase - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TimelinePhase') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.TimelinePhase ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to TimelinePhase';
END
GO

-- ============================================
-- PhaseDurationBySize - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PhaseDurationBySize') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.PhaseDurationBySize ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to PhaseDurationBySize';
END
GO

-- ============================================
-- ServiceSizeOption - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceSizeOption') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceSizeOption ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceSizeOption';
END
GO

-- ============================================
-- SizingCriteria - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingCriteria') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingCriteria ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingCriteria';
END
GO

-- ============================================
-- SizingCriteriaValue - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingCriteriaValue') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingCriteriaValue ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingCriteriaValue';
END
GO

-- ============================================
-- SizingParameter - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingParameter') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingParameter ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingParameter';
END
GO

-- ============================================
-- SizingParameterValue - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingParameterValue') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingParameterValue ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingParameterValue';
END
GO

-- ============================================
-- EffortEstimationItem - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.EffortEstimationItem') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.EffortEstimationItem ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to EffortEstimationItem';
END
GO

-- ============================================
-- TechnicalComplexityAddition - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TechnicalComplexityAddition') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.TechnicalComplexityAddition ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to TechnicalComplexityAddition';
END
GO

-- ============================================
-- ScopeDependency - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ScopeDependency') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ScopeDependency ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ScopeDependency';
END
GO

-- ============================================
-- SizingExample - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingExample') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingExample ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingExample';
END
GO

-- ============================================
-- SizingExampleCharacteristic - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SizingExampleCharacteristic') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.SizingExampleCharacteristic ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to SizingExampleCharacteristic';
END
GO

-- ============================================
-- ServiceResponsibleRole - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceResponsibleRole') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceResponsibleRole ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceResponsibleRole';
END
GO

-- ============================================
-- ServiceTeamAllocation - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceTeamAllocation') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceTeamAllocation ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceTeamAllocation';
END
GO

-- ============================================
-- ServiceMultiCloudConsideration - Add BaseEntity audit columns
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ServiceMultiCloudConsideration') AND name = 'CreatedBy')
BEGIN
    ALTER TABLE dbo.ServiceMultiCloudConsideration ADD 
        CreatedBy NVARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy NVARCHAR(100) NULL,
        ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added audit columns to ServiceMultiCloudConsideration';
END
GO

PRINT 'All missing BaseEntity audit columns added successfully.';
GO
