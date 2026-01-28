# Backend Import Schema - Requirements

## 🔴 CRITICAL REQUIREMENTS

### 1. ServiceCode Pattern
```
Pattern: ^ID\d{3}$
Valid:   ID001, ID002, ID999
Invalid: ID0XX, ID01, IDABC
```

### 2. Required Fields (ALL MUST BE PRESENT)
- `serviceCode` (string, pattern: ^ID\d{3}$)
- `serviceName` (string, 1-200 chars)
- `version` (string)
- `category` (string, min 1 char)
- `description` (string, min 1 char)

### 3. toolsAndEnvironment Structure (IF PRESENT)

⚠️ **ALL ARRAYS MUST BE ARRAYS (NOT NULL):**

```json
{
  "toolsAndEnvironment": {
    "cloudPlatforms": [],      // MUST be array
    "designTools": [],         // MUST be array
    "automationTools": [],     // MUST be array
    "collaborationTools": [],  // ⚠️ MUST be array (common mistake!)
    "other": []                // MUST be array
  }
}
```

**Each tool item:**
```json
{
  "category": "string or null",
  "toolName": "string or null",
  "version": "string or null",
  "purpose": "string or null"
}
```

## ❌ Common Mistakes

### Mistake 1: ServiceCode with letters
```json
{
  "serviceCode": "ID0XX"  // ❌ WRONG - contains letters
}
```
**Fix:**
```json
{
  "serviceCode": "ID001"  // ✅ CORRECT
}
```

### Mistake 2: null instead of empty array
```json
{
  "toolsAndEnvironment": {
    "collaborationTools": null  // ❌ WRONG - null not allowed
  }
}
```
**Fix:**
```json
{
  "toolsAndEnvironment": {
    "collaborationTools": []  // ✅ CORRECT - empty array
  }
}
```

### Mistake 3: String values in tool arrays
```json
{
  "designTools": [
    "Visio",  // ❌ WRONG - must be object
    "Lucidchart"
  ]
}
```
**Fix:**
```json
{
  "designTools": [
    {  // ✅ CORRECT - object with properties
      "category": "Design Tools",
      "toolName": "Visio",
      "version": "",
      "purpose": ""
    }
  ]
}
```

## ✅ Minimal Valid JSON

```json
{
  "serviceCode": "ID001",
  "serviceName": "My Service",
  "version": "v1.0",
  "category": "Services/Category",
  "description": "Description here",
  "toolsAndEnvironment": {
    "cloudPlatforms": [],
    "designTools": [],
    "automationTools": [],
    "collaborationTools": [],
    "other": []
  }
}
```

## 📋 Validation Checklist

Before importing, verify:

- [ ] serviceCode matches ^ID\d{3}$ pattern
- [ ] All 5 required fields present
- [ ] serviceName is 1-200 characters
- [ ] description is at least 1 character
- [ ] If toolsAndEnvironment exists:
  - [ ] All 5 arrays present
  - [ ] All 5 arrays are arrays (not null)
  - [ ] All tool items are objects (not strings)
  - [ ] Each tool object has category/toolName/version/purpose properties

## 🎯 Testing

To test your JSON:
1. POST to: http://localhost:7071/api/services/import/validate
2. Expected response (success):
   ```json
   {
     "isValid": true,
     "message": "Validation passed - service is ready to import"
   }
   ```
3. If validation fails, response will include error details
