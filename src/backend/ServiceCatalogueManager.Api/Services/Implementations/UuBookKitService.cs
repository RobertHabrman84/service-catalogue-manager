using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using ServiceCatalogueManager.Api.Configuration;
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
    private readonly ILogger<UuBookKitService> _logger;

    public UuBookKitService(
        IHttpClientFactory httpClientFactory,
        IOptions<UuBookKitOptions> options,
        IMarkdownGeneratorService markdownGenerator,
        ILogger<UuBookKitService> logger)
    {
        _httpClientFactory = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
        _options = options?.Value ?? throw new ArgumentNullException(nameof(options));
        _markdownGenerator = markdownGenerator ?? throw new ArgumentNullException(nameof(markdownGenerator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<UuBookKitPublishResultDto> PublishServiceAsync(
        UuBookKitPublishRequestDto request, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);
        ArgumentNullException.ThrowIfNull(request.Service);

        _logger.LogInformation("Publishing service {ServiceCode} to UuBookKit", request.Service.ServiceCode);

        try
        {
            // Generate markdown content
            var markdown = await _markdownGenerator.GenerateServiceMarkdownAsync(request.Service, cancellationToken);

            var httpClient = _httpClientFactory.CreateClient("UuBookKit");

            var publishRequest = new
            {
                title = request.Service.ServiceName,
                content = markdown,
                code = request.Service.ServiceCode,
                category = request.Service.CategoryName,
                tags = new[] { request.Service.CategoryName, "service-catalog" }
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
                    ErrorMessage = $"UuBookKit API error: {response.StatusCode}"
                };
            }

            var result = await response.Content.ReadFromJsonAsync<UuBookKitPublishResponse>(cancellationToken);

            _logger.LogInformation("Successfully published service {ServiceCode} to UuBookKit, PageId: {PageId}", 
                request.Service.ServiceCode, result?.PageId);

            return new UuBookKitPublishResultDto
            {
                Success = true,
                PageId = result?.PageId ?? string.Empty,
                PageUrl = result?.PageUrl ?? string.Empty,
                PublishedDate = DateTime.UtcNow
            };
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error publishing service {ServiceCode} to UuBookKit", 
                request.Service.ServiceCode);

            return new UuBookKitPublishResultDto
            {
                Success = false,
                ErrorMessage = $"Connection error: {ex.Message}"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error publishing service {ServiceCode} to UuBookKit", 
                request.Service.ServiceCode);

            return new UuBookKitPublishResultDto
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    public async Task<UuBookKitSyncResultDto> SyncServicesAsync(
        UuBookKitSyncRequestDto request, 
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        _logger.LogInformation("Syncing {Count} services to UuBookKit", request.ServiceIds?.Count ?? 0);

        var result = new UuBookKitSyncResultDto
        {
            TotalServices = request.ServiceIds?.Count ?? 0,
            SuccessCount = 0,
            FailedCount = 0,
            Results = new List<UuBookKitPublishResultDto>()
        };

        if (request.ServiceIds == null || !request.ServiceIds.Any())
        {
            _logger.LogWarning("No services to sync");
            return result;
        }

        foreach (var serviceId in request.ServiceIds)
        {
            try
            {
                // Note: In real implementation, you would fetch service details from repository
                // For now, this is a placeholder
                _logger.LogInformation("Would sync service ID: {ServiceId}", serviceId);
                
                result.SuccessCount++;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to sync service ID: {ServiceId}", serviceId);
                result.FailedCount++;
            }
        }

        return result;
    }

    public async Task<UuBookKitStatusDto> GetStatusAsync(CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Checking UuBookKit status");

        try
        {
            var httpClient = _httpClientFactory.CreateClient("UuBookKit");
            var response = await httpClient.GetAsync("/api/status", cancellationToken);

            var isConnected = response.IsSuccessStatusCode;

            _logger.LogInformation("UuBookKit status: {Status}", isConnected ? "Connected" : "Disconnected");

            return new UuBookKitStatusDto
            {
                IsConnected = isConnected,
                ApiUrl = _options.ApiUrl,
                LastChecked = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking UuBookKit status");

            return new UuBookKitStatusDto
            {
                IsConnected = false,
                ApiUrl = _options.ApiUrl,
                LastChecked = DateTime.UtcNow,
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
        public string PageId { get; set; } = string.Empty;
        public string PageUrl { get; set; } = string.Empty;
    }
}
