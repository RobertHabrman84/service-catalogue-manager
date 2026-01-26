-- =============================================================================
-- SERVICE CATALOGUE MANAGER - LOOKUP TABLES
-- File: 002_lookup_tables.sql
-- Description: Lookup/reference tables for service catalogue
-- =============================================================================

-- =============================================================================
-- SERVICE STATUS
-- =============================================================================
CREATE TABLE [dbo].[ServiceStatus] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [ColorCode] NVARCHAR(7) NULL,
    [IconName] NVARCHAR(50) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_ServiceStatus] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_ServiceStatus_Code] UNIQUE ([Code])
);

-- =============================================================================
-- SERVICE CATEGORY
-- =============================================================================
CREATE TABLE [dbo].[ServiceCategory] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [ParentId] INT NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [ColorCode] NVARCHAR(7) NULL,
    [IconName] NVARCHAR(50) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_ServiceCategory] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_ServiceCategory_Code] UNIQUE ([Code]),
    CONSTRAINT [FK_ServiceCategory_Parent] FOREIGN KEY ([ParentId]) 
        REFERENCES [dbo].[ServiceCategory]([Id])
);

-- =============================================================================
-- BUSINESS UNIT
-- =============================================================================
CREATE TABLE [dbo].[BusinessUnit] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [ManagerEmail] NVARCHAR(255) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_BusinessUnit] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_BusinessUnit_Code] UNIQUE ([Code])
);

-- =============================================================================
-- RESPONSIBLE ROLE
-- =============================================================================
CREATE TABLE [dbo].[ResponsibleRole] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_ResponsibleRole] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_ResponsibleRole_Code] UNIQUE ([Code])
);

-- =============================================================================
-- DEPENDENCY TYPE
-- =============================================================================
CREATE TABLE [dbo].[DependencyType] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_DependencyType] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_DependencyType_Code] UNIQUE ([Code])
);

-- =============================================================================
-- INTERACTION TYPE
-- =============================================================================
CREATE TABLE [dbo].[InteractionType] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_InteractionType] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_InteractionType_Code] UNIQUE ([Code])
);

-- =============================================================================
-- DATA TYPE
-- =============================================================================
CREATE TABLE [dbo].[DataType] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_DataType] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_DataType_Code] UNIQUE ([Code])
);

-- =============================================================================
-- LICENSE TYPE
-- =============================================================================
CREATE TABLE [dbo].[LicenseType] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [RequiresApproval] BIT NOT NULL DEFAULT 0,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_LicenseType] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_LicenseType_Code] UNIQUE ([Code])
);

-- =============================================================================
-- CLOUD PROVIDER
-- =============================================================================
CREATE TABLE [dbo].[CloudProvider] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [LogoUrl] NVARCHAR(500) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_CloudProvider] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_CloudProvider_Code] UNIQUE ([Code])
);

-- =============================================================================
-- EFFORT CATEGORY
-- =============================================================================
CREATE TABLE [dbo].[EffortCategory] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_EffortCategory] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_EffortCategory_Code] UNIQUE ([Code])
);

-- =============================================================================
-- SCOPE CATEGORY
-- =============================================================================
CREATE TABLE [dbo].[ScopeCategory] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    CONSTRAINT [PK_ScopeCategory] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_ScopeCategory_Code] UNIQUE ([Code])
);

GO

PRINT 'Lookup tables created successfully.';
