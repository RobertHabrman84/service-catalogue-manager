-- =============================================================================
-- SERVICE CATALOGUE MANAGER - LOOKUP DATA
-- File: 003_lookup_data.sql
-- Description: Initial data for lookup tables
-- =============================================================================

-- =============================================================================
-- SERVICE STATUS
-- =============================================================================
INSERT INTO [dbo].[ServiceStatus] ([Code], [Name], [Description], [DisplayOrder], [ColorCode], [IconName])
VALUES
    ('DRAFT', 'Draft', 'Service is being drafted', 1, '#6B7280', 'draft'),
    ('PENDING_REVIEW', 'Pending Review', 'Service is awaiting review', 2, '#F59E0B', 'clock'),
    ('ACTIVE', 'Active', 'Service is active and available', 3, '#10B981', 'check-circle'),
    ('DEPRECATED', 'Deprecated', 'Service is deprecated but still available', 4, '#EF4444', 'alert-triangle'),
    ('RETIRED', 'Retired', 'Service has been retired', 5, '#9CA3AF', 'archive');

-- =============================================================================
-- SERVICE CATEGORY
-- =============================================================================
INSERT INTO [dbo].[ServiceCategory] ([Code], [Name], [Description], [DisplayOrder], [ColorCode], [IconName])
VALUES
    ('INFRASTRUCTURE', 'Infrastructure', 'Infrastructure and platform services', 1, '#3B82F6', 'server'),
    ('APPLICATION', 'Application', 'Application development and deployment', 2, '#8B5CF6', 'code'),
    ('DATA', 'Data & Analytics', 'Data management and analytics services', 3, '#06B6D4', 'database'),
    ('SECURITY', 'Security', 'Security and compliance services', 4, '#EF4444', 'shield'),
    ('INTEGRATION', 'Integration', 'Integration and API services', 5, '#F59E0B', 'link'),
    ('SUPPORT', 'Support', 'Support and operational services', 6, '#10B981', 'headphones'),
    ('BUSINESS', 'Business', 'Business process services', 7, '#EC4899', 'briefcase');

-- =============================================================================
-- BUSINESS UNIT
-- =============================================================================
INSERT INTO [dbo].[BusinessUnit] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('IT_OPS', 'IT Operations', 'IT Operations and Infrastructure', 1),
    ('DEV', 'Development', 'Software Development', 2),
    ('SEC', 'Security', 'Information Security', 3),
    ('DATA', 'Data Engineering', 'Data Engineering and Analytics', 4),
    ('QA', 'Quality Assurance', 'Testing and Quality Assurance', 5),
    ('PMO', 'PMO', 'Project Management Office', 6),
    ('ARCH', 'Architecture', 'Enterprise Architecture', 7);

-- =============================================================================
-- RESPONSIBLE ROLE
-- =============================================================================
INSERT INTO [dbo].[ResponsibleRole] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('SERVICE_OWNER', 'Service Owner', 'Owns the service end-to-end', 1),
    ('TECH_LEAD', 'Technical Lead', 'Technical leadership and decisions', 2),
    ('PRODUCT_OWNER', 'Product Owner', 'Product vision and backlog', 3),
    ('DEVELOPER', 'Developer', 'Development and implementation', 4),
    ('OPS_ENGINEER', 'Operations Engineer', 'Operations and maintenance', 5),
    ('SECURITY_OFFICER', 'Security Officer', 'Security review and approval', 6),
    ('ARCHITECT', 'Architect', 'Architecture design and review', 7),
    ('SUPPORT_ENGINEER', 'Support Engineer', 'User support and incidents', 8);

-- =============================================================================
-- DEPENDENCY TYPE
-- =============================================================================
INSERT INTO [dbo].[DependencyType] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('REQUIRED', 'Required', 'Hard dependency - service cannot function without it', 1),
    ('OPTIONAL', 'Optional', 'Soft dependency - enhances functionality', 2),
    ('RUNTIME', 'Runtime', 'Required at runtime only', 3),
    ('BUILD', 'Build', 'Required for build process only', 4),
    ('DATA', 'Data', 'Data dependency', 5);

-- =============================================================================
-- INTERACTION TYPE
-- =============================================================================
INSERT INTO [dbo].[InteractionType] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('API_REST', 'REST API', 'RESTful API interaction', 1),
    ('API_GRAPHQL', 'GraphQL API', 'GraphQL API interaction', 2),
    ('API_GRPC', 'gRPC', 'gRPC communication', 3),
    ('MESSAGE_QUEUE', 'Message Queue', 'Asynchronous messaging', 4),
    ('EVENT', 'Event', 'Event-driven communication', 5),
    ('DATABASE', 'Database', 'Direct database access', 6),
    ('FILE', 'File Transfer', 'File-based integration', 7),
    ('UI', 'User Interface', 'User interface interaction', 8);

-- =============================================================================
-- DATA TYPE
-- =============================================================================
INSERT INTO [dbo].[DataType] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('STRING', 'String', 'Text data', 1),
    ('NUMBER', 'Number', 'Numeric data (integer or decimal)', 2),
    ('BOOLEAN', 'Boolean', 'True/False value', 3),
    ('DATE', 'Date', 'Date value', 4),
    ('DATETIME', 'DateTime', 'Date and time value', 5),
    ('JSON', 'JSON', 'JSON object', 6),
    ('XML', 'XML', 'XML document', 7),
    ('BINARY', 'Binary', 'Binary data (files, images)', 8),
    ('ARRAY', 'Array', 'Array/List of values', 9),
    ('GUID', 'GUID', 'Globally unique identifier', 10);

-- =============================================================================
-- LICENSE TYPE
-- =============================================================================
INSERT INTO [dbo].[LicenseType] ([Code], [Name], [Description], [DisplayOrder], [RequiresApproval])
VALUES
    ('OPEN_SOURCE', 'Open Source', 'Open source license (MIT, Apache, etc.)', 1, 0),
    ('COMMERCIAL', 'Commercial', 'Commercial license required', 2, 1),
    ('ENTERPRISE', 'Enterprise', 'Enterprise agreement', 3, 1),
    ('INTERNAL', 'Internal', 'Internal/proprietary', 4, 0),
    ('FREE', 'Free', 'Free to use', 5, 0),
    ('SUBSCRIPTION', 'Subscription', 'Subscription-based license', 6, 1);

-- =============================================================================
-- CLOUD PROVIDER
-- =============================================================================
INSERT INTO [dbo].[CloudProvider] ([Code], [Name], [Description], [DisplayOrder], [LogoUrl])
VALUES
    ('AZURE', 'Microsoft Azure', 'Microsoft Azure cloud platform', 1, '/assets/logos/azure.svg'),
    ('AWS', 'Amazon Web Services', 'Amazon Web Services cloud platform', 2, '/assets/logos/aws.svg'),
    ('GCP', 'Google Cloud Platform', 'Google Cloud Platform', 3, '/assets/logos/gcp.svg'),
    ('ON_PREMISE', 'On-Premise', 'On-premise infrastructure', 4, '/assets/logos/datacenter.svg'),
    ('HYBRID', 'Hybrid', 'Hybrid cloud deployment', 5, '/assets/logos/hybrid.svg');

-- =============================================================================
-- EFFORT CATEGORY
-- =============================================================================
INSERT INTO [dbo].[EffortCategory] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('ANALYSIS', 'Analysis', 'Requirements analysis and design', 1),
    ('DEVELOPMENT', 'Development', 'Development and coding', 2),
    ('TESTING', 'Testing', 'Testing and QA', 3),
    ('DEPLOYMENT', 'Deployment', 'Deployment and release', 4),
    ('DOCUMENTATION', 'Documentation', 'Documentation and training', 5),
    ('SUPPORT', 'Support', 'Ongoing support and maintenance', 6),
    ('MANAGEMENT', 'Management', 'Project management', 7);

-- =============================================================================
-- SCOPE CATEGORY
-- =============================================================================
INSERT INTO [dbo].[ScopeCategory] ([Code], [Name], [Description], [DisplayOrder])
VALUES
    ('FUNCTIONAL', 'Functional', 'Functional requirements', 1),
    ('TECHNICAL', 'Technical', 'Technical requirements', 2),
    ('SECURITY', 'Security', 'Security requirements', 3),
    ('PERFORMANCE', 'Performance', 'Performance requirements', 4),
    ('INTEGRATION', 'Integration', 'Integration requirements', 5),
    ('COMPLIANCE', 'Compliance', 'Compliance requirements', 6);

GO

PRINT 'Lookup data inserted successfully.';
