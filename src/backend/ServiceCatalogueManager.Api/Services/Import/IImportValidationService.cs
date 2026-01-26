using ServiceCatalogueManager.Api.Models.Import;

namespace ServiceCatalogueManager.Api.Services.Import;

/// <summary>
/// Service for validating import data before persisting to database
/// </summary>
public interface IImportValidationService
{
    /// <summary>
    /// Validates the complete import model
    /// </summary>
    Task<Models.Import.ValidationResult> ValidateImportAsync(ImportServiceModel model);

    /// <summary>
    /// Validates business rules
    /// </summary>
    Task<List<ValidationError>> ValidateBusinessRulesAsync(ImportServiceModel model);

    /// <summary>
    /// Validates that all lookup references can be resolved
    /// </summary>
    Task<List<ValidationError>> ValidateLookupsAsync(ImportServiceModel model);

    /// <summary>
    /// Checks for duplicate service codes
    /// </summary>
    Task<List<ValidationError>> ValidateDuplicatesAsync(ImportServiceModel model);

    /// <summary>
    /// Validates cross-references within the model
    /// </summary>
    Task<List<ValidationError>> ValidateReferencesAsync(ImportServiceModel model);
}
