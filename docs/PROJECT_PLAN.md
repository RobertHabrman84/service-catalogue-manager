# Service Catalogue Manager - Import Feature

## 📋 Cíl řešení

### Problém
Organizace má služby zdokumentované v **PDF formátu** (20-30 stránek na službu) a potřebuje je převést do **strukturované databáze** pro Service Catalogue Manager.

### Řešení
Automatizovaný import služeb z PDF dokumentů do databáze pomocí AI-powered extrakce a validace.

### Klíčové požadavky
1. ✅ **Automatická extrakce** - Minimalizovat ruční práci
2. ✅ **Validace** - Zajistit kvalitu a konzistenci dat
3. ✅ **Kompletnost** - Zachytit všechny důležité informace (38 databázových tabulek)
4. ✅ **Bezpečnost** - Transactional import (all-or-nothing)
5. ✅ **Škálovatelnost** - Batch processing pro více služeb

---

## 🏗️ Architektura řešení

```
┌─────────────────────────────────────────────────────────┐
│                   PDF DOCUMENTS                         │
│          (Enterprise LZ Design, App LZ Design)          │
└─────────────────────────────────────────────────────────┘
                        │
                        │ FÁZE 2: PDF Extraction
                        ↓
┌─────────────────────────────────────────────────────────┐
│           PDF EXTRACTION TOOL (Python)                  │
│         Uses Claude API to extract structured data      │
│                                                          │
│  - extract_services.py                                  │
│  - Claude Sonnet 4 API                                  │
│  - JSON Schema validation                               │
└─────────────────────────────────────────────────────────┘
                        │
                        │ Generated JSON files
                        ↓
┌─────────────────────────────────────────────────────────┐
│              JSON FILES (output/)                       │
│    - Enterprise_Scale_LZ.json                          │
│    - Application_LZ.json                               │
└─────────────────────────────────────────────────────────┘
                        │
                        │ FÁZE 1: JSON Schema & Models
                        │ FÁZE 3: Lookup Resolution
                        │ FÁZE 4: Validation
                        │ FÁZE 5: Orchestration
                        ↓
┌─────────────────────────────────────────────────────────┐
│      SERVICE CATALOGUE MANAGER (C# / .NET)             │
│                                                          │
│  1. Validation Service                                  │
│     - Business rules                                    │
│     - Lookup validation                                 │
│     - Duplicate detection                               │
│                                                          │
│  2. Lookup Resolution Service                           │
│     - Friendly names → Database IDs                     │
│     - 30-minute caching                                 │
│                                                          │
│  3. Import Orchestration Service                        │
│     - Transaction management                            │
│     - Entity mapping                                    │
│     - Database insertion                                │
└─────────────────────────────────────────────────────────┘
                        │
                        │ Validated & Imported
                        ↓
┌─────────────────────────────────────────────────────────┐
│            AZURE SQL DATABASE                           │
│              (38 tables)                                │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Rozsah dat

### PDF Dokument obsahuje
- **Základní info:** ID, název, verze, kategorie, popis
- **8 usage scenarios** - Kdy a jak službu použít
- **Dependencies:** Prerequisite, Triggers, Parallel (s requirement levels)
- **Scope:** 10 kategorií in-scope items + 12 out-of-scope items
- **Prerequisites:** Organizational, Technical, Documentation
- **Tools & Environment:** 5 kategorií nástrojů
- **Licenses:** Required, Recommended, Provided
- **Stakeholder Interaction:** HIGH level, workshop roles, access requirements
- **Service Inputs:** ~15 parametrů s requirement levels
- **Service Outputs:** ~10 kategorií výstupů
- **Timeline:** Fáze s durací podle velikosti
- **Size Options (S/M/L):** Každá obsahuje:
  - Effort breakdown (11 oblastí)
  - Complexity additions
  - Team allocation
  - 3 sizing examples
  - Sizing parameters
- **Responsible Roles:** 4-5 rolí
- **Multi-Cloud Considerations:** Specifické požadavky

### Databázová struktura (38 tabulek)
1. ServiceCatalogItem (parent)
2. UsageScenario (1:N)
3. ServiceDependency (1:N)
4. ServiceScopeCategory + ServiceScopeItem (1:N:M)
5. ServicePrerequisite (1:N)
6. ServiceToolFramework (1:N)
7. ServiceLicense (1:N)
8. ServiceInteraction + StakeholderInvolvement (1:N:M)
9. ServiceInput (1:N)
10. ServiceOutputCategory + ServiceOutputItem (1:N:M)
11. TimelinePhase (1:N)
12. ServiceSizeOption (1:N) + 10 related tables
13. ServiceResponsibleRole (1:N)
14. ServiceMultiCloudConsideration (1:N)
15. + 11 Lookup tables (LU_*)

---

## 🚀 Navrhovaný postup (8 fází)

### ✅ **Fáze 1: JSON Schema Design & Validation** (8h, 1 den) - HOTOVO
**Cíl:** Definovat strukturu dat a validační pravidla

**Výstupy:**
- ✅ JSON Schema v7 (`service-import-schema.json`)
- ✅ 16 C# import modelů s validací
- ✅ ImportResult, ValidationResult modely
- ✅ 3 service interfaces (ILookupResolver, IValidation, IOrchestration)
- ✅ 12 unit testů pro model validation

**Výsledek:** Máme definovanou strukturu dat a základní validaci.

---

### ✅ **Fáze 2: PDF Extraction Tool** (12h, 1-2 dny) - HOTOVO
**Cíl:** Automatizovat extrakci dat z PDF pomocí AI

**Výstupy:**
- ✅ Python script (`extract_services.py`)
- ✅ Claude API integrace
- ✅ Batch processing support
- ✅ JSON schema validation
- ✅ Runner scripts (run.sh, run.ps1)
- ✅ Kompletní dokumentace (EN + CZ)

**Výsledek:** Dokážeme převést PDF → JSON automaticky.

**Použití:**
```bash
cd tools/pdf-extractor
export ANTHROPIC_API_KEY='your-key'
python extract_services.py
# Output: Enterprise_Scale_LZ.json, Application_LZ.json
```

**Náklady:** ~$0.27 per PDF (20-30 stran)

---

### ✅ **Fáze 3: Lookup Resolution Service** (4h, 0.5 dne) - HOTOVO
**Cíl:** Převádět friendly names na databázové ID

**Výstupy:**
- ✅ LookupResolverService (11 resolver metod)
- ✅ IMemoryCache integrace (30min TTL)
- ✅ Case-insensitive lookups
- ✅ Normalization helpers
- ✅ 23 unit testů (100% coverage)

**Výsledek:** Můžeme převést "Services/Architecture" → CategoryId, "M" → SizeId, atd.

**Funkce:**
```csharp
var categoryId = await _lookupResolver.ResolveCategoryIdAsync("Services/Architecture");
var sizeId = await _lookupResolver.ResolveSizeOptionIdAsync("M");
var roleId = await _lookupResolver.ResolveRoleIdAsync("Cloud Architect");
```

---

### ✅ **Fáze 4: Import Validation Service** (8h, 1 den) - HOTOVO
**Cíl:** Validovat data před importem do databáze

**Výstupy:**
- ✅ ImportValidationService (5 validation metod)
- ✅ 16 validation rules
- ✅ 13 error code types
- ✅ Error code dokumentace
- ✅ 27 unit testů (100% coverage)

**Výsledek:** Dokážeme zkontrolovat validitu dat před importem.

**Validace:**
1. Data Annotations (required fields, string length)
2. Business Rules (ServiceCode format, unique scenarios, etc.)
3. Lookups (all lookup values exist)
4. Duplicates (no duplicate ServiceCode)
5. References (no circular dependencies, primary owner required)

---

### ⏳ **Fáze 5: Import Orchestration Service** (16h, 2 dny) - NEXT
**Cíl:** Implementovat hlavní import logiku

**Plán:**
1. **ImportOrchestrationService class**
   - `ImportServiceAsync(ImportServiceModel)` - Single import
   - `ImportServicesAsync(List<ImportServiceModel>)` - Bulk import
   - `ValidateImportAsync(ImportServiceModel)` - Dry-run

2. **Transaction Management**
   - EF Core transaction
   - All-or-nothing guarantee
   - Rollback on any error

3. **Entity Mapping**
   - JSON model → Database entities
   - Resolve all lookup IDs
   - Create nested structures

4. **Database Insertion (FK-safe order)**
   ```
   1. ServiceCatalogItem (parent)
   2. UsageScenario
   3. ServiceDependency
   4. ServiceScopeCategory → ServiceScopeItem
   5. ServicePrerequisite
   6. ServiceToolFramework
   7. ServiceLicense
   8. ServiceInteraction → StakeholderInvolvement
   9. ServiceInput
   10. ServiceOutputCategory → ServiceOutputItem
   11. TimelinePhase
   12. ServiceSizeOption + nested (10 tables)
   13. ServiceResponsibleRole
   14. ServiceMultiCloudConsideration
   ```

5. **Error Handling**
   - Comprehensive logging
   - Error aggregation
   - Detailed error messages

**Výstupy:**
- ImportOrchestrationService.cs (~500 řádků)
- Entity mapping methods (14 metod)
- Integration tests
- Performance tests

**Výsledek:** Kompletní import pipeline fungující end-to-end.

---

### ⏳ **Fáze 6: Azure Function API** (4h, 0.5 dne)
**Cíl:** Vystavit import jako HTTP API endpoint

**Plán:**
1. **Import Function**
   ```csharp
   [Function("ImportService")]
   public async Task<HttpResponseData> ImportService(
       [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
   {
       var model = await req.ReadFromJsonAsync<ImportServiceModel>();
       var result = await _importService.ImportServiceAsync(model);
       return req.CreateResponse(result.IsSuccess ? HttpStatusCode.OK : HttpStatusCode.BadRequest);
   }
   ```

2. **Bulk Import Function**
   ```csharp
   [Function("ImportServicesBulk")]
   public async Task<HttpResponseData> ImportServicesBulk(...)
   {
       var models = await req.ReadFromJsonAsync<List<ImportServiceModel>>();
       var result = await _importService.ImportServicesAsync(models);
       return req.CreateResponse(HttpStatusCode.OK);
   }
   ```

3. **Validate Function** (dry-run)
   ```csharp
   [Function("ValidateImport")]
   public async Task<HttpResponseData> ValidateImport(...)
   ```

**Výstupy:**
- ImportFunction.cs
- OpenAPI documentation
- Postman collection

**Výsledek:** Import dostupný přes REST API.

**Použití:**
```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @Enterprise_Scale_LZ.json
```

---

### ⏳ **Fáze 7: Testing & Validation** (8h, 1 den)
**Cíl:** Ověřit kompletní funkcionalitu

**Plán:**
1. **End-to-End testy**
   - Extract PDF → JSON
   - Validate JSON
   - Import to database
   - Verify data integrity

2. **Integration testy**
   - Test with real PDFs
   - Test with both services (ESLZ, ALZ)
   - Verify all relationships
   - Check lookup resolutions

3. **Performance testy**
   - Bulk import (10 services)
   - Measure duration
   - Check database queries
   - Verify caching effectiveness

4. **Error scenario testy**
   - Invalid JSON
   - Missing lookups
   - Duplicate ServiceCode
   - Circular dependencies

**Výstupy:**
- Integration test suite
- Performance test results
- Error scenario test cases
- Test data set

**Výsledek:** Ověřená funkčnost celého systému.

---

### ⏳ **Fáze 8: Frontend Integration** (8h, 1 den) - OPTIONAL
**Cíl:** UI pro import služeb

**Plán:**
1. **Import Page Component**
   - File upload (JSON)
   - Import button
   - Progress indicator
   - Success/Error messages

2. **Validation Preview**
   - Show validation results
   - Display errors with details
   - Allow correction before import

3. **Import History**
   - List of imported services
   - Import timestamp
   - Import status
   - Error logs

**Výstupy:**
- React components
- API integration
- Error handling UI

**Výsledek:** User-friendly UI pro import.

---

## 📈 Celkový harmonogram

| Fáze | Název | Čas | Status | Výstup |
|------|-------|-----|--------|--------|
| 1 | JSON Schema & Models | 8h | ✅ Hotovo | Schema + 16 modelů |
| 2 | PDF Extraction Tool | 12h | ✅ Hotovo | Python tool + dokumentace |
| 3 | Lookup Resolution | 4h | ✅ Hotovo | 11 resolver metod + cache |
| 4 | Validation Service | 8h | ✅ Hotovo | 16 validation rules |
| 5 | Orchestration Service | 16h | ⏳ Next | Import pipeline |
| 6 | API Endpoints | 4h | ⏳ Pending | HTTP API |
| 7 | Testing & Validation | 8h | ⏳ Pending | E2E tests |
| 8 | Frontend Integration | 8h | ⏳ Optional | UI components |

**Celkem (bez frontendu):** 60 hodin (~8 pracovních dnů při 0.8 FTE)  
**Celkem (s frontendem):** 68 hodin (~9 pracovních dnů)

**Dokončeno:** 32 hodin (53%)  
**Zbývá:** 28 hodin (47%)

---

## 🎯 Klíčové milníky

### ✅ Milestone 1: Data Structure (Fáze 1) - DONE
- JSON schema definována
- Import modely vytvořeny
- Validace připravena

### ✅ Milestone 2: PDF Processing (Fáze 2) - DONE
- AI-powered extrakce funguje
- JSON soubory generovány
- Dokumentace kompletní

### ✅ Milestone 3: Core Services (Fáze 3-4) - DONE
- Lookup resolution funguje
- Validation funguje
- Ready pro import

### ⏳ Milestone 4: Import Pipeline (Fáze 5-6)
- Import orchestration hotova
- API endpointy vystaveny
- **→ Po dokončení: Funkční import systém**

### ⏳ Milestone 5: Production Ready (Fáze 7)
- Všechny testy prošly
- Performance ověřena
- **→ Připraveno pro produkci**

---

## 💰 Náklady

### Anthropic API (PDF Extraction)
- **Per PDF:** ~$0.27 (20-30 stran)
- **2 PDFs:** ~$0.54
- **10 PDFs:** ~$2.70
- **50 PDFs:** ~$13.50

### Vývoj (odhad)
- **Junior Developer:** 60h × $30/h = **$1,800**
- **Mid Developer:** 60h × $50/h = **$3,000**
- **Senior Developer:** 60h × $80/h = **$4,800**

### Azure (měsíční provoz)
- **Azure Functions:** ~$10-20/měsíc
- **Azure SQL:** ~$5-10/měsíc (Basic tier)
- **Storage:** ~$1/měsíc

**Celkem:** ~$16-31/měsíc provozní náklady

---

## 🔧 Technologie

### Backend
- **.NET 8** - Azure Functions
- **Entity Framework Core** - ORM
- **Azure SQL** - Database
- **IMemoryCache** - Caching (30min TTL)
- **FluentValidation** - Validation
- **Moq** - Unit testing
- **xUnit** - Test framework

### PDF Extraction
- **Python 3.10+**
- **Anthropic SDK** - Claude API
- **jsonschema** - Validation
- **Claude Sonnet 4** - AI model

### Frontend (optional)
- **React** - UI framework
- **TypeScript** - Type safety
- **Material-UI** - Components

---

## 📋 Checklist před produkcí

### Fáze 5 (Orchestration)
- [ ] ImportOrchestrationService implementována
- [ ] Transaction management funguje
- [ ] Entity mapping kompletní
- [ ] FK-safe insert order
- [ ] Error handling robustní
- [ ] Integration testy napsány

### Fáze 6 (API)
- [ ] Import endpoint vytvořen
- [ ] Bulk import endpoint vytvořen
- [ ] Validate endpoint vytvořen
- [ ] OpenAPI dokumentace
- [ ] Authentication/Authorization
- [ ] Rate limiting

### Fáze 7 (Testing)
- [ ] E2E testy prošly
- [ ] Integration testy prošły
- [ ] Performance testy OK
- [ ] Error scenarios pokryty
- [ ] Data integrity ověřena
- [ ] Security audit proveden

### Deployment
- [ ] Azure Functions deployed
- [ ] Database migrations applied
- [ ] Lookup tables seeded
- [ ] API keys configured
- [ ] Monitoring nastaveno
- [ ] Logs configured
- [ ] Backup strategy

---

## 🎓 Dokumentace

### Pro vývojáře
- ✅ `/docs/IMPORT_FEATURE.md` - Feature overview
- ✅ `/docs/VALIDATION_ERROR_CODES.md` - Error codes
- ✅ `/schemas/service-import-schema.json` - JSON schema
- ⏳ `/docs/API.md` - API documentation (Fáze 6)
- ⏳ `/docs/DEPLOYMENT.md` - Deployment guide (Fáze 7)

### Pro uživatele
- ✅ `/tools/pdf-extractor/README.md` - English guide
- ✅ `/tools/pdf-extractor/QUICKSTART.md` - Quick start
- ✅ `/tools/pdf-extractor/NAVOD_CZ.md` - Czech guide
- ⏳ User manual (Fáze 8)

### Changelog
- ✅ `CHANGELOG_IMPORT.md` - Complete history

---

## 🚀 Quick Start (po dokončení Fáze 5-6)

### 1. Extract PDF → JSON
```bash
cd tools/pdf-extractor
export ANTHROPIC_API_KEY='your-key'
python extract_services.py
# Output: output/Enterprise_Scale_LZ.json
```

### 2. Validate JSON
```bash
curl -X POST http://localhost:7071/api/services/import/validate \
  -H "Content-Type: application/json" \
  -d @output/Enterprise_Scale_LZ.json
```

### 3. Import to Database
```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @output/Enterprise_Scale_LZ.json
```

### 4. Verify in UI
```
http://localhost:3000/services
```

---

## ❓ FAQ

### Q: Můžu importovat více služeb najednou?
**A:** Ano, Fáze 6 obsahuje bulk import endpoint.

### Q: Co když PDF extraction selže?
**A:** Můžete JSON upravit ručně a validovat před importem.

### Q: Jak dlouho trvá import jedné služby?
**A:** ~2-5 sekund (včetně validace a lookup resolution).

### Q: Jsou data v transakci?
**A:** Ano, all-or-nothing. Pokud cokoli selže, celý import se rollbackne.

### Q: Můžu importovat stejnou službu dvakrát?
**A:** Ne, duplicate ServiceCode detekce to zabrání.

### Q: Co když potřebuji update existující služby?
**A:** V současné fázi je podporován pouze INSERT. Update můžete přidat jako extension.

### Q: Jak často můžu volat PDF extraction?
**A:** Unlimited, platíte per token (viz Anthropic pricing).

### Q: Je cache sdílená mezi requesty?
**A:** Ano, IMemoryCache je singleton v rámci Azure Function instance.

---

## 🎉 Výsledek

Po dokončení všech fází budete mít:

✅ **Automatizovaný import pipeline**
- PDF → JSON → Database
- AI-powered extraction
- Comprehensive validation
- Transactional guarantees

✅ **Production-ready systém**
- REST API
- Error handling
- Logging & monitoring
- Documentation

✅ **Škálovatelné řešení**
- Batch processing
- Caching
- Performance optimized
- Azure cloud-ready

✅ **Dokumentace**
- Developer docs
- User guides (EN + CZ)
- API documentation
- Deployment guides

---

**Vytvořeno:** 26. ledna 2026  
**Autor:** Claude (Anthropic)  
**Status:** 4/8 fází dokončeno (53%)  
**Next:** Fáze 5 - Import Orchestration Service
