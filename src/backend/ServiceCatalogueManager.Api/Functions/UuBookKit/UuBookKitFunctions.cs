using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Models.DTOs.UuBookKit;
using ServiceCatalogueManager.Api.Models.Responses;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Functions.UuBookKit;

/// <summary>
/// Azure Functions for UuBookKit integration
/// </summary>
public class UuBookKitFunctions
{
    private readonly IUuBookKitService _uuBookKitService;
    private readonly ILogger<UuBookKitFunctions> _logger;

    public UuBookKitFunctions(
        IUuBookKitService uuBookKitService,
        ILogger<UuBookKitFunctions> logger)
    {
        _uuBookKitService = uuBookKitService;
        _logger = logger;
    }

    /// <summary>
    /// Publish service to UuBookKit
    /// </summary>
    [Function("PublishToUuBookKit")]
    public async Task<HttpResponseData> PublishToUuBookKit(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "services/{id:int}/publish")] HttpRequestData req,
        int id,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Publishing service {ServiceId} to UuBookKit", id);

        var publishRequest = await req.ReadFromJsonAsync<UuBookKitPublishRequestDto>(cancellationToken);
        if (publishRequest == null)
        {
            var errorResponse = req.CreateResponse(HttpStatusCode.BadRequest);
            await errorResponse.WriteAsJsonAsync(
                ApiResponse<string>.Fail("Invalid request body"),
                cancellationToken);
            return errorResponse;
        }
        publishRequest = publishRequest with { ServiceId = id };

        var result = await _uuBookKitService.PublishServiceAsync(publishRequest, cancellationToken);

        var statusCode = result.Success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        var response = req.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(ApiResponse<UuBookKitPublishResultDto>.Ok(result), cancellationToken);
        return response;
    }

    /// <summary>
    /// Sync multiple services to UuBookKit
    /// </summary>
    [Function("SyncToUuBookKit")]
    public async Task<HttpResponseData> SyncToUuBookKit(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "uubookkit/sync")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Syncing services to UuBookKit");

        var syncRequest = await req.ReadFromJsonAsync<UuBookKitSyncRequestDto>(cancellationToken);
        var result = await _uuBookKitService.SyncServicesAsync(syncRequest!, cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<UuBookKitSyncResultDto>.Ok(result), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get UuBookKit connection status
    /// </summary>
    [Function("GetUuBookKitStatus")]
    public async Task<HttpResponseData> GetUuBookKitStatus(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "uubookkit/status")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting UuBookKit status");

        var status = await _uuBookKitService.GetStatusAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<UuBookKitStatusDto>.Ok(status), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get published page URL for a service
    /// </summary>
    [Function("GetServicePageUrl")]
    public async Task<HttpResponseData> GetServicePageUrl(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/{id:int}/uubookkit")] HttpRequestData req,
        int id,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting UuBookKit page URL for service {ServiceId}", id);

        var pageInfo = await _uuBookKitService.GetServicePageInfoAsync(id, cancellationToken);

        if (pageInfo == null)
        {
            var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
            await notFoundResponse.WriteAsJsonAsync(
                ApiResponse<UuBookKitPublishResultDto>.Fail($"Service {id} not published to UuBookKit"),
                cancellationToken);
            return notFoundResponse;
        }

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<UuBookKitPublishResultDto>.Ok(pageInfo), cancellationToken);
        return response;
    }

    /// <summary>
    /// Unpublish service from UuBookKit
    /// </summary>
    [Function("UnpublishFromUuBookKit")]
    public async Task<HttpResponseData> UnpublishFromUuBookKit(
        [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "services/{id:int}/publish")] HttpRequestData req,
        int id,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Unpublishing service {ServiceId} from UuBookKit", id);

        var success = await _uuBookKitService.UnpublishServiceAsync(id, cancellationToken);

        if (!success)
        {
            var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
            await notFoundResponse.WriteAsJsonAsync(
                ApiResponse<bool>.Fail($"Service {id} not found or not published"),
                cancellationToken);
            return notFoundResponse;
        }

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<bool>.Ok(true, "Service unpublished successfully"), cancellationToken);
        return response;
    }
}
