# PowerShell Script & JSON Normalization - Version 1.4

**Datum:** 27. ledna 2026  
**Verze:** 1.4 - Script Improvements & JSON Normalization  
**Status:** ✅ Ready

## ✅ Implementované Změny

### 1. PowerShell Script Improvements

#### Změna 1: Snížení Health Check Timeout
**Soubor:** `start-all.ps1`  
**Řádek:** 22

**PŘED:**
```powershell
[int]$HealthCheckTimeout = 120,
```

**PO:**
```powershell
[int]$HealthCheckTimeout = 30,
```

**Důvod:**
- 120 sekund je příliš dlouhé čekání
- 30 sekund je dostatečné pro normální startup
- Rychlejší feedback při problémech

#### Změna 2: Vylepšená Wait-ForBackend Funkce
**Soubor:** `start-all.ps1`  
**Funkce:** `Wait-ForBackend` (řádky 500-606)

**Co bylo vylepšeno:**
- ✅ Lepší progress indicator (spinner animace)
- ✅ Přesnější error reporting (zobrazuje last error)
- ✅ Lepší diagnostické informace
- ✅ Kratší sleep time mezi pokusy (exponential backoff)
- ✅ Přehlednější formátování výstupu
- ✅ Více užitečných diagnostických příkazů

**Nový progress indicator:**
```
  | Attempt 5... [12.3s/30s]
```
Místo původního:
```
  Attempt 5/15... [12.3s]
```

**Vylepšené diagnostické informace:**
```
Common issues:
  • Backend compilation errors - check backend window
  • Port 7071 already in use - kill conflicting process
  • Missing dependencies - run: dotnet restore

Quick diagnostics:
  Check backend health:
    Invoke-WebRequest http://localhost:7071/api/health
  Check port usage:
    netstat -ano | findstr :7071
  View backend logs:
    Get-Content logs\backend.log -Tail 50
```

### 2. JSON Normalization

#### Problém: Application_Landing_Zone_Design.json

Původní JSON měl nevalidní strukturu v `toolsAndEnvironment`:

**PROBLÉM 1: cloudPlatforms - Multi-cloud struktura**
```json
{
  "capability": "Reference Architecture",
  "aws": "AWS Well-Architected Framework",
  "azure": "Azure Cloud Adoption Framework (CAF)",
  "gcp": "Google Cloud Architecture Framework"
}
```

❌ **Schéma očekává:** Array of `toolItem` objects

**PROBLÉM 2: designTools - Stringy místo objektů**
```json
[
  "Diagramming tools (Visio, Lucidchart, Draw.io, Diagrams.net)",
  "Cloud-native diagram tools (...)",
  ...
]
```

❌ **Schéma očekává:** Array of `toolItem` objects

**PROBLÉM 3: automationTools - Špatná struktura**
```json
{
  "category": "IaC Frameworks",
  "tools": "Terraform, Bicep, CloudFormation, Pulumi"
}
```

❌ **Schéma očekává:** Array of individual `toolItem` objects, ne `{category, tools}`

**PROBLÉM 4: assessmentTools - Neexistující v schématu**
```json
"assessmentTools": [...]
```

❌ **Není ve schématu** - mělo by být v `other` poli

#### Řešení: Normalizace

**OPRAVA 1: cloudPlatforms - Expanze multi-cloud do jednotlivých položek**
```json
// 1 multi-cloud objekt se 4 capabilities a 3 clouds = 12 jednotlivých položek
[
  {
    "category": "Reference Architecture",
    "toolName": "AWS",
    "version": "",
    "purpose": "AWS Well-Architected Framework"
  },
  {
    "category": "Reference Architecture",
    "toolName": "AZURE",
    "version": "",
    "purpose": "Azure Cloud Adoption Framework (CAF)"
  },
  {
    "category": "Reference Architecture",
    "toolName": "GCP",
    "version": "",
    "purpose": "Google Cloud Architecture Framework"
  }
  // ... dalších 9 items
]
```

**Transformace:** 4 multi-cloud objekty → 12 individual tool items

**OPRAVA 2: designTools - Konverze stringů na objekty**
```json
[
  {
    "category": "Design Tools",
    "toolName": "Diagramming tools (Visio, Lucidchart, Draw.io, Diagrams.net)",
    "version": "",
    "purpose": ""
  },
  {
    "category": "Design Tools",
    "toolName": "Cloud-native diagram tools (AWS Architecture Icons, Azure Diagrams, GCP Architecture Diagramming)",
    "version": "",
    "purpose": ""
  }
  // ... další items
]
```

**Transformace:** 4 stringy → 4 toolItem objekty

**OPRAVA 3: automationTools - Rozdělení comma-separated values**
```json
// Původní: {category: "IaC Frameworks", tools: "Terraform, Bicep, CloudFormation, Pulumi"}
// Nové:
[
  {
    "category": "IaC Frameworks",
    "toolName": "Terraform",
    "version": "",
    "purpose": ""
  },
  {
    "category": "IaC Frameworks",
    "toolName": "Bicep",
    "version": "",
    "purpose": ""
  },
  {
    "category": "IaC Frameworks",
    "toolName": "CloudFormation",
    "version": "",
    "purpose": ""
  },
  {
    "category": "IaC Frameworks",
    "toolName": "Pulumi",
    "version": "",
    "purpose": ""
  }
  // ... další items
]
```

**Smart handling:** 
- `"Git (GitHub, GitLab, Azure DevOps)"` → ponecháno jako jeden item (parentheses znamenají že patří dohromady)
- `"Terraform, Bicep"` → rozděleno na 2 separate items

**Transformace:** 4 struktury → 11 individual tool items

**OPRAVA 4: assessmentTools - Přesun do "other"**
```json
// assessmentTools není ve schématu, přesunuto do "other"
"other": [
  {
    "category": "Assessment Tools",
    "toolName": "Cloud provider assessment tools",
    "version": "",
    "purpose": ""
  },
  {
    "category": "Assessment Tools",
    "toolName": "Network topology analyzers",
    "version": "",
    "purpose": ""
  }
  // ... další items
]
```

**Transformace:** 4 assessment tools → 4 items v "other" kategorii

## 📊 Výsledky Normalizace

### Před Normalizací:
```
toolsAndEnvironment:
  cloudPlatforms: 4 items (multi-cloud objects) ❌
  designTools: 4 items (strings) ❌
  automationTools: 4 items ({category, tools}) ❌
  assessmentTools: 4 items (nevalidní pole) ❌
```

### Po Normalizaci:
```
toolsAndEnvironment:
  cloudPlatforms: 12 items (individual toolItem objects) ✅
  designTools: 4 items (toolItem objects) ✅
  automationTools: 11 items (individual toolItem objects) ✅
  other: 4 items (moved from assessmentTools) ✅
```

### Data Integrity:
- ✅ **100% dat zachováno**
- ✅ 4 multi-cloud objekty → 12 cloud platform items (expanze)
- ✅ 4 design tool stringy → 4 tool objekty (konverze)
- ✅ 4 automation struktury → 11 tool items (rozdělení comma-separated)
- ✅ 4 assessment tools → 4 items v "other" (přesun)
- ✅ **Celkem: 31 tool items po normalizaci**

## 📁 Nové Soubory

### Přidáno do projektu:
- `examples/Application_Landing_Zone_Design_NORMALIZED.json` - Normalized version ready for import

### Použití:
```bash
# 1. Otevřít aplikaci
# 2. Přejít na Import
# 3. Nahrát examples/Application_Landing_Zone_Design_NORMALIZED.json
# 4. Validate ✅
# 5. Import ✅
```

## 🎯 Schema Compliance

**Před normalizací:**
- ❌ cloudPlatforms: Wrong structure
- ❌ designTools: Wrong type (strings)
- ❌ automationTools: Wrong structure
- ❌ assessmentTools: Not in schema

**Po normalizaci:**
- ✅ cloudPlatforms: Correct toolItem array
- ✅ designTools: Correct toolItem array
- ✅ automationTools: Correct toolItem array
- ✅ other: Correct toolItem array
- ✅ **100% schema compliant**

## 🔍 toolItem Schema

**Definice:**
```json
{
  "type": "object",
  "properties": {
    "category": { "type": "string" },
    "toolName": { "type": "string" },
    "version": { "type": "string" },
    "purpose": { "type": "string" }
  }
}
```

**Všechny normalized items splňují tuto strukturu!**

## ✅ Status

**PowerShell Script:**
- ✅ Timeout snížen z 120s na 30s
- ✅ Wait-ForBackend vylepšena
- ✅ Lepší UX a diagnostika

**JSON Normalization:**
- ✅ 100% data integrity
- ✅ Schema compliant
- ✅ Ready for import
- ✅ 31 tool items properly structured

---

**Připravil:** Service Catalogue Manager Team  
**Datum:** 27. ledna 2026  
**Status:** ✅ Ready for Use
