#!/usr/bin/env python3
"""
Automatická analýza nesrovnalostí mezi databázovým schématem a C# entity modely
"""

import re
import json
from pathlib import Path

def parse_db_schema(db_file):
    """Parse SQL schema file and extract table definitions"""
    with open(db_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tables = {}
    # Find all CREATE TABLE statements
    table_pattern = r'CREATE TABLE\s+dbo\.(\w+)\s*\((.*?)\);'
    
    for match in re.finditer(table_pattern, content, re.DOTALL | re.IGNORECASE):
        table_name = match.group(1)
        columns_block = match.group(2)
        
        # Extract column definitions
        columns = []
        for line in columns_block.split('\n'):
            line = line.strip()
            if line and not line.startswith('CONSTRAINT') and not line.startswith('PRIMARY KEY'):
                # Extract column name (first word)
                parts = line.split()
                if parts and not parts[0].upper() in ['CONSTRAINT', 'PRIMARY', 'FOREIGN', 'UNIQUE', 'CHECK']:
                    col_name = parts[0].strip(',')
                    columns.append(col_name)
        
        tables[table_name] = columns
    
    return tables

def parse_entity_classes(entities_dir):
    """Parse C# entity classes and extract properties"""
    entities = {}
    
    for cs_file in Path(entities_dir).rglob('*.cs'):
        if 'Migrations' in str(cs_file) or 'DbContext' in str(cs_file):
            continue
            
        with open(cs_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all public class definitions
        class_pattern = r'public class (\w+).*?\{(.*?)(?=\n\s*public class|\n\s*public interface|\Z)'
        
        for match in re.finditer(class_pattern, content, re.DOTALL):
            class_name = match.group(1)
            class_body = match.group(2)
            
            # Skip base classes and interfaces
            if class_name in ['BaseEntity', 'ISortable', 'IEntity']:
                continue
            
            # Extract properties
            properties = []
            prop_pattern = r'public\s+\w+[\?\[\]]*\s+(\w+)\s*\{[^}]*get;'
            
            for prop_match in re.finditer(prop_pattern, class_body):
                prop_name = prop_match.group(1)
                # Skip navigation properties (virtual keyword or collection types)
                if 'virtual' not in prop_match.group(0) and 'ICollection' not in prop_match.group(0):
                    properties.append(prop_name)
            
            if properties:
                entities[class_name] = properties
    
    return entities

def compare_schemas(db_tables, entities):
    """Compare database schema with entity models"""
    issues = []
    
    for entity_name, entity_props in entities.items():
        # Try to find corresponding table (handle naming conventions)
        table_name = entity_name
        if table_name not in db_tables:
            # Try common variations
            continue
        
        db_columns = [col.lower() for col in db_tables[table_name]]
        
        for prop in entity_props:
            # Convert C# property to expected DB column name
            # C# convention: PascalCase, DB convention: PascalCase (SQL Server)
            expected_col = prop
            
            if expected_col.lower() not in db_columns:
                issues.append({
                    'entity': entity_name,
                    'table': table_name,
                    'property': prop,
                    'issue_type': 'MISSING_COLUMN',
                    'severity': 'HIGH'
                })
    
    # Check for tables without entities
    for table_name in db_tables:
        if table_name not in entities and not table_name.startswith('LU_'):
            issues.append({
                'table': table_name,
                'issue_type': 'NO_ENTITY',
                'severity': 'MEDIUM'
            })
    
    return issues

def main():
    base_path = Path('/home/user/webapp')
    db_schema_file = base_path / 'db_structure.sql'
    entities_dir = base_path / 'src/backend/ServiceCatalogueManager.Api/Data/Entities'
    
    print("🔍 Analyzing database schema...")
    db_tables = parse_db_schema(db_schema_file)
    print(f"✅ Found {len(db_tables)} database tables")
    
    print("\n🔍 Analyzing C# entity models...")
    entities = parse_entity_classes(entities_dir)
    print(f"✅ Found {len(entities)} entity classes")
    
    print("\n🔍 Comparing schemas...")
    issues = compare_schemas(db_tables, entities)
    
    print(f"\n📊 Found {len(issues)} potential issues\n")
    print("=" * 80)
    
    # Group by severity
    high_severity = [i for i in issues if i['severity'] == 'HIGH']
    
    if high_severity:
        print("\n🔴 HIGH SEVERITY ISSUES:")
        print("-" * 80)
        for issue in high_severity:
            if issue['issue_type'] == 'MISSING_COLUMN':
                print(f"\nEntity: {issue['entity']}")
                print(f"  Table: {issue['table']}")
                print(f"  Missing Column: {issue['property']}")
                print(f"  ❌ Property exists in C# but column is MISSING in database")
    
    # Save detailed report
    report_file = base_path / 'schema_analysis_report.json'
    with open(report_file, 'w') as f:
        json.dump({
            'database_tables': {k: v for k, v in db_tables.items()},
            'entity_models': {k: v for k, v in entities.items()},
            'issues': issues
        }, f, indent=2)
    
    print(f"\n\n📄 Detailed report saved to: {report_file}")
    
    return len(high_severity)

if __name__ == '__main__':
    exit(main())
