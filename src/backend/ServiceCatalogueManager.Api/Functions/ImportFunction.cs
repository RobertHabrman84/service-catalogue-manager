using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Services.Import;
using System.Text.Json;

namespace ServiceCatalogueManager.Api.Functions;

/// <summary>
/// Azure Function for importing services into the catalog
/// </summary>
public class ImportFunction
{
    private readonly IImportOrchestrationService _importService;
    private readonly ILogger<ImportFunction> _logger;

    public ImportFunction(
        IImportOrchestrationService importService,
        ILogger<ImportFunction> logger)
    {
        _importService = importService;
        _logger = logger;
    }

    /// <summary>
    /// Import a single service
    /// POST /api/services/import
    /// </summary>
    [Function("ImportService")]
    public async Task<HttpResponseData> ImportService(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "services/import")] 
        HttpRequestData req)
    {
        _logger.LogInformation("Import service endpoint called");

        try
        {
            // Parse request body
            var model = await JsonSerializer.DeserializeAsync<ImportServiceModel>(
                req.Body,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (model == null)
            {
                _logger.LogWarning("Invalid request body - could not deserialize");
                return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                    "Invalid request body");
            }

            // Import service
            var result = await _importService.ImportServiceAsync(model);

            // Return response
            if (result.IsSuccess)
            {
                _logger.LogInformation("Service imported successfully: {ServiceCode}", result.ServiceCode);
                return await CreateSuccessResponse(req, result);
            }
            else
            {
                _logger.LogWarning("Service import failed: {ServiceCode}", model.ServiceCode);
                return await CreateValidationErrorResponse(req, result);
            }
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON deserialization error");
            return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                "Invalid JSON format");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error importing service");
            return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                "An unexpected error occurred");
        }
    }

    /// <summary>
    /// Import multiple services in bulk
    /// POST /api/services/import/bulk
    /// </summary>
    [Function("ImportServicesBulk")]
    public async Task<HttpResponseData> ImportServicesBulk(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "services/import/bulk")] 
        HttpRequestData req)
    {
        _logger.LogInformation("Bulk import endpoint called");

        try
        {
            // Parse request body
            var models = await JsonSerializer.DeserializeAsync<List<ImportServiceModel>>(
                req.Body,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (models == null || !models.Any())
            {
                _logger.LogWarning("Invalid request body - empty or null list");
                return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                    "Request body must contain at least one service");
            }

            _logger.LogInformation("Bulk importing {Count} services", models.Count);

            // Import services
            var result = await _importService.ImportServicesAsync(models);

            // Return response
            _logger.LogInformation("Bulk import completed: {Success} succeeded, {Failed} failed",
                result.SuccessCount, result.FailCount);

            return await CreateBulkImportResponse(req, result);
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON deserialization error");
            return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                "Invalid JSON format");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error in bulk import");
            return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                "An unexpected error occurred");
        }
    }

    /// <summary>
    /// Validate service import without actually importing (dry-run)
    /// POST /api/services/import/validate
    /// </summary>
    [Function("ValidateImport")]
    public async Task<HttpResponseData> ValidateImport(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "services/import/validate")] 
        HttpRequestData req)
    {
        _logger.LogInformation("Validate import endpoint called");

        try
        {
            // Parse request body
            var model = await JsonSerializer.DeserializeAsync<ImportServiceModel>(
                req.Body,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (model == null)
            {
                _logger.LogWarning("Invalid request body - could not deserialize");
                return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                    "Invalid request body");
            }

            // Validate only (dry-run)
            var result = await _importService.ValidateImportAsync(model);

            // Return response
            if (result.IsValid)
            {
                _logger.LogInformation("Validation passed for service: {ServiceCode}", model.ServiceCode);
                
                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(new
                {
                    isValid = true,
                    message = "Validation passed - service is ready to import",
                    serviceCode = model.ServiceCode
                });
                return response;
            }
            else
            {
                _logger.LogWarning("Validation failed for service: {ServiceCode}", model.ServiceCode);
                
                var response = req.CreateResponse(HttpStatusCode.BadRequest);
                await response.WriteAsJsonAsync(new
                {
                    isValid = false,
                    message = "Validation failed",
                    errors = result.Errors.Select(e => new
                    {
                        field = e.Field,
                        message = e.Message,
                        code = e.Code
                    })
                });
                return response;
            }
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON deserialization error");
            return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                "Invalid JSON format");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error validating service");
            return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                "An unexpected error occurred");
        }
    }

    /// <summary>
    /// Health check endpoint
    /// GET /api/services/import/health
    /// </summary>
    [Function("ImportHealthCheck")]
    public async Task<HttpResponseData> HealthCheck(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/import/health")] 
        HttpRequestData req)
    {
        _logger.LogInformation("Health check endpoint called");

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(new
        {
            status = "healthy",
            service = "Service Catalogue Import API",
            timestamp = DateTime.UtcNow
        });

        return response;
    }

    #region Private Helper Methods

    private async Task<HttpResponseData> CreateSuccessResponse(
        HttpRequestData req, 
        ImportResult result)
    {
        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(new
        {
            success = true,
            message = "Service imported successfully",
            serviceId = result.ServiceId,
            serviceCode = result.ServiceCode
        });
        return response;
    }

    private async Task<HttpResponseData> CreateValidationErrorResponse(
        HttpRequestData req,
        ImportResult result)
    {
        var response = req.CreateResponse(HttpStatusCode.BadRequest);
        await response.WriteAsJsonAsync(new
        {
            success = false,
            message = "Service import failed validation",
            errors = result.Errors.Select(e => new
            {
                field = e.Field,
                message = e.Message,
                code = e.Code
            })
        });
        return response;
    }

    private async Task<HttpResponseData> CreateBulkImportResponse(
        HttpRequestData req,
        BulkImportResult result)
    {
        var statusCode = result.FailCount == 0 
            ? HttpStatusCode.OK 
            : (result.SuccessCount > 0 ? HttpStatusCode.MultiStatus : HttpStatusCode.BadRequest);

        var response = req.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(new
        {
            totalCount = result.TotalCount,
            successCount = result.SuccessCount,
            failCount = result.FailCount,
            results = result.Results.Select(r => new
            {
                success = r.IsSuccess,
                serviceId = r.ServiceId,
                serviceCode = r.ServiceCode,
                errors = r.Errors?.Select(e => new
                {
                    field = e.Field,
                    message = e.Message,
                    code = e.Code
                })
            })
        });
        return response;
    }

    private async Task<HttpResponseData> CreateErrorResponse(
        HttpRequestData req,
        HttpStatusCode statusCode,
        string message)
    {
        var response = req.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(new
        {
            success = false,
            message = message
        });
        return response;
    }

    #endregion
}
