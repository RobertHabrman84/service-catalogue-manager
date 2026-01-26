namespace ServiceCatalogueManager.Api.Models.Responses;

/// <summary>
/// API response wrapper
/// </summary>
public record ApiResponse<T>
{
    public bool Success { get; init; }
    public T? Data { get; init; }
    public string? Message { get; init; }
    public ICollection<string> Errors { get; init; } = new List<string>();
    public DateTime Timestamp { get; init; } = DateTime.UtcNow;

    public static ApiResponse<T> Ok(T data, string? message = null) => new()
    {
        Success = true,
        Data = data,
        Message = message
    };

    public static ApiResponse<T> Fail(string error) => new()
    {
        Success = false,
        Errors = new List<string> { error }
    };

    public static ApiResponse<T> Fail(IEnumerable<string> errors) => new()
    {
        Success = false,
        Errors = errors.ToList()
    };
}

/// <summary>
/// Paginated response
/// </summary>
public record PagedResponse<T>
{
    public ICollection<T> Items { get; init; } = new List<T>();
    public int Page { get; init; }
    public int PageSize { get; init; }
    public int TotalCount { get; init; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasPreviousPage => Page > 1;
    public bool HasNextPage => Page < TotalPages;

    public static PagedResponse<T> Create(IEnumerable<T> items, int page, int pageSize, int totalCount) => new()
    {
        Items = items.ToList(),
        Page = page,
        PageSize = pageSize,
        TotalCount = totalCount
    };
}

/// <summary>
/// Bulk operation response
/// </summary>
public record BulkOperationResponse
{
    public bool Success { get; init; }
    public int TotalCount { get; init; }
    public int SuccessCount { get; init; }
    public int FailedCount { get; init; }
    public ICollection<BulkOperationItemResult> Results { get; init; } = new List<BulkOperationItemResult>();
}

/// <summary>
/// Individual bulk operation item result
/// </summary>
public record BulkOperationItemResult
{
    public int Id { get; init; }
    public bool Success { get; init; }
    public string? ErrorMessage { get; init; }
}

/// <summary>
/// Health check response
/// </summary>
public record HealthCheckResponse
{
    public string Status { get; init; } = "Healthy";
    public DateTime Timestamp { get; init; } = DateTime.UtcNow;
    public string Version { get; init; } = string.Empty;
    public string Environment { get; init; } = string.Empty;
    public ICollection<HealthCheckItem> Checks { get; init; } = new List<HealthCheckItem>();
}

/// <summary>
/// Health check item
/// </summary>
public record HealthCheckItem
{
    public string Name { get; init; } = string.Empty;
    public string Status { get; init; } = "Healthy";
    public string? Description { get; init; }
    public TimeSpan? Duration { get; init; }
    public Dictionary<string, object>? Data { get; init; }
}

/// <summary>
/// Validation error response
/// </summary>
public record ValidationErrorResponse
{
    public string Type { get; init; } = "ValidationError";
    public string Title { get; init; } = "Validation Failed";
    public int Status { get; init; } = 400;
    public Dictionary<string, string[]> Errors { get; init; } = new();
}

/// <summary>
/// Error response
/// </summary>
public record ErrorResponse
{
    public string Type { get; init; } = "Error";
    public string Title { get; init; } = string.Empty;
    public int Status { get; init; }
    public string? Detail { get; init; }
    public string? Instance { get; init; }
    public string? TraceId { get; init; }
}
