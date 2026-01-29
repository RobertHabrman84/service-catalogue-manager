# Changelog - Version 2.9.1

## 🐛 Hotfix Release - 29. ledna 2026

### Kritická oprava importu služeb

**Problém:**
Aplikace selhávala při importu služeb s chybou:
```
Invalid column name 'TypeCode'.
Invalid column name 'IsActive'.
Invalid column name 'TypeName'.
```

**Příčina:**
Nesoulad mezi databázovou migrací a Entity Framework konfigurací v DbContext pro následující lookup tabulky:
- LU_RequirementLevel
- LU_DependencyType
- LU_ScopeType
- LU_InteractionLevel

**Řešení:**
Odstraněno chybné mapování `.HasColumnName("TypeCode")` a `.HasColumnName("TypeName")` v `ServiceCatalogDbContext.cs`

### Změněné soubory:

1. **ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs**
   - Opravena konfigurace LU_DependencyType (řádky ~473-481)
   - Opravena konfigurace LU_ScopeType (řádky ~513-521)
   - Opravena konfigurace LU_InteractionLevel (řádky ~523-531)
   - Opravena konfigurace LU_RequirementLevel (řádky ~533-541)

### Impact:
- ✅ Import služeb nyní funguje správně
- ✅ Všechny lookup tabulky správně mapovány
- ✅ Žádné změny databázového schématu nutné
- ✅ Žádný dopad na existující data

### Testing:
Otestováno:
- ✅ Import služby s usage scenarios
- ✅ Import služby se service inputs
- ✅ Načítání requirement levels
- ✅ Všechny ostatní lookup tabulky

### Dokumentace:
Detailní analýza a popis opravy: `docs/FIX_ANALYSIS.md`

---

**Upgrade Path z v2.9.0 → v2.9.1:**
1. Stáhnout novou verzi
2. Nahradit soubor `ServiceCatalogDbContext.cs`
3. Rebuild projektu
4. Žádné databázové migrace nejsou nutné
