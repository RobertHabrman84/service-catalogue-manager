# PDF Extractor - Relaxed Validation Mode

## 🎯 Overview

The PDF extractor now supports **two-pass workflow**:

1. **Pass 1:** Extract all PDFs without strict validation (--relaxed mode)
2. **Pass 2:** Analyze all extractions and identify schema issues
3. **Pass 3:** Apply batch fixes to schema or prompt
4. **Pass 4:** Re-run with validation enabled

This approach is **much faster** than fixing issues one-by-one!

---

## 🚀 Quick Start

### Option 1: Traditional Mode (Strict Validation)
```bash
python extract_services.py
```
Stops at first validation error.

### Option 2: Relaxed Mode (Recommended)
```bash
# Step 1: Extract all PDFs without validation
python extract_services.py --relaxed

# Step 2: Analyze extractions
python analyze_extractions.py

# Step 3: Apply recommended fixes to schema/prompt

# Step 4: Re-run with validation
python extract_services.py
```

---

## 📖 Detailed Workflow

### Step 1: Extract with Relaxed Mode

```bash
python extract_services.py --relaxed
```

**What happens:**
- Extracts JSON from all PDFs
- Skips strict schema validation
- Saves all extractions to `output/`
- Shows potential issues but doesn't fail

**Example output:**
```
🚀 Service Catalog PDF Extractor
============================================================
Schema: service-import-schema.json
PDF Directory: .../pdfs
Output Directory: .../output
Found 2 PDF file(s)
⚠️  RELAXED MODE: Schema validation disabled
   Run 'python analyze_extractions.py' after extraction
============================================================

[1/2] Processing: Application Landing Zone Design.pdf
------------------------------------------------------------
📄 Processing: .../Application Landing Zone Design.pdf
🤖 Calling Claude API...
✅ Extraction successful
⚠️  Relaxed mode: Skipping strict schema validation
⚠️  Detected 5 potential schema issues (will be analyzed later)
💾 Saved to: output/Application Landing Zone Design.json
📊 Service Code: ID0XX
📊 Service Name: Application Landing Zone Design
------------------------------------------------------------

[2/2] Processing: Enterprise Scale Landing Zone Design.pdf
------------------------------------------------------------
✅ Extraction successful
⚠️  Detected 4 potential schema issues
💾 Saved to: output/Enterprise Scale Landing Zone Design.json
------------------------------------------------------------

============================================================
📊 Summary
============================================================
✅ Successful: 2
❌ Failed: 0
📁 Output directory: .../output

✅ Extraction complete! JSON files are ready

📊 Next step: Analyze extractions for schema issues
   Run: python .../analyze_extractions.py
```

---

### Step 2: Analyze Extractions

```bash
python analyze_extractions.py
```

**What happens:**
- Scans all JSON files in `output/`
- Compares against schema
- Identifies type mismatches
- Groups issues by pattern
- Suggests fixes

**Example output:**
```
🔍 Analyzing 2 extracted JSON file(s)...
============================================================

📄 Application Landing Zone Design.json
   ⚠️  5 issue(s) detected

📄 Enterprise Scale Landing Zone Design.json
   ⚠️  4 issue(s) detected

============================================================
📊 ANALYSIS SUMMARY
============================================================

⚠️  Found 5 distinct issue pattern(s):

1. Path: responsibleRoles[3].responsibilities
   Expected: string
   Actual: array
   Occurrences: 2 file(s)
   Example: ['Timeline management', 'Resource coordination', ...]
   💡 Suggestion: Schema: Change 'responsibilities' type to 'array'

2. Path: sizeOptions[2].teamSize
   Expected: string
   Actual: integer
   Occurrences: 2 file(s)
   Example: 4
   💡 Suggestion: Prompt: Specify 'teamSize' must be string (e.g., "2-3 people")

3. Path: stakeholderInteraction.accessRequirements[5]
   Expected: object
   Actual: string
   Occurrences: 2 file(s)
   Example: Network topology documentation
   💡 Suggestion: Prompt: Specify 'accessRequirements' must be object with properties

4. Path: stakeholderInteraction.customerMustProvide[5]
   Expected: string
   Actual: object
   Occurrences: 1 file(s)
   Example: {'itemName': 'Architecture feedback', ...}
   💡 Suggestion: Schema: Change 'customerMustProvide' type to 'string'

5. Path: serviceInputs[14].exampleValue
   Expected: string
   Actual: null
   Occurrences: 2 file(s)
   Example: None
   💡 Suggestion: Schema: Allow null values

============================================================
🔧 RECOMMENDED ACTIONS
============================================================

📝 Schema Fixes (change schema to match extracted data):
   1. responsibleRoles.responsibilities: 'string' → 'array'
   2. serviceInputs.exampleValue: 'string' → 'string/null'
   3. stakeholderInteraction.customerMustProvide: 'object' → 'string'

✏️  Prompt Fixes (update extraction instructions):
   1. sizeOptions.teamSize: Specify must be 'string' not 'integer'
   2. stakeholderInteraction.accessRequirements: Specify must be 'object' not 'string'

============================================================
Next steps:
1. Review recommendations above
2. Apply schema fixes: edit schemas/service-import-schema.json
3. Apply prompt fixes: edit tools/pdf-extractor/extract_services.py
4. Re-run extraction: python extract_services.py
============================================================
```

---

### Step 3: Apply Fixes

#### Schema Fixes

Edit `schemas/service-import-schema.json`:

```json
// Before:
"responsibilities": {
  "type": "string"
}

// After:
"responsibilities": {
  "type": "array",
  "items": { "type": "string" }
}
```

```json
// Before:
"exampleValue": {
  "type": "string"
}

// After:
"exampleValue": {
  "type": ["string", "null"]
}
```

#### Prompt Fixes

Edit `tools/pdf-extractor/extract_services.py`:

```python
# Before:
c) teamSize, complexity (LOW/MEDIUM/HIGH)

# After:
c) teamSize (STRING, e.g. "2-3 people", "4-5 FTE"), complexity (LOW/MEDIUM/HIGH)
```

---

### Step 4: Re-run with Validation

```bash
python extract_services.py
```

Now with validation enabled, should pass all checks!

---

## 🎯 Benefits

### Traditional Approach (12 iterations):
```
Extract → Error (teamSize) → Fix → Commit → PR → Test
Extract → Error (responsibilities) → Fix → Commit → PR → Test
Extract → Error (accessRequirements) → Fix → Commit → PR → Test
... (9 more iterations)
```

⏱️ **Time:** ~2-3 hours  
💰 **API Calls:** 12+ Claude calls  
😓 **Effort:** High (repetitive)

### Relaxed Mode Approach (2 iterations):
```
Extract ALL (relaxed) → Analyze ALL → Fix ALL → Test
```

⏱️ **Time:** ~30 minutes  
💰 **API Calls:** 2-3 Claude calls  
😊 **Effort:** Low (batch fixes)

---

## 🔧 Command Reference

### Extract Commands

```bash
# Strict mode (default)
python extract_services.py

# Relaxed mode (skip validation)
python extract_services.py --relaxed
python extract_services.py --no-validation

# Help
python extract_services.py --help
```

### Analyze Commands

```bash
# Analyze default output directory
python analyze_extractions.py

# Analyze custom directory
python analyze_extractions.py /path/to/output
```

---

## 📊 Comparison

| Feature | Traditional Mode | Relaxed Mode |
|---------|-----------------|--------------|
| **Validation** | Strict, stops at first error | Relaxed, analyzes all |
| **Iterations** | Many (one per error) | Few (batch fix) |
| **Time** | Slow (sequential) | Fast (parallel analysis) |
| **API Calls** | High | Low |
| **Best For** | Production, final run | Development, first run |

---

## 💡 Best Practices

### First Time Extraction
```bash
# Use relaxed mode for initial extraction
python extract_services.py --relaxed
python analyze_extractions.py
# Apply all recommended fixes
python extract_services.py  # Final run with validation
```

### Production Extraction
```bash
# Use strict mode for production
python extract_services.py
```

### Iterative Development
```bash
# Relaxed → Analyze → Fix → Repeat
python extract_services.py --relaxed
python analyze_extractions.py
# Fix issues
python extract_services.py --relaxed  # Test fixes
python analyze_extractions.py  # Verify
python extract_services.py  # Final validation
```

---

## 🐛 Troubleshooting

### Issue: Analyzer shows no issues but extraction still fails

**Solution:** Run strict mode to see actual validation error:
```bash
python extract_services.py
```

### Issue: Too many issues detected

**Solution:** Focus on most common patterns first (highest occurrence count)

### Issue: Schema fix breaks other parts

**Solution:** Review all occurrences of the field before changing type

---

## 📝 Notes

- Relaxed mode saves ALL extractions, even with type mismatches
- Analyzer shows patterns across ALL files, not just one
- Schema fixes are usually safer than prompt fixes
- Some issues may require both schema AND prompt fixes
- Always test with strict mode after applying fixes

---

*Generated: 2026-01-27*  
*Feature: Relaxed Validation Mode*  
*Version: 2.0*
