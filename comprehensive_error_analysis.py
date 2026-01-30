import json

analysis = {
    "error_summary": {
        "primary_error": "Invalid column name 'EstimationEffortEstimationId'",
        "affected_table": "EffortEstimationItem",
        "error_type": "Column name mismatch"
    },
    "root_cause": {
        "issue": "EF Core is generating incorrect column name 'EstimationEffortEstimationId' instead of 'EstimationId'",
        "reason": "DbContext.cs line 318 uses wrong primary key: HasKey(e => e.EstimationId) but entity has EstimationItemId as PK",
        "ef_core_behavior": "When HasKey points to wrong property, EF generates compound/shadow properties"
    },
    "evidence": {
        "entity_definition": {
            "file": "EffortEstimationItem.cs",
            "line": 6,
            "actual_pk": "public int EstimationItemId { get; set; }",
            "note": "This is the real PK property"
        },
        "dbcontext_mapping": {
            "file": "ServiceCatalogDbContext.cs",
            "line": 318,
            "wrong_mapping": "entity.HasKey(e => e.EstimationId);",
            "should_be": "entity.HasKey(e => e.EstimationItemId);"
        },
        "db_structure": {
            "file": "db_structure.sql",
            "line": 552,
            "actual_pk_column": "EstimationItemID INT IDENTITY(1,1) PRIMARY KEY",
            "note": "DB has EstimationItemID as PK"
        }
    },
    "impact": {
        "severity": "CRITICAL",
        "blocks": "Service import completely fails",
        "affects": [
            "ImportSizeOptionsAsync",
            "All EffortEstimationItem CRUD operations"
        ]
    },
    "fix_required": {
        "file": "ServiceCatalogDbContext.cs",
        "line": 318,
        "change_from": "entity.HasKey(e => e.EstimationId);",
        "change_to": "entity.HasKey(e => e.EstimationItemId);",
        "priority": "IMMEDIATE"
    },
    "similar_issues_to_check": [
        "Check all HasKey() mappings in DbContext",
        "Verify PK property names match between Entity, DbContext, and db_structure.sql",
        "Look for other shadow properties being generated"
    ]
}

print(json.dumps(analysis, indent=2))
