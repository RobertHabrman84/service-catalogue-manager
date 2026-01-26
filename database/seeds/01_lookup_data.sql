-- =============================================
-- Lookup Tables Seed Data
-- Service Catalogue Manager
-- =============================================

SET IDENTITY_INSERT LU_ServiceCategory ON;
INSERT INTO LU_ServiceCategory (CategoryId, CategoryCode, CategoryName, Description, ParentCategoryId, SortOrder, IsActive)
VALUES 
    (1, 'CLOUD', 'Cloud Services', 'Cloud infrastructure and platform services', NULL, 1, 1),
    (2, 'SECURITY', 'Security Services', 'Security and compliance services', NULL, 2, 1),
    (3, 'DATA', 'Data Services', 'Data management and analytics services', NULL, 3, 1),
    (4, 'DEVOPS', 'DevOps Services', 'DevOps and automation services', NULL, 4, 1),
    (5, 'INTEGRATION', 'Integration Services', 'Integration and API services', NULL, 5, 1),
    (6, 'CLOUD-INFRA', 'Cloud Infrastructure', 'Infrastructure as a Service', 1, 1, 1),
    (7, 'CLOUD-PLATFORM', 'Cloud Platform', 'Platform as a Service', 1, 2, 1),
    (8, 'CLOUD-CONTAINER', 'Container Services', 'Container orchestration services', 1, 3, 1),
    (9, 'SEC-IAM', 'Identity & Access', 'Identity and Access Management', 2, 1, 1),
    (10, 'SEC-NETWORK', 'Network Security', 'Network security services', 2, 2, 1);
SET IDENTITY_INSERT LU_ServiceCategory OFF;

SET IDENTITY_INSERT LU_SizeOption ON;
INSERT INTO LU_SizeOption (SizeOptionId, SizeCode, SizeName, Description, SortOrder, IsActive)
VALUES 
    (1, 'S', 'Small', 'Small scope implementation', 1, 1),
    (2, 'M', 'Medium', 'Medium scope implementation', 2, 1),
    (3, 'L', 'Large', 'Large scope implementation', 3, 1),
    (4, 'XL', 'Extra Large', 'Enterprise-wide implementation', 4, 1);
SET IDENTITY_INSERT LU_SizeOption OFF;

SET IDENTITY_INSERT LU_CloudProvider ON;
INSERT INTO LU_CloudProvider (CloudProviderId, ProviderCode, ProviderName, Description, SortOrder, IsActive)
VALUES 
    (1, 'AZURE', 'Microsoft Azure', 'Microsoft Azure cloud platform', 1, 1),
    (2, 'AWS', 'Amazon Web Services', 'Amazon Web Services cloud platform', 2, 1),
    (3, 'GCP', 'Google Cloud Platform', 'Google Cloud Platform', 3, 1),
    (4, 'ONPREM', 'On-Premises', 'On-premises infrastructure', 4, 1);
SET IDENTITY_INSERT LU_CloudProvider OFF;

SET IDENTITY_INSERT LU_DependencyType ON;
INSERT INTO LU_DependencyType (DependencyTypeId, TypeCode, TypeName, Description, SortOrder, IsActive)
VALUES 
    (1, 'INT', 'Internal Service', 'Dependency on internal service', 1, 1),
    (2, 'EXT', 'External Service', 'Dependency on external/third-party service', 2, 1),
    (3, 'INF', 'Infrastructure', 'Infrastructure dependency', 3, 1),
    (4, 'DATA', 'Data Source', 'Dependency on data source', 4, 1);
SET IDENTITY_INSERT LU_DependencyType OFF;

SET IDENTITY_INSERT LU_RequirementLevel ON;
INSERT INTO LU_RequirementLevel (RequirementLevelId, LevelCode, LevelName, Description, SortOrder, IsActive)
VALUES 
    (1, 'REQ', 'Required', 'Mandatory requirement', 1, 1),
    (2, 'OPT', 'Optional', 'Optional but recommended', 2, 1),
    (3, 'CON', 'Conditional', 'Required under certain conditions', 3, 1);
SET IDENTITY_INSERT LU_RequirementLevel OFF;

SET IDENTITY_INSERT LU_ScopeType ON;
INSERT INTO LU_ScopeType (ScopeTypeId, TypeCode, TypeName, Description, SortOrder, IsActive)
VALUES 
    (1, 'IN', 'In Scope', 'Items included in service delivery', 1, 1),
    (2, 'OUT', 'Out of Scope', 'Items excluded from service delivery', 2, 1);
SET IDENTITY_INSERT LU_ScopeType OFF;

SET IDENTITY_INSERT LU_InteractionLevel ON;
INSERT INTO LU_InteractionLevel (InteractionLevelId, LevelCode, LevelName, Description, SortOrder, IsActive)
VALUES 
    (1, 'LOW', 'Low Touch', 'Minimal customer interaction required', 1, 1),
    (2, 'MED', 'Medium Touch', 'Regular customer interaction required', 2, 1),
    (3, 'HIGH', 'High Touch', 'Intensive customer collaboration required', 3, 1);
SET IDENTITY_INSERT LU_InteractionLevel OFF;

SET IDENTITY_INSERT LU_PrerequisiteCategory ON;
INSERT INTO LU_PrerequisiteCategory (PrerequisiteCategoryId, CategoryCode, CategoryName, Description, SortOrder, IsActive)
VALUES 
    (1, 'TECH', 'Technical', 'Technical prerequisites', 1, 1),
    (2, 'ORG', 'Organizational', 'Organizational prerequisites', 2, 1),
    (3, 'DATA', 'Data', 'Data prerequisites', 3, 1),
    (4, 'SEC', 'Security', 'Security prerequisites', 4, 1),
    (5, 'ACCESS', 'Access', 'Access and permissions prerequisites', 5, 1);
SET IDENTITY_INSERT LU_PrerequisiteCategory OFF;

SET IDENTITY_INSERT LU_ToolCategory ON;
INSERT INTO LU_ToolCategory (ToolCategoryId, CategoryCode, CategoryName, Description, SortOrder, IsActive)
VALUES 
    (1, 'DEV', 'Development', 'Development tools', 1, 1),
    (2, 'INFRA', 'Infrastructure', 'Infrastructure tools', 2, 1),
    (3, 'MON', 'Monitoring', 'Monitoring and observability tools', 3, 1),
    (4, 'SEC', 'Security', 'Security tools', 4, 1),
    (5, 'COLLAB', 'Collaboration', 'Collaboration tools', 5, 1);
SET IDENTITY_INSERT LU_ToolCategory OFF;

SET IDENTITY_INSERT LU_LicenseType ON;
INSERT INTO LU_LicenseType (LicenseTypeId, TypeCode, TypeName, Description, SortOrder, IsActive)
VALUES 
    (1, 'MSFT', 'Microsoft', 'Microsoft licenses', 1, 1),
    (2, 'OPEN', 'Open Source', 'Open source licenses', 2, 1),
    (3, 'COMM', 'Commercial', 'Commercial third-party licenses', 3, 1),
    (4, 'SAAS', 'SaaS', 'Software as a Service subscriptions', 4, 1);
SET IDENTITY_INSERT LU_LicenseType OFF;

SET IDENTITY_INSERT LU_Role ON;
INSERT INTO LU_Role (RoleId, RoleCode, RoleName, Description, SortOrder, IsActive)
VALUES 
    (1, 'CA', 'Cloud Architect', 'Cloud solution architect', 1, 1),
    (2, 'CE', 'Cloud Engineer', 'Cloud infrastructure engineer', 2, 1),
    (3, 'SA', 'Security Architect', 'Security architect', 3, 1),
    (4, 'PM', 'Project Manager', 'Project/delivery manager', 4, 1),
    (5, 'DE', 'Data Engineer', 'Data engineer', 5, 1),
    (6, 'DO', 'DevOps Engineer', 'DevOps/platform engineer', 6, 1),
    (7, 'BA', 'Business Analyst', 'Business analyst', 7, 1),
    (8, 'QA', 'QA Engineer', 'Quality assurance engineer', 8, 1);
SET IDENTITY_INSERT LU_Role OFF;

SET IDENTITY_INSERT LU_EffortCategory ON;
INSERT INTO LU_EffortCategory (EffortCategoryId, CategoryCode, CategoryName, Description, SortOrder, IsActive)
VALUES 
    (1, 'DISC', 'Discovery', 'Discovery and requirements gathering', 1, 1),
    (2, 'DESIGN', 'Design', 'Architecture and design', 2, 1),
    (3, 'IMPL', 'Implementation', 'Implementation and development', 3, 1),
    (4, 'TEST', 'Testing', 'Testing and validation', 4, 1),
    (5, 'DEPLOY', 'Deployment', 'Deployment and go-live', 5, 1),
    (6, 'DOC', 'Documentation', 'Documentation and training', 6, 1),
    (7, 'PM', 'Project Management', 'Project management overhead', 7, 1);
SET IDENTITY_INSERT LU_EffortCategory OFF;

PRINT 'Lookup data seeded successfully';
GO
