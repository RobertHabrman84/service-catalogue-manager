using ServiceCatalogueManager.Api.Models.Import;

namespace ServiceCatalogueManager.Api.Services.Import;

/// <summary>
/// Service for orchestrating the import of service catalog items
/// </summary>
public interface IImportOrchestrationService
{
    /// <summary>
    /// Imports a single service from JSON model
    /// </summary>
    Task<ImportResult> ImportServiceAsync(ImportServiceModel model);

    /// <summary>
    /// Imports multiple services from JSON models
    /// </summary>
    Task<BulkImportResult> ImportServicesAsync(List<ImportServiceModel> models);

    /// <summary>
    /// Validates import without persisting (dry-run)
    /// </summary>
    Task<ValidationResult> ValidateImportAsync(ImportServiceModel model);
}
