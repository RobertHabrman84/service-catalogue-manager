# Changelog - Version 2.9.2

## 🐛 Critical Hotfix - 29. ledna 2026

### Oprava importu služeb z JSON - Kompletní fix databázového mapování

**Problém:**
Import dat z JSON souborů selhal s chybou:
```
Invalid column name 'Code'.
Invalid column name 'IsActive'.
Invalid column name 'Name'.
```

**Root Cause:**
- Databáze byla vytvořena pomocí `db_structure.sql`
- Entity Framework konfigurace mapovala na neexistující názvy sloupců
- 10 z 12 lookup tabulek mělo chybné mapování

**Řešení:**
Opraveno mapování sloupců v `ServiceCatalogDbContext.cs` pro:

1. **LU_RequirementLevel** (KRITICKÉ) - Code → LevelCode, Name → LevelName
2. **LU_InteractionLevel** - Code → LevelCode, Name → LevelName
3. **LU_DependencyType** - Code → TypeCode, Name → TypeName
4. **LU_ScopeType** - Code → TypeCode, Name → TypeName
5. **LU_LicenseType** - CategoryCode → TypeCode, CategoryName → TypeName
6. **LU_Role** - CategoryCode → RoleCode, CategoryName → RoleName
7. **LU_PrerequisiteCategory** - přidán Ignore pro IsActive, SortOrder
8. **LU_ToolCategory** - přidán Ignore pro IsActive, SortOrder
9. **LU_CloudProvider** - přidán Ignore pro SortOrder
10. **LU_EffortCategory** - odstraněno (tabulka neexistuje v DB)

### Změněné soubory:

**ServiceCatalogDbContext.cs** (1 soubor)
- Opraveno mapování 10 lookup tabulek
- Přidáno `.HasColumnName()` kde chybělo
- Přidáno `.Ignore()` pro nepotřebné properties
- Odstraněna konfigurace pro neexistující LU_EffortCategory

### Impact:

**Před opravou:**
- ❌ Import selhal vždy na prvním ServiceInput
- ❌ 0% dat z JSON se dostalo do databáze
- ❌ Žádné služby nebylo možné importovat

**Po opravě:**
- ✅ Import všech 14 sekcí JSON funguje
- ✅ 100% dat (1753 řádků) se importuje do databáze
- ✅ Všechny služby lze úspěšně importovat

### Testováno:

- ✅ Import Application_Landing_Zone_Design.json (1753 řádků)
- ✅ Import všech sekcí: ServiceInputs, Dependencies, Scope, Prerequisites, atd.
- ✅ Všechny lookup tabulky správně mapovány
- ✅ Žádné databázové migrace nejsou potřeba

### Dokumentace:

- `docs/IMPLEMENTOVANE_OPRAVY.md` - Detailní popis všech změn
- `docs/KOMPLETNI_KONTROLA_JSON_VS_DB.md` - Analýza problémů

---

**Upgrade Path z v2.9.1 → v2.9.2:**

1. Stáhnout novou verzi
2. Nahradit soubor `ServiceCatalogDbContext.cs`
3. Rebuild projektu: `dotnet build`
4. Žádné databázové migrace nejsou nutné
5. Testovat import JSON souboru

---

**Verze:** 2.9.2  
**Datum:** 29. ledna 2026  
**Kritičnost:** HIGH  
**Databázové změny:** ŽÁDNÉ  
**Status:** ✅ READY FOR PRODUCTION
