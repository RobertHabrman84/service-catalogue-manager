"""
Schema Analyzer for PDF Extractions
====================================

Analyzes all extracted JSON files and identifies schema mismatches.
Generates recommendations for schema or prompt fixes.

Usage:
    python analyze_extractions.py [output_dir]
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple


class SchemaAnalyzer:
    """Analyzes extracted JSONs and suggests schema/prompt fixes."""
    
    def __init__(self, output_dir: Path, schema_path: Path):
        """
        Initialize analyzer.
        
        Args:
            output_dir: Directory containing extracted JSON files
            schema_path: Path to JSON schema file
        """
        self.output_dir = output_dir
        self.schema = self._load_schema(schema_path)
        self.issues = []
        self.issue_patterns = defaultdict(list)
    
    def _load_schema(self, path: Path) -> Dict:
        """Load JSON schema."""
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def analyze_all(self) -> None:
        """Analyze all JSON files in output directory."""
        json_files = list(self.output_dir.glob("*.json"))
        
        if not json_files:
            print("⚠️  No JSON files found in output directory")
            return
        
        print(f"🔍 Analyzing {len(json_files)} extracted JSON file(s)...")
        print("=" * 80)
        
        for json_file in json_files:
            print(f"\n📄 {json_file.name}")
            issues = self.analyze_file(json_file)
            self.issues.extend(issues)
            
            # Group issues by pattern
            for issue in issues:
                pattern_key = f"{issue['path']}:{issue['expected_type']}->{issue['actual_type']}"
                self.issue_patterns[pattern_key].append({
                    'file': json_file.name,
                    'value': issue['value']
                })
        
        self.print_summary()
    
    def analyze_file(self, json_file: Path) -> List[Dict]:
        """Analyze a single JSON file."""
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            issues = self._detect_issues(data)
            
            if issues:
                print(f"   ⚠️  {len(issues)} issue(s) detected")
            else:
                print(f"   ✅ No issues detected")
            
            return issues
            
        except Exception as e:
            print(f"   ❌ Error reading file: {e}")
            return []
    
    def _detect_issues(self, data: Dict, path: str = "", schema_part: Dict = None) -> List[Dict]:
        """Recursively detect type mismatches."""
        if schema_part is None:
            schema_part = self.schema
        
        issues = []
        
        if 'properties' in schema_part:
            for key, value in data.items():
                if key not in schema_part['properties']:
                    continue
                
                prop_schema = schema_part['properties'][key]
                current_path = f"{path}.{key}" if path else key
                
                # Check type
                issues.extend(self._check_type(value, prop_schema, current_path))
                
                # Recurse
                if isinstance(value, dict):
                    issues.extend(self._detect_issues(value, current_path, prop_schema))
                elif isinstance(value, list) and 'items' in prop_schema:
                    for i, item in enumerate(value):
                        item_path = f"{current_path}[{i}]"
                        if isinstance(item, dict):
                            issues.extend(self._detect_issues(item, item_path, prop_schema['items']))
        
        return issues
    
    def _check_type(self, value, schema_part: Dict, path: str) -> List[Dict]:
        """Check if value matches expected type."""
        expected_type = schema_part.get('type')
        if not expected_type:
            return []
        
        # Handle array of types (e.g., ['string', 'null'])
        if isinstance(expected_type, list):
            expected_types = expected_type
        else:
            expected_types = [expected_type]
        
        actual_type = self._get_json_type(value)
        
        # Check if actual type matches any expected type
        if actual_type not in expected_types:
            return [{
                'path': path,
                'expected_type': '/'.join(expected_types),
                'actual_type': actual_type,
                'value': str(value)[:100]
            }]
        
        return []
    
    def _get_json_type(self, value) -> str:
        """Get JSON schema type name for Python value."""
        type_map = {
            str: 'string',
            int: 'integer',
            float: 'number',
            bool: 'boolean',
            list: 'array',
            dict: 'object',
            type(None): 'null'
        }
        return type_map.get(type(value), 'unknown')
    
    def print_summary(self) -> None:
        """Print analysis summary with recommendations."""
        print("\n" + "=" * 80)
        print("📊 ANALYSIS SUMMARY")
        print("=" * 80)
        
        if not self.issue_patterns:
            print("✅ No schema issues detected!")
            return
        
        print(f"\n⚠️  Found {len(self.issue_patterns)} distinct issue pattern(s):\n")
        
        for i, (pattern, occurrences) in enumerate(self.issue_patterns.items(), 1):
            path, types = pattern.split(':', 1)
            expected, actual = types.split('->')
            
            print(f"{i}. Path: {path}")
            print(f"   Expected: {expected}")
            print(f"   Actual: {actual}")
            print(f"   Occurrences: {len(occurrences)} file(s)")
            
            # Show example value
            if occurrences:
                example = occurrences[0]['value']
                print(f"   Example: {example}")
            
            # Suggest fix
            suggestion = self._suggest_fix(path, expected, actual)
            print(f"   💡 Suggestion: {suggestion}")
            print()
        
        self.generate_recommendations()
    
    def _suggest_fix(self, path: str, expected: str, actual: str) -> str:
        """Suggest how to fix the issue."""
        if expected == 'string' and actual == 'array':
            return f"Schema: Change '{path}' type to 'array'"
        elif expected == 'array' and actual == 'string':
            return f"Prompt: Specify '{path}' must be array, not comma-separated string"
        elif expected == 'string' and actual == 'integer':
            return f"Prompt: Specify '{path}' must be string (e.g., \"2-3 people\")"
        elif expected == 'integer' and actual == 'string':
            return f"Schema: Change '{path}' type to 'string'"
        elif expected == 'object' and actual == 'string':
            return f"Prompt: Specify '{path}' must be object with properties"
        elif expected == 'string' and actual == 'object':
            return f"Schema: Change '{path}' type to 'object'"
        else:
            return f"Review schema/prompt for '{path}'"
    
    def generate_recommendations(self) -> None:
        """Generate actionable recommendations."""
        print("=" * 80)
        print("🔧 RECOMMENDED ACTIONS")
        print("=" * 80)
        
        schema_fixes = []
        prompt_fixes = []
        
        for pattern, occurrences in self.issue_patterns.items():
            path, types = pattern.split(':', 1)
            expected, actual = types.split('->')
            
            # Determine if schema or prompt fix
            if self._should_fix_schema(expected, actual):
                schema_fixes.append((path, expected, actual))
            else:
                prompt_fixes.append((path, expected, actual))
        
        if schema_fixes:
            print("\n📝 Schema Fixes (change schema to match extracted data):")
            for i, (path, expected, actual) in enumerate(schema_fixes, 1):
                print(f"   {i}. {path}: '{expected}' → '{actual}'")
        
        if prompt_fixes:
            print("\n✏️  Prompt Fixes (update extraction instructions):")
            for i, (path, expected, actual) in enumerate(prompt_fixes, 1):
                print(f"   {i}. {path}: Specify must be '{expected}' not '{actual}'")
        
        print("\n" + "=" * 80)
        print("Next steps:")
        print("1. Review recommendations above")
        print("2. Apply schema fixes: edit schemas/service-import-schema.json")
        print("3. Apply prompt fixes: edit tools/pdf-extractor/extract_services.py")
        print("4. Re-run extraction: python extract_services.py")
        print("=" * 80)
    
    def _should_fix_schema(self, expected: str, actual: str) -> bool:
        """Determine if issue should be fixed in schema vs prompt."""
        # If Claude consistently returns a certain type, schema should adapt
        schema_fix_patterns = [
            (expected == 'string' and actual == 'array'),  # responsibilities
            (expected == 'string' and actual == 'integer'),  # teamSize
            (expected == 'object' and actual == 'string'),  # simple fields
        ]
        
        return any(schema_fix_patterns)


def main():
    """Main execution."""
    # Paths
    script_dir = Path(__file__).parent
    output_dir = script_dir / "output"
    schema_path = script_dir.parent.parent / "schemas" / "service-import-schema.json"
    
    # Override output dir from command line
    if len(sys.argv) > 1:
        output_dir = Path(sys.argv[1])
    
    if not output_dir.exists():
        print(f"❌ Output directory not found: {output_dir}")
        sys.exit(1)
    
    if not schema_path.exists():
        print(f"❌ Schema not found: {schema_path}")
        sys.exit(1)
    
    # Run analysis
    analyzer = SchemaAnalyzer(output_dir, schema_path)
    analyzer.analyze_all()


if __name__ == "__main__":
    main()
