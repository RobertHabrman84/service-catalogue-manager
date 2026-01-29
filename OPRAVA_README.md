# 🔧 OPRAVA - Service Catalogue Manager v2.9.1

## ⚡ Rychlý přehled

**Co bylo opraveno:** Kritická chyba při importu služeb  
**Verze:** 2.9.0 → 2.9.1  
**Datum:** 29. ledna 2026  
**Změněné soubory:** 1 soubor (ServiceCatalogDbContext.cs)

## 🎯 Popis problému

Aplikace selhávala při pokusu o import služeb s chybovou hláškou:
```
Invalid column name 'TypeCode'.
Invalid column name 'TypeName'.
```

Import se zastavil při zpracování Service Inputs v metodě `FindOrCreateRequirementLevelAsync()`.

## ✅ Co bylo opraveno

### Soubor: `ServiceCatalogDbContext.cs`

Odstraněno chybné mapování sloupců pro 4 lookup tabulky:

1. **LU_RequirementLevel**
2. **LU_DependencyType**
3. **LU_ScopeType**
4. **LU_InteractionLevel**

### Konkrétní změna:

**PŘED:**
```csharp
entity.Property(e => e.Code).HasColumnName("TypeCode");
entity.Property(e => e.Name).HasColumnName("TypeName");
```

**PO:**
```csharp
entity.Property(e => e.Code).IsRequired().HasMaxLength(XX);
entity.Property(e => e.Name).IsRequired().HasMaxLength(YY);
```

## 📋 Postup instalace opravy

### Varianta A: Kompletní nová verze (doporučeno)

1. Stáhněte `service-catalogue-manager-v2_9_1.zip`
2. Rozbalte do vašeho pracovního adresáře
3. Rebuild projektu:
   ```powershell
   dotnet build
   ```
4. Spusťte aplikaci normálně

### Varianta B: Manuální patch (pouze oprava)

1. Otevřete soubor:  
   `src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs`

2. Najděte tyto 4 sekce a odstraňte `.HasColumnName(...)`:

   **LU_DependencyType** (cca řádek 477-478):
   ```csharp
   // Odstraňte .HasColumnName("TypeCode") a .HasColumnName("TypeName")
   entity.Property(e => e.Code).IsRequired().HasMaxLength(50);
   entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
   ```

   **LU_ScopeType** (cca řádek 517-518):
   ```csharp
   entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
   entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
   ```

   **LU_InteractionLevel** (cca řádek 527-528):
   ```csharp
   entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
   entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
   ```

   **LU_RequirementLevel** (cca řádek 537-538):
   ```csharp
   entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
   entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
   ```

3. Uložte soubor a rebuild:
   ```powershell
   dotnet build
   ```

## 🧪 Ověření opravy

Po instalaci opravy otestujte:

1. Spusťte aplikaci
2. Importujte testovací službu (např. `Application Landing Zone Design.json`)
3. Import by měl proběhnout úspěšně bez chyb

## ❓ FAQ

**Q: Potřebuji spustit databázovou migraci?**  
A: Ne, databáze je v pořádku. Problém byl pouze v kódu.

**Q: Ovlivní to moje existující data?**  
A: Ne, oprava nemá žádný vliv na existující data.

**Q: Musím smazat databázi?**  
A: Ne, určitě ne. Databáze zůstává stejná.

**Q: Fungují ostatní funkce aplikace?**  
A: Ano, oprava ovlivňuje pouze import služeb.

## 📞 Podpora

Pokud máte problémy s opravou, podívejte se do:
- `docs/FIX_ANALYSIS.md` - detailní technická analýza
- `CHANGELOG-v2.9.1.md` - kompletní changelog

## ✨ Co dál

Po instalaci opravy můžete:
1. ✅ Importovat služby bez problémů
2. ✅ Používat všechny funkce normálně
3. ✅ Pokračovat ve vývoji

---

**Verze:** 2.9.1  
**Datum:** 29.1.2026  
**Status:** ✅ OPRAVENO
