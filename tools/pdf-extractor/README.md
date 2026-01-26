# PDF to JSON Service Extractor

Automated tool for extracting structured service catalog data from PDF documents using Claude API.

## Overview

This tool uses Claude's advanced PDF understanding capabilities to extract all service catalog data from PDF documents and convert them into structured JSON format ready for import into the Service Catalogue Manager.

## Features

- ✅ **Automated Extraction**: Uses Claude API to intelligently extract data from PDFs
- ✅ **Schema Validation**: Validates output against JSON schema
- ✅ **Batch Processing**: Process multiple PDFs in one run
- ✅ **Complete Coverage**: Extracts all 14+ sections including:
  - Basic service information
  - Usage scenarios
  - Dependencies (prerequisite, triggers, parallel)
  - Scope (in/out)
  - Prerequisites (organizational, technical, documentation)
  - Tools and environment
  - Licenses
  - Stakeholder interaction
  - Service inputs/outputs
  - Timeline phases
  - Size options with complete details
  - Responsible roles
  - Multi-cloud considerations

## Prerequisites

- Python 3.8 or higher
- Anthropic API key
- PDF files to process

## Installation

### 1. Install Python Dependencies

```bash
cd tools/pdf-extractor
pip install -r requirements.txt
```

### 2. Set API Key

```bash
# Linux/Mac
export ANTHROPIC_API_KEY='your-api-key-here'

# Windows (PowerShell)
$env:ANTHROPIC_API_KEY='your-api-key-here'

# Windows (Command Prompt)
set ANTHROPIC_API_KEY=your-api-key-here
```

### 3. Place PDF Files

Create a `pdfs` directory and place your PDF files there:

```bash
mkdir -p pdfs
# Copy your PDF files to the pdfs/ directory
```

## Usage

### Basic Usage

```bash
python extract_services.py
```

### What It Does

1. **Scans** the `pdfs/` directory for PDF files
2. **Extracts** structured data from each PDF using Claude API
3. **Validates** against JSON schema
4. **Saves** JSON files to `output/` directory
5. **Reports** success/failure for each file

### Directory Structure

```
pdf-extractor/
├── extract_services.py      # Main extraction script
├── requirements.txt          # Python dependencies
├── README.md                 # This file
├── pdfs/                     # Input PDFs (create this)
│   ├── Service1.pdf
│   └── Service2.pdf
└── output/                   # Output JSONs (auto-created)
    ├── Service1.json
    └── Service2.json
```

## Example Output

### Console Output

```
🚀 Service Catalog PDF Extractor
============================================================
Schema: service-import-schema.json
PDF Directory: /path/to/pdfs
Output Directory: /path/to/output
Found 2 PDF file(s)
============================================================

[1/2] Processing: Enterprise_Scale_Landing_Zone_Design.pdf
------------------------------------------------------------
📄 Processing: Enterprise_Scale_Landing_Zone_Design.pdf
🤖 Calling Claude API...
✅ Extraction successful
✅ JSON schema validation passed
💾 Saved to: output/Enterprise_Scale_Landing_Zone_Design.json
📊 Service Code: ID001
📊 Service Name: Enterprise Scale Landing Zone Design
------------------------------------------------------------

[2/2] Processing: Application_Landing_Zone_Design.pdf
------------------------------------------------------------
📄 Processing: Application_Landing_Zone_Design.pdf
🤖 Calling Claude API...
✅ Extraction successful
✅ JSON schema validation passed
💾 Saved to: output/Application_Landing_Zone_Design.json
📊 Service Code: ID002
📊 Service Name: Application Landing Zone Design
------------------------------------------------------------

============================================================
📊 Summary
============================================================
✅ Successful: 2
❌ Failed: 0
📁 Output directory: output
```

### JSON Output Example

```json
{
  "serviceCode": "ID001",
  "serviceName": "Enterprise Scale Landing Zone Design",
  "version": "v1.0",
  "category": "Services/Architecture/Technical Architecture",
  "description": "This service delivers comprehensive design...",
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Greenfield Cloud Adoption",
      "scenarioDescription": "Organizations beginning their cloud journey...",
      "sortOrder": 1
    }
  ],
  "dependencies": {
    "prerequisite": [
      {
        "serviceName": "Enterprise Scale Landing Zone Assessment",
        "serviceCode": "ID002",
        "requirementLevel": "REQUIRED",
        "notes": "Initial assessment required"
      }
    ]
  },
  "sizeOptions": [
    {
      "sizeCode": "S",
      "description": "Single cloud, 1-2 regions...",
      "duration": "4-6 weeks",
      "durationInDays": 30,
      "effort": {
        "hoursMin": 160,
        "hoursMax": 240,
        "currency": "USD"
      },
      "complexity": "LOW",
      "effortBreakdown": [...],
      "complexityAdditions": [...],
      "teamAllocation": [...],
      "examples": [...]
    }
  ]
}
```

## How It Works

### 1. PDF Reading
- Reads PDF file as binary
- Converts to base64 for API transmission

### 2. Claude API Call
- Sends PDF to Claude with detailed extraction prompt
- Uses `claude-sonnet-4-20250514` model
- Max tokens: 16,000 for comprehensive extraction

### 3. Structured Extraction
Claude extracts:
- **Basic Info**: Service code, name, version, category, description
- **Usage Scenarios**: All numbered scenarios with titles and descriptions
- **Dependencies**: Categorized by type (prerequisite, triggers, parallel)
- **Scope**: In-scope items (hierarchical) and out-of-scope list
- **Prerequisites**: Grouped by category (organizational, technical, documentation)
- **Tools**: Categorized tools (cloud platforms, design, automation, etc.)
- **Licenses**: Grouped by type (required, recommended, provided)
- **Stakeholder Info**: Interaction level, requirements, workshop roles
- **Inputs/Outputs**: Parameter definitions and deliverable categories
- **Timeline**: Phases with durations by size
- **Size Options**: Complete sizing info including:
  - Effort breakdown by scope area
  - Complexity additions
  - Team allocations by role
  - Real-world examples with characteristics
  - Scope dependencies
  - Sizing parameters
- **Roles**: Responsible roles with primary owner flag
- **Multi-Cloud**: Considerations for multi-cloud scenarios

### 4. Validation
- Parses JSON response
- Validates against JSON Schema
- Reports any validation errors

### 5. Output
- Saves validated JSON to output directory
- Uses PDF filename as base for JSON filename

## Error Handling

### Common Issues

**1. Missing API Key**
```
❌ Error: ANTHROPIC_API_KEY environment variable not set
```
**Solution**: Set the environment variable with your API key

**2. No PDF Files**
```
⚠️  No PDF files found in pdfs/
```
**Solution**: Place PDF files in the `pdfs/` directory

**3. Schema Validation Failed**
```
⚠️  JSON schema validation failed: 'serviceCode' is a required property
```
**Solution**: Check PDF content - may need manual review and correction

**4. API Error**
```
❌ Failed to process file.pdf: Claude API error: rate_limit_error
```
**Solution**: Wait a moment and retry, or check your API limits

## Advanced Usage

### Process Specific PDFs

Edit the script to filter specific files:

```python
# In main() function
pdf_files = list(pdf_dir.glob("Enterprise*.pdf"))  # Only Enterprise files
```

### Adjust Model Parameters

```python
# In ServicePdfExtractor.__init__()
self.model = "claude-sonnet-4-20250514"  # Change model
self.max_tokens = 16000                  # Adjust token limit
```

### Add Custom Validation

```python
# In process_pdf_file() function
def process_pdf_file(extractor, pdf_path, output_dir):
    service_data = extractor.extract_from_pdf(str(pdf_path))
    
    # Custom validation
    if not service_data.get('sizeOptions'):
        print("⚠️  Warning: No size options found")
    
    # Save...
```

## Cost Estimation

Based on Anthropic pricing (as of Jan 2026):
- Model: Claude Sonnet 4
- Input: ~$3 per million tokens
- Output: ~$15 per million tokens

Typical service PDF (20-30 pages):
- Input tokens: ~50,000 (PDF content + prompt)
- Output tokens: ~8,000 (JSON response)
- Cost per PDF: ~$0.15 - $0.30

For 10 PDFs: ~$1.50 - $3.00

## Troubleshooting

### Large PDFs
If PDFs are very large (>50 pages), consider:
1. Splitting into sections
2. Increasing `max_tokens`
3. Using Claude Opus for better extraction

### Incomplete Extraction
If some data is missing:
1. Check PDF structure and formatting
2. Review extraction prompt
3. Add specific instructions for missing sections
4. Manually review and complete JSON

### Validation Errors
If schema validation fails:
1. Review the validation error message
2. Check the generated JSON
3. Fix manually or adjust extraction prompt
4. Re-run validation

## Next Steps

After successful extraction:

1. **Review JSONs**: Check `output/` directory for generated files
2. **Validate Data**: Manually review key sections
3. **Import**: Use the Import API to load into database:
   ```bash
   curl -X POST http://localhost:7071/api/services/import \
     -H "Content-Type: application/json" \
     -d @output/Service1.json
   ```

## Support

For issues or questions:
1. Check this README
2. Review console error messages
3. Validate JSON schema compliance
4. Check Anthropic API documentation

## License

Part of Service Catalogue Manager - See main project license.
