namespace ServiceCatalogueManager.Api.Models.Import;

/// <summary>
/// Result of an import operation
/// </summary>
public class ImportResult
{
    public bool IsSuccess { get; set; }
    public int? ServiceId { get; set; }
    public string? ServiceCode { get; set; }
    public List<ValidationError> Errors { get; set; } = new();
    public string? Message { get; set; }

    public static ImportResult Success(int serviceId, string serviceCode)
    {
        return new ImportResult
        {
            IsSuccess = true,
            ServiceId = serviceId,
            ServiceCode = serviceCode,
            Message = $"Service {serviceCode} imported successfully with ID {serviceId}"
        };
    }

    public static ImportResult Failed(IEnumerable<ValidationError> errors)
    {
        return new ImportResult
        {
            IsSuccess = false,
            Errors = errors.ToList(),
            Message = "Import failed due to validation errors"
        };
    }

    public static ImportResult Failed(string errorMessage)
    {
        return new ImportResult
        {
            IsSuccess = false,
            Errors = new List<ValidationError>
            {
                new ValidationError("Import", errorMessage)
            },
            Message = "Import failed"
        };
    }
}

/// <summary>
/// Validation error details
/// </summary>
public class ValidationError
{
    public string Field { get; set; }
    public string Message { get; set; }
    public string? Code { get; set; }

    public ValidationError(string field, string message, string? code = null)
    {
        Field = field;
        Message = message;
        Code = code;
    }
}

/// <summary>
/// Result of validation only (without import)
/// </summary>
public class ValidationResult
{
    public bool IsValid { get; set; }
    public List<ValidationError> Errors { get; set; } = new();

    public static ValidationResult Valid()
    {
        return new ValidationResult { IsValid = true };
    }

    public static ValidationResult Invalid(IEnumerable<ValidationError> errors)
    {
        return new ValidationResult
        {
            IsValid = false,
            Errors = errors.ToList()
        };
    }
}

/// <summary>
/// Bulk import result
/// </summary>
public class BulkImportResult
{
    public int TotalCount { get; set; }
    public int SuccessCount { get; set; }
    public int FailureCount { get; set; }
    public int FailCount => FailureCount; // Alias for backwards compatibility
    public List<ImportResult> Results { get; set; } = new();
}
