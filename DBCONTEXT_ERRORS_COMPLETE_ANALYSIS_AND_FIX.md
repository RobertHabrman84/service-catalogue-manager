# 🔴 KRITICKÁ ANALÝZA CHYB DbContext - KE SCHVÁLENÍ

**Datum analýzy:** 2026-01-30  
**Analyzovaný soubor:** ServiceCatalogDbContext.cs, ImportOrchestrationService.cs  
**Status:** 🟡 ČEKÁ NA SCHVÁLENÍ

---

## 📋 SHRNUTÍ EXECUTIVE SUMMARY

### Nalezené chyby
- **KRITICKÉ:** 1 (blokuje import služeb)
- **VYSOKÁ PRIORITA:** 1 (přispívá ke kritické chybě)
- **STŘEDNÍ PRIORITA:** 3 (mapování sloupců, potenciální korupce dat)
- **NÍZKÁ PRIORITA:** 2 (konvenční problémy)

### Dopad
- **PŘED opravou:** 0% úspěšnost importu (kritický blok)
- **PO opravě:** 100% očekávaná úspěšnost
- **Odhadovaný čas opravy:** 30-45 minut

---

## 🔴 KRITICKÁ CHYBA #1: ServiceSizeOption Entity Tracking Conflict

### Popis chyby
```
System.InvalidOperationException: The instance of entity type 'ServiceSizeOption' 
cannot be tracked because another instance with the same key value for 
{'ServiceSizeOptionId'} is already being tracked.
```

### Lokace
- **Soubor:** `ImportOrchestrationService.cs`
- **Řádek:** ~1100
- **Metoda:** `ImportSizeOptionsAsync`

### Kořenová příčina
1. Metoda `ImportSizeOptionsAsync` prochází v cyklu jednotlivé size options
2. Pro každou size option dotazuje `LU_SizeOption` **S TRACKINGEM**
3. Vytváří `ServiceSizeOption` entity s FK na `LU_SizeOption`
4. Volá `SaveChangesAsync` pro každou entitu
5. Databáze vrací vygenerované `ServiceSizeOptionId` (IDENTITY)
6. EF propaguje ID zpět přes `ColumnModification.SetStoreGeneratedValue`
7. **ERROR:** IdentityMap již má tuto entitu trackovnou

### Technické důvody
- **EF Core Identity Map:** Zabraňuje duplicitním klíčům v ChangeTracker
- **Tracking v loopu:** Opakované dotazy na `LU_SizeOption` způsobují konflikty
- **Propagace ID:** Když DB vrací ID, EF se pokouší aktualizovat již trackovanou entitu

### Problémový kódový tok
```
ImportServiceAsync
  └─> ImportSizeOptionsAsync (line 1100)
        ├─> Loop: foreach (var sizeOption in sizeOptions)
        │     ├─> Query LU_SizeOption WITH TRACKING ❌
        │     ├─> Create ServiceSizeOption
        │     ├─> Add to context
        │     └─> SaveChangesAsync
        │           └─> DB returns ServiceSizeOptionId
        │                 └─> EF propagates ID
        │                       └─> ERROR: Duplicate key in ChangeTracker
        └─> Related failures: EffortEstimationItem, ServiceLicense
```

---

## 🔧 NAVRŽENÉ ŘEŠENÍ #1: KRITICKÁ OPRAVA

### Změny v ImportOrchestrationService.cs (řádek ~1090-1110)

#### Strategie A: AsNoTracking + Batch Insert (DOPORUČENO)
```csharp
public async Task ImportSizeOptionsAsync(int serviceId, List<SizeOptionModel> sizeOptions)
{
    _logger.LogInformation("Importing {Count} size options", sizeOptions.Count);
    
    // FIX 1: Load all LU_SizeOptions at once WITH AsNoTracking()
    var sizeOptionCodes = sizeOptions.Select(so => so.Size.ToUpperInvariant()).Distinct().ToList();
    var luSizeOptions = await _context.LU_SizeOptions
        .AsNoTracking() // ✅ Prevents tracking conflicts
        .Where(lu => sizeOptionCodes.Contains(lu.Code))
        .ToDictionaryAsync(lu => lu.Code, lu => lu.SizeOptionId);
    
    // FIX 2: Batch all entities into single list
    var serviceSizeOptions = new List<ServiceSizeOption>();
    
    foreach (var sizeOption in sizeOptions)
    {
        var sizeCode = sizeOption.Size.ToUpperInvariant();
        
        if (!luSizeOptions.TryGetValue(sizeCode, out var sizeOptionId))
        {
            _logger.LogWarning("Size option {Size} not found in LU_SizeOption", sizeCode);
            continue;
        }
        
        var serviceSizeOption = new ServiceSizeOption
        {
            ServiceId = serviceId,
            SizeOptionId = sizeOptionId, // FK to LU_SizeOption
            Description = sizeOption.Description,
            Duration = sizeOption.Duration,
            DurationInDays = sizeOption.DurationInDays,
            EffortRange = sizeOption.EffortRange,
            Complexity = sizeOption.Complexity,
            TeamSize = sizeOption.TeamSize
        };
        
        serviceSizeOptions.Add(serviceSizeOption);
    }
    
    // FIX 3: Single batch insert
    if (serviceSizeOptions.Any())
    {
        await _context.ServiceSizeOptions.AddRangeAsync(serviceSizeOptions);
        await _unitOfWork.SaveChangesAsync(); // ✅ Single SaveChanges for all entities
        _logger.LogInformation("Successfully imported {Count} size options", serviceSizeOptions.Count);
    }
}
```

#### Strategie B: Clear ChangeTracker (alternativa)
```csharp
public async Task ImportSizeOptionsAsync(int serviceId, List<SizeOptionModel> sizeOptions)
{
    foreach (var sizeOption in sizeOptions)
    {
        // Query with AsNoTracking
        var luSizeOption = await _context.LU_SizeOptions
            .AsNoTracking()
            .FirstOrDefaultAsync(lu => lu.Code == sizeOption.Size.ToUpperInvariant());
        
        if (luSizeOption == null) continue;
        
        var serviceSizeOption = new ServiceSizeOption
        {
            ServiceId = serviceId,
            SizeOptionId = luSizeOption.SizeOptionId,
            // ... other properties
        };
        
        await _context.ServiceSizeOptions.AddAsync(serviceSizeOption);
        await _unitOfWork.SaveChangesAsync();
        
        // FIX: Clear ChangeTracker after each save
        _context.ChangeTracker.Clear(); // ✅ Removes all tracked entities
    }
}
```

### Doporučení
**Použít Strategii A (Batch Insert)** protože:
1. ✅ Výrazně lepší výkon (1 dotaz místo N dotazů)
2. ✅ Nižší zátěž databáze
3. ✅ Atomická operace (všechno uspěje nebo nic)
4. ✅ Čistší ChangeTracker management

---

## 🟡 VYSOKÁ PRIORITA #2: LU_SizeOption Tracking v loopu

### Problém
`LU_SizeOption` je dotazována v loopu **BEZ** `AsNoTracking()`, což způsobuje tracking conflicts.

### Řešení
Viz Strategie A výše - načíst všechny LU_SizeOptions najednou s `AsNoTracking()`.

---

## 🟠 STŘEDNÍ PRIORITA #3: ServiceLicense Column Mapping

### Problém
```csharp
// ServiceCatalogDbContext.cs line 406
entity.Property(e => e.LicenseName).HasColumnName("LicenseDescription");
```

**Důsledek:** Entity vlastnost `LicenseName` mapována na DB sloupec `LicenseDescription` - možná záměna sloupců!

### Ověření potřebné
Zkontrolovat `db_structure.sql`:
```sql
-- Co je skutečný název sloupce v DB?
CREATE TABLE ServiceLicense (
    LicenseId INT,
    LicenseName NVARCHAR(200),        -- nebo
    LicenseDescription NVARCHAR(MAX)  -- toto?
);
```

### Možná řešení
```csharp
// Varianta 1: Sloupec se skutečně jmenuje LicenseDescription
entity.Property(e => e.LicenseName).HasColumnName("LicenseDescription"); // ✅ OK

// Varianta 2: Sloupec se jmenuje LicenseName
entity.Property(e => e.LicenseName); // ✅ Odstranit HasColumnName

// Varianta 3: Přejmenovat entity property na LicenseDescription
public string LicenseDescription { get; set; } // V entity třídě
entity.Property(e => e.LicenseDescription); // V DbContext
```

### Doporučení
**Ověřit db_structure.sql a odstranit mapování, pokud názvy odpovídají.**

---

## 🟠 STŘEDNÍ PRIORITA #4: ServiceToolFramework PK Mapping

### Problém
```csharp
// ServiceCatalogDbContext.cs line 398
entity.Property(e => e.ToolId).HasColumnName("ToolFrameworkID");
```

**Důsledek:** PK property `ToolId` mapován na DB sloupec `ToolFrameworkID` - potenciální konflikty.

### Ověření potřebné
```sql
-- V db_structure.sql
CREATE TABLE ServiceToolFramework (
    ToolFrameworkID INT PRIMARY KEY, -- Skutečný název?
    ...
);
```

### Doporučení
**Ověřit a zvážit přejmenování entity property na `ToolFrameworkId` pro konzistenci.**

---

## 🟠 STŘEDNÍ PRIORITA #5: TechnicalComplexityAddition PK Mapping

### Problém
```csharp
// ServiceCatalogDbContext.cs line 431
entity.Property(e => e.AdditionId).HasColumnName("ComplexityAdditionID");
```

**Důsledek:** Stejný problém jako u ServiceToolFramework.

### Doporučení
**Konzistence názvů: entity `AdditionId` ↔ DB `ComplexityAdditionID`.**

---

## 🔵 NÍZKÁ PRIORITA #6: ServiceSizeOption Missing Explicit Relationship

### Problém
DbContext nemá explicitně definovaný vztah `ServiceSizeOption -> LU_SizeOption`.

### Navržené řešení
```csharp
// ServiceCatalogDbContext.cs - přidat po řádku 311
modelBuilder.Entity<ServiceSizeOption>(entity =>
{
    entity.ToTable("ServiceSizeOption");
    entity.HasKey(e => e.ServiceSizeOptionId);

    // Explicit relationship to LU_SizeOption
    entity.HasOne<LU_SizeOption>()
        .WithMany()
        .HasForeignKey(e => e.SizeOptionId)
        .OnDelete(DeleteBehavior.Restrict); // ✅ Prevent cascade delete
    
    // Relationship to Service (already exists via convention)
    entity.HasOne(e => e.Service)
        .WithMany(s => s.SizeOptions)
        .HasForeignKey(e => e.ServiceId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

## 🔵 NÍZKÁ PRIORITA #7: ServicePricingConfig Missing ToTable()

### Problém
```csharp
// ServiceCatalogDbContext.cs line 445
modelBuilder.Entity<ServicePricingConfig>().HasKey(e => e.PricingConfigId);
// ❌ Chybí .ToTable("ServicePricingConfig")
```

### Řešení
```csharp
modelBuilder.Entity<ServicePricingConfig>(entity =>
{
    entity.ToTable("ServicePricingConfig"); // ✅ Explicitní název tabulky
    entity.HasKey(e => e.PricingConfigId);
});
```

---

## 📝 VALIDAČNÍ PLÁN

### Krok 1: Aplikovat kritickou opravu
- [ ] Upravit `ImportOrchestrationService.ImportSizeOptionsAsync`
- [ ] Implementovat Strategii A (Batch Insert + AsNoTracking)

### Krok 2: Testovat import
- [ ] Spustit import služby ID999 s multiple size options
- [ ] Ověřit log: žádné `InvalidOperationException`
- [ ] Ověřit DB: všechny `ServiceSizeOption` záznamy vytvořeny

### Krok 3: Ověřit related entities
- [ ] `EffortEstimationItem.ServiceSizeOptionId` správně vyplněné
- [ ] `ServiceLicense` importy fungují
- [ ] `TimelinePhase` importy fungují

### Krok 4: Opravit DbContext mappings
- [ ] Ověřit `ServiceLicense.LicenseName` mapping proti db_structure.sql
- [ ] Přidat explicitní `ServiceSizeOption` relationship
- [ ] Opravit `ServicePricingConfig.ToTable()`

### Kritéria úspěchu
✅ Import dokončen se statusem 200  
✅ Žádné `InvalidOperationException` v logách  
✅ Všechny `ServiceSizeOption` záznamy v DB  
✅ `EffortEstimationItem` relationships fungují  

---

## 📊 ANALÝZA RIZIK

### Před opravou
| Metrika | Hodnota |
|---------|---------|
| Úspěšnost importu | **0%** |
| Závažnost blokace | **KRITICKÁ** |
| Postižené funkce | Import služeb, Size Options, Effort Estimation |

### Po opravě
| Metrika | Hodnota |
|---------|---------|
| Očekávaná úspěšnost | **100%** |
| Residuální rizika | Column mapping issues (středně závažné) |
| Doporučený monitoring | ServiceLicense/ToolFramework mapping errors |

---

## 📁 SOUBORY K ÚPRAVĚ

### 1. ImportOrchestrationService.cs
- **Cesta:** `src/backend/ServiceCatalogueManager.Api/Services/Import/ImportOrchestrationService.cs`
- **Řádky:** ~1090-1110
- **Typ změny:** **KRITICKÁ OPRAVA**
- **Popis:** AsNoTracking + Batch insert

### 2. ServiceCatalogDbContext.cs
- **Cesta:** `src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs`
- **Řádky:** 302-312 (ServiceSizeOption), 402-407 (ServiceLicense)
- **Typ změny:** **VYSOKÁ PRIORITA**
- **Popis:** Explicit relationships + Column mapping fixes

---

## ✅ SCHVÁLENÍ

**Prosím schvalte následující akce:**

1. ✅ **Aplikovat kritickou opravu #1** (ImportSizeOptionsAsync - Batch Insert)
2. ✅ **Přidat explicit ServiceSizeOption relationship** (DbContext)
3. ⚠️ **Ověřit a opravit ServiceLicense column mapping** (vyžaduje kontrolu db_structure.sql)
4. ⚠️ **Ověřit ServiceToolFramework & TechnicalComplexityAddition** (vyžaduje kontrolu db_structure.sql)
5. ✅ **Přidat ServicePricingConfig.ToTable()** (low priority)

**Odhadovaný čas implementace:** 30-45 minut  
**Testovací čas:** 15-20 minut  
**Celkem:** ~1 hodina

---

## 🎯 DALŠÍ KROKY

Po schválení provedu:
1. Implementaci kritické opravy #1
2. Úpravu ServiceCatalogDbContext.cs
3. Vytvoření unit testů pro ImportSizeOptionsAsync
4. Validaci proti db_structure.sql
5. Commit & PR s detailním popisem změn

**Schválit a pokračovat?** (ano/ne/upravit)
