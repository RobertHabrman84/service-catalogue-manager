"""
PDF to JSON Service Extractor
==============================

This script extracts structured service catalog data from PDF documents
using Claude API and converts it to JSON format according to the import schema.

Author: Service Catalogue Manager Team
Date: 2026-01-26
"""

import json
import base64
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional
import anthropic
from jsonschema import validate, ValidationError
from json_repair import repair_json


class ServicePdfExtractor:
    """
    Extracts structured JSON data from service catalog PDF documents
    using Claude API.
    """
    
    def __init__(self, api_key: str, schema_path: str, output_dir: Path = None):
        """
        Initialize the PDF extractor.
        
        Args:
            api_key: Anthropic API key
            schema_path: Path to JSON schema file
            output_dir: Directory for output files (for debug logging)
        """
        self.client = anthropic.Anthropic(api_key=api_key)
        self.schema = self._load_schema(schema_path)
        self.model = "claude-sonnet-4-20250514"
        self.max_tokens = 32000  # Increased from 16000 for larger PDFs
        self.output_dir = output_dir
    
    def _load_schema(self, path: str) -> Dict:
        """Load JSON schema from file."""
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            raise Exception(f"Failed to load schema from {path}: {str(e)}")
    
    def extract_from_pdf(self, pdf_path: str) -> Dict:
        """
        Extract structured JSON from PDF using Claude API.
        
        Args:
            pdf_path: Path to PDF file
            
        Returns:
            Dictionary with extracted service data
        """
        print(f"📄 Processing: {pdf_path}")
        
        # Read PDF content
        with open(pdf_path, 'rb') as f:
            pdf_content = f.read()
        
        # Convert to base64
        pdf_base64 = base64.standard_b64encode(pdf_content).decode('utf-8')
        
        # Create extraction prompt
        prompt = self._create_extraction_prompt()
        
        print("🤖 Calling Claude API...")
        
        try:
            # Call Claude API with extended timeout for large PDFs
            message = self.client.messages.create(
                model=self.model,
                max_tokens=self.max_tokens,
                timeout=900.0,  # 15 minutes timeout for large PDFs
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "document",
                                "source": {
                                    "type": "base64",
                                    "media_type": "application/pdf",
                                    "data": pdf_base64
                                }
                            },
                            {
                                "type": "text",
                                "text": prompt
                            }
                        ]
                    }
                ]
            )
            
            # Extract JSON from response
            json_text = self._extract_json_from_response(message.content)
            
            # Parse JSON with automatic repair
            service_data = self._parse_json_safely(json_text)
            
            print("✅ Extraction successful")
            
            # Validate against schema
            self._validate_against_schema(service_data)
            
            return service_data
            
        except anthropic.APIError as e:
            raise Exception(f"Claude API error: {str(e)}")
        except json.JSONDecodeError as e:
            raise Exception(f"Failed to parse JSON response: {str(e)}")
        except Exception as e:
            raise Exception(f"Extraction failed: {str(e)}")
    
    def _create_extraction_prompt(self) -> str:
        """Create the extraction prompt for Claude."""
        return f"""You are extracting structured data from a Service Catalogue PDF document.

**Task:** Extract ALL information from the PDF and structure it as JSON according to the provided schema.

**JSON Schema Reference:**
The output must conform to the service import JSON schema with the following structure:
- serviceCode (required, pattern: ID0XX)
- serviceName (required)
- version (default: v1.0)
- category (required)
- description (required)
- notes (optional)
- usageScenarios (array of scenarios with scenarioNumber, scenarioTitle, scenarioDescription)
- dependencies (object with prerequisite, triggersFor, parallelWith arrays)
- scope (object with inScope and outOfScope)
- prerequisites (organizational, technical, documentation)
- toolsAndEnvironment (cloudPlatforms, designTools, automationTools, etc.)
- licenses (requiredByCustomer, recommendedOptional, providedByServiceProvider)
- stakeholderInteraction (interactionLevel, customerMustProvide, workshopParticipation, accessRequirements)
- serviceInputs (array of parameters with requirementLevel)
- serviceOutputs (array of output categories with items)
- timeline (phases array)
- sizeOptions (array with S/M/L sizing, effort breakdown, complexity additions, team allocation, examples)
- responsibleRoles (array of roles)
- multiCloudConsiderations (array of considerations)

**Critical Instructions:**

1. **Service Code & Basic Info:**
   - Extract the ID code (e.g., ID001, ID002)
   - Extract full service name
   - Extract version (default to v1.0 if not specified)
   - Extract category path (e.g., "Services/Architecture/Technical Architecture")
   - Extract complete description

2. **Usage Scenarios:**
   - Extract ALL numbered scenarios (typically 6-8)
   - Include scenarioNumber, scenarioTitle, and full scenarioDescription
   - Preserve order with sortOrder

3. **Dependencies:**
   - Group into three types: prerequisite, triggersFor, parallelWith
   - For each dependency include: serviceName, serviceCode (if mentioned), requirementLevel (REQUIRED/RECOMMENDED/OPTIONAL)

4. **Scope:**
   - In-scope: Extract all numbered categories with their items
   - Each category should have categoryName, categoryNumber (if numbered), and items array
   - Out-of-scope: Extract all bullet points as simple strings

5. **Prerequisites:**
   - Group by category: organizational, technical, documentation
   - For each prerequisite: name, description, requirementLevel

6. **Tools and Environment:**
   - Group by category: cloudPlatforms, designTools, automationTools, collaborationTools
   - Extract tool names, versions (if specified), purpose

7. **Licenses:**
   - Group into: requiredByCustomer, recommendedOptional, providedByServiceProvider
   - For each: licenseName, licenseType, description

8. **Stakeholder Interaction:**
   - Extract interactionLevel (LOW/MEDIUM/HIGH)
   - Extract "Customer Must Provide" list
   - Extract workshop participation roles with involvementLevel
   - Extract access requirements

9. **Service Inputs:**
   - Extract ALL input parameters
   - Include: parameterName, description, requirementLevel (REQUIRED/RECOMMENDED/OPTIONAL)
   - Include dataType, defaultValue, exampleValue if mentioned

10. **Service Outputs:**
    - Extract all numbered output categories
    - For each category: categoryName, categoryNumber, items array
    - Each item should have itemName and itemDescription

11. **Timeline:**
    - Extract all phases with phaseNumber, phaseName, description
    - Include durationBySize (small, medium, large) if provided

12. **Size Options (CRITICAL - Most Complex Section):**
    - Extract ALL size options (S, M, L, typically 3)
    - For EACH size option extract:
      a) Basic info: sizeCode, description, duration, durationInDays
      b) Effort: hours (or hoursMin/hoursMax range), currency
      c) teamSize, complexity (LOW/MEDIUM/HIGH)
      d) sizingCriteria: array of criteria with criteriaName and values
      e) effortBreakdown: array with scopeArea, baseHours, notes
      f) complexityAdditions: array with factor, condition, additionalHours
      g) teamAllocation: array with role, allocation (FTE), notes
      h) examples: array with exampleName, scenario, description, characteristics (name/value pairs), deliverables
      i) scopeDependencies: array with scopeArea and requires array
      j) sizingParameters: array with parameterName, parameterType (SCALE/TECHNICAL), description, values

13. **Responsible Roles:**
    - Extract all roles
    - For each: roleName, isPrimaryOwner (true for primary, false otherwise), responsibilities

14. **Multi-Cloud Considerations:**
    - Extract all considerations as array
    - Each with: considerationTitle, description

**Output Format:**
- Return ONLY valid JSON
- No markdown code blocks (no ```json)
- No explanations or preamble
- Start directly with {{ and end with }}
- Use null for missing optional fields
- Use empty arrays [] for missing array fields
- Ensure all required fields are present

**Data Type Rules:**
- Strings: Use quotes
- Numbers: No quotes (e.g., 160, 240, 0.5)
- Booleans: true or false (no quotes)
- Arrays: Use [] even if empty
- Objects: Use {{}} even if empty
- Enums: Use exact values (REQUIRED, RECOMMENDED, OPTIONAL, LOW, MEDIUM, HIGH, S, M, L)

**Quality Checks:**
- Preserve ALL details - do not summarize
- Maintain exact hierarchies (categories → items)
- Keep original numbers (hours, days, FTE allocations)
- Extract ALL examples for each size option
- Include ALL characteristics for each example

Begin extraction now. Return only the JSON object:"""
    
    def _extract_json_from_response(self, content) -> str:
        """Extract JSON from Claude's response."""
        text = content[0].text
        
        # Remove markdown code blocks if present
        if '```json' in text:
            text = text.split('```json')[1].split('```')[0]
        elif '```' in text:
            text = text.split('```')[1].split('```')[0]
        
        return text.strip()
    
    def _parse_json_safely(self, json_text: str) -> Dict:
        """
        Parse JSON with automatic repair for common issues.
        
        Args:
            json_text: JSON string to parse
            
        Returns:
            Parsed JSON dictionary
        """
        try:
            # First try: standard parse
            return json.loads(json_text)
        except json.JSONDecodeError as e:
            print(f"⚠️  JSON parse error at line {e.lineno}, col {e.colno}")
            print(f"   Message: {e.msg}")
            print("🔧 Attempting automatic repair...")
            
            try:
                # Second try: repair and parse
                repaired = repair_json(json_text)
                result = json.loads(repaired)
                print("✅ JSON repaired successfully")
                return result
            except Exception as repair_error:
                print(f"❌ JSON repair failed: {str(repair_error)}")
                if self.output_dir:
                    self._save_debug_json(json_text, e)
                raise
    
    def _save_debug_json(self, json_text: str, error: Exception) -> None:
        """
        Save problematic JSON for debugging.
        
        Args:
            json_text: The problematic JSON string
            error: The exception that occurred
        """
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        debug_file = self.output_dir / f"debug_failed_{timestamp}.txt"
        
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"Error: {str(error)}\n")
            f.write(f"Error Type: {type(error).__name__}\n")
            if hasattr(error, 'lineno'):
                f.write(f"Line: {error.lineno}, Column: {error.colno}\n")
            f.write("=" * 80 + "\n\n")
            f.write(json_text)
        
        print(f"🐛 Debug JSON saved to: {debug_file}")
    
    def _validate_against_schema(self, data: Dict) -> None:
        """Validate extracted JSON against schema."""
        try:
            validate(instance=data, schema=self.schema)
            print("✅ JSON schema validation passed")
        except ValidationError as e:
            print(f"⚠️  JSON schema validation failed: {e.message}")
            print(f"   Path: {' -> '.join(str(p) for p in e.path)}")
            raise


def process_pdf_file(
    extractor: ServicePdfExtractor,
    pdf_path: Path,
    output_dir: Path
) -> bool:
    """
    Process a single PDF file and save JSON output.
    
    Args:
        extractor: ServicePdfExtractor instance
        pdf_path: Path to PDF file
        output_dir: Directory for output JSON
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Extract JSON from PDF
        service_data = extractor.extract_from_pdf(str(pdf_path))
        
        # Determine output filename
        output_file = output_dir / f"{pdf_path.stem}.json"
        
        # Save JSON
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(service_data, f, indent=2, ensure_ascii=False)
        
        print(f"💾 Saved to: {output_file}")
        print(f"📊 Service Code: {service_data.get('serviceCode', 'N/A')}")
        print(f"📊 Service Name: {service_data.get('serviceName', 'N/A')}")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to process {pdf_path.name}: {str(e)}")
        return False


def main():
    """Main execution function."""
    
    # Configuration
    API_KEY = os.environ.get('ANTHROPIC_API_KEY')
    if not API_KEY:
        print("❌ Error: ANTHROPIC_API_KEY environment variable not set")
        print("   Set it with: export ANTHROPIC_API_KEY='your-api-key'")
        sys.exit(1)
    
    # Paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent
    schema_path = project_root / "schemas" / "service-import-schema.json"
    pdf_dir = script_dir / "pdfs"
    output_dir = script_dir / "output"
    
    # Check paths
    if not schema_path.exists():
        print(f"❌ Error: Schema not found at {schema_path}")
        sys.exit(1)
    
    if not pdf_dir.exists():
        print(f"📁 Creating PDF directory: {pdf_dir}")
        pdf_dir.mkdir(parents=True)
        print(f"   Please place PDF files in: {pdf_dir}")
        sys.exit(0)
    
    # Create output directory
    output_dir.mkdir(exist_ok=True)
    
    # Find PDF files
    pdf_files = list(pdf_dir.glob("*.pdf"))
    
    if not pdf_files:
        print(f"⚠️  No PDF files found in {pdf_dir}")
        print(f"   Please place PDF files in this directory")
        sys.exit(0)
    
    print(f"🚀 Service Catalog PDF Extractor")
    print(f"=" * 60)
    print(f"Schema: {schema_path.name}")
    print(f"PDF Directory: {pdf_dir}")
    print(f"Output Directory: {output_dir}")
    print(f"Found {len(pdf_files)} PDF file(s)")
    print(f"=" * 60)
    print()
    
    # Initialize extractor
    extractor = ServicePdfExtractor(API_KEY, str(schema_path), output_dir)
    
    # Process each PDF
    success_count = 0
    failure_count = 0
    
    for i, pdf_file in enumerate(pdf_files, 1):
        print(f"\n[{i}/{len(pdf_files)}] Processing: {pdf_file.name}")
        print("-" * 60)
        
        if process_pdf_file(extractor, pdf_file, output_dir):
            success_count += 1
        else:
            failure_count += 1
        
        print("-" * 60)
    
    # Summary
    print(f"\n{'=' * 60}")
    print(f"📊 Summary")
    print(f"{'=' * 60}")
    print(f"✅ Successful: {success_count}")
    print(f"❌ Failed: {failure_count}")
    print(f"📁 Output directory: {output_dir}")
    print()
    
    if success_count > 0:
        print("✅ Extraction complete! JSON files are ready for import.")
    
    if failure_count > 0:
        print("⚠️  Some files failed to process. Check error messages above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
