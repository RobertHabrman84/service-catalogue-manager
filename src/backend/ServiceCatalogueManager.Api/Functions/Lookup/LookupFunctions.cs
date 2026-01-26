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

    /// <summary>
    /// Get tool categories
    /// </summary>
    [Function("GetToolCategories")]
    public async Task<HttpResponseData> GetToolCategories(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/tool-categories")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting tool categories");

        // Return empty list for now - can be implemented later with proper DB table
        var toolCategories = Array.Empty<object>();

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<object>.Ok(toolCategories), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get requirement levels
    /// </summary>
    [Function("GetRequirementLevels")]
    public async Task<HttpResponseData> GetRequirementLevels(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/requirement-levels")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting requirement levels");

        // Return mock data for requirement levels
        var requirementLevels = new[]
        {
            new { Id = 1, Code = "REQUIRED", Name = "Required", Description = "Mandatory requirement" },
            new { Id = 2, Code = "RECOMMENDED", Name = "Recommended", Description = "Recommended but not mandatory" },
            new { Id = 3, Code = "OPTIONAL", Name = "Optional", Description = "Optional requirement" }
        };

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<object>.Ok(requirementLevels), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get services list (simple list for dropdowns)
    /// </summary>
    [Function("GetServicesList")]
    public async Task<HttpResponseData> GetServicesList(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/services-list")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting services list");

        try
        {
            // Try to get from database through service catalog service
            var services = await _lookupService.GetServicesListAsync(cancellationToken);
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(ApiResponse<object>.Ok(services), cancellationToken);
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to get services list from database, returning empty list");
            
            // Return empty list if database is not available
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(ApiResponse<object>.Ok(Array.Empty<object>()), cancellationToken);
            return response;
        }
    }

    /// <summary>
    /// Get license types
    /// </summary>
    [Function("GetLicenseTypes")]
    public async Task<HttpResponseData> GetLicenseTypes(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "lookups/license-types")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting license types");

        // Return mock data for license types
        var licenseTypes = new[]
        {
            new { Id = 1, Code = "MIT", Name = "MIT License", IsOpenSource = true },
            new { Id = 2, Code = "APACHE", Name = "Apache License 2.0", IsOpenSource = true },
            new { Id = 3, Code = "GPL", Name = "GNU General Public License", IsOpenSource = true },
            new { Id = 4, Code = "PROPRIETARY", Name = "Proprietary License", IsOpenSource = false },
            new { Id = 5, Code = "BSD", Name = "BSD License", IsOpenSource = true },
            new { Id = 6, Code = "COMMERCIAL", Name = "Commercial License", IsOpenSource = false }
        };

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<object>.Ok(licenseTypes), cancellationToken);
        return response;
    }
}
