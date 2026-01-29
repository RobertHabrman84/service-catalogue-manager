-- ============================================
-- HOTFIX: CloudProviderCapability audit columns
-- Date: 2026-01-29
-- ============================================
-- Tento skript opravuje chybu s názvem tabulky
-- Spusťte pouze pokud jste použili původní verzi
-- a viděli jste chybu "Cannot find the object CloudProviderCapabilities"
-- ============================================

USE [YourDatabaseName]; -- ZMĚŇTE NA VÁŠ NÁZEV DATABÁZE
GO

PRINT 'Applying CloudProviderCapability hotfix...';
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
    PRINT '✓ Added audit columns to CloudProviderCapability';
END
ELSE
BEGIN
    PRINT '✓ CloudProviderCapability already has audit columns';
END
GO

-- Verify the fix
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CloudProviderCapability') AND name = 'CreatedBy')
BEGIN
    PRINT '';
    PRINT '============================================';
    PRINT '✓✓✓ HOTFIX APPLIED SUCCESSFULLY! ✓✓✓';
    PRINT '============================================';
END
ELSE
BEGIN
    PRINT '';
    PRINT '============================================';
    PRINT '✗✗✗ HOTFIX FAILED! ✗✗✗';
    PRINT 'Please check if table CloudProviderCapability exists';
    PRINT '============================================';
END
GO
