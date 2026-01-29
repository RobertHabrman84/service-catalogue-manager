using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Services.Calculator;
using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ServiceCatalogueManager.Api.Functions.Calculator;

/// <summary>
/// Azure Functions for calculator and service map endpoints
/// </summary>
public class CalculatorFunctions
{
    private readonly ILogger<CalculatorFunctions> _logger;
    private readonly ICalculatorService _calculatorService;
    private readonly JsonSerializerOptions _jsonOptions;

    public CalculatorFunctions(
        ILogger<CalculatorFunctions> logger,
        ICalculatorService calculatorService)
    {
        _logger = logger;
        _calculatorService = calculatorService;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            WriteIndented = false
        };
    }

    /// <summary>
    /// Get calculator configuration for a specific service
    /// GET /api/services/{serviceId}/calculator-config
    /// </summary>
    [Function("GetCalculatorConfig")]
    public async Task<HttpResponseData> GetCalculatorConfig(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/{serviceId:int}/calculator-config")] 
        HttpRequestData req,
        int serviceId)
    {
        _logger.LogInformation("Getting calculator config for service {ServiceId}", serviceId);

        try
        {
            var config = await _calculatorService.GetCalculatorConfigAsync(serviceId);

            if (config == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteAsJsonAsync(new { error = $"Service with ID {serviceId} not found" });
                return notFoundResponse;
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");
            await response.WriteStringAsync(JsonSerializer.Serialize(config, _jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting calculator config for service {ServiceId}", serviceId);
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new { error = "An error occurred while retrieving calculator configuration" });
            return errorResponse;
        }
    }

    /// <summary>
    /// Get calculator configuration by service code
    /// GET /api/services/code/{serviceCode}/calculator-config
    /// </summary>
    [Function("GetCalculatorConfigByCode")]
    public async Task<HttpResponseData> GetCalculatorConfigByCode(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/code/{serviceCode}/calculator-config")] 
        HttpRequestData req,
        string serviceCode)
    {
        _logger.LogInformation("Getting calculator config for service code {ServiceCode}", serviceCode);

        try
        {
            // We need to get service ID from code first - this would be better with a direct lookup
            // For now, we'll handle this at the service level
            var response = req.CreateResponse(HttpStatusCode.NotImplemented);
            await response.WriteAsJsonAsync(new { error = "Use /api/services/{serviceId}/calculator-config endpoint" });
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting calculator config for service code {ServiceCode}", serviceCode);
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new { error = "An error occurred" });
            return errorResponse;
        }
    }

    /// <summary>
    /// Get service map showing all services and their dependencies
    /// GET /api/service-map
    /// </summary>
    [Function("GetServiceMap")]
    public async Task<HttpResponseData> GetServiceMap(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "service-map")] 
        HttpRequestData req)
    {
        _logger.LogInformation("Getting service map");

        try
        {
            var serviceMap = await _calculatorService.GetServiceMapAsync();

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");
            await response.WriteStringAsync(JsonSerializer.Serialize(serviceMap, _jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service map");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new { error = "An error occurred while retrieving service map" });
            return errorResponse;
        }
    }
}
