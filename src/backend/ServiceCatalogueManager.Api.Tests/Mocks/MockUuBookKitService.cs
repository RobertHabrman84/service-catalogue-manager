// =============================================================================
// SERVICE CATALOGUE MANAGER - MOCK UUBOOKKIT SERVICE
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Mocks;

public class MockUuBookKitService : IUuBookKitService
{
    private readonly Dictionary<string, PublishStatus> _pages = new();
    private readonly List<SyncResult> _syncHistory = new();

    public Task<PublishResult> PublishPageAsync(ServiceCatalogDetailDto service, string pageId, CancellationToken cancellationToken = default)
    {
        _pages[pageId] = new PublishStatus { PageId = pageId, Status = "PUBLISHED", LastPublished = DateTime.UtcNow };
        return Task.FromResult(new PublishResult { Success = true, PageId = pageId, Message = "Page published successfully" });
    }

    public Task<string> CreatePageAsync(ServiceCatalogDetailDto service, CancellationToken cancellationToken = default)
    {
        var pageId = $"page-{Guid.NewGuid():N}";
        _pages[pageId] = new PublishStatus { PageId = pageId, Status = "DRAFT", CreatedAt = DateTime.UtcNow };
        return Task.FromResult(pageId);
    }

    public Task<PublishResult> UpdatePageAsync(ServiceCatalogDetailDto service, string pageId, CancellationToken cancellationToken = default)
    {
        if (!_pages.ContainsKey(pageId))
            throw new NotFoundException($"Page {pageId} not found");

        _pages[pageId].Status = "UPDATED";
        _pages[pageId].LastModified = DateTime.UtcNow;
        return Task.FromResult(new PublishResult { Success = true, PageId = pageId, Message = "Page updated" });
    }

    public Task<PublishStatus> GetPublishStatusAsync(string pageId, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_pages.TryGetValue(pageId, out var status)
            ? status
            : new PublishStatus { PageId = pageId, Status = "NOT_FOUND" });
    }

    public Task<SyncResult> SyncCatalogAsync(IEnumerable<ServiceCatalogDetailDto> services, CancellationToken cancellationToken = default)
    {
        var serviceList = services.ToList();
        var result = new SyncResult
        {
            SyncedCount = serviceList.Count,
            FailedCount = 0,
            StartedAt = DateTime.UtcNow,
            CompletedAt = DateTime.UtcNow.AddSeconds(serviceList.Count)
        };
        _syncHistory.Add(result);
        return Task.FromResult(result);
    }

    public Task<SyncStatus> GetSyncStatusAsync(CancellationToken cancellationToken = default)
    {
        var last = _syncHistory.LastOrDefault();
        return Task.FromResult(new SyncStatus
        {
            IsRunning = false,
            LastSyncAt = last?.CompletedAt,
            LastSyncedCount = last?.SyncedCount ?? 0
        });
    }

    public Task<string> GenerateUu5ContentAsync(ServiceCatalogDetailDto service, CancellationToken cancellationToken = default)
    {
        return Task.FromResult($"<uu5string/><UU5.Bricks.Section header=\"{service.ServiceName}\"><UU5.Bricks.P>{service.ShortDescription}</UU5.Bricks.P></UU5.Bricks.Section>");
    }

    public void Reset()
    {
        _pages.Clear();
        _syncHistory.Clear();
    }
}

public class PublishResult
{
    public bool Success { get; set; }
    public string PageId { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}

public class PublishStatus
{
    public string PageId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime? CreatedAt { get; set; }
    public DateTime? LastModified { get; set; }
    public DateTime? LastPublished { get; set; }
}

public class SyncResult
{
    public int SyncedCount { get; set; }
    public int FailedCount { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime CompletedAt { get; set; }
}

public class SyncStatus
{
    public bool IsRunning { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public int LastSyncedCount { get; set; }
}
