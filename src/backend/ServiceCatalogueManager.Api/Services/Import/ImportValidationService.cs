namespace ServiceCatalogueManager.Api.Services.Import;

using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Data.Repositories;
using System.Text.RegularExpressions;

/// <summary>
/// Service for validating import models
/// v3.3.0: Basic validation with current model structure
/// </summary>
public class ImportValidationService : IImportValidationService
{
    private readonly IUnitOfWork _unitOfWork;

    public ImportValidationService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ValidationResult> ValidateImportAsync(ImportServiceModel model)
    {
        var errors = new List<ValidationError>();

        // Basic required field validation
        errors.AddRange(ValidateRequiredFields(model));
        
        // Business rules validation
        errors.AddRange(await ValidateBusinessRulesAsync(model));
        
        // Duplicates check
        errors.AddRange(await ValidateDuplicatesAsync(model));

        return errors.Count == 0 
            ? ValidationResult.Valid() 
            : ValidationResult.Invalid(errors);
    }

    public Task<List<ValidationError>> ValidateBusinessRulesAsync(ImportServiceModel model)
    {
        var errors = new List<ValidationError>();

        // Service code format (ID001, ID002, etc.)
        if (!Regex.IsMatch(model.ServiceCode, @"^ID\d{3}$"))
        {
            errors.Add(new ValidationError(
                nameof(model.ServiceCode),
                "Service code must match pattern ID0XX (e.g., ID001)",
                "INVALID_FORMAT"
            ));
        }

        // Service name length
        if (model.ServiceName.Length < 1 || model.ServiceName.Length > 200)
        {
            errors.Add(new ValidationError(
                nameof(model.ServiceName),
                "Service name must be between 1 and 200 characters",
                "INVALID_LENGTH"
            ));
        }

        return Task.FromResult(errors);
    }

    public Task<List<ValidationError>> ValidateLookupsAsync(ImportServiceModel model)
    {
        // v3.3.0: Simplified - skip lookup validation for now
        return Task.FromResult(new List<ValidationError>());
    }

    public async Task<List<ValidationError>> ValidateDuplicatesAsync(ImportServiceModel model)
    {
        var errors = new List<ValidationError>();

        // Check for duplicate service code
        var existing = await _unitOfWork.ServiceCatalogs.GetByCodeAsync(model.ServiceCode);
        if (existing != null)
        {
            errors.Add(new ValidationError(
                nameof(model.ServiceCode),
                $"Service with code '{model.ServiceCode}' already exists (ID: {existing.ServiceId})",
                "DUPLICATE_CODE"
            ));
        }

        return errors;
    }

    public Task<List<ValidationError>> ValidateReferencesAsync(ImportServiceModel model)
    {
        // v3.3.0: Simplified - no complex reference validation yet
        return Task.FromResult(new List<ValidationError>());
    }

    private List<ValidationError> ValidateRequiredFields(ImportServiceModel model)
    {
        var errors = new List<ValidationError>();

        if (string.IsNullOrWhiteSpace(model.ServiceCode))
        {
            errors.Add(new ValidationError(
                nameof(model.ServiceCode),
                "Service code is required",
                "REQUIRED_FIELD"
            ));
        }

        if (string.IsNullOrWhiteSpace(model.ServiceName))
        {
            errors.Add(new ValidationError(
                nameof(model.ServiceName),
                "Service name is required",
                "REQUIRED_FIELD"
            ));
        }

        if (string.IsNullOrWhiteSpace(model.Description))
        {
            errors.Add(new ValidationError(
                nameof(model.Description),
                "Description is required",
                "REQUIRED_FIELD"
            ));
        }

        return errors;
    }
}
