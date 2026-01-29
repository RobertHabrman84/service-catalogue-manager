# Changelog v2.9.8

## Datum: 2026-01-29

## Opravená chyba

### UNIQUE KEY Constraint Violation při importu služeb

**Symptom:**
```
Violation of UNIQUE KEY constraint 'UQ__LU_Prere__371BA9551737C7CA'. 
Cannot insert duplicate key in object 'dbo.LU_PrerequisiteCategory'. 
The duplicate key value is (ORGANIZATIONAL).
```

**SKUTEČNÁ Příčina (v2.9.8 FIX):**
Metody `FindOrCreate*` hledaly existující záznamy podle sloupce `Name`, ale UNIQUE constraint je na sloupci `Code`!

```csharp
// ŠPATNĚ - hledání podle Name
var category = categories.FirstOrDefault(c => 
    c.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));

// Ale UNIQUE constraint je na Code, ne na Name!
// Pokud v DB existuje záznam s Code="ORGANIZATIONAL" ale Name="", kód ho NENAJDE
// a pokusí se vytvořit duplicitní Code → UNIQUE KEY VIOLATION
```

**Řešení:**
1. Změna vyhledávání z `Name` na `Code`
2. Konzistentní použití `cacheKey` s `.Replace(" ", "_")` 
3. Použití session cache pro prevenci duplicit v rámci transakce

### Opravené metody:

| Metoda | Cache | Hledání (PŘED) | Hledání (PO) |
|--------|-------|----------------|--------------|
| `FindOrCreateRequirementLevelAsync` | `_requirementLevelCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreateDependencyTypeAsync` | `_dependencyTypeCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreateScopeTypeAsync` | `_scopeTypeCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreateInteractionLevelAsync` | `_interactionLevelCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreatePrerequisiteCategoryAsync` | `_prerequisiteCategoryCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreateLicenseTypeAsync` | `_licenseTypeCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |
| `FindOrCreateSizeOptionAsync` | `_sizeOptionCache` | `.Name.Equals(...)` | `.Code.Equals(...)` |

### Vzor opravy (příklad pro PrerequisiteCategory):

```csharp
private async Task<LU_PrerequisiteCategory?> FindOrCreatePrerequisiteCategoryAsync(string categoryName)
{
    // 1. Cache key konzistentní s Code formátem
    var cacheKey = categoryName.ToUpper().Replace(" ", "_");
    if (_prerequisiteCategoryCache.TryGetValue(cacheKey, out var cached))
    {
        return cached;
    }

    var categories = await _unitOfWork.PrerequisiteCategories.GetAllAsync();
    
    // 2. HLEDÁNÍ PODLE CODE (má UNIQUE constraint), NE PODLE NAME!
    var category = categories.FirstOrDefault(c => 
        c.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
    
    if (category == null)
    {
        _logger.LogInformation("Creating prerequisite category: {CategoryName}", categoryName);
        category = new LU_PrerequisiteCategory
        {
            Code = cacheKey,  // Použití stejného klíče
            Name = categoryName,
            Description = $"Auto-created: {categoryName}",
            SortOrder = 1
        };
        category = await _unitOfWork.PrerequisiteCategories.AddAsync(category);
        await _unitOfWork.SaveChangesAsync();
    }
    
    // 3. Uložení do cache
    _prerequisiteCategoryCache[cacheKey] = category;
    
    return category;
}
```

## Změněné soubory

- `src/backend/ServiceCatalogueManager.Api/Services/Import/ImportOrchestrationService.cs`

## Poznámky k testování

Po aplikaci opravy by import služby měl:
1. Najít existující lookup záznamy podle Code (i když mají jiné Name)
2. Nevytvářet duplicitní záznamy
3. Správně fungovat i při opakovaných importech

## Verze

- Předchozí verze: 2.9.7
- Aktuální verze: 2.9.8 (FINAL FIX)
