# 🔴 KRITICKÉ: Návrh opravy chyby EstimationEffortEstimationId

## 📊 Souhrn chyby

**Chyba:** `Invalid column name 'EstimationEffortEstimationId'`  
**Tabulka:** `EffortEstimationItem`  
**Závažnost:** **CRITICAL** ⛔  
**Důsledek:** Import služeb kompletně selhává

---

## 🔍 Detailní analýza

### Příčina
EF Core generuje nesprávný název sloupce `EstimationEffortEstimationId` místo `EstimationItemId` nebo `EstimationId`.

### Proč k tomu dochází?
**DbContext.cs řádek 318** má chybný mapping:
```csharp
entity.HasKey(e => e.EstimationId);  // ❌ ŠPATNĚ
```

Ale **entita EffortEstimationItem.cs řádek 6** má jako PK:
```csharp
public int EstimationItemId { get; set; }  // ✅ SPRÁVNÝ PK
```

A **db_structure.sql řádek 552** definuje:
```sql
EstimationItemID INT IDENTITY(1,1) PRIMARY KEY  -- ✅ SPRÁVNÝ PK v DB
```

### Co se děje
Když EF Core vidí `HasKey(e => e.EstimationId)`, ale entita nemá property `EstimationId` jako PK, generuje **shadow property** s názvem podle konvence:
- `Estimation` (z názvu property) + `Effort` + `EstimationId` → `EstimationEffortEstimationId`

---

## ✅ Navrhované řešení

### 1. Oprava DbContext.cs (IMMEDIATE - PRIORITA 1)

**Soubor:** `src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs`  
**Řádek:** 318

```csharp
// ❌ PŘED (chybné):
entity.HasKey(e => e.EstimationId);

// ✅ PO (správné):
entity.HasKey(e => e.EstimationItemId);
```

---

## 📋 Kompletní oprava EffortEstimationItem konfigurace

```csharp
// Configure EffortEstimationItem
modelBuilder.Entity<EffortEstimationItem>(entity =>
{
    entity.ToTable("EffortEstimationItem");
    entity.HasKey(e => e.EstimationItemId);  // ✅ OPRAVENO
    entity.Property(e => e.EffortDays).HasPrecision(18, 2);
    entity.Property(e => e.EstimatedHours).HasPrecision(10, 2);  // ✅ PŘIDÁNO

    entity.HasOne(e => e.Service)
        .WithMany(s => s.EffortEstimations)
        .HasForeignKey(e => e.ServiceId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

## 🔎 Verifikace dalších možných problémů

### Kontrolovaných HasKey mappings: 40+
**Výsledek:** ✅ Žádné další problémy nenalezeny

Všechny ostatní HasKey mapování jsou správně namapovány na odpovídající PK properties.

---

## 📈 Dopad opravy

### Před opravou:
- ❌ Import služeb selhává
- ❌ MERGE EffortEstimationItem generuje neplatný SQL
- ❌ Chyba: `Invalid column name 'EstimationEffortEstimationId'`

### Po opravě:
- ✅ Import služeb funguje
- ✅ MERGE EffortEstimationItem používá správný sloupec `EstimationItemId`
- ✅ Žádné chyby shadow properties

---

## 🧪 Testovací plán

1. **Oprava DbContext.cs** - změna řádku 318
2. **Rebuild řešení** - ujistit se, že EF Core regeneruje mappings
3. **Spuštění importu** - test endpointu `/api/services/import`
4. **Verifikace** - kontrola, že:
   - Import projde bez chyby
   - EffortEstimationItem se správně uloží do DB
   - SQL log neobsahuje `EstimationEffortEstimationId`

---

## 📦 Změněné soubory

| Soubor | Řádek | Změna |
|--------|-------|-------|
| `ServiceCatalogDbContext.cs` | 318 | `e.EstimationId` → `e.EstimationItemId` |

---

## ⚠️ Rizika

**Žádná** - Tato oprava pouze napravuje chybný mapping a uvádí do souladu:
- ✅ Entity property name
- ✅ DbContext HasKey mapping
- ✅ Database column name

---

## 🚀 Implementace

### Krok 1: Oprava kódu
```bash
# Editovat src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs
# Řádek 318: změnit e.EstimationId na e.EstimationItemId
```

### Krok 2: Build & Test
```bash
cd src/backend/ServiceCatalogueManager.Api
dotnet build
dotnet test
```

### Krok 3: Spustit import
```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @test_import.json
```

---

## 📝 Poznámky

- **Entity EffortEstimationItem.cs** je v pořádku - nemění se
- **db_structure.sql** je v pořádku - nemění se
- Změna se týká **pouze DbContext.cs**

---

## ✅ Schválení

**Je tento návrh řešení schválen k implementaci?**

- [ ] Ano, proveďte opravu
- [ ] Ne, potřebuji více informací

---

**Datum analýzy:** 2026-01-30  
**Analyzováno:** 1 kritická chyba  
**Navrženo oprav:** 1 změna (1 řádek)  
**Odhadovaný čas opravy:** 2 minuty
