# Souhrn oprav - Service Catalogue Manager

## Datum: 27. ledna 2026

### Opravené chyby:

#### 1. ERROR CS0019 - ImportFunction.cs (řádek 202)
**Problém:** Operátor `??` nelze použít na operandy typu `IEnumerable<anonymous type>` a `object[]`.

**Řešení:** 
- Přidán `.ToArray()` na výsledek `Select()` pro převod `IEnumerable` na pole
- Soubor: `src/backend/ServiceCatalogueManager.Api/Functions/ImportFunction.cs`
- Změna na řádku 207:
  ```csharp
  // Před:
  }) ?? Array.Empty<object>()
  
  // Po:
  }).ToArray() ?? Array.Empty<object>()
  ```

#### 2. JSON Schema Validation Error - PDF Extractor
**Problém:** Extrakce z PDF generovala stringy místo objektů pro pole `designTools` a další tool kategorie.

**Řešení:**
1. **Vylepšení promptu** (`tools/pdf-extractor/extract_services.py`):
   - Přidány jasné instrukce, že všechny tools musí být objekty s vlastnostmi:
     - `category`: string
     - `toolName`: string
     - `version`: string
     - `purpose`: string
   - Přidán explicitní příklad formátu

2. **Nová normalizační funkce** `_normalize_tools_and_environment()`:
   - Automaticky opravuje špatně strukturovaná data před validací
   - Konvertuje stringy na správné objekty
   - Opravuje legacy formát s polem `tools` na správný `toolName`
   - Zpracovává speciální strukturu cloudPlatforms
   - Soubor: `tools/pdf-extractor/extract_services.py`

#### 3. Bezpečnostní varování NU1902 - Microsoft.Identity.Web
**Problém:** Balíček `Microsoft.Identity.Web` verze 3.7.0 má známou bezpečnostní zranitelnost.

**Řešení:**
- Aktualizace z verze 3.7.0 na 3.8.0
- Soubor: `src/backend/ServiceCatalogueManager.Api/ServiceCatalogueManager.Api.csproj`
- Změna na řádku 35:
  ```xml
  <!-- Před: -->
  <PackageReference Include="Microsoft.Identity.Web" Version="3.7.0" />
  
  <!-- Po: -->
  <PackageReference Include="Microsoft.Identity.Web" Version="3.8.0" />
  ```

### Testování:

Po aplikaci těchto oprav:
1. Backend by se měl úspěšně zkompilovat bez chyby CS0019
2. PDF extractor by měl správně validovat výstupní JSON proti schématu
3. Nemělo by se zobrazovat bezpečnostní varování pro Microsoft.Identity.Web

### Technické detaily:

**Soubory upravené:**
1. `src/backend/ServiceCatalogueManager.Api/Functions/ImportFunction.cs`
2. `tools/pdf-extractor/extract_services.py`
3. `src/backend/ServiceCatalogueManager.Api/ServiceCatalogueManager.Api.csproj`

**Změněné řádky:**
- ImportFunction.cs: řádek 207
- extract_services.py: řádky 191-199 (prompt), nová funkce ~65 řádků
- ServiceCatalogueManager.Api.csproj: řádek 35
