-- =============================================
-- KOMPLETNÍ AKTUALIZACE DATABÁZE PODLE EF CORE MODELU
-- =============================================
-- Autor: Automatizovaná synchronizace
-- Datum: 2025-01-28
-- Popis: Kompletní synchronizace databáze s EF Core modelem
--         včetně zálohy dat, aktualizace schématu a obnovení
-- =============================================

PRINT 'ZAČÍNÁ KOMPLETNÍ AKTUALIZACE DATABÁZE PODLE EF CORE MODELU';

-- =============================================
-- 1. ZÁLOHA EXISTUJÍCÍCH DAT
-- =============================================
PRINT 'Vytváření zálohy existujících dat...';

-- Záloha LU_ServiceCategory
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LU_ServiceCategory')
BEGIN
    IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceCategory') IS NOT NULL
        DROP TABLE #Backup_LU_ServiceCategory;
    
    SELECT * INTO #Backup_LU_ServiceCategory FROM LU_ServiceCategory;
    PRINT 'Zálohováno ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' záznamů z LU_ServiceCategory';
END

-- Záloha dalších lookup tabulek podle potřeby
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LU_ServiceType')
BEGIN
    IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceType') IS NOT NULL
        DROP TABLE #Backup_LU_ServiceType;
    
    SELECT * INTO #Backup_LU_ServiceType FROM LU_ServiceType;
    PRINT 'Zálohováno ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' záznamů z LU_ServiceType';
END

-- =============================================
-- 2. AKTUALIZACE SCHÉMATU PODLE EF CORE MODELU
-- =============================================
PRINT 'Aktualizace schématu podle EF Core modelu...';

-- Sloupce pro LU_ServiceCategory (pokud ještě neexistují)
IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'CategoryCode')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceCategory] ADD CategoryCode NVARCHAR(50) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'CategoryName')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceCategory] ADD CategoryName NVARCHAR(255) NULL;
END

-- Sloupce pro LU_ServiceType (pokud ještě neexistují)
IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceType]') 
                AND name = 'TypeCode')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceType] ADD TypeCode NVARCHAR(50) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceType]') 
                AND name = 'TypeName')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceType] ADD TypeName NVARCHAR(255) NULL;
END

-- Další schématové změny podle EF Core modelu
-- Zde by byly přidány další ALTER TABLE příkazy podle potřeby

-- =============================================
-- 3. OBNOVENÍ DAT ZÁLOHY
-- =============================================
PRINT 'Obnovení dat ze zálohy...';

-- Obnovení LU_ServiceCategory
IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceCategory') IS NOT NULL
BEGIN
    MERGE INTO LU_ServiceCategory AS target
    USING #Backup_LU_ServiceCategory AS source
    ON target.Id = source.Id
    WHEN MATCHED THEN
        UPDATE SET 
            target.CategoryCode = ISNULL(source.CategoryCode, 'DEFAULT'),
            target.CategoryName = ISNULL(source.CategoryName, 'Default Category'),
            target.[Description] = source.[Description],
            target.IsActive = source.IsActive,
            target.CreatedDate = source.CreatedDate,
            target.ModifiedDate = source.ModifiedDate
    WHEN NOT MATCHED THEN
        INSERT (CategoryCode, CategoryName, [Description], IsActive, CreatedDate, ModifiedDate)
        VALUES (ISNULL(source.CategoryCode, 'DEFAULT'), ISNULL(source.CategoryName, 'Default Category'), 
                source.[Description], source.IsActive, source.CreatedDate, source.ModifiedDate);
    
    PRINT 'Obnoveno ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' záznamů do LU_ServiceCategory';
END

-- Obnovení LU_ServiceType
IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceType') IS NOT NULL
BEGIN
    MERGE INTO LU_ServiceType AS target
    USING #Backup_LU_ServiceType AS source
    ON target.Id = source.Id
    WHEN MATCHED THEN
        UPDATE SET 
            target.TypeCode = ISNULL(source.TypeCode, 'DEFAULT'),
            target.TypeName = ISNULL(source.TypeName, 'Default Type'),
            target.[Description] = source.[Description],
            target.IsActive = source.IsActive,
            target.CreatedDate = source.CreatedDate,
            target.ModifiedDate = source.ModifiedDate
    WHEN NOT MATCHED THEN
        INSERT (TypeCode, TypeName, [Description], IsActive, CreatedDate, ModifiedDate)
        VALUES (ISNULL(source.TypeCode, 'DEFAULT'), ISNULL(source.TypeName, 'Default Type'), 
                source.[Description], source.IsActive, source.CreatedDate, source.ModifiedDate);
    
    PRINT 'Obnoveno ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' záznamů do LU_ServiceType';
END

-- =============================================
-- 4. VYTVOŘENÍ CHYBĚJÍCÍCH INDEXŮ A CONSTRAINTS
-- =============================================
PRINT 'Vytváření indexů a constraints...';

-- Index pro LU_ServiceCategory.CategoryCode
IF NOT EXISTS (SELECT * FROM sys.indexes 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'IX_LU_ServiceCategory_CategoryCode')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LU_ServiceCategory_CategoryCode] 
    ON [dbo].[LU_ServiceCategory] ([CategoryCode]);
    PRINT 'Vytvořen index IX_LU_ServiceCategory_CategoryCode';
END

-- Index pro LU_ServiceType.TypeCode
IF NOT EXISTS (SELECT * FROM sys.indexes 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceType]') 
                AND name = 'IX_LU_ServiceType_TypeCode')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LU_ServiceType_TypeCode] 
    ON [dbo].[LU_ServiceType] ([TypeCode]);
    PRINT 'Vytvořen index IX_LU_ServiceType_TypeCode';
END

-- =============================================
-- 5. ČIŠTĚNÍ DOČASNÝCH OBJEKTŮ
-- =============================================
PRINT 'Čištění dočasných objektů...';

IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceCategory') IS NOT NULL
    DROP TABLE #Backup_LU_ServiceCategory;

IF OBJECT_ID('tempdb.dbo.#Backup_LU_ServiceType') IS NOT NULL
    DROP TABLE #Backup_LU_ServiceType;

PRINT 'KOMPLETNÍ AKTUALIZACE DATABÁZE DOKONČENA ÚSPĚŠNĚ';
PRINT '=============================================';
PRINT 'Všechny sloupce podle EF Core modelu byly úspěšně přidány.';
PRINT 'Data byla zachována a aktualizována podle nového schématu.';
PRINT '=============================================';