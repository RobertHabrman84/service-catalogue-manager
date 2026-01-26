namespace ServiceCatalogueManager.Api.Models.Requests;

/// <summary>
/// Paginated request base
/// </summary>
public record PaginatedRequest
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 20;
    public string? SortBy { get; init; }
    public bool SortDescending { get; init; }
}

/// <summary>
/// Get services request with filters
/// </summary>
public record GetServicesRequest : PaginatedRequest
{
    public string? SearchTerm { get; init; }
    public int? CategoryId { get; init; }
    public bool? IsActive { get; init; }
    public DateTime? CreatedAfter { get; init; }
    public DateTime? CreatedBefore { get; init; }
    public string? CreatedBy { get; init; }
}

/// <summary>
/// Create service request
/// </summary>
public record CreateServiceRequest
{
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public string Version { get; init; } = "v1.0";
    public int CategoryId { get; init; }
    public string Description { get; init; } = string.Empty;
    public string? Notes { get; init; }
    public bool IsActive { get; init; } = true;
}

/// <summary>
/// Update service request
/// </summary>
public record UpdateServiceRequest
{
    public string? ServiceCode { get; init; }
    public string? ServiceName { get; init; }
    public string? Version { get; init; }
    public int? CategoryId { get; init; }
    public string? Description { get; init; }
    public string? Notes { get; init; }
    public bool? IsActive { get; init; }
}

/// <summary>
/// Bulk operation request
/// </summary>
public record BulkOperationRequest
{
    public int[] ServiceIds { get; init; } = Array.Empty<int>();
}

/// <summary>
/// Bulk delete request
/// </summary>
public record BulkDeleteRequest : BulkOperationRequest
{
    public bool HardDelete { get; init; }
}

/// <summary>
/// Bulk activate/deactivate request
/// </summary>
public record BulkActivationRequest : BulkOperationRequest
{
    public bool Activate { get; init; }
}

/// <summary>
/// Clone service request
/// </summary>
public record CloneServiceRequest
{
    public int SourceServiceId { get; init; }
    public string NewServiceCode { get; init; } = string.Empty;
    public string NewServiceName { get; init; } = string.Empty;
    public bool CloneUsageScenarios { get; init; } = true;
    public bool CloneDependencies { get; init; } = true;
    public bool CloneScope { get; init; } = true;
    public bool ClonePrerequisites { get; init; } = true;
    public bool CloneAll { get; init; } = true;
}
