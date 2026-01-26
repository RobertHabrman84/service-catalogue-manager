-- =============================================================================
-- SERVICE CATALOGUE MANAGER - TEST DATA
-- File: 03_test_data.sql
-- Description: Test data for automated testing
-- Environment: Test only - DO NOT run in production
-- =============================================================================

-- =============================================================================
-- CLEANUP EXISTING TEST DATA
-- =============================================================================
DELETE FROM [dbo].[ServiceResponsibleRole] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[EffortEstimation] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[TimelinePhase] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceInteraction] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceOutput] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceInput] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceTool] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServicePrerequisite] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceScope] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceDependency] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[UsageScenario] WHERE ServiceId IN (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%');
DELETE FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'TEST-%';
GO

-- =============================================================================
-- TEST SERVICES - BASIC
-- =============================================================================

-- Test Service 1: Active Public Service
INSERT INTO [dbo].[ServiceCatalogItem] (
    ServiceCode, ServiceName, ShortDescription, LongDescription,
    StatusId, CategoryId, BusinessUnitId, Version,
    ServiceOwner, ServiceOwnerEmail, TechnicalContact, TechnicalContactEmail,
    DocumentationUrl, IsPublic, Notes, CreatedBy
)
VALUES (
    'TEST-001', 'Test Active Public Service', 'A test service that is active and public',
    'This is a test service used for automated testing. It represents an active, publicly visible service.',
    (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'ACTIVE'),
    (SELECT Id FROM [dbo].[ServiceCategory] WHERE [Code] = 'APPLICATION'),
    (SELECT Id FROM [dbo].[BusinessUnit] WHERE [Code] = 'DEV'),
    '1.0.0',
    'Test Owner', 'test.owner@example.com', 'Test Tech', 'test.tech@example.com',
    'https://docs.example.com/test-001', 1, 'Test notes for TEST-001', 'test-system'
);

-- Test Service 2: Draft Private Service
INSERT INTO [dbo].[ServiceCatalogItem] (
    ServiceCode, ServiceName, ShortDescription, LongDescription,
    StatusId, CategoryId, BusinessUnitId, Version,
    ServiceOwner, ServiceOwnerEmail, IsPublic, CreatedBy
)
VALUES (
    'TEST-002', 'Test Draft Private Service', 'A test service in draft status',
    'This is a test service used for automated testing. It represents a draft, private service.',
    (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'DRAFT'),
    (SELECT Id FROM [dbo].[ServiceCategory] WHERE [Code] = 'INFRASTRUCTURE'),
    (SELECT Id FROM [dbo].[BusinessUnit] WHERE [Code] = 'IT_OPS'),
    '0.1.0',
    'Draft Owner', 'draft.owner@example.com', 0, 'test-system'
);

-- Test Service 3: Deprecated Service
INSERT INTO [dbo].[ServiceCatalogItem] (
    ServiceCode, ServiceName, ShortDescription, LongDescription,
    StatusId, CategoryId, BusinessUnitId, Version,
    ServiceOwner, ServiceOwnerEmail, IsPublic, CreatedBy
)
VALUES (
    'TEST-003', 'Test Deprecated Service', 'A test service that is deprecated',
    'This is a test service used for automated testing. It represents a deprecated service.',
    (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'DEPRECATED'),
    (SELECT Id FROM [dbo].[ServiceCategory] WHERE [Code] = 'DATA'),
    (SELECT Id FROM [dbo].[BusinessUnit] WHERE [Code] = 'DATA'),
    '2.5.0',
    'Legacy Owner', 'legacy.owner@example.com', 1, 'test-system'
);

-- Test Service 4: Service with Dependencies (Dependent)
INSERT INTO [dbo].[ServiceCatalogItem] (
    ServiceCode, ServiceName, ShortDescription, LongDescription,
    StatusId, CategoryId, BusinessUnitId, Version,
    ServiceOwner, ServiceOwnerEmail, IsPublic, CreatedBy
)
VALUES (
    'TEST-004', 'Test Service With Dependencies', 'A test service that has dependencies',
    'This is a test service that depends on other services.',
    (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'ACTIVE'),
    (SELECT Id FROM [dbo].[ServiceCategory] WHERE [Code] = 'INTEGRATION'),
    (SELECT Id FROM [dbo].[BusinessUnit] WHERE [Code] = 'DEV'),
    '1.2.0',
    'Dep Owner', 'dep.owner@example.com', 1, 'test-system'
);

-- Test Service 5: Service that Others Depend On
INSERT INTO [dbo].[ServiceCatalogItem] (
    ServiceCode, ServiceName, ShortDescription, LongDescription,
    StatusId, CategoryId, BusinessUnitId, Version,
    ServiceOwner, ServiceOwnerEmail, IsPublic, CreatedBy
)
VALUES (
    'TEST-005', 'Test Core Service', 'A core service that other services depend on',
    'This is a test core service that other services depend on.',
    (SELECT Id FROM [dbo].[ServiceStatus] WHERE [Code] = 'ACTIVE'),
    (SELECT Id FROM [dbo].[ServiceCategory] WHERE [Code] = 'INFRASTRUCTURE'),
    (SELECT Id FROM [dbo].[BusinessUnit] WHERE [Code] = 'IT_OPS'),
    '3.0.0',
    'Core Owner', 'core.owner@example.com', 1, 'test-system'
);
GO

-- =============================================================================
-- TEST DEPENDENCIES
-- =============================================================================

-- TEST-004 depends on TEST-005 (Required)
INSERT INTO [dbo].[ServiceDependency] (ServiceId, DependsOnServiceId, DependencyTypeId, Description, IsRequired)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-004'),
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-005'),
    (SELECT Id FROM [dbo].[DependencyType] WHERE [Code] = 'REQUIRED'),
    'Required dependency for core functionality',
    1;

-- TEST-004 depends on TEST-001 (Optional)
INSERT INTO [dbo].[ServiceDependency] (ServiceId, DependsOnServiceId, DependencyTypeId, Description, IsRequired)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-004'),
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    (SELECT Id FROM [dbo].[DependencyType] WHERE [Code] = 'OPTIONAL'),
    'Optional dependency for enhanced features',
    0;
GO

-- =============================================================================
-- TEST USAGE SCENARIOS
-- =============================================================================

INSERT INTO [dbo].[UsageScenario] (ServiceId, Title, Description, ActorRole, Preconditions, Steps, ExpectedOutcome, DisplayOrder)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'Test Scenario 1', 'Basic usage scenario for testing',
    'Test User', 'User is authenticated', 
    '1. Navigate to service\n2. Submit request\n3. Verify response',
    'Request is processed successfully', 1;

INSERT INTO [dbo].[UsageScenario] (ServiceId, Title, Description, ActorRole, Preconditions, Steps, ExpectedOutcome, DisplayOrder)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'Test Scenario 2', 'Error handling scenario',
    'Test User', 'User is authenticated',
    '1. Submit invalid request\n2. Check error response',
    'Appropriate error message returned', 2;
GO

-- =============================================================================
-- TEST INPUTS AND OUTPUTS
-- =============================================================================

-- Inputs for TEST-001
INSERT INTO [dbo].[ServiceInput] (ServiceId, Name, DataTypeId, Format, Description, IsRequired, SampleValue, DisplayOrder)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'testInput1', (SELECT Id FROM [dbo].[DataType] WHERE [Code] = 'STRING'),
    'text', 'A test input parameter', 1, 'sample value', 1;

INSERT INTO [dbo].[ServiceInput] (ServiceId, Name, DataTypeId, Format, Description, IsRequired, SampleValue, DisplayOrder)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'testInput2', (SELECT Id FROM [dbo].[DataType] WHERE [Code] = 'NUMBER'),
    'integer', 'A test numeric input', 0, '42', 2;

-- Outputs for TEST-001
INSERT INTO [dbo].[ServiceOutput] (ServiceId, Name, DataTypeId, Format, Description, SampleValue, DisplayOrder)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'testOutput1', (SELECT Id FROM [dbo].[DataType] WHERE [Code] = 'JSON'),
    'application/json', 'A test output response', '{"status": "success"}', 1;
GO

-- =============================================================================
-- TEST TIMELINE PHASES
-- =============================================================================

INSERT INTO [dbo].[TimelinePhase] (ServiceId, PhaseName, PhaseOrder, StartDate, EndDate, DurationDays, Description, Status, CompletionPercentage)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'Test Phase 1', 1, '2026-01-01', '2026-01-15', 14, 'Initial phase', 'Completed', 100;

INSERT INTO [dbo].[TimelinePhase] (ServiceId, PhaseName, PhaseOrder, StartDate, EndDate, DurationDays, Description, Status, CompletionPercentage)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    'Test Phase 2', 2, '2026-01-16', '2026-01-31', 15, 'Second phase', 'In Progress', 50;
GO

-- =============================================================================
-- TEST EFFORT ESTIMATION
-- =============================================================================

INSERT INTO [dbo].[EffortEstimation] (ServiceId, EffortCategoryId, Activity, EstimatedHours, ActualHours, Notes)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    (SELECT Id FROM [dbo].[EffortCategory] WHERE [Code] = 'DEVELOPMENT'),
    'Test development activity', 40, 35, 'Completed under estimate';

INSERT INTO [dbo].[EffortEstimation] (ServiceId, EffortCategoryId, Activity, EstimatedHours, ActualHours, Notes)
SELECT 
    (SELECT Id FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode = 'TEST-001'),
    (SELECT Id FROM [dbo].[EffortCategory] WHERE [Code] = 'TESTING'),
    'Test QA activity', 20, NULL, 'Not started';
GO

PRINT 'Test data inserted successfully.';
PRINT 'Created test services: TEST-001 through TEST-005';
