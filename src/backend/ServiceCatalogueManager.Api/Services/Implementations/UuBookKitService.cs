using System.Net.Http.Json;
using AutoMapper;
using Microsoft.Extensions.Options;
using ServiceCatalogueManager.Api.Configuration;
using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Models.DTOs.UuBookKit;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Service for integrating with UuBookKit platform
/// </summary>
public class UuBookKitService : IUuBookKitService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly UuBookKitOptions _options;
    private readonly IMarkdownGeneratorService _markdownGenerator;
    private readonly IServiceCatalogRepository _repository;
    private readonly IMapper _mapper;
    private readonly ILogger<UuBookKitService> _logger;

    public UuBookKitService(
        IHttpClientFactory httpClientFactory,
        IOptions<UuBookKitOptions> options,
        IMarkdownGeneratorService markdownGenerator,
        IServiceCatalogRepository repository,
        IMapper mapper,
        ILogger<UuBookKitService> logger)
    {
        _httpClientFactory = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
        _options = options?.Value ?? throw new ArgumentNullException(nameof(options));
        _markdownGenerator = markdownGenerator ?? throw new ArgumentNullException(nameof(markdownGenerator));
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<UuBookKitPublishResultDto> PublishServiceAsync(
        UuBookKitPublishRequestDto request, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        _logger.LogInformation("Publishing service ID {ServiceId} to UuBookKit", request.ServiceId);

        try
        {
            // Fetch service details from repository
            var service = await _repository.GetByIdAsync(request.ServiceId, cancellationToken);
            if (service == null)
            {
                _logger.LogWarning("Service ID {ServiceId} not found", request.ServiceId);
                return new UuBookKitPublishResultDto
                {
                    Success = false,
                    ErrorMessage = $"Service ID {request.ServiceId} not found",
                    ErrorCode = "SERVICE_NOT_FOUND"
                };
            }

            // Map entity to DTO
            var serviceDto = _mapper.Map<ServiceCatalogFullDto>(service);

            // Generate markdown content
            var markdown = await _markdownGenerator.GenerateServiceMarkdownAsync(serviceDto, cancellationToken);

            var httpClient = _httpClientFactory.CreateClient("UuBookKit");

            var publishRequest = new
            {
                title = serviceDto.ServiceName,
                content = markdown,
                code = serviceDto.ServiceCode,
                category = serviceDto.CategoryName,
                tags = new[] { serviceDto.CategoryName ?? "Uncategorized", "service-catalog" },
                targetBookUri = request.TargetBookUri,
                targetPageCode = request.TargetPageCode,
                forceUpdate = request.ForceUpdate
            };

            var response = await httpClient.PostAsJsonAsync("/api/pages/publish", publishRequest, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogError("Failed to publish to UuBookKit: {StatusCode} - {Error}", 
                    response.StatusCode, error);

                return new UuBookKitPublishResultDto
                {
                    Success = false,
                    ErrorMessage = $"UuBookKit API error: {response.StatusCode}",
                    ErrorCode = response.StatusCode.ToString()
                };
            }

            var result = await response.Content.ReadFromJsonAsync<UuBookKitPublishResponse>(cancellationToken);

            _logger.LogInformation("Successfully published service {ServiceCode} to UuBookKit, PageCode: {PageCode}", 
                service.ServiceCode, result?.PageCode);

            return new UuBookKitPublishResultDto
            {
                Success = true,
                PageCode = result?.PageCode ?? string.Empty,
                PageUri = result?.PageUri ?? string.Empty,
                PageUrl = result?.PageUrl ?? string.Empty,
                PublishedAt = DateTime.UtcNow
            };
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error publishing service ID {ServiceId} to UuBookKit", request.ServiceId);

            return new UuBookKitPublishResultDto
            {
                Success = false,
                ErrorMessage = $"Connection error: {ex.Message}",
                ErrorCode = "HTTP_ERROR"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error publishing service ID {ServiceId} to UuBookKit", request.ServiceId);

            return new UuBookKitPublishResultDto
            {
                Success = false,
                ErrorMessage = ex.Message,
                ErrorCode = "UNEXPECTED_ERROR"
            };
        }
    }

    public async Task<UuBookKitSyncResultDto> SyncServicesAsync(
        UuBookKitSyncRequestDto request, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        _logger.LogInformation("Syncing {Count} services to UuBookKit", request.ServiceIds?.Length ?? 0);

        var startedAt = DateTime.UtcNow;
        var results = new List<UuBookKitSyncItemResultDto>();

        if (request.ServiceIds == null || request.ServiceIds.Length == 0)
        {
            _logger.LogWarning("No services to sync");
            return new UuBookKitSyncResultDto
            {
                Success = true,
                TotalServices = 0,
                SuccessCount = 0,
                FailedCount = 0,
                SkippedCount = 0,
                StartedAt = startedAt,
                CompletedAt = DateTime.UtcNow,
                Results = results
            };
        }

        foreach (var serviceId in request.ServiceIds)
        {
            try
            {
                // Fetch service details
                var service = await _repository.GetByIdAsync(serviceId, cancellationToken);
                if (service == null)
                {
                    _logger.LogWarning("Service ID {ServiceId} not found, skipping", serviceId);
                    results.Add(new UuBookKitSyncItemResultDto
                    {
                        ServiceId = serviceId,
                        ServiceCode = $"SVC-{serviceId}",
                        ServiceName = "Unknown",
                        Status = SyncStatus.Skipped,
                        ErrorMessage = "Service not found"
                    });
                    continue;
                }

                // Publish service
                var publishRequest = new UuBookKitPublishRequestDto
                {
                    ServiceId = serviceId,
                    ForceUpdate = request.ForceUpdate,
                    TargetBookUri = request.TargetBookUri
                };

                var publishResult = await PublishServiceAsync(publishRequest, cancellationToken);

                results.Add(new UuBookKitSyncItemResultDto
                {
                    ServiceId = serviceId,
                    ServiceCode = service.ServiceCode ?? $"SVC-{serviceId}",
                    ServiceName = service.ServiceName ?? "Unnamed Service",
                    Status = publishResult.Success ? SyncStatus.Success : SyncStatus.Failed,
                    PageCode = publishResult.PageCode,
                    PageUrl = publishResult.PageUrl,
                    ErrorMessage = publishResult.ErrorMessage
                });

                _logger.LogInformation("Synced service ID {ServiceId}: {Status}", 
                    serviceId, publishResult.Success ? "Success" : "Failed");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to sync service ID: {ServiceId}", serviceId);
                results.Add(new UuBookKitSyncItemResultDto
                {
                    ServiceId = serviceId,
                    ServiceCode = $"SVC-{serviceId}",
                    ServiceName = "Unknown",
                    Status = SyncStatus.Failed,
                    ErrorMessage = ex.Message
                });
            }
        }

        var successCount = results.Count(r => r.Status == SyncStatus.Success);
        var failedCount = results.Count(r => r.Status == SyncStatus.Failed);
        var skippedCount = results.Count(r => r.Status == SyncStatus.Skipped);

        return new UuBookKitSyncResultDto
        {
            Success = failedCount == 0,
            TotalServices = request.ServiceIds.Length,
            SuccessCount = successCount,
            FailedCount = failedCount,
            SkippedCount = skippedCount,
            StartedAt = startedAt,
            CompletedAt = DateTime.UtcNow,
            Results = results
        };
    }

    public async Task<UuBookKitStatusDto> GetStatusAsync(CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Checking UuBookKit status");

        try
        {
            var httpClient = _httpClientFactory.CreateClient("UuBookKit");
            var response = await httpClient.GetAsync("/api/status", cancellationToken);

            var isConnected = response.IsSuccessStatusCode;

            // Try to get book info
            string? bookUri = null;
            string? bookName = null;
            if (isConnected)
            {
                try
                {
                    var bookInfo = await response.Content.ReadFromJsonAsync<UuBookKitBookInfo>(cancellationToken);
                    bookUri = bookInfo?.BookUri;
                    bookName = bookInfo?.BookName;
                }
                catch
                {
                    // Ignore JSON parsing errors
                }
            }

            _logger.LogInformation("UuBookKit status: {Status}", isConnected ? "Connected" : "Disconnected");

            return new UuBookKitStatusDto
            {
                IsConnected = isConnected,
                BookUri = bookUri,
                BookName = bookName,
                LastSyncAt = DateTime.UtcNow,
                SyncedServicesCount = 0 // TODO: Implement synced services count tracking
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking UuBookKit status");

            return new UuBookKitStatusDto
            {
                IsConnected = false,
                LastSyncAt = DateTime.UtcNow,
                ErrorMessage = ex.Message
            };
        }
    }

    public async Task<UuBookKitPublishResultDto?> GetServicePageInfoAsync(
        int serviceId, 
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Getting UuBookKit page info for service ID: {ServiceId}", serviceId);

        try
        {
            var httpClient = _httpClientFactory.CreateClient("UuBookKit");
            var response = await httpClient.GetAsync($"/api/pages/service/{serviceId}", cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            var result = await response.Content.ReadFromJsonAsync<UuBookKitPublishResultDto>(cancellationToken);
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting UuBookKit page info for service ID: {ServiceId}", serviceId);
            return null;
        }
    }

    public async Task<bool> UnpublishServiceAsync(int serviceId, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Unpublishing service ID: {ServiceId} from UuBookKit", serviceId);

        try
        {
            var httpClient = _httpClientFactory.CreateClient("UuBookKit");
            var response = await httpClient.DeleteAsync($"/api/pages/service/{serviceId}", cancellationToken);

            var success = response.IsSuccessStatusCode;

            if (success)
            {
                _logger.LogInformation("Successfully unpublished service ID: {ServiceId}", serviceId);
            }
            else
            {
                _logger.LogWarning("Failed to unpublish service ID: {ServiceId}, Status: {StatusCode}", 
                    serviceId, response.StatusCode);
            }

            return success;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error unpublishing service ID: {ServiceId}", serviceId);
            return false;
        }
    }

    private class UuBookKitPublishResponse
    {
        public string PageCode { get; set; } = string.Empty;
        public string PageUri { get; set; } = string.Empty;
        public string PageUrl { get; set; } = string.Empty;
    }

    private class UuBookKitBookInfo
    {
        public string BookUri { get; set; } = string.Empty;
        public string BookName { get; set; } = string.Empty;
    }
}
