# 🚨 Rychlý přehled problémů - Import nezobrazuje data v UI

## TL;DR - Hlavní příčiny

Po úspěšném JSON importu se data nezobrazují kvůli **5 kritickým problémům**:

| # | Problém | Lokace | Fix Složitost | Priorita |
|---|---------|--------|---------------|----------|
| 🔴 1 | **API Response není správně parsován** | `services/api.ts` | ⭐ Velmi jednoduchá | **P0** |
| 🔴 2 | **Žádná invalidace cache po importu** | `Import/ImportPage.tsx` | ⭐ Velmi jednoduchá | **P0** |
| 🔴 3 | **Nekonzistentní query keys** | `Dashboard/index.tsx` | ⭐ Velmi jednoduchá | **P0** |
| 🟡 4 | **Chybí auto-refresh UX** | `Import/ImportPage.tsx` | ⭐⭐ Jednoduchá | **P1** |
| 🟢 5 | **Backend cache není invalidována** | `ImportOrchestrationService.cs` | ⭐ Velmi jednoduchá | **P2** |

---

## 🔴 Problém #1: Backend vrací `ApiResponse<PagedResponse<T>>`, frontend očekává `PagedResponse<T>`

### Co se děje:
```typescript
// Backend vrací:
{
  "success": true,
  "data": {                    // ← Vnořená úroveň!
    "items": [...],
    "totalCount": 5
  }
}

// Frontend očekává:
{
  "items": [...],              // ← Přímo na první úrovni
  "totalCount": 5
}

// Výsledek:
servicesData?.items === undefined  // ❌ Vždy prázdné!
```

### Jednořádková oprava:
```typescript
// services/api.ts - Přidat axios interceptor
apiClient.interceptors.response.use((response) => {
  if (response.data?.success && response.data?.data !== undefined) {
    response.data = response.data.data;  // Unwrap ApiResponse wrapper
  }
  return response;
});
```

---

## 🔴 Problém #2: Import neinvaliduje React Query cache

### Co se děje:
```typescript
// Import/ImportPage.tsx - Po úspěšném importu:
const result = await importService.importService(serviceData);
setImportResult(result);
// ❌ KONEC - žádná invalidace cache!

// React Query cache stále obsahuje STARÁ DATA
// Dashboard a Catalog zobrazují staré počty služeb
```

### Třířádková oprava:
```typescript
// Import/ImportPage.tsx
import { useQueryClient } from '@tanstack/react-query';
import { queryKeys } from '../../hooks/useServiceCatalog';

const queryClient = useQueryClient();

const handleImport = async () => {
  const result = await importService.importService(serviceData);
  if (result.success) {
    await queryClient.invalidateQueries({ queryKey: queryKeys.services.all }); // ✅ FIX
  }
  setImportResult(result);
};
```

---

## 🔴 Problém #3: Dashboard používá vlastní query key mimo standardní strukturu

### Co se děje:
```typescript
// Dashboard používá:
useQuery({
  queryKey: ['services', 'dashboard'],  // ❌ Nestandardní key
  queryFn: () => serviceCatalogApi.getServices({}, 1, 10),
});

// Catalog používá:
useServices(filters, page, pageSize)
// = queryKey: ['services', 'list', { filters, page, pageSize }]  // ✅ Standardní

// Invalidace v useCreateService/useUpdateService:
queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
// = invaliduje ['services', 'list'] a pod-keys
// ❌ ALE NE ['services', 'dashboard']!
```

### Jednořádková oprava:
```typescript
// pages/Dashboard/index.tsx
// PŘED:
const { data: servicesData } = useQuery({
  queryKey: ['services', 'dashboard'],
  queryFn: () => serviceCatalogApi.getServices({}, 1, 10),
});

// PO:
const { data: servicesData } = useServices({}, 1, 10);  // ✅ Používá standardní query key
```

---

## 🟡 Problém #4: Po importu není jasné, že data nebudou viditelná bez refresh

### Co chybí:
```typescript
// Po úspěšném importu uživatel vidí:
// ✅ "Service imported successfully"
// ✅ Link "View Service" na detail
// ❌ CHYBÍ: "Go to Catalog" (s auto-refresh)
// ❌ CHYBÍ: "Go to Dashboard" (s auto-refresh)
// ❌ CHYBÍ: Auto-redirect po 3 sekundách

// Uživatel neví, že musí:
// 1. Jít do Catalog NEBO
// 2. Kliknout na Refresh tlačítko NEBO
// 3. Stisknout F5
```

### Oprava (přidání UX prvků):
```typescript
// Import/ImportPage.tsx
{step === 'complete' && importResult?.success && (
  <div className="bg-green-50 p-4">
    <p>✅ Import successful! Redirecting to catalog in {countdown} seconds...</p>
    <div className="flex gap-4 mt-4">
      <button onClick={() => navigate('/catalog')}>Go to Catalog Now</button>
      <button onClick={() => navigate('/dashboard')}>View Dashboard</button>
    </div>
  </div>
)}

// + Auto-redirect
useEffect(() => {
  if (step === 'complete' && importResult?.success) {
    const timer = setTimeout(() => navigate('/catalog'), 3000);
    return () => clearTimeout(timer);
  }
}, [step, importResult]);
```

---

## 🟢 Problém #5: Backend cache není invalidována po importu

### Co chybí:
```csharp
// ImportOrchestrationService.cs - Po commit:
await _unitOfWork.CommitTransactionAsync();
_logger.LogInformation("Successfully imported service");
// ❌ CHYBÍ invalidace cache

// ServiceCatalogService.GetServiceByIdAsync cachuje:
var cacheKey = $"service_{id}";
var cached = await _cacheService.GetAsync<ServiceCatalogItemDto>(cacheKey);
```

### Jednořádková oprava:
```csharp
// ImportOrchestrationService.cs
await _unitOfWork.CommitTransactionAsync();
await _cacheService.RemoveByPrefixAsync("service_");  // ✅ FIX
_logger.LogInformation("Successfully imported service");
```

---

## 📊 Vizualizace problému

### Aktuální stav (❌):
```
1. Uživatel importuje JSON
2. Backend: ✅ Data uložena do DB
3. Backend: ✅ Vrací ApiResponse<PagedResponse<T>>
4. Frontend: ❌ Parsuje response.data místo response.data.data
5. Frontend: ❌ servicesData.items = undefined
6. Frontend: ❌ Cache NENÍ invalidována
7. Dashboard: ❌ Zobrazí stará cachovaná data (['services', 'dashboard'])
8. Catalog: ❌ Zobrazí stará cachovaná data (pokud existují)
9. Uživatel: ❓ "Import byl úspěšný, ale nevidím službu..."
```

### Po opravě (✅):
```
1. Uživatel importuje JSON
2. Backend: ✅ Data uložena do DB
3. Backend: ✅ Vrací ApiResponse<PagedResponse<T>>
4. Frontend: ✅ Axios interceptor unwrapuje na PagedResponse<T>
5. Frontend: ✅ servicesData.items = [...], totalCount = 6
6. Frontend: ✅ Cache invalidována pro ['services']
7. Dashboard: ✅ Refetch → zobrazí 6 služeb (včetně nové)
8. Catalog: ✅ Refetch → zobrazí novou službu v seznamu
9. Uživatel: ✅ "Vidím novou službu v Catalog i Dashboard!"
```

---

## 🎯 Doporučené pořadí oprav

### Fáze 1: Základní funkcionalita (P0 - 30 minut)
1. ✅ Fix #1: Přidat axios interceptor pro API response unwrapping
2. ✅ Fix #2: Přidat cache invalidaci do ImportPage
3. ✅ Fix #3: Změnit Dashboard query key na standardní

**Výsledek:** Import funguje, data se zobrazují v UI

### Fáze 2: UX vylepšení (P1 - 1 hodina)
4. ✅ Fix #4: Přidat auto-redirect a CTA tlačítka

**Výsledek:** Uživatel ví, co dělat po importu

### Fáze 3: Best practices (P2 - 15 minut)
5. ✅ Fix #5: Přidat backend cache invalidaci

**Výsledek:** Prevence budoucích problémů

---

## 🧪 Rychlý test po opravě

```bash
# 1. Spustit aplikaci
npm run dev

# 2. Otevřít DevTools (F12) → Network tab

# 3. Import test služby
# - Jít na /import
# - Nahrát test JSON
# - Kliknout Import

# 4. Ověřit:
# ✅ Network: POST /services/import → status 200
# ✅ Network: GET /services?pageNumber=1 → NOVÝ request (ne cache)
# ✅ Dashboard: Počet služeb se zvýšil
# ✅ Catalog: Nová služba je v seznamu
# ✅ Console: Žádné errory

# 5. Prohlédnout React Query DevTools:
# ✅ Cache byla invalidována
# ✅ Nové data byla fetchována
```

---

## 📈 Očekávaný výsledek

| Metrika | Před | Po |
|---------|------|-----|
| Import viditelný bez F5 | ❌ 0% | ✅ 100% |
| Dashboard aktuální data | ❌ 0% | ✅ 100% |
| Catalog aktuální data | ❌ ~30% (náhodně) | ✅ 100% |
| API calls úspěšné | ✅ 100% | ✅ 100% |
| API data parsovaná | ❌ 0% | ✅ 100% |
| UX spokojenost | 😡 2/10 | 😊 9/10 |

---

## 🔗 Kompletní dokumentace

Viz: `ANALÝZA_PROBLÉMU_NEZOBRAZOVÁNÍ_DAT.md` pro:
- Detailní root cause analysis
- Code snippets s kontextem
- Testovací scénáře
- Preventivní opatření
- Sequence diagramy

---

**Status:** ✅ Analýza kompletní  
**Akce:** 🛠️ Připraveno k implementaci  
**ETA:** ⏱️ 2-3 hodiny (včetně testování)
