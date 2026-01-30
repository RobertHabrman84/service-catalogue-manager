import re
import os
import glob

print("=" * 80)
print("DEEP DBCONTEXT CROSS-REFERENCE ANALYSIS")
print("=" * 80)

# Read files
with open('src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs', 'r') as f:
    dbcontext = f.read()

with open('db_structure.sql', 'r') as f:
    db_structure = f.read()

issues = []
warnings = []

# Get all entity files
entity_files = glob.glob('src/backend/ServiceCatalogueManager.Api/Data/Entities/*.cs')

print(f"\nAnalyzing {len(entity_files)} entity files...\n")

# Extract entity configurations from DbContext
entity_configs = {}
config_pattern = r'modelBuilder\.Entity<(\w+)>\(entity =>(.*?)\n        \}\);'
for match in re.finditer(config_pattern, dbcontext, re.DOTALL):
    entity_name = match.group(1)
    config_body = match.group(2)
    entity_configs[entity_name] = config_body

print("CROSS-REFERENCE CHECK: Entity Properties vs DbContext HasKey")
print("-" * 80)

for entity_file in entity_files:
    with open(entity_file, 'r') as f:
        entity_content = f.read()
    
    # Extract class name
    class_match = re.search(r'public class (\w+)', entity_content)
    if not class_match:
        continue
    
    entity_name = class_match.group(1)
    
    # Skip if not in DbContext
    if entity_name not in entity_configs:
        continue
    
    # Extract PK property from entity
    pk_pattern = r'public int (\w+Id) \{ get; set; \}'
    pk_matches = re.findall(pk_pattern, entity_content)
    
    if not pk_matches:
        continue
    
    # Get HasKey from DbContext
    haskey_match = re.search(r'entity\.HasKey\(e => e\.(\w+)\)', entity_configs[entity_name])
    
    if not haskey_match:
        warnings.append({
            "severity": "WARNING",
            "entity": entity_name,
            "issue": "No HasKey mapping found in DbContext",
            "recommendation": "Add explicit HasKey mapping"
        })
        print(f"  ⚠️  {entity_name:30s} -> Missing HasKey in DbContext")
        continue
    
    dbcontext_key = haskey_match.group(1)
    
    # Check if the HasKey matches any PK property in entity
    if dbcontext_key not in pk_matches:
        issues.append({
            "severity": "ERROR",
            "entity": entity_name,
            "entity_file": entity_file,
            "entity_pk": pk_matches[0] if pk_matches else "NOT FOUND",
            "dbcontext_key": dbcontext_key,
            "issue": f"HasKey mismatch: DbContext uses '{dbcontext_key}' but entity has '{pk_matches[0]}'",
            "fix": f"Change DbContext line to: entity.HasKey(e => e.{pk_matches[0]});"
        })
        print(f"  ❌ {entity_name:30s} -> Entity: {pk_matches[0]} | DbContext: {dbcontext_key} (MISMATCH!)")
    else:
        print(f"  ✅ {entity_name:30s} -> {dbcontext_key}")

print()
print("=" * 80)
print("CHECKING: db_structure.sql vs DbContext Table Names")
print("=" * 80)

# Extract CREATE TABLE statements from db_structure.sql
db_tables = re.findall(r'CREATE TABLE dbo\.(\w+)', db_structure)
db_tables_set = set(db_tables)

# Extract ToTable mappings from DbContext
dbcontext_tables = {}
for entity_name, config in entity_configs.items():
    table_match = re.search(r'entity\.ToTable\("(\w+)"\)', config)
    if table_match:
        dbcontext_tables[entity_name] = table_match.group(1)

print(f"\nFound {len(db_tables_set)} tables in db_structure.sql")
print(f"Found {len(dbcontext_tables)} ToTable mappings in DbContext\n")

for entity_name, table_name in sorted(dbcontext_tables.items()):
    if table_name not in db_tables_set:
        issues.append({
            "severity": "ERROR",
            "entity": entity_name,
            "table": table_name,
            "issue": f"Table '{table_name}' mapped in DbContext but not found in db_structure.sql",
            "fix": f"Add 'CREATE TABLE dbo.{table_name}' to db_structure.sql"
        })
        print(f"  ❌ {entity_name:30s} -> {table_name} (NOT IN DB!)")
    else:
        print(f"  ✅ {entity_name:30s} -> {table_name}")

print()
print("=" * 80)
print("CHECKING: Missing HasPrecision for DECIMAL columns")
print("=" * 80)

# Check db_structure for DECIMAL columns
decimal_columns = {}
for table_name in db_tables:
    table_pattern = f'CREATE TABLE dbo\.{table_name}\\s*\\((.*?)\\);'
    table_match = re.search(table_pattern, db_structure, re.DOTALL)
    if table_match:
        table_body = table_match.group(1)
        # Find DECIMAL columns
        decimal_cols = re.findall(r'(\w+)\s+DECIMAL\((\d+),\s*(\d+)\)', table_body)
        if decimal_cols:
            decimal_columns[table_name] = decimal_cols

print(f"\nFound DECIMAL columns in {len(decimal_columns)} tables\n")

for table_name, cols in sorted(decimal_columns.items()):
    # Find corresponding entity
    entity_name = None
    for ent, tbl in dbcontext_tables.items():
        if tbl == table_name:
            entity_name = ent
            break
    
    if not entity_name:
        continue
    
    # Check if DbContext has HasPrecision for these columns
    for col_name, precision, scale in cols:
        precision_pattern = f'entity\\.Property\\(e => e\\.{col_name}\\)\\.HasPrecision'
        if precision_pattern not in entity_configs.get(entity_name, ''):
            warnings.append({
                "severity": "WARNING",
                "entity": entity_name,
                "table": table_name,
                "column": col_name,
                "issue": f"DECIMAL column '{col_name}' in DB but no HasPrecision in DbContext",
                "recommendation": f"Add: entity.Property(e => e.{col_name}).HasPrecision({precision}, {scale});"
            })
            print(f"  ⚠️  {entity_name:30s} -> {col_name} DECIMAL({precision},{scale}) missing HasPrecision")

print()
print("=" * 80)
print("FINAL SUMMARY")
print("=" * 80)
print(f"Total Entities Checked: {len(entity_configs)}")
print(f"❌ Critical Issues: {len([i for i in issues if i['severity'] == 'ERROR'])}")
print(f"⚠️  Warnings: {len(warnings)}")
print()

if issues:
    print("=" * 80)
    print("❌ CRITICAL ISSUES FOUND")
    print("=" * 80)
    for i, issue in enumerate(issues, 1):
        print(f"\n{i}. [{issue['severity']}] {issue['entity']}")
        print(f"   Issue: {issue['issue']}")
        if 'fix' in issue:
            print(f"   Fix: {issue['fix']}")
        if 'entity_pk' in issue:
            print(f"   Entity PK: {issue['entity_pk']}")
            print(f"   DbContext Key: {issue['dbcontext_key']}")

if warnings:
    print()
    print("=" * 80)
    print("⚠️  WARNINGS")
    print("=" * 80)
    for i, warning in enumerate(warnings, 1):
        print(f"\n{i}. {warning['entity']} - {warning.get('column', 'N/A')}")
        print(f"   {warning['issue']}")
        if 'recommendation' in warning:
            print(f"   Recommendation: {warning['recommendation']}")

# Save detailed report
import json
with open('deep_dbcontext_analysis.json', 'w') as f:
    json.dump({
        "summary": {
            "total_entities": len(entity_configs),
            "critical_issues": len([i for i in issues if i['severity'] == 'ERROR']),
            "warnings": len(warnings)
        },
        "issues": issues,
        "warnings": warnings
    }, f, indent=2)

print()
print("=" * 80)
print("✅ Detailed report saved to: deep_dbcontext_analysis.json")
print("=" * 80)

