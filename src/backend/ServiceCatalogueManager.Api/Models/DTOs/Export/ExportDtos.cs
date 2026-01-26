namespace ServiceCatalogueManager.Api.Models.DTOs.Export;

/// <summary>
/// Export request
/// </summary>
public record ExportRequestDto
{
    public int[]? ServiceIds { get; init; }
    public ExportFormat Format { get; init; } = ExportFormat.Pdf;
    public ExportOptions Options { get; init; } = new();
}

/// <summary>
/// Export format enum
/// </summary>
public enum ExportFormat
{
    Pdf,
    Markdown,
    UuBookKit
}

/// <summary>
/// Export options
/// </summary>
public record ExportOptions
{
    public bool IncludeUsageScenarios { get; init; } = true;
    public bool IncludeDependencies { get; init; } = true;
    public bool IncludeScope { get; init; } = true;
    public bool IncludePrerequisites { get; init; } = true;
    public bool IncludeInputsOutputs { get; init; } = true;
    public bool IncludeTimeline { get; init; } = true;
    public bool IncludeSizing { get; init; } = true;
    public bool IncludeEffort { get; init; } = true;
    public bool IncludeTeam { get; init; } = true;
    public bool IncludeMultiCloud { get; init; } = true;
    public bool IncludeExamples { get; init; } = true;
    public bool IncludeInteraction { get; init; } = true;
    public bool IncludeNotes { get; init; } = true;
    public bool IncludeTableOfContents { get; init; } = true;
    public bool IncludePageNumbers { get; init; } = true;
    public string? CustomHeader { get; init; }
    public string? CustomFooter { get; init; }
}

/// <summary>
/// Export result
/// </summary>
public record ExportResultDto
{
    public string FileName { get; init; } = string.Empty;
    public string ContentType { get; init; } = string.Empty;
    public byte[] Content { get; init; } = Array.Empty<byte>();
    public long FileSizeBytes { get; init; }
    public DateTime GeneratedAt { get; init; } = DateTime.UtcNow;
    public int ServiceCount { get; init; }
    public ExportFormat Format { get; init; }
}

/// <summary>
/// Export history item
/// </summary>
public record ExportHistoryItemDto
{
    public int ExportId { get; init; }
    public string FileName { get; init; } = string.Empty;
    public ExportFormat Format { get; init; }
    public int ServiceCount { get; init; }
    public long FileSizeBytes { get; init; }
    public DateTime GeneratedAt { get; init; }
    public string GeneratedBy { get; init; } = string.Empty;
    public string? BlobUrl { get; init; }
    public DateTime? ExpiresAt { get; init; }
}

/// <summary>
/// Saved export reference
/// </summary>
public record SavedExportDto
{
    public string ExportId { get; init; } = string.Empty;
    public string DownloadUrl { get; init; } = string.Empty;
    public DateTime ExpiresAt { get; init; }
}
