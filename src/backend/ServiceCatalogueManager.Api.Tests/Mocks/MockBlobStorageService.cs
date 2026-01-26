// =============================================================================
// SERVICE CATALOGUE MANAGER - MOCK BLOB STORAGE SERVICE
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Mocks;

public class MockBlobStorageService : IBlobStorageService
{
    private readonly Dictionary<string, byte[]> _storage = new();
    private readonly List<ExportHistoryDto> _history = new();

    public Task<string> UploadAsync(byte[] content, string fileName, string? contentType = null, CancellationToken cancellationToken = default)
    {
        var blobName = $"{Guid.NewGuid()}/{fileName}";
        _storage[blobName] = content;

        _history.Add(new ExportHistoryDto
        {
            Id = _history.Count + 1,
            FileName = fileName,
            BlobUrl = $"https://mock.blob.core.windows.net/exports/{blobName}",
            ContentType = contentType ?? "application/octet-stream",
            FileSizeBytes = content.Length,
            CreatedAt = DateTime.UtcNow
        });

        return Task.FromResult($"https://mock.blob.core.windows.net/exports/{blobName}");
    }

    public Task<byte[]?> DownloadAsync(string blobName, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_storage.TryGetValue(blobName, out var content) ? content : null);
    }

    public Task<bool> DeleteAsync(string blobName, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_storage.Remove(blobName));
    }

    public Task<bool> ExistsAsync(string blobName, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_storage.ContainsKey(blobName));
    }

    public Task<IEnumerable<ExportHistoryDto>> GetExportHistoryAsync(int limit = 20, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_history.OrderByDescending(h => h.CreatedAt).Take(limit).AsEnumerable());
    }

    public Task<string> GetSasUrlAsync(string blobName, TimeSpan validFor, CancellationToken cancellationToken = default)
    {
        var sasToken = $"?sv=2021-06-08&st={DateTime.UtcNow:o}&se={DateTime.UtcNow.Add(validFor):o}&sr=b&sp=r&sig=mock";
        return Task.FromResult($"https://mock.blob.core.windows.net/exports/{blobName}{sasToken}");
    }

    public void Reset()
    {
        _storage.Clear();
        _history.Clear();
    }
}
