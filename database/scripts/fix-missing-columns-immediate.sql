-- =============================================
-- OKAMŽITÁ OPRAVA: Přidání chybějících sloupců do LU_ServiceCategory
-- =============================================
-- Autor: Automatizovaná oprava
-- Datum: 2025-01-28
-- Popis: Přidává chybějící sloupce CategoryCode a CategoryName 
--         do tabulky LU_ServiceCategory podle požadavků EF Core modelu
-- =============================================

-- Kontrola existence sloupců před přidáním
IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'CategoryCode')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceCategory] 
    ADD CategoryCode NVARCHAR(50) NULL;
    
    PRINT 'Přidán sloupec CategoryCode do LU_ServiceCategory';
END
ELSE
BEGIN
    PRINT 'Sloupec CategoryCode již existuje v LU_ServiceCategory';
END

IF NOT EXISTS (SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'CategoryName')
BEGIN
    ALTER TABLE [dbo].[LU_ServiceCategory] 
    ADD CategoryName NVARCHAR(255) NULL;
    
    PRINT 'Přidán sloupec CategoryName do LU_ServiceCategory';
END
ELSE
BEGIN
    PRINT 'Sloupec CategoryName již existuje v LU_ServiceCategory';
END

-- Aktualizace výchozích hodnot pro existující záznamy
UPDATE [dbo].[LU_ServiceCategory] 
SET CategoryCode = 'DEFAULT',
    CategoryName = 'Default Category'
WHERE CategoryCode IS NULL OR CategoryName IS NULL;

PRINT 'Aktualizovány výchozí hodnoty pro existující záznamy';

-- Vytvoření indexu pro lepší výkon při vyhledávání
IF NOT EXISTS (SELECT * FROM sys.indexes 
                WHERE object_id = OBJECT_ID(N'[dbo].[LU_ServiceCategory]') 
                AND name = 'IX_LU_ServiceCategory_CategoryCode')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LU_ServiceCategory_CategoryCode] 
    ON [dbo].[LU_ServiceCategory] ([CategoryCode]);
    
    PRINT 'Vytvořen index IX_LU_ServiceCategory_CategoryCode';
END
ELSE
BEGIN
    PRINT 'Index IX_LU_ServiceCategory_CategoryCode již existuje';
END

PRINT 'OKAMŽITÁ OPRAVA DOKONČENA ÚSPĚŠNĚ';