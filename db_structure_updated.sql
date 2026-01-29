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
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Cloud Providers
CREATE TABLE dbo.LU_CloudProvider (
    CloudProviderID INT IDENTITY(1,1) PRIMARY KEY,
    ProviderCode NVARCHAR(20) NOT NULL UNIQUE,
    ProviderName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Dependency Types (Prerequisite, Triggers for, Parallel)
CREATE TABLE dbo.LU_DependencyType (
    DependencyTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL
);

-- Prerequisite Categories (Organizational, Technical, Documentation)
CREATE TABLE dbo.LU_PrerequisiteCategory (
    PrerequisiteCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL
);

-- License Types (Required by Customer, Recommended/Optional, Provided by Service Provider)
CREATE TABLE dbo.LU_LicenseType (
    LicenseTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(50) NOT NULL UNIQUE,
    TypeName NVARCHAR(100) NOT NULL
);

-- Tool Categories (Cloud Platforms, Design & Documentation, IaC, Assessment & Analysis)
CREATE TABLE dbo.LU_ToolCategory (
    ToolCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL
);

-- Scope Type (In Scope, Out of Scope)
CREATE TABLE dbo.LU_ScopeType (
    ScopeTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(20) NOT NULL UNIQUE,
    TypeName NVARCHAR(50) NOT NULL
);

-- Interaction Level (HIGH, MEDIUM, LOW)
CREATE TABLE dbo.LU_InteractionLevel (
    InteractionLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

-- Requirement Level (Required, Recommended, Optional)
CREATE TABLE dbo.LU_RequirementLevel (
    RequirementLevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

-- Roles
CREATE TABLE dbo.LU_Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode NVARCHAR(50) NOT NULL UNIQUE,
    RoleName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
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

CREATE TABLE 
    ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScenarioNumber INT NOT NULL,
    ScenarioTitle NVARCHAR(200) NOT NULL,
    ScenarioDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.UsageScenario (
    ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScenarioNumber INT NOT NULL,
    ScenarioTitle NVARCHAR(200) NOT NULL,
    ScenarioDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_UsageScenario_Service ON dbo.UsageScenario(ServiceID);

-- ============================================
-- DEPENDENCIES
-- ============================================

CREATE TABLE dbo.ServiceDependency (
    DependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    DependencyTypeID INT NOT NULL REFERENCES dbo.LU_DependencyType(DependencyTypeID),
    DependentServiceID INT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID), -- NULL if external service
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
CREATE TABLE 
    ScopeItemID INT IDENTITY(1,1) PRIMARY KEY,
    ScopeCategoryID INT NOT NULL REFERENCES dbo.ServiceScopeCategory(ScopeCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceScopeItem (
    ScopeItemID INT IDENTITY(1,1) PRIMARY KEY,
    ScopeCategoryID INT NOT NULL REFERENCES dbo.ServiceScopeCategory(ScopeCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceScopeItem_Category ON dbo.ServiceScopeItem(ScopeCategoryID);

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

CREATE INDEX IX_ServicePrerequisite_Service ON dbo.ServicePrerequisite(ServiceID);

-- ============================================
-- REQUIRED TOOLS & FRAMEWORKS
-- ============================================

-- Cloud Provider Capabilities (Reference Architecture, Landing Zone Accelerator, etc.)
CREATE TABLE 
    CapabilityID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CloudProviderID INT NOT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),
    CapabilityType NVARCHAR(100) NOT NULL,              -- e.g., "Reference Architecture", "Landing Zone Accelerator"
    CapabilityName NVARCHAR(200) NOT NULL,              -- e.g., "AWS Well-Architected Framework"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.CloudProviderCapability (
    CapabilityID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CloudProviderID INT NOT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID),
    CapabilityType NVARCHAR(100) NOT NULL,              -- e.g., "Reference Architecture", "Landing Zone Accelerator"
    CapabilityName NVARCHAR(200) NOT NULL,              -- e.g., "AWS Well-Architected Framework"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_CloudProviderCapability_Service ON dbo.CloudProviderCapability(ServiceID);

-- Tools and Frameworks (IaC Frameworks, Module Libraries, etc.)
CREATE TABLE 
    ToolFrameworkID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ToolCategoryID INT NOT NULL REFERENCES dbo.LU_ToolCategory(ToolCategoryID),
    ToolName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceToolFramework (
    ToolFrameworkID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ToolCategoryID INT NOT NULL REFERENCES dbo.LU_ToolCategory(ToolCategoryID),
    ToolName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceToolFramework_Service ON dbo.ServiceToolFramework(ServiceID);

-- ============================================
-- LICENSES
-- ============================================

CREATE TABLE 
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    LicenseTypeID INT NOT NULL REFERENCES dbo.LU_LicenseType(LicenseTypeID),
    LicenseDescription NVARCHAR(MAX) NOT NULL,
    CloudProviderID INT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID), -- Optional, if specific to a cloud
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceLicense (
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    LicenseTypeID INT NOT NULL REFERENCES dbo.LU_LicenseType(LicenseTypeID),
    LicenseDescription NVARCHAR(MAX) NOT NULL,
    CloudProviderID INT NULL REFERENCES dbo.LU_CloudProvider(CloudProviderID), -- Optional, if specific to a cloud
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
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
CREATE TABLE 
    InvolvementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    StakeholderRole NVARCHAR(200) NOT NULL,             -- e.g., "CTO/CIO or delegate"
    InvolvementDescription NVARCHAR(MAX) NOT NULL,      -- e.g., "Kick-off, key decision points, final sign-off"
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.StakeholderInvolvement (
    InvolvementID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    StakeholderRole NVARCHAR(200) NOT NULL,             -- e.g., "CTO/CIO or delegate"
    InvolvementDescription NVARCHAR(MAX) NOT NULL,      -- e.g., "Kick-off, key decision points, final sign-off"
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_StakeholderInvolvement_Service ON dbo.StakeholderInvolvement(ServiceID);

-- ============================================
-- SERVICE INPUTS (PARAMETERS)
-- ============================================

CREATE TABLE 
    InputID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterName NVARCHAR(200) NOT NULL,
    ParameterDescription NVARCHAR(MAX) NOT NULL,
    RequirementLevelID INT NOT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    DataType NVARCHAR(50) NULL,                         -- e.g., "Text", "Number", "List", "Boolean"
    DefaultValue NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceInput (
    InputID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    InputName NVARCHAR(200) NOT NULL DEFAULT '',
    ParameterName NVARCHAR(200) NOT NULL,
    ParameterDescription NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RequirementLevelID INT NOT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    DataType NVARCHAR(50) NULL,
    DefaultValue NVARCHAR(500) NULL,
    ExampleValue NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceInput_Service ON dbo.ServiceInput(ServiceID);

-- ============================================
-- SERVICE OUTPUTS
-- ============================================

-- Output Categories (e.g., "Technical Architecture Design Document")
CREATE TABLE 
    OutputCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CategoryNumber INT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceOutputCategory (
    OutputCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CategoryNumber INT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceOutputCategory_Service ON dbo.ServiceOutputCategory(ServiceID);

-- Output Items (individual deliverables within each category)
CREATE TABLE 
    OutputItemID INT IDENTITY(1,1) PRIMARY KEY,
    OutputCategoryID INT NOT NULL REFERENCES dbo.ServiceOutputCategory(OutputCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceOutputItem (
    OutputItemID INT IDENTITY(1,1) PRIMARY KEY,
    OutputCategoryID INT NOT NULL REFERENCES dbo.ServiceOutputCategory(OutputCategoryID) ON DELETE CASCADE,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceOutputItem_Category ON dbo.ServiceOutputItem(OutputCategoryID);

-- ============================================
-- TIMELINE & PHASES
-- ============================================

CREATE TABLE 
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_TimelinePhase_Service ON dbo.TimelinePhase(ServiceID);

-- Phase Duration by Size (added as separate table for flexibility)
-- This will be handled through ServiceSizeOption

-- ============================================
-- SIZE OPTIONS
-- ============================================

CREATE TABLE 
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
 (
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
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceSizeOption_Service ON dbo.ServiceSizeOption(ServiceID);

-- Phase Duration per Size
CREATE TABLE 
    PhaseDurationID INT IDENTITY(1,1) PRIMARY KEY,
    PhaseID INT NOT NULL REFERENCES dbo.TimelinePhase(PhaseID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    DurationMin NVARCHAR(50) NULL,
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL                  -- e.g., "2-3 days"
 (
CREATE TABLE dbo.PhaseDurationBySize (
    PhaseDurationID INT IDENTITY(1,1) PRIMARY KEY,
    PhaseID INT NOT NULL REFERENCES dbo.TimelinePhase(PhaseID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    DurationMin NVARCHAR(50) NULL,
    DurationMax NVARCHAR(50) NULL,
    DurationDisplay NVARCHAR(100) NULL                  -- e.g., "2-3 days",
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_PhaseDurationBySize_Phase ON dbo.PhaseDurationBySize(PhaseID);

-- ============================================
-- SIZING CRITERIA
-- ============================================

CREATE TABLE 
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CriteriaName NVARCHAR(200) NOT NULL,                -- e.g., "Number of applications"
    CriteriaType NVARCHAR(50) NULL,                     -- e.g., "Scale", "Technical"
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.SizingCriteria (
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    CriteriaName NVARCHAR(200) NOT NULL,                -- e.g., "Number of applications"
    CriteriaType NVARCHAR(50) NULL,                     -- e.g., "Scale", "Technical"
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingCriteria_Service ON dbo.SizingCriteria(ServiceID);

-- Criteria Values per Size
CREATE TABLE 
    CriteriaValueID INT IDENTITY(1,1) PRIMARY KEY,
    CriteriaID INT NOT NULL REFERENCES dbo.SizingCriteria(CriteriaID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    CriteriaValue NVARCHAR(500) NOT NULL,               -- e.g., "1", "2-5", "6+"
    Notes NVARCHAR(500) NULL
 (
CREATE TABLE dbo.SizingCriteriaValue (
    CriteriaValueID INT IDENTITY(1,1) PRIMARY KEY,
    CriteriaID INT NOT NULL REFERENCES dbo.SizingCriteria(CriteriaID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    CriteriaValue NVARCHAR(500) NOT NULL,               -- e.g., "1", "2-5", "6+"
    Notes NVARCHAR(500) NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingCriteriaValue_Criteria ON dbo.SizingCriteriaValue(CriteriaID);

-- ============================================
-- SIZING PARAMETERS (Scale & Technical Parameters)
-- ============================================

CREATE TABLE 
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterCategory NVARCHAR(50) NOT NULL,            -- "Scale" or "Technical"
    ParameterName NVARCHAR(200) NOT NULL,               -- e.g., "Number of Applications", "Hybrid Connectivity"
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.SizingParameter (
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ParameterCategory NVARCHAR(50) NOT NULL,            -- "Scale" or "Technical"
    ParameterName NVARCHAR(200) NOT NULL,               -- e.g., "Number of Applications", "Hybrid Connectivity"
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingParameter_Service ON dbo.SizingParameter(ServiceID);

-- Parameter Values (e.g., "1 application: Size S" or "+16 hours")
CREATE TABLE 
    ParameterValueID INT IDENTITY(1,1) PRIMARY KEY,
    ParameterID INT NOT NULL REFERENCES dbo.SizingParameter(ParameterID) ON DELETE CASCADE,
    ValueCondition NVARCHAR(500) NOT NULL,              -- e.g., "1 application", "ExpressRoute/Direct Connect required"
    ResultSize NVARCHAR(50) NULL,                       -- e.g., "Size S", "Size M"
    HoursAdjustment INT NULL,                           -- e.g., 16, -8
    AdjustmentDisplay NVARCHAR(100) NULL,               -- e.g., "+16 hours", "baseline"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.SizingParameterValue (
    ParameterValueID INT IDENTITY(1,1) PRIMARY KEY,
    ParameterID INT NOT NULL REFERENCES dbo.SizingParameter(ParameterID) ON DELETE CASCADE,
    ValueCondition NVARCHAR(500) NOT NULL,              -- e.g., "1 application", "ExpressRoute/Direct Connect required"
    ResultSize NVARCHAR(50) NULL,                       -- e.g., "Size S", "Size M"
    HoursAdjustment INT NULL,                           -- e.g., 16, -8
    AdjustmentDisplay NVARCHAR(100) NULL,               -- e.g., "+16 hours", "baseline"
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingParameterValue_Parameter ON dbo.SizingParameterValue(ParameterID);

-- ============================================
-- EFFORT ESTIMATION
-- ============================================

CREATE TABLE 
    EstimationItemID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Platform Architecture", "Network Architecture"
    BaseHours INT NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.EffortEstimationItem (
    EstimationItemID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Platform Architecture", "Network Architecture"
    BaseHours INT NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_EffortEstimationItem_Service ON dbo.EffortEstimationItem(ServiceID);

-- Technical Complexity Additions
CREATE TABLE 
    ComplexityAdditionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    AdditionName NVARCHAR(200) NOT NULL,                -- e.g., "Hybrid connectivity"
    Condition NVARCHAR(500) NOT NULL,                   -- e.g., "On-premises integration required"
    HoursAdded INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.TechnicalComplexityAddition (
    ComplexityAdditionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    AdditionName NVARCHAR(200) NOT NULL,                -- e.g., "Hybrid connectivity"
    Condition NVARCHAR(500) NOT NULL,                   -- e.g., "On-premises integration required"
    HoursAdded INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_TechnicalComplexityAddition_Service ON dbo.TechnicalComplexityAddition(ServiceID);

-- ============================================
-- SCOPE DEPENDENCIES
-- ============================================

CREATE TABLE 
    ScopeDependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Container Platform Design"
    RequiredAreas NVARCHAR(MAX) NOT NULL,               -- e.g., "Compute Architecture, Network Architecture"
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ScopeDependency (
    ScopeDependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ScopeArea NVARCHAR(200) NOT NULL,                   -- e.g., "Container Platform Design"
    RequiredAreas NVARCHAR(MAX) NOT NULL,               -- e.g., "Compute Architecture, Network Architecture"
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ScopeDependency_Service ON dbo.ScopeDependency(ServiceID);

-- ============================================
-- SIZING EXAMPLES
-- ============================================

CREATE TABLE 
    ExampleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ExampleTitle NVARCHAR(200) NOT NULL,                -- e.g., "Single PaaS Web Application Landing Zone"
    Scenario NVARCHAR(MAX) NOT NULL,
    Deliverables NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.SizingExample (
    ExampleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    ExampleTitle NVARCHAR(200) NOT NULL,                -- e.g., "Single PaaS Web Application Landing Zone"
    Scenario NVARCHAR(MAX) NOT NULL,
    Deliverables NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingExample_Service ON dbo.SizingExample(ServiceID);

-- Example Characteristics
CREATE TABLE 
    CharacteristicID INT IDENTITY(1,1) PRIMARY KEY,
    ExampleID INT NOT NULL REFERENCES dbo.SizingExample(ExampleID) ON DELETE CASCADE,
    CharacteristicDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.SizingExampleCharacteristic (
    CharacteristicID INT IDENTITY(1,1) PRIMARY KEY,
    ExampleID INT NOT NULL REFERENCES dbo.SizingExample(ExampleID) ON DELETE CASCADE,
    CharacteristicDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_SizingExampleCharacteristic_Example ON dbo.SizingExampleCharacteristic(ExampleID);

-- ============================================
-- RESPONSIBLE ROLES
-- ============================================

CREATE TABLE 
    ServiceRoleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    IsPrimaryOwner BIT NOT NULL DEFAULT 0,
    Responsibility NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceResponsibleRole (
    ServiceRoleID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    IsPrimaryOwner BIT NOT NULL DEFAULT 0,
    Responsibility NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceResponsibleRole_Service ON dbo.ServiceResponsibleRole(ServiceID);

-- ============================================
-- TEAM ALLOCATION
-- ============================================

CREATE TABLE 
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    FTEAllocation DECIMAL(3,2) NOT NULL,                -- e.g., 0.80, 1.00
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceTeamAllocation (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    SizeOptionID INT NOT NULL REFERENCES dbo.LU_SizeOption(SizeOptionID),
    RoleID INT NOT NULL REFERENCES dbo.LU_Role(RoleID),
    FTEAllocation DECIMAL(3,2) NOT NULL,                -- e.g., 0.80, 1.00
    Notes NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
);

CREATE INDEX IX_ServiceTeamAllocation_Service ON dbo.ServiceTeamAllocation(ServiceID);

-- ============================================
-- MULTI-CLOUD CONSIDERATIONS
-- ============================================

CREATE TABLE 
    ConsiderationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ConsiderationTitle NVARCHAR(200) NOT NULL,          -- e.g., "Design Pattern Abstraction"
    ConsiderationDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
 (
CREATE TABLE dbo.ServiceMultiCloudConsideration (
    ConsiderationID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    ConsiderationTitle NVARCHAR(200) NOT NULL,          -- e.g., "Design Pattern Abstraction"
    ConsiderationDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(200) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(200) NULL
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
GO-- ============================================
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
