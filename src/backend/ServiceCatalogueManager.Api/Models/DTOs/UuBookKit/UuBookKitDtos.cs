namespace ServiceCatalogueManager.Api.Models.DTOs.UuBookKit;

/// <summary>
/// UuBookKit publish request
/// </summary>
public record UuBookKitPublishRequestDto
{
    public int ServiceId { get; init; }
    public bool ForceUpdate { get; init; }
    public string? TargetBookUri { get; init; }
    public string? TargetPageCode { get; init; }
}

/// <summary>
/// UuBookKit publish result
/// </summary>
public record UuBookKitPublishResultDto
{
    public bool Success { get; init; }
    public string? PageCode { get; init; }
    public string? PageUri { get; init; }
    public string? PageUrl { get; init; }
    public DateTime? PublishedAt { get; init; }
    public string? ErrorMessage { get; init; }
    public string? ErrorCode { get; init; }
}

/// <summary>
/// UuBookKit sync request
/// </summary>
public record UuBookKitSyncRequestDto
{
    public int[]? ServiceIds { get; init; }
    public bool ForceUpdate { get; init; }
    public string? TargetBookUri { get; init; }
}

/// <summary>
/// UuBookKit sync result
/// </summary>
public record UuBookKitSyncResultDto
{
    public bool Success { get; init; }
    public int TotalServices { get; init; }
    public int SuccessCount { get; init; }
    public int FailedCount { get; init; }
    public int SkippedCount { get; init; }
    public DateTime StartedAt { get; init; }
    public DateTime? CompletedAt { get; init; }
    public ICollection<UuBookKitSyncItemResultDto> Results { get; init; } = new List<UuBookKitSyncItemResultDto>();
}

/// <summary>
/// Individual sync item result
/// </summary>
public record UuBookKitSyncItemResultDto
{
    public int ServiceId { get; init; }
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public SyncStatus Status { get; init; }
    public string? PageCode { get; init; }
    public string? PageUrl { get; init; }
    public string? ErrorMessage { get; init; }
}

/// <summary>
/// Sync status enum
/// </summary>
public enum SyncStatus
{
    Pending,
    InProgress,
    Success,
    Failed,
    Skipped
}

/// <summary>
/// UuBookKit connection status
/// </summary>
public record UuBookKitStatusDto
{
    public bool IsConnected { get; init; }
    public string? BookUri { get; init; }
    public string? BookName { get; init; }
    public DateTime? LastSyncAt { get; init; }
    public int SyncedServicesCount { get; init; }
    public string? ErrorMessage { get; init; }
}

/// <summary>
/// UuBookKit page content
/// </summary>
public record UuBookKitPageContentDto
{
    public string PageCode { get; init; } = string.Empty;
    public string Content { get; init; } = string.Empty;
    public string ContentType { get; init; } = "uu5string";
    public Dictionary<string, object>? Metadata { get; init; }
}

/// <summary>
/// Uu5String builder helper
/// </summary>
public static class Uu5StringBuilder
{
    public static string Header(string text, int level = 1) => 
        $"<uu5string/><UU5.Bricks.Header level=\"{level}\">{text}</UU5.Bricks.Header>";

    public static string Paragraph(string text) => 
        $"<UU5.Bricks.P>{text}</UU5.Bricks.P>";

    public static string List(IEnumerable<string> items) =>
        $"<UU5.Bricks.Ul>{string.Join("", items.Select(i => $"<UU5.Bricks.Li>{i}</UU5.Bricks.Li>"))}</UU5.Bricks.Ul>";

    public static string Table(string[] headers, IEnumerable<string[]> rows)
    {
        var headerRow = $"<UU5.Bricks.Table.Tr>{string.Join("", headers.Select(h => $"<UU5.Bricks.Table.Th>{h}</UU5.Bricks.Table.Th>"))}</UU5.Bricks.Table.Tr>";
        var bodyRows = string.Join("", rows.Select(r => 
            $"<UU5.Bricks.Table.Tr>{string.Join("", r.Select(c => $"<UU5.Bricks.Table.Td>{c}</UU5.Bricks.Table.Td>"))}</UU5.Bricks.Table.Tr>"));
        
        return $"<UU5.Bricks.Table><UU5.Bricks.Table.THead>{headerRow}</UU5.Bricks.Table.THead><UU5.Bricks.Table.TBody>{bodyRows}</UU5.Bricks.Table.TBody></UU5.Bricks.Table>";
    }

    public static string Section(string title, string content) =>
        $"<UU5.Bricks.Section header=\"{title}\">{content}</UU5.Bricks.Section>";

    public static string Badge(string text, string colorSchema = "blue") =>
        $"<UU5.Bricks.Badge colorSchema=\"{colorSchema}\">{text}</UU5.Bricks.Badge>";
}
