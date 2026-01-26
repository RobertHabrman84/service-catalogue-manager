using Microsoft.Extensions.DependencyInjection;
using ServiceCatalogueManager.Api.Services.Import;

namespace ServiceCatalogueManager.Api.Extensions;

/// <summary>
/// Extension methods for registering import services
/// </summary>
public static class ImportServiceExtensions
{
    /// <summary>
    /// Registers all import-related services
    /// </summary>
    public static IServiceCollection AddImportServices(this IServiceCollection services)
    {
        // Lookup Resolution Service
        services.AddScoped<ILookupResolverService, LookupResolverService>();

        // Import Validation Service
        services.AddScoped<IImportValidationService, ImportValidationService>();

        // Import Orchestration Service
        services.AddScoped<IImportOrchestrationService, ImportOrchestrationService>();

        return services;
    }
}
