-- Migration: Fix Decimal Precision for EffortDays and AllocationPercentage
-- Version: V1.0.3
-- Date: 2026-01-26 10:02:44
-- Description: Update EffortEstimationItem.EffortDays and ServiceTeamAllocation.AllocationPercentage to decimal(18,2)

-- ============================================================
-- 1) EffortEstimationItem - Update EffortDays to decimal(18,2)
-- ============================================================
IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'EffortEstimationItem' 
    AND COLUMN_NAME = 'EffortDays'
)
BEGIN
    -- Check if column already has correct precision
    IF NOT EXISTS (
        SELECT 1 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'EffortEstimationItem' 
        AND COLUMN_NAME = 'EffortDays'
        AND DATA_TYPE = 'decimal'
        AND NUMERIC_PRECISION = 18
        AND NUMERIC_SCALE = 2
    )
    BEGIN
        PRINT 'Updating EffortEstimationItem.EffortDays to decimal(18,2)';
        ALTER TABLE dbo.EffortEstimationItem 
        ALTER COLUMN EffortDays DECIMAL(18,2) NOT NULL;
    END
    ELSE
    BEGIN
        PRINT 'EffortEstimationItem.EffortDays already has decimal(18,2) precision';
    END
END
ELSE
BEGIN
    PRINT 'Table EffortEstimationItem or column EffortDays does not exist';
END
GO

-- ============================================================
-- 2) ServiceTeamAllocation - Update AllocationPercentage to decimal(18,2)
-- ============================================================
IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ServiceTeamAllocation' 
    AND COLUMN_NAME = 'AllocationPercentage'
)
BEGIN
    -- Check if column already has correct precision
    IF NOT EXISTS (
        SELECT 1 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'ServiceTeamAllocation' 
        AND COLUMN_NAME = 'AllocationPercentage'
        AND DATA_TYPE = 'decimal'
        AND NUMERIC_PRECISION = 18
        AND NUMERIC_SCALE = 2
    )
    BEGIN
        PRINT 'Updating ServiceTeamAllocation.AllocationPercentage to decimal(18,2)';
        ALTER TABLE dbo.ServiceTeamAllocation 
        ALTER COLUMN AllocationPercentage DECIMAL(18,2) NULL;
    END
    ELSE
    BEGIN
        PRINT 'ServiceTeamAllocation.AllocationPercentage already has decimal(18,2) precision';
    END
END
ELSE
BEGIN
    PRINT 'Table ServiceTeamAllocation or column AllocationPercentage does not exist';
END
GO

-- ============================================================
-- Migration History Record
-- ============================================================
PRINT 'Migration V1.0.3 completed successfully';
GO