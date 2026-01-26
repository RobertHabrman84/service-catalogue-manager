namespace ServiceCatalogueManager.Api.Services.Import;

using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Data.Entities;

/// <summary>
/// Service for orchestrating import operations
/// v3.3.0: Basic implementation with current model structure
/// </summary>
public class ImportOrchestrationService : IImportOrchestrationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IImportValidationService _validationService;

    public ImportOrchestrationService(
        IUnitOfWork unitOfWork,
        IImportValidationService validationService)
    {
        _unitOfWork = unitOfWork;
        _validationService = validationService;
    }

    public async Task<ImportResult> ImportServiceAsync(ImportServiceModel model)
    {
        try
        {
            // Validate first
            var validationResult = await _validationService.ValidateImportAsync(model);
            if (!validationResult.IsValid)
            {
                return ImportResult.Failed(validationResult.Errors);
            }

            // Check for duplicates
            var existing = await _unitOfWork.ServiceCatalogs.GetByCodeAsync(model.ServiceCode);
            if (existing != null)
            {
                return ImportResult.Failed($"Service with code {model.ServiceCode} already exists");
            }

            // Create basic service (v3.3.0: simplified, only core fields)
            var service = new ServiceCatalogItem
            {
                ServiceCode = model.ServiceCode,
                ServiceName = model.ServiceName,
                Version = model.Version ?? "v1.0",
                Description = model.Description ?? string.Empty,
                Notes = model.Notes,
                IsActive = true,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            // Try to find category by name (simplified - just search all)
            if (!string.IsNullOrWhiteSpace(model.Category))
            {
                // For v3.3.0: We'll skip category assignment if it's complex
                // User can add it manually after import
            }

            // Save to database
            var added = await _unitOfWork.ServiceCatalogs.AddAsync(service);
            await _unitOfWork.SaveChangesAsync();

            return ImportResult.Success(added.ServiceId, model.ServiceCode);
        }
        catch (Exception ex)
        {
            return ImportResult.Failed($"Import failed: {ex.Message}");
        }
    }
    
    public async Task<BulkImportResult> ImportServicesAsync(List<ImportServiceModel> models)
    {
        var result = new BulkImportResult
        {
            TotalCount = models.Count,
            Results = new List<ImportResult>()
        };

        foreach (var model in models)
        {
            var importResult = await ImportServiceAsync(model);
            result.Results.Add(importResult);

            if (importResult.IsSuccess)
                result.SuccessCount++;
            else
                result.FailureCount++;
        }

        return result;
    }

    public async Task<ValidationResult> ValidateImportAsync(ImportServiceModel model)
    {
        return await _validationService.ValidateImportAsync(model);
    }
}
