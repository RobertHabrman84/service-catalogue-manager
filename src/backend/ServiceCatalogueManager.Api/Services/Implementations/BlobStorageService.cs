using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Blob storage service for Azure Blob Storage operations
/// </summary>
public class BlobStorageService : IBlobStorageService
{
    private readonly BlobServiceClient _blobServiceClient;
    private readonly ILogger<BlobStorageService> _logger;

    public BlobStorageService(
        BlobServiceClient blobServiceClient,
        ILogger<BlobStorageService> logger)
    {
        _blobServiceClient = blobServiceClient ?? throw new ArgumentNullException(nameof(blobServiceClient));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<string> UploadAsync(
        string containerName, 
        string blobName, 
        byte[] content, 
        string contentType, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(containerName);
        ArgumentNullException.ThrowIfNull(blobName);
        ArgumentNullException.ThrowIfNull(content);

        _logger.LogInformation("Uploading blob {BlobName} to container {ContainerName}", blobName, containerName);

        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            
            // Ensure container exists
            await containerClient.CreateIfNotExistsAsync(cancellationToken: cancellationToken);

            var blobClient = containerClient.GetBlobClient(blobName);

            using var stream = new MemoryStream(content);
            
            var uploadOptions = new BlobUploadOptions
            {
                HttpHeaders = new BlobHttpHeaders
                {
                    ContentType = contentType
                }
            };

            await blobClient.UploadAsync(stream, uploadOptions, cancellationToken);

            _logger.LogInformation("Successfully uploaded blob {BlobName} ({Size} bytes)", blobName, content.Length);

            return blobClient.Uri.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload blob {BlobName} to container {ContainerName}", blobName, containerName);
            throw;
        }
    }

    public async Task<byte[]?> DownloadAsync(
        string containerName, 
        string blobName, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(containerName);
        ArgumentNullException.ThrowIfNull(blobName);

        _logger.LogInformation("Downloading blob {BlobName} from container {ContainerName}", blobName, containerName);

        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            if (!await blobClient.ExistsAsync(cancellationToken))
            {
                _logger.LogWarning("Blob {BlobName} not found in container {ContainerName}", blobName, containerName);
                return null;
            }

            using var memoryStream = new MemoryStream();
            await blobClient.DownloadToAsync(memoryStream, cancellationToken);

            _logger.LogInformation("Successfully downloaded blob {BlobName} ({Size} bytes)", blobName, memoryStream.Length);

            return memoryStream.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to download blob {BlobName} from container {ContainerName}", blobName, containerName);
            throw;
        }
    }

    public async Task<bool> DeleteAsync(
        string containerName, 
        string blobName, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(containerName);
        ArgumentNullException.ThrowIfNull(blobName);

        _logger.LogInformation("Deleting blob {BlobName} from container {ContainerName}", blobName, containerName);

        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            var response = await blobClient.DeleteIfExistsAsync(cancellationToken: cancellationToken);

            if (response.Value)
            {
                _logger.LogInformation("Successfully deleted blob {BlobName}", blobName);
            }
            else
            {
                _logger.LogWarning("Blob {BlobName} did not exist", blobName);
            }

            return response.Value;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete blob {BlobName} from container {ContainerName}", blobName, containerName);
            throw;
        }
    }

    public async Task<string> GetSasUrlAsync(
        string containerName, 
        string blobName, 
        TimeSpan validFor, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(containerName);
        ArgumentNullException.ThrowIfNull(blobName);

        _logger.LogInformation("Generating SAS URL for blob {BlobName} in container {ContainerName}", blobName, containerName);

        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            if (!await blobClient.ExistsAsync(cancellationToken))
            {
                throw new FileNotFoundException($"Blob {blobName} not found in container {containerName}");
            }

            // Check if we can generate SAS token (requires account key)
            if (!blobClient.CanGenerateSasUri)
            {
                _logger.LogWarning("Cannot generate SAS URL for blob {BlobName} - using direct URL instead", blobName);
                return blobClient.Uri.ToString();
            }

            var sasBuilder = new BlobSasBuilder
            {
                BlobContainerName = containerName,
                BlobName = blobName,
                Resource = "b", // b = blob
                StartsOn = DateTimeOffset.UtcNow.AddMinutes(-5), // Allow 5 min clock skew
                ExpiresOn = DateTimeOffset.UtcNow.Add(validFor)
            };

            sasBuilder.SetPermissions(BlobSasPermissions.Read);

            var sasUri = blobClient.GenerateSasUri(sasBuilder);

            _logger.LogInformation("Successfully generated SAS URL for blob {BlobName}, valid until {ExpiresOn}", 
                blobName, sasBuilder.ExpiresOn);

            return sasUri.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate SAS URL for blob {BlobName} in container {ContainerName}", 
                blobName, containerName);
            throw;
        }
    }
}
