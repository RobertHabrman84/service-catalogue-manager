-- ============================================
-- Seed Data: Sample Services for Development
-- Date: 2026-01-22
-- Environment: Development Only
-- ============================================

-- Clear existing sample data (only in dev)
DELETE FROM dbo.ServiceMultiCloudConsideration WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceTeamAllocation WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceResponsibleRole WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.SizingExample WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ScopeDependency WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.TechnicalComplexityAddition WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.EffortEstimationItem WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceSizeOption WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.TimelinePhase WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceOutputItem WHERE ScopeCategoryID IN (SELECT OutputCategoryID FROM dbo.ServiceOutputCategory WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%'));
DELETE FROM dbo.ServiceOutputCategory WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceInput WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.StakeholderInvolvement WHERE InteractionID IN (SELECT InteractionID FROM dbo.ServiceInteraction WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%'));
DELETE FROM dbo.AccessRequirement WHERE InteractionID IN (SELECT InteractionID FROM dbo.ServiceInteraction WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%'));
DELETE FROM dbo.CustomerRequirement WHERE InteractionID IN (SELECT InteractionID FROM dbo.ServiceInteraction WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%'));
DELETE FROM dbo.ServiceInteraction WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceLicense WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceToolFramework WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.CloudProviderCapability WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServicePrerequisite WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceScopeItem WHERE ScopeCategoryID IN (SELECT ScopeCategoryID FROM dbo.ServiceScopeCategory WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%'));
DELETE FROM dbo.ServiceScopeCategory WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceDependency WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.UsageScenario WHERE ServiceID IN (SELECT ServiceID FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%');
DELETE FROM dbo.ServiceCatalogItem WHERE ServiceCode LIKE 'DEV%';
GO

-- Insert Sample Service 1: Application Landing Zone Design
DECLARE @ServiceID1 INT;

INSERT INTO dbo.ServiceCatalogItem (ServiceCode, ServiceName, Version, CategoryID, Description, Notes, IsActive, CreatedBy)
VALUES (
    'DEV001',
    'Application Landing Zone Design',
    'v1.0',
    3, -- Technical Architecture
    'Comprehensive design service for creating secure, scalable, and well-architected application landing zones in cloud environments. This service establishes the foundational infrastructure patterns that enable rapid and consistent application deployments.',
    'This is a sample service for development and testing purposes.',
    1,
    'seed-script'
);

SET @ServiceID1 = SCOPE_IDENTITY();

-- Usage Scenarios
INSERT INTO dbo.UsageScenario (ServiceID, ScenarioNumber, ScenarioTitle, ScenarioDescription, SortOrder)
VALUES
    (@ServiceID1, 1, 'Greenfield Cloud Migration', 'Organization starting fresh cloud journey and needs foundational landing zone architecture.', 1),
    (@ServiceID1, 2, 'Multi-Application Platform', 'Establishing shared platform for hosting multiple applications with common services.', 2),
    (@ServiceID1, 3, 'Security-First Architecture', 'Organizations with strict compliance requirements needing secure-by-default infrastructure.', 3);

-- Dependencies
INSERT INTO dbo.ServiceDependency (ServiceID, DependencyTypeID, DependentServiceName, RequirementLevelID, Notes, SortOrder)
VALUES
    (@ServiceID1, 1, 'Cloud Strategy Assessment', 1, 'Understanding of cloud strategy is essential', 1),
    (@ServiceID1, 1, 'Network Architecture Design', 1, 'Network topology must be defined', 2),
    (@ServiceID1, 2, 'Application Migration', 2, 'Landing zone enables application migrations', 3);

-- Scope Categories (In Scope)
DECLARE @ScopeCatID1 INT;
INSERT INTO dbo.ServiceScopeCategory (ServiceID, ScopeTypeID, CategoryNumber, CategoryName, SortOrder)
VALUES (@ServiceID1, 1, '1', 'Architecture Design', 1);
SET @ScopeCatID1 = SCOPE_IDENTITY();

INSERT INTO dbo.ServiceScopeItem (ScopeCategoryID, ItemDescription, SortOrder)
VALUES
    (@ScopeCatID1, 'Landing zone architecture design document', 1),
    (@ScopeCatID1, 'Network topology and segmentation design', 2),
    (@ScopeCatID1, 'Identity and access management patterns', 3),
    (@ScopeCatID1, 'Security controls and policies', 4);

DECLARE @ScopeCatID2 INT;
INSERT INTO dbo.ServiceScopeCategory (ServiceID, ScopeTypeID, CategoryNumber, CategoryName, SortOrder)
VALUES (@ServiceID1, 1, '2', 'Documentation', 2);
SET @ScopeCatID2 = SCOPE_IDENTITY();

INSERT INTO dbo.ServiceScopeItem (ScopeCategoryID, ItemDescription, SortOrder)
VALUES
    (@ScopeCatID2, 'Architecture decision records (ADRs)', 1),
    (@ScopeCatID2, 'Deployment runbooks', 2),
    (@ScopeCatID2, 'Operations guide', 3);

-- Scope Categories (Out of Scope)
DECLARE @ScopeCatID3 INT;
INSERT INTO dbo.ServiceScopeCategory (ServiceID, ScopeTypeID, CategoryNumber, CategoryName, SortOrder)
VALUES (@ServiceID1, 2, '1', 'Exclusions', 1);
SET @ScopeCatID3 = SCOPE_IDENTITY();

INSERT INTO dbo.ServiceScopeItem (ScopeCategoryID, ItemDescription, SortOrder)
VALUES
    (@ScopeCatID3, 'Application code development', 1),
    (@ScopeCatID3, 'Ongoing infrastructure management', 2),
    (@ScopeCatID3, 'Third-party tool licensing', 3);

-- Prerequisites
INSERT INTO dbo.ServicePrerequisite (ServiceID, PrerequisiteCategoryID, PrerequisiteDescription, SortOrder)
VALUES
    (@ServiceID1, 1, 'Executive sponsorship for cloud initiative', 1),
    (@ServiceID1, 1, 'Defined cloud governance model', 2),
    (@ServiceID1, 2, 'Active cloud subscription (Azure/AWS/GCP)', 3),
    (@ServiceID1, 2, 'Network connectivity to cloud provider', 4),
    (@ServiceID1, 3, 'Current state architecture documentation', 5);

-- Cloud Provider Capabilities
INSERT INTO dbo.CloudProviderCapability (ServiceID, CloudProviderID, CapabilityName, CapabilityDescription, SortOrder)
VALUES
    (@ServiceID1, 2, 'Azure Landing Zones', 'Microsoft Cloud Adoption Framework landing zones', 1),
    (@ServiceID1, 1, 'AWS Control Tower', 'AWS multi-account landing zone solution', 2),
    (@ServiceID1, 3, 'GCP Landing Zone', 'Google Cloud foundation blueprint', 3);

-- Tools
INSERT INTO dbo.ServiceToolFramework (ServiceID, ToolCategoryID, ToolName, ToolDescription, SortOrder)
VALUES
    (@ServiceID1, 1, 'Azure Portal / AWS Console / GCP Console', 'Cloud management portals', 1),
    (@ServiceID1, 2, 'Visio / Draw.io / Lucidchart', 'Architecture diagramming', 2),
    (@ServiceID1, 3, 'Terraform / Bicep / CloudFormation', 'Infrastructure as Code', 3),
    (@ServiceID1, 4, 'Azure Advisor / AWS Trusted Advisor', 'Best practices assessment', 4);

-- Licenses
INSERT INTO dbo.ServiceLicense (ServiceID, LicenseTypeID, LicenseName, LicenseDescription, SortOrder)
VALUES
    (@ServiceID1, 1, 'Cloud Subscription', 'Active cloud provider subscription', 1),
    (@ServiceID1, 2, 'Diagramming Tool', 'Architecture visualization tool', 2),
    (@ServiceID1, 3, 'IaC Templates', 'Pre-built infrastructure templates', 3);

-- Interaction
DECLARE @InteractionID1 INT;
INSERT INTO dbo.ServiceInteraction (ServiceID, InteractionLevelID)
VALUES (@ServiceID1, 1);
SET @InteractionID1 = SCOPE_IDENTITY();

INSERT INTO dbo.CustomerRequirement (InteractionID, RequirementDescription, SortOrder)
VALUES
    (@InteractionID1, 'Dedicated technical point of contact', 1),
    (@InteractionID1, 'Access to existing architecture documentation', 2),
    (@InteractionID1, 'Participation in design workshops', 3);

INSERT INTO dbo.AccessRequirement (InteractionID, AccessDescription, SortOrder)
VALUES
    (@InteractionID1, 'Read access to cloud subscriptions', 1),
    (@InteractionID1, 'Access to identity provider configuration', 2);

INSERT INTO dbo.StakeholderInvolvement (InteractionID, RoleID, InvolvementDescription, SortOrder)
VALUES
    (@InteractionID1, 1, 'Architecture design and review', 1),
    (@InteractionID1, 2, 'Security requirements and compliance review', 2),
    (@InteractionID1, 4, 'Timeline and resource coordination', 3);

-- Inputs
INSERT INTO dbo.ServiceInput (ServiceID, ParameterName, ParameterDescription, RequirementLevelID, SortOrder)
VALUES
    (@ServiceID1, 'Business Requirements', 'High-level business objectives and constraints', 1, 1),
    (@ServiceID1, 'Current Architecture', 'Existing infrastructure documentation', 1, 2),
    (@ServiceID1, 'Compliance Requirements', 'Regulatory and compliance needs', 1, 3),
    (@ServiceID1, 'Growth Projections', 'Expected scale and growth patterns', 2, 4);

-- Outputs
DECLARE @OutputCatID1 INT;
INSERT INTO dbo.ServiceOutputCategory (ServiceID, CategoryName, SortOrder)
VALUES (@ServiceID1, 'Architecture Artifacts', 1);
SET @OutputCatID1 = SCOPE_IDENTITY();

INSERT INTO dbo.ServiceOutputItem (OutputCategoryID, ItemDescription, SortOrder)
VALUES
    (@OutputCatID1, 'Landing Zone Architecture Document', 1),
    (@OutputCatID1, 'Network Design Document', 2),
    (@OutputCatID1, 'Security Architecture Document', 3);

DECLARE @OutputCatID2 INT;
INSERT INTO dbo.ServiceOutputCategory (ServiceID, CategoryName, SortOrder)
VALUES (@ServiceID1, 'Implementation Assets', 2);
SET @OutputCatID2 = SCOPE_IDENTITY();

INSERT INTO dbo.ServiceOutputItem (OutputCategoryID, ItemDescription, SortOrder)
VALUES
    (@OutputCatID2, 'Infrastructure as Code templates', 1),
    (@OutputCatID2, 'Deployment pipelines', 2),
    (@OutputCatID2, 'Configuration scripts', 3);

-- Timeline Phases
INSERT INTO dbo.TimelinePhase (ServiceID, PhaseName, PhaseDescription, SortOrder)
VALUES
    (@ServiceID1, 'Discovery', 'Requirements gathering and current state analysis', 1),
    (@ServiceID1, 'Design', 'Architecture design and documentation', 2),
    (@ServiceID1, 'Review', 'Design review and refinement', 3),
    (@ServiceID1, 'Handover', 'Knowledge transfer and documentation delivery', 4);

-- Size Options
INSERT INTO dbo.ServiceSizeOption (ServiceID, SizeOptionID, ScopeDescription, DurationDisplay, EffortDisplay, TeamSizeDisplay, Complexity)
VALUES
    (@ServiceID1, 2, 'Single application, single cloud', '2-3 weeks', '40-60 hours', '2-3 people', 'Low'),
    (@ServiceID1, 3, 'Multiple applications, single cloud', '4-6 weeks', '80-120 hours', '3-4 people', 'Medium'),
    (@ServiceID1, 4, 'Enterprise platform, multi-cloud', '8-12 weeks', '160-240 hours', '4-6 people', 'High');

-- Responsible Roles
INSERT INTO dbo.ServiceResponsibleRole (ServiceID, RoleID, IsPrimary, ResponsibilityDescription, SortOrder)
VALUES
    (@ServiceID1, 1, 1, 'Lead architecture design and technical direction', 1),
    (@ServiceID1, 2, 0, 'Security architecture and compliance mapping', 2),
    (@ServiceID1, 3, 0, 'Network topology and connectivity design', 3);

-- Multi-Cloud Considerations
INSERT INTO dbo.ServiceMultiCloudConsideration (ServiceID, ConsiderationTitle, ConsiderationDescription, SortOrder)
VALUES
    (@ServiceID1, 'Provider Abstraction', 'Use provider-agnostic patterns where possible to enable portability', 1),
    (@ServiceID1, 'Consistent Governance', 'Implement unified governance model across all cloud providers', 2),
    (@ServiceID1, 'Network Interconnect', 'Plan for secure connectivity between cloud environments', 3);

GO

-- Insert Sample Service 2: Cloud Security Assessment
DECLARE @ServiceID2 INT;

INSERT INTO dbo.ServiceCatalogItem (ServiceCode, ServiceName, Version, CategoryID, Description, Notes, IsActive, CreatedBy)
VALUES (
    'DEV002',
    'Cloud Security Assessment',
    'v1.0',
    5, -- Assessment
    'Comprehensive security assessment of cloud infrastructure identifying vulnerabilities, compliance gaps, and providing remediation recommendations aligned with industry best practices and regulatory requirements.',
    'Sample assessment service for development.',
    1,
    'seed-script'
);

SET @ServiceID2 = SCOPE_IDENTITY();

-- Usage Scenarios
INSERT INTO dbo.UsageScenario (ServiceID, ScenarioNumber, ScenarioTitle, ScenarioDescription, SortOrder)
VALUES
    (@ServiceID2, 1, 'Pre-Production Security Review', 'Security assessment before going live with new cloud workloads.', 1),
    (@ServiceID2, 2, 'Compliance Audit Preparation', 'Assessment to prepare for regulatory compliance audits.', 2),
    (@ServiceID2, 3, 'Security Posture Improvement', 'Regular assessment to improve overall security posture.', 3);

-- Size Options
INSERT INTO dbo.ServiceSizeOption (ServiceID, SizeOptionID, ScopeDescription, DurationDisplay, EffortDisplay, TeamSizeDisplay, Complexity)
VALUES
    (@ServiceID2, 2, 'Single subscription/account', '1-2 weeks', '20-40 hours', '1-2 people', 'Low'),
    (@ServiceID2, 3, 'Multiple subscriptions, single org', '2-4 weeks', '40-80 hours', '2-3 people', 'Medium'),
    (@ServiceID2, 4, 'Enterprise-wide assessment', '4-8 weeks', '80-160 hours', '3-5 people', 'High');

GO

PRINT 'Sample services seeded successfully.';
GO
