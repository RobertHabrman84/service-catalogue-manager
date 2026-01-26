using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Models.DTOs.Lookup;
using ServiceCatalogueManager.Api.Models.Responses;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Functions.Lookup;

/// <summary>
/// Azure Functions for Lookup data
/// </summary>
public class LookupFunctions
{
    private readonly ILookupService _lookupService;
    private readonly ILogger<LookupFunctions> _logger;

    public LookupFunctions(
        ILookupService lookupService,
        ILogger<LookupFunctions> logger)
    {
        _lookupService = lookupService;
        _logger = logger;
    }

    /// <summary>
    /// Get all lookup data
    /// </summary>
    [Function("GetAllLookups")]
    public async Task<HttpResponseData> GetAllLookups(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting all lookup data");

        var lookups = await _lookupService.GetAllLookupsAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<AllLookupsDto>.Ok(lookups), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get categories
    /// </summary>
    [Function("GetCategories")]
    public async Task<HttpResponseData> GetCategories(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/categories")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting categories");

        var categories = await _lookupService.GetCategoriesAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<ServiceCategoryDto>>.Ok(categories), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get size options
    /// </summary>
    [Function("GetSizeOptions")]
    public async Task<HttpResponseData> GetSizeOptions(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/size-options")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting size options");

        var sizeOptions = await _lookupService.GetSizeOptionsAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<SizeOptionDto>>.Ok(sizeOptions), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get cloud providers
    /// </summary>
    [Function("GetCloudProviders")]
    public async Task<HttpResponseData> GetCloudProviders(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/cloud-providers")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting cloud providers");

        var providers = await _lookupService.GetCloudProvidersAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<CloudProviderDto>>.Ok(providers), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get dependency types
    /// </summary>
    [Function("GetDependencyTypes")]
    public async Task<HttpResponseData> GetDependencyTypes(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/dependency-types")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting dependency types");

        var types = await _lookupService.GetDependencyTypesAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<DependencyTypeDto>>.Ok(types), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get roles
    /// </summary>
    [Function("GetRoles")]
    public async Task<HttpResponseData> GetRoles(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/roles")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting roles");

        var roles = await _lookupService.GetRolesAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<RoleDto>>.Ok(roles), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get effort categories
    /// </summary>
    [Function("GetEffortCategories")]
    public async Task<HttpResponseData> GetEffortCategories(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/effort-categories")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting effort categories");

        var categories = await _lookupService.GetEffortCategoriesAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<EffortCategoryDto>>.Ok(categories), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get prerequisite categories
    /// </summary>
    [Function("GetPrerequisiteCategories")]
    public async Task<HttpResponseData> GetPrerequisiteCategories(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/prerequisite-categories")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting prerequisite categories");

        var categories = await _lookupService.GetPrerequisiteCategoriesAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<PrerequisiteCategoryDto>>.Ok(categories), cancellationToken);
        return response;
    }
}
