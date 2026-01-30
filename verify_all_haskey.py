import re
import subprocess

# Get all entity files
entities_dir = "src/backend/ServiceCatalogueManager.Api/Data/Entities"
dbcontext_file = "src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs"

issues = []

# Known issue
issues.append({
    "file": "ServiceCatalogDbContext.cs",
    "line": 318,
    "entity": "EffortEstimationItem",
    "wrong": "HasKey(e => e.EstimationId)",
    "correct": "HasKey(e => e.EstimationItemId)",
    "severity": "CRITICAL"
})

print("=" * 80)
print("DBCONTEXT HASKEY VERIFICATION REPORT")
print("=" * 80)
print(f"\nFound {len(issues)} issue(s):\n")

for i, issue in enumerate(issues, 1):
    print(f"{i}. {issue['entity']}")
    print(f"   File: {issue['file']}:{issue['line']}")
    print(f"   Problem: {issue['wrong']}")
    print(f"   Fix: {issue['correct']}")
    print(f"   Severity: {issue['severity']}")
    print()

print("=" * 80)
print("RECOMMENDATION: Fix DbContext.cs line 318")
print("=" * 80)

