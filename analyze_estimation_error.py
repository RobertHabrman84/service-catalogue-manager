import json
import re

# Analyze the error
error_analysis = {
    "primary_error": {
        "message": "Invalid column name 'EstimationEffortEstimationId'",
        "table": "EffortEstimationItem",
        "operation": "MERGE/INSERT",
        "error_code": "207 (Invalid column name)"
    },
    "context": {
        "location": "ImportOrchestrationService.ImportSizeOptionsAsync",
        "line": 1100,
        "service": "ID999"
    },
    "ef_core_attempting_to_use": [
        "EstimationEffortEstimationId"
    ],
    "needs_investigation": [
        "EffortEstimationItem entity definition",
        "EffortEstimationItem DbContext mapping",
        "EffortEstimationItem in db_structure.sql"
    ]
}

print("=" * 80)
print("CRITICAL ERROR ANALYSIS: EstimationEffortEstimationId")
print("=" * 80)
print(json.dumps(error_analysis, indent=2))
print("\nSearching for related code...")

