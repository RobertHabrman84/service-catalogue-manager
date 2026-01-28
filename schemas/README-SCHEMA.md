# JSON Schema Documentation - Service Import

**Datum:** 27. ledna 2026  
**Verze:** 1.5  
**Status:** ✅ Official Schema

## 📄 Dostupné Soubory

### 1. service-import-schema.json
**Popis:** Oficiální JSON Schema definice  
**Použití:** Pro validaci JSON před importem  
**Nástroje:** VS Code, online validators, json-schema libraries

### 2. service-import-minimal-example.json
**Popis:** Minimální validní příklad (pouze povinná pole)  
**Použití:** Quick start, testing, template  
**Velikost:** ~325 bytes

### 3. service-import-complete-example.json
**Popis:** Kompletní příklad s daty  
**Použití:** Reference pro všechna pole  
**Velikost:** ~922 bytes

## 🔑 Kritická Pravidla

### 1. ServiceCode Pattern
```
Pattern: ^ID\d{3}$
```

**Validní:**
- ✅ `ID001`
- ✅ `ID123`
- ✅ `ID999`

**Nevalidní:**
- ❌ `ID0XX` (obsahuje písmena)
- ❌ `ID01` (pouze 2 číslice)
- ❌ `ID1234` (4 číslice)
- ❌ `id001` (malá písmena)

### 2. Required Fields
Následující pole jsou **POVINNÁ**:
```json
{
  "serviceCode": "string",     // Pattern: ^ID\d{3}$
  "serviceName": "string",     // 1-200 znaků
  "version": "string",         // Default: "v1.0"
  "category": "string",        // Min 1 znak
  "description": "string"      // Min 1 znak
}
```

### 3. ToolsAndEnvironment - KRITICKÉ!
```json
"toolsAndEnvironment": {
  "cloudPlatforms": [],      // MUST be array (can be empty)
  "designTools": [],         // MUST be array (can be empty)
  "automationTools": [],     // MUST be array (can be empty)
  "collaborationTools": [],  // MUST be array (CANNOT be null!)
  "other": []                // MUST be array (can be empty)
}
```

**DŮLEŽITÉ:**
- ❌ `"collaborationTools": null` → 400 Bad Request
- ✅ `"collaborationTools": []` → OK

### 4. Tool Item Structure
```json
{
  "category": "string or null",
  "toolName": "string or null",
  "version": "string or null",
  "purpose": "string or null"
}
```

Všechna pole jsou optional, ale objekt musí existovat.

## 📋 Minimal Valid Example

```json
{
  "serviceCode": "ID001",
  "serviceName": "Example Service",
  "version": "v1.0",
  "category": "Services/Example",
  "description": "This is a minimal valid example",
  "toolsAndEnvironment": {
    "cloudPlatforms": [],
    "designTools": [],
    "automationTools": [],
    "collaborationTools": [],
    "other": []
  }
}
```

**Tento JSON:**
- ✅ Projde validací
- ✅ Lze importovat
- ✅ Vytvoří službu v databázi

## 📋 Complete Example Structure

```json
{
  "serviceCode": "ID003",
  "serviceName": "Application Landing Zone Design",
  "version": "v1.0",
  "category": "Services/Architecture/Technical Architecture",
  "description": "Complete service description",
  "notes": "Optional notes",
  
  "toolsAndEnvironment": {
    "cloudPlatforms": [
      {
        "category": "Reference Architecture",
        "toolName": "AWS",
        "version": "",
        "purpose": "AWS Well-Architected Framework"
      }
    ],
    "designTools": [...],
    "automationTools": [...],
    "collaborationTools": [],  // Empty but ARRAY
    "other": []
  },
  
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Title",
      "scenarioDescription": "Description",
      "sortOrder": 1
    }
  ],
  
  "dependencies": {
    "prerequisite": [...],
    "triggersFor": [...],
    "parallelWith": [...]
  },
  
  "scope": {
    "inScope": [
      {
        "category": "Category Name",
        "items": ["Item 1", "Item 2"]
      }
    ],
    "outOfScope": ["Out of scope item"]
  },
  
  "prerequisites": {
    "organizational": [...],
    "technical": [...],
    "documentation": [...]
  },
  
  "licenses": {
    "requiredByCustomer": [...],
    "recommendedOptional": [...],
    "providedByServiceProvider": [...]
  },
  
  "stakeholderInteraction": {
    "interactionLevel": "MEDIUM",
    "customerMustProvide": [...],
    "workshopParticipation": [...],
    "accessRequirements": [...]
  },
  
  "serviceInputs": [...],
  "serviceOutputs": [...],
  "timeline": {...},
  "sizeOptions": [...],
  "responsibleRoles": [...],
  "multiCloudConsiderations": [...]
}
```

## 🔧 Validace JSON

### V VS Code:
1. Install extension: "JSON Schema Validator"
2. Add to workspace settings:
```json
{
  "json.schemas": [
    {
      "fileMatch": ["*import*.json"],
      "url": "./schemas/service-import-schema.json"
    }
  ]
}
```

### Online:
- https://www.jsonschemavalidator.net/
- Upload schema + JSON
- Verify validation

### Command Line:
```bash
# Using ajv-cli
npm install -g ajv-cli
ajv validate -s service-import-schema.json -d your-data.json
```

### Python:
```python
import json
import jsonschema

# Load schema
with open('service-import-schema.json') as f:
    schema = json.load(f)

# Load data
with open('your-data.json') as f:
    data = json.load(f)

# Validate
try:
    jsonschema.validate(data, schema)
    print("✅ Valid!")
except jsonschema.ValidationError as e:
    print(f"❌ Invalid: {e.message}")
```

## 🚨 Common Errors

### Error 1: ServiceCode Pattern
```
Error: "serviceCode" does not match pattern "^ID\\d{3}$"
Solution: Change "ID0XX" to "ID001" (or any ID + 3 digits)
```

### Error 2: collaborationTools is null
```
Error: "collaborationTools" must be array
Solution: Change null to []
```

### Error 3: Missing required field
```
Error: "serviceCode" is required
Solution: Add all required fields (see Required Fields section)
```

### Error 4: String too long
```
Error: "serviceName" is longer than maximum length of 200
Solution: Shorten serviceName to max 200 characters
```

## 📚 Full Field Reference

### Top Level (Required)
- ✅ `serviceCode` - string (pattern: ^ID\d{3}$)
- ✅ `serviceName` - string (1-200 chars)
- ✅ `version` - string
- ✅ `category` - string (min 1)
- ✅ `description` - string (min 1)

### Top Level (Optional)
- ⚪ `notes` - string | null
- ⚪ `usageScenarios` - array | null
- ⚪ `dependencies` - object | null
- ⚪ `scope` - object | null
- ⚪ `prerequisites` - object | null
- ⚪ `toolsAndEnvironment` - object | null
- ⚪ `licenses` - object | null
- ⚪ `stakeholderInteraction` - object | null
- ⚪ `serviceInputs` - array | null
- ⚪ `serviceOutputs` - array | null
- ⚪ `timeline` - object | null
- ⚪ `sizeOptions` - array | null
- ⚪ `responsibleRoles` - array | null
- ⚪ `multiCloudConsiderations` - array | null

## 📖 Quick Reference Card

```
✅ MUST HAVE:
   • serviceCode (ID001-ID999)
   • serviceName (1-200 chars)
   • version (any string)
   • category (any string)
   • description (any string)

⚠️  CRITICAL:
   • toolsAndEnvironment.collaborationTools CANNOT be null
   • All tool arrays MUST be arrays (use [] if empty)

⚪ OPTIONAL:
   • Everything else can be null or omitted
```

## 🎯 Testing Workflow

1. **Create JSON** using minimal-example as template
2. **Validate** against schema (VS Code or online)
3. **Test** in application:
   - Open Import page
   - Select JSON file
   - Click "Validate"
   - Should return 200 OK
4. **Import** if validation passes
5. **Verify** data in Services list

---

**Připravil:** Service Catalogue Manager Team  
**Datum:** 27. ledna 2026  
**Status:** ✅ Official Documentation
