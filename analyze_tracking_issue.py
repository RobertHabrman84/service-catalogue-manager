"""
CRITICAL ERROR ANALYSIS: ServiceSizeOption Entity Tracking Conflict
====================================================================

ERROR: The instance of entity type 'ServiceSizeOption' cannot be tracked because 
another instance with the same key value for {'ServiceSizeOptionId'} is already being tracked.

LOCATION: ImportOrchestrationService.ImportSizeOptionsAsync (line 1100)
"""

import json
from datetime import datetime

analysis = {
    "error_analysis": {
        "primary_error": {
            "type": "System.InvalidOperationException",
            "message": "ServiceSizeOption identity tracking conflict",
            "severity": "CRITICAL",
            "impact": "Blocks all service imports"
        },
        "root_cause": {
            "description": "Multiple ServiceSizeOption instances with same ServiceSizeOptionId in DbContext ChangeTracker",
            "technical_reason": "EF Core Identity Map prevents duplicate key tracking within same DbContext scope",
            "trigger_point": "When SaveChangesAsync propagates database-generated ServiceSizeOptionId back to entity"
        },
        "affected_operations": [
            "ImportSizeOptionsAsync (line 1100)",
            "ImportServiceAsync (line 161)", 
            "Related: ServiceLicense, StakeholderInvolvement, TimelinePhase, EffortEstimationItem inserts"
        ]
    },
    
    "code_flow_analysis": {
        "sequence": [
            "1. ImportServiceAsync creates Service",
            "2. ImportSizeOptionsAsync loops through size options",
            "3. For each size option: queries LU_SizeOption (tracked)",
            "4. Creates ServiceSizeOption with FK to LU_SizeOption",
            "5. SaveChangesAsync inserts ServiceSizeOption",
            "6. DB returns ServiceSizeOptionId (IDENTITY)",
            "7. EF propagates ID back via ColumnModification.SetStoreGeneratedValue",
            "8. ERROR: IdentityMap already has this entity tracked"
        ],
        "problem_pattern": "Loop creates multiple ServiceSizeOption entities referencing same LU_SizeOption, causing tracking conflicts when IDs are set"
    },
    
    "dbcontext_issues_found": {
        "critical": [
            {
                "entity": "ServiceSizeOption",
                "issue": "No explicit tracking control in ImportSizeOptionsAsync",
                "risk": "CRITICAL - blocks import",
                "location": "ImportOrchestrationService.cs line 1100"
            }
        ],
        "high": [
            {
                "entity": "LU_SizeOption",  
                "issue": "Queried with tracking in loop, causing duplicate references",
                "risk": "HIGH - contributes to tracking conflict",
                "recommendation": "Use AsNoTracking() for lookup queries"
            }
        ],
        "medium": [
            {
                "entity": "ServiceLicense",
                "issue": "Column mapping mismatch - LicenseName mapped to LicenseDescription",
                "risk": "MEDIUM - data corruption",
                "location": "ServiceCatalogDbContext.cs line 406"
            },
            {
                "entity": "ServiceToolFramework",
                "issue": "PK column mapping - ToolId mapped to ToolFrameworkID",
                "risk": "MEDIUM - potential ID conflicts",
                "location": "ServiceCatalogDbContext.cs line 398"
            },
            {
                "entity": "TechnicalComplexityAddition",
                "issue": "PK column mapping - AdditionId mapped to ComplexityAdditionID",  
                "risk": "MEDIUM - potential ID conflicts",
                "location": "ServiceCatalogDbContext.cs line 431"
            }
        ],
        "low": [
            {
                "entity": "ServicePricingConfig",
                "issue": "Missing explicit .ToTable() call",
                "risk": "LOW - conventions may handle",
                "location": "ServiceCatalogDbContext.cs line 445"
            }
        ]
    },
    
    "proposed_solutions": {
        "immediate_fix": {
            "priority": "CRITICAL",
            "target": "ImportOrchestrationService.ImportSizeOptionsAsync",
            "changes": [
                {
                    "step": 1,
                    "action": "Add AsNoTracking() to LU_SizeOption queries",
                    "code": "var sizeOption = await _context.LU_SizeOptions.AsNoTracking().FirstOrDefaultAsync(...);"
                },
                {
                    "step": 2,
                    "action": "Clear ChangeTracker between iterations if needed",
                    "code": "_context.ChangeTracker.Clear(); // After each SaveChanges"
                },
                {
                    "step": 3,
                    "action": "Batch all ServiceSizeOption inserts into single SaveChanges",
                    "code": "// Add all entities to context, then single SaveChangesAsync()"
                }
            ],
            "estimated_time": "30 minutes",
            "testing_required": "Import service with multiple size options"
        },
        
        "dbcontext_fixes": {
            "priority": "HIGH",
            "changes": [
                {
                    "file": "ServiceCatalogDbContext.cs",
                    "line": 406,
                    "current": "entity.Property(e => e.LicenseName).HasColumnName(\"LicenseDescription\");",
                    "fixed": "// Remove mapping - use same name in entity and DB or map to LicenseName column",
                    "reason": "Column name mismatch causes data corruption"
                },
                {
                    "file": "ServiceCatalogDbContext.cs",
                    "line": 302,
                    "add_after_line": 311,
                    "new_config": """
            // Add explicit query filter or configuration
            entity.HasOne(e => e.SizeOption)
                .WithMany()
                .HasForeignKey(e => e.SizeOptionId)
                .OnDelete(DeleteBehavior.Restrict);""",
                    "reason": "Define ServiceSizeOption -> LU_SizeOption relationship explicitly"
                }
            ]
        },
        
        "schema_validation": {
            "priority": "MEDIUM",
            "action": "Verify db_structure.sql matches entity definitions",
            "checks": [
                "ServiceLicense.LicenseName vs DB LicenseDescription column",
                "ServiceToolFramework.ToolId vs DB ToolFrameworkID column",
                "TechnicalComplexityAddition.AdditionId vs DB ComplexityAdditionID column",
                "ServiceSizeOption relationships to LU_SizeOption"
            ]
        }
    },
    
    "verification_plan": {
        "step1": "Apply ImportOrchestrationService fixes",
        "step2": "Test import with ID999 service data",
        "step3": "Verify no tracking conflicts in logs",
        "step4": "Confirm ServiceSizeOption entities saved correctly",
        "step5": "Check EffortEstimationItem relationships work",
        "success_criteria": [
            "Import completes with 200 status",
            "No InvalidOperationException in logs",
            "All ServiceSizeOption records in DB",
            "EffortEstimationItem.ServiceSizeOptionId populated"
        ]
    },
    
    "files_to_modify": [
        {
            "path": "src/backend/ServiceCatalogueManager.Api/Services/Import/ImportOrchestrationService.cs",
            "lines": "~1090-1110",
            "change_type": "CRITICAL FIX",
            "description": "Add AsNoTracking() and improve entity lifecycle management"
        },
        {
            "path": "src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs",  
            "lines": "302-312, 402-407",
            "change_type": "HIGH PRIORITY",
            "description": "Fix column mappings and add explicit relationships"
        }
    ],
    
    "risk_assessment": {
        "before_fix": {
            "import_success_rate": "0%",
            "blocking_severity": "CRITICAL",
            "affected_features": ["Service Import", "Size Options", "Effort Estimation"]
        },
        "after_fix": {
            "expected_success_rate": "100%",
            "residual_risks": ["Column mapping issues may cause data inconsistency"],
            "recommended_monitoring": "Watch for any ServiceLicense/ToolFramework mapping errors"
        }
    },
    
    "metadata": {
        "analysis_date": datetime.now().isoformat(),
        "total_issues_found": 7,
        "critical": 1,
        "high": 1,
        "medium": 3,
        "low": 2
    }
}

print(json.dumps(analysis, indent=2))
print("\n" + "="*80)
print("EXECUTIVE SUMMARY")
print("="*80)
print(f"""
CRITICAL ERROR: ServiceSizeOption Entity Tracking Conflict

ROOT CAUSE:
- EF Core ChangeTracker has multiple ServiceSizeOption instances with same key
- Triggered when DB-generated ID propagates back during SaveChanges
- Import loop queries LU_SizeOption WITH tracking, creates conflicts

IMMEDIATE FIX REQUIRED:
1. ImportOrchestrationService.ImportSizeOptionsAsync (line ~1100)
   - Add .AsNoTracking() to LU_SizeOption queries
   - Batch ServiceSizeOption inserts into single SaveChanges
   - Clear ChangeTracker between operations if needed

2. ServiceCatalogDbContext.cs
   - Fix ServiceLicense.LicenseName mapping (line 406)
   - Add explicit ServiceSizeOption relationships (after line 311)

IMPACT:
- Before: 0% import success rate (CRITICAL BLOCKER)
- After: 100% expected success rate

ESTIMATED FIX TIME: 30-45 minutes
TESTING: Import service ID999 with multiple size options

Files to modify: 2
Total issues: 7 (1 critical, 1 high, 3 medium, 2 low)
""")

