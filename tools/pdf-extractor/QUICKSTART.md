# Quick Start Guide - PDF Extractor

## 5-Minute Setup

### Step 1: Install Dependencies (1 minute)

```bash
cd tools/pdf-extractor
pip install -r requirements.txt
```

### Step 2: Set API Key (1 minute)

**Option A - Environment Variable (Temporary)**
```bash
# Linux/Mac
export ANTHROPIC_API_KEY='sk-ant-...'

# Windows PowerShell
$env:ANTHROPIC_API_KEY='sk-ant-...'
```

**Option B - .env File (Permanent)**
```bash
# Copy example and edit
cp .env.example .env
# Edit .env and add your API key
nano .env
```

### Step 3: Place PDF Files (1 minute)

```bash
# Copy your PDFs to the pdfs directory
cp /path/to/your/service.pdf pdfs/
```

### Step 4: Run Extraction (2 minutes)

**Linux/Mac:**
```bash
./run.sh
```

**Windows PowerShell:**
```powershell
.\run.ps1
```

**Or directly:**
```bash
python extract_services.py
```

### Step 5: Check Results

```bash
# View generated JSON files
ls output/

# View a JSON file
cat output/Enterprise_Scale_Landing_Zone_Design.json
```

## That's it! 🎉

Your JSON files are now in the `output/` directory, ready for import.

## Next Steps

1. **Review JSONs**: Open and verify the extracted data
2. **Import to Database**: Use the Import API endpoint
3. **Verify in UI**: Check the Service Catalogue Manager frontend

## Troubleshooting

### "API key not set"
→ Make sure you've set the `ANTHROPIC_API_KEY` environment variable

### "No PDF files found"
→ Place your PDF files in the `pdfs/` directory

### "Module not found"
→ Run `pip install -r requirements.txt`

### "Validation failed"
→ Check the error message and manually review/fix the JSON

## Example API Import

After extraction, import to database:

```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @output/Enterprise_Scale_Landing_Zone_Design.json
```

## Cost

~$0.15-$0.30 per PDF (typical 20-30 page service document)

## Support

See full README.md for detailed documentation.
