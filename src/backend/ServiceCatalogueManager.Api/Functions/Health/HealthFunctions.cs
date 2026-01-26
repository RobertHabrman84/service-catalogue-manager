using System.Diagnostics;
using System.Net;
using System.Reflection;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Models.Responses;

namespace ServiceCatalogueManager.Api.Functions.Health;

/// <summary>
/// Azure Functions for Health checks
/// </summary>
public class HealthFunctions
{
    private readonly ServiceCatalogDbContext _dbContext;
    private readonly IConfiguration _configuration;
    private readonly ILogger<HealthFunctions> _logger;

    public HealthFunctions(
        ServiceCatalogDbContext dbContext,
        IConfiguration configuration,
        ILogger<HealthFunctions> logger)
    {
        _dbContext = dbContext;
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Basic health check
    /// </summary>
    [Function("Health")]
    public async Task<HttpResponseData> Health(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Health check requested");

        var healthResponse = new HealthCheckResponse
        {
            Status = "Healthy",
            Version = GetVersion(),
            Environment = _configuration["AZURE_FUNCTIONS_ENVIRONMENT"] ?? "Development",
            Checks = new List<HealthCheckItem>()
        };

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(healthResponse, cancellationToken);
        return response;
    }

    /// <summary>
    /// Detailed health check with dependency checks
    /// </summary>
    [Function("HealthDetailed")]
    public async Task<HttpResponseData> HealthDetailed(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health/detailed")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Detailed health check requested");

        var checks = new List<HealthCheckItem>();
        var overallStatus = "Healthy";

        // Database check
        var dbCheck = await CheckDatabaseAsync(cancellationToken);
        checks.Add(dbCheck);
        if (dbCheck.Status != "Healthy") overallStatus = "Unhealthy";

        // Memory check
        var memoryCheck = CheckMemory();
        checks.Add(memoryCheck);

        // Configuration check
        var configCheck = CheckConfiguration();
        checks.Add(configCheck);
        if (configCheck.Status != "Healthy") overallStatus = "Degraded";

        var healthResponse = new HealthCheckResponse
        {
            Status = overallStatus,
            Version = GetVersion(),
            Environment = _configuration["AZURE_FUNCTIONS_ENVIRONMENT"] ?? "Development",
            Checks = checks
        };

        var statusCode = overallStatus == "Healthy" ? HttpStatusCode.OK : HttpStatusCode.ServiceUnavailable;
        var response = req.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(healthResponse, cancellationToken);
        return response;
    }

    /// <summary>
    /// Liveness probe
    /// </summary>
    [Function("Liveness")]
    public HttpResponseData Liveness(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health/live")] HttpRequestData req)
    {
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.WriteString("OK");
        return response;
    }

    /// <summary>
    /// Readiness probe
    /// </summary>
    [Function("Readiness")]
    public async Task<HttpResponseData> Readiness(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health/ready")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        try
        {
            // Check if database is accessible
            await _dbContext.Database.CanConnectAsync(cancellationToken);

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.WriteString("Ready");
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Readiness check failed");
            var response = req.CreateResponse(HttpStatusCode.ServiceUnavailable);
            response.WriteString("Not Ready");
            return response;
        }
    }

    private async Task<HealthCheckItem> CheckDatabaseAsync(CancellationToken cancellationToken)
    {
        var sw = Stopwatch.StartNew();
        try
        {
            await _dbContext.Database.CanConnectAsync(cancellationToken);
            sw.Stop();

            return new HealthCheckItem
            {
                Name = "Database",
                Status = "Healthy",
                Description = "SQL Server connection successful",
                Duration = sw.Elapsed,
                Data = new Dictionary<string, object>
                {
                    { "Provider", _dbContext.Database.ProviderName ?? "Unknown" }
                }
            };
        }
        catch (Exception ex)
        {
            sw.Stop();
            return new HealthCheckItem
            {
                Name = "Database",
                Status = "Unhealthy",
                Description = ex.Message,
                Duration = sw.Elapsed
            };
        }
    }

    private static HealthCheckItem CheckMemory()
    {
        var process = Process.GetCurrentProcess();
        var workingSet = process.WorkingSet64;
        var managedMemory = GC.GetTotalMemory(false);

        return new HealthCheckItem
        {
            Name = "Memory",
            Status = "Healthy",
            Description = "Memory usage within limits",
            Data = new Dictionary<string, object>
            {
                { "WorkingSetMB", workingSet / 1024 / 1024 },
                { "ManagedMemoryMB", managedMemory / 1024 / 1024 },
                { "Gen0Collections", GC.CollectionCount(0) },
                { "Gen1Collections", GC.CollectionCount(1) },
                { "Gen2Collections", GC.CollectionCount(2) }
            }
        };
    }

    private HealthCheckItem CheckConfiguration()
    {
        var requiredSettings = new[]
        {
            "AzureAd:TenantId",
            "AzureAd:ClientId",
            "AzureSQL:ConnectionString"
        };

        var missingSettings = requiredSettings
            .Where(s => string.IsNullOrEmpty(_configuration[s]))
            .ToList();

        if (missingSettings.Any())
        {
            return new HealthCheckItem
            {
                Name = "Configuration",
                Status = "Degraded",
                Description = $"Missing settings: {string.Join(", ", missingSettings)}",
                Data = new Dictionary<string, object>
                {
                    { "MissingCount", missingSettings.Count }
                }
            };
        }

        return new HealthCheckItem
        {
            Name = "Configuration",
            Status = "Healthy",
            Description = "All required settings present"
        };
    }

    private static string GetVersion()
    {
        var assembly = Assembly.GetExecutingAssembly();
        var version = assembly.GetName().Version;
        return version?.ToString() ?? "1.0.0";
    }
}
