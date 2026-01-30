import re
import json

# Read DbContext file
with open('src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs', 'r') as f:
    dbcontext_content = f.read()

# Read db_structure.sql
with open('db_structure.sql', 'r') as f:
    db_structure = f.read()

issues = []
warnings = []
recommendations = []

# Extract all Entity configurations
entity_configs = re.findall(r'modelBuilder\.Entity<(\w+)>\(entity =>(.*?)}\);', dbcontext_content, re.DOTALL)

print("=" * 80)
print("COMPREHENSIVE DBCONTEXT VERIFICATION REPORT")
print("=" * 80)
print(f"\nFound {len(entity_configs)} entity configurations to check\n")

# Check 1: HasKey mappings
print("CHECK 1: Verifying HasKey mappings...")
print("-" * 80)

haskey_pattern = r'entity\.HasKey\(e => e\.(\w+)\)'
for entity_name, config in entity_configs:
    haskey_matches = re.findall(haskey_pattern, config)
    if haskey_matches:
        for key_property in haskey_matches:
            print(f"  {entity_name:30s} -> HasKey: {key_property}")

print()

# Check 2: Table name mappings
print("CHECK 2: Verifying ToTable mappings...")
print("-" * 80)

totable_pattern = r'entity\.ToTable\("(\w+)"\)'
for entity_name, config in entity_configs:
    totable_matches = re.findall(totable_pattern, config)
    if totable_matches:
        table_name = totable_matches[0]
        print(f"  {entity_name:30s} -> Table: {table_name}")
        
        # Check if table exists in db_structure.sql
        if f"CREATE TABLE dbo.{table_name}" not in db_structure:
            issues.append({
                "severity": "ERROR",
                "entity": entity_name,
                "issue": f"Table '{table_name}' not found in db_structure.sql",
                "fix": f"Add CREATE TABLE dbo.{table_name} to db_structure.sql"
            })

print()

# Check 3: HasPrecision for decimal columns
print("CHECK 3: Verifying HasPrecision for decimal/numeric properties...")
print("-" * 80)

precision_pattern = r'entity\.Property\(e => e\.(\w+)\)\.HasPrecision\((\d+),\s*(\d+)\)'
for entity_name, config in entity_configs:
    precision_matches = re.findall(precision_pattern, config)
    if precision_matches:
        for prop_name, precision, scale in precision_matches:
            print(f"  {entity_name:30s} -> {prop_name}: HasPrecision({precision}, {scale})")

print()

# Check 4: Foreign key relationships
print("CHECK 4: Verifying foreign key relationships...")
print("-" * 80)

fk_pattern = r'entity\.HasOne\(e => e\.(\w+)\).*?\.HasForeignKey\(e => e\.(\w+)\)'
for entity_name, config in entity_configs:
    fk_matches = re.findall(fk_pattern, config, re.DOTALL)
    if fk_matches:
        for nav_prop, fk_prop in fk_matches:
            print(f"  {entity_name:30s} -> {nav_prop} via {fk_prop}")

print()

# Check 5: OnDelete behaviors
print("CHECK 5: Verifying OnDelete behaviors...")
print("-" * 80)

delete_pattern = r'\.OnDelete\(DeleteBehavior\.(\w+)\)'
for entity_name, config in entity_configs:
    delete_matches = re.findall(delete_pattern, config)
    if delete_matches:
        for behavior in delete_matches:
            print(f"  {entity_name:30s} -> OnDelete: {behavior}")

print()

# Output summary
print("=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"Total configurations checked: {len(entity_configs)}")
print(f"Issues found: {len(issues)}")
print(f"Warnings: {len(warnings)}")
print(f"Recommendations: {len(recommendations)}")
print()

if issues:
    print("\n⚠️  ISSUES FOUND:")
    for i, issue in enumerate(issues, 1):
        print(f"\n{i}. [{issue['severity']}] {issue['entity']}")
        print(f"   Issue: {issue['issue']}")
        print(f"   Fix: {issue['fix']}")

# Save report
with open('dbcontext_verification_report.json', 'w') as f:
    json.dump({
        "total_configs": len(entity_configs),
        "issues": issues,
        "warnings": warnings,
        "recommendations": recommendations
    }, f, indent=2)

print("\n✅ Report saved to: dbcontext_verification_report.json")

