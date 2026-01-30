namespace ServiceCatalogueManager.Api.Services.Import;

using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Services.Interfaces;
using Microsoft.Extensions.Logging;
using System.Text;

/// <summary>
/// Service for orchestrating import operations - FIXED VERSION
/// All property mappings corrected to match actual entities
/// </summary>
public class ImportOrchestrationService : IImportOrchestrationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IImportValidationService _validationService;
    private readonly CategoryHelper _categoryHelper;
    private readonly ToolsHelper _toolsHelper;
    private readonly ICacheService _cacheService;
    private readonly ILogger<ImportOrchestrationService> _logger;
    
    // Session cache for lookup entities to avoid duplicate key violations
    private readonly Dictionary<string, LU_RequirementLevel> _requirementLevelCache = new();
    private readonly Dictionary<string, LU_DependencyType> _dependencyTypeCache = new();
    private readonly Dictionary<string, LU_ScopeType> _scopeTypeCache = new();
    private readonly Dictionary<string, LU_InteractionLevel> _interactionLevelCache = new();
    private readonly Dictionary<string, LU_PrerequisiteCategory> _prerequisiteCategoryCache = new();
    private readonly Dictionary<string, LU_LicenseType> _licenseTypeCache = new();
    private readonly Dictionary<string, LU_SizeOption> _sizeOptionCache = new();


    public ImportOrchestrationService(
        IUnitOfWork unitOfWork,
        IImportValidationService validationService,
        CategoryHelper categoryHelper,
        ToolsHelper toolsHelper,
        ICacheService cacheService,
        ILogger<ImportOrchestrationService> logger)
    {
        _unitOfWork = unitOfWork;
        _validationService = validationService;
        _categoryHelper = categoryHelper;
        _toolsHelper = toolsHelper;
        _cacheService = cacheService;
        _logger = logger;
    }

    public async Task<BulkImportResult> ImportServicesAsync(List<ImportServiceModel> models)
    {
        var results = new List<ImportResult>();
        var successCount = 0;
        var failureCount = 0;

        foreach (var model in models)
        {
            try
            {
                var result = await ImportServiceAsync(model);
                results.Add(result);
                
                if (result.IsSuccess)
                    successCount++;
                else
                    failureCount++;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error importing service {ServiceCode}", model.ServiceCode);
                results.Add(ImportResult.Failed($"Exception: {ex.Message}"));
                failureCount++;
            }
        }

        return new BulkImportResult
        {
            TotalCount = models.Count,
            SuccessCount = successCount,
            FailureCount = failureCount,
            Results = results
        };
    }

    public async Task<ValidationResult> ValidateImportAsync(ImportServiceModel model)
    {
        return await _validationService.ValidateImportAsync(model);
    }

    public async Task<ImportResult> ImportServiceAsync(ImportServiceModel model)
    {
        try
        {
            _logger.LogInformation("Starting import for service: {ServiceCode}", model.ServiceCode);

            // Validate first
            var validationResult = await _validationService.ValidateImportAsync(model);
            if (!validationResult.IsValid)
            {
                _logger.LogWarning("Validation failed for service: {ServiceCode}", model.ServiceCode);
                return ImportResult.Failed(validationResult.Errors);
            }

            // Check for duplicates
            var existing = await _unitOfWork.ServiceCatalogs.GetByCodeAsync(model.ServiceCode);
            if (existing != null)
            {
                _logger.LogWarning("Service already exists: {ServiceCode}", model.ServiceCode);
                return ImportResult.Failed(new[]
                {
                    new ValidationError("ServiceCode", $"Service with code {model.ServiceCode} already exists")
                });
            }

            // Execute import within transaction
            await _unitOfWork.BeginTransactionAsync();

            // Clear session cache for this import
            _requirementLevelCache.Clear();
            _dependencyTypeCache.Clear();
            _scopeTypeCache.Clear();
            _interactionLevelCache.Clear();
            _prerequisiteCategoryCache.Clear();
            _licenseTypeCache.Clear();
            _sizeOptionCache.Clear();

            try
            {
                    // Find or create category
                    var categoryId = await _categoryHelper.FindOrCreateCategoryAsync(model.Category);

                    // Create main service record
                    var service = new ServiceCatalogItem
                    {
                        ServiceCode = model.ServiceCode,
                        ServiceName = model.ServiceName,
                        Version = model.Version ?? "v1.0",
                        CategoryId = categoryId,
                        Description = model.Description,
                        Notes = model.Notes,
                        IsActive = true,
                        CreatedDate = DateTime.UtcNow,
                        ModifiedDate = DateTime.UtcNow
                    };

                    service = await _unitOfWork.ServiceCatalogs.AddAsync(service);
                    await _unitOfWork.SaveChangesAsync();

                    _logger.LogInformation("Created service with ID: {ServiceId}", service.ServiceId);

                    // Import all related data
                    await ImportUsageScenariosAsync(service.ServiceId, model.UsageScenarios);
                    await ImportServiceInputsAsync(service.ServiceId, model.ServiceInputs);
                    await ImportServiceOutputsAsync(service.ServiceId, model.ServiceOutputs);
                    await ImportPrerequisitesAsync(service.ServiceId, model.Prerequisites);
                    await _toolsHelper.ImportToolsAsync(service.ServiceId, model.ToolsAndEnvironment);
                    await ImportDependenciesAsync(service.ServiceId, model.Dependencies);
                    await ImportScopeAsync(service.ServiceId, model.Scope);
                    await ImportLicensesAsync(service.ServiceId, model.Licenses);
                    await ImportStakeholderInteractionAsync(service.ServiceId, model.StakeholderInteraction);
                    await ImportTimelineAsync(service.ServiceId, model.Timeline);
                    await ImportSizeOptionsAsync(service.ServiceId, model.SizeOptions);
                    await ImportResponsibleRolesAsync(service.ServiceId, model.ResponsibleRoles);
                    await ImportMultiCloudConsiderationsAsync(service.ServiceId, model.MultiCloudConsiderations);

                    await _unitOfWork.SaveChangesAsync();
                    await _unitOfWork.CommitTransactionAsync();

                    // Clear session cache after successful commit
                    _requirementLevelCache.Clear();
                    _dependencyTypeCache.Clear();
                    _scopeTypeCache.Clear();
                    _interactionLevelCache.Clear();
                    _prerequisiteCategoryCache.Clear();
                    _licenseTypeCache.Clear();
                    _sizeOptionCache.Clear();

                    // Invalidate cache after successful import
                    await _cacheService.RemoveByPrefixAsync("service_");
                    _logger.LogInformation("Cache invalidated after import");

                    _logger.LogInformation("Successfully imported service: {ServiceCode}", model.ServiceCode);

                    return ImportResult.Success(service.ServiceId, model.ServiceCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during import, rolling back transaction");
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to import service: {ServiceCode}", model.ServiceCode);
            return ImportResult.Failed(new[]
            {
                new ValidationError("General", $"Import failed: {ex.Message}", "IMPORT_ERROR")
            });
        }
    }


    private async Task<LU_RequirementLevel?> FindOrCreateRequirementLevelAsync(string levelName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = levelName.ToUpper().Replace(" ", "_");
        if (_requirementLevelCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found requirement level in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var levels = await _unitOfWork.RequirementLevels.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var level = levels.FirstOrDefault(l => 
            l.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (level == null)
        {
            _logger.LogInformation("Creating requirement level: {LevelName} with Code: {Code}", levelName, cacheKey);
            try
            {
                level = new LU_RequirementLevel
                {
                    Code = cacheKey,
                    Name = levelName,
                    Description = $"Auto-created: {levelName}",
                    SortOrder = 1
                };
                level = await _unitOfWork.RequirementLevels.AddAsync(level);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for requirement level {Code}, reloading from database", cacheKey);
                levels = await _unitOfWork.RequirementLevels.GetAllAsync();
                level = levels.FirstOrDefault(l => l.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (level == null) throw;
            }
        }
        
        // Store in session cache
        _requirementLevelCache[cacheKey] = level;
        
        return level;
    }

    private async Task<LU_DependencyType?> FindOrCreateDependencyTypeAsync(string typeName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = typeName.ToUpper().Replace(" ", "_");
        if (_dependencyTypeCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found dependency type in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var types = await _unitOfWork.DependencyTypes.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var type = types.FirstOrDefault(t => 
            t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (type == null)
        {
            _logger.LogInformation("Creating dependency type: {TypeName} with Code: {Code}", typeName, cacheKey);
            try
            {
                type = new LU_DependencyType
                {
                    Code = cacheKey,
                    Name = typeName,
                    Description = $"Auto-created: {typeName}",
                    SortOrder = 1
                };
                type = await _unitOfWork.DependencyTypes.AddAsync(type);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for dependency type {Code}, reloading from database", cacheKey);
                types = await _unitOfWork.DependencyTypes.GetAllAsync();
                type = types.FirstOrDefault(t => t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (type == null) throw;
            }
        }
        
        // Store in session cache
        _dependencyTypeCache[cacheKey] = type;
        
        return type;
    }

    private async Task<LU_ScopeType?> FindOrCreateScopeTypeAsync(string typeName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = typeName.ToUpper().Replace(" ", "_");
        if (_scopeTypeCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found scope type in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var types = await _unitOfWork.ScopeTypes.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var type = types.FirstOrDefault(t => 
            t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (type == null)
        {
            _logger.LogInformation("Creating scope type: {TypeName} with Code: {Code}", typeName, cacheKey);
            try
            {
                type = new LU_ScopeType
                {
                    Code = cacheKey,
                    Name = typeName,
                    Description = $"Auto-created: {typeName}",
                    SortOrder = 1
                };
                type = await _unitOfWork.ScopeTypes.AddAsync(type);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for scope type {Code}, reloading from database", cacheKey);
                types = await _unitOfWork.ScopeTypes.GetAllAsync();
                type = types.FirstOrDefault(t => t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (type == null) throw;
            }
        }
        
        // Store in session cache
        _scopeTypeCache[cacheKey] = type;
        
        return type;
    }

    private async Task<LU_InteractionLevel?> FindOrCreateInteractionLevelAsync(string levelName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = levelName.ToUpper().Replace(" ", "_");
        if (_interactionLevelCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found interaction level in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var levels = await _unitOfWork.InteractionLevels.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var level = levels.FirstOrDefault(l => 
            l.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (level == null)
        {
            _logger.LogInformation("Creating interaction level: {LevelName} with Code: {Code}", levelName, cacheKey);
            try
            {
                level = new LU_InteractionLevel
                {
                    Code = cacheKey,
                    Name = levelName,
                    Description = $"Auto-created: {levelName}",
                    SortOrder = 1
                };
                level = await _unitOfWork.InteractionLevels.AddAsync(level);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for interaction level {Code}, reloading from database", cacheKey);
                levels = await _unitOfWork.InteractionLevels.GetAllAsync();
                level = levels.FirstOrDefault(l => l.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (level == null) throw;
            }
        }
        
        // Store in session cache
        _interactionLevelCache[cacheKey] = level;
        
        return level;
    }

    private async Task<LU_PrerequisiteCategory?> FindOrCreatePrerequisiteCategoryAsync(string categoryName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = categoryName.ToUpper().Replace(" ", "_");
        if (_prerequisiteCategoryCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found prerequisite category in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var categories = await _unitOfWork.PrerequisiteCategories.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var category = categories.FirstOrDefault(c => 
            c.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (category == null)
        {
            _logger.LogInformation("Creating prerequisite category: {CategoryName} with Code: {Code}", categoryName, cacheKey);
            try
            {
                category = new LU_PrerequisiteCategory
                {
                    Code = cacheKey,
                    Name = categoryName,
                    Description = $"Auto-created: {categoryName}",
                    SortOrder = 1
                };
                category = await _unitOfWork.PrerequisiteCategories.AddAsync(category);
                await _unitOfWork.SaveChangesAsync();
                _logger.LogInformation("Successfully created prerequisite category: {Code}", cacheKey);
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                // Race condition - category was created by another process, reload from DB
                _logger.LogWarning("Duplicate key detected for category {Code}, reloading from database", cacheKey);
                categories = await _unitOfWork.PrerequisiteCategories.GetAllAsync();
                category = categories.FirstOrDefault(c => 
                    c.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                
                if (category == null)
                {
                    _logger.LogError("Failed to find category {Code} after duplicate key error", cacheKey);
                    throw;
                }
            }
        }
        else
        {
            _logger.LogDebug("Found existing prerequisite category: {Code}", cacheKey);
        }
        
        // Store in session cache
        _prerequisiteCategoryCache[cacheKey] = category;
        
        return category;
    }

    private async Task<LU_LicenseType?> FindOrCreateLicenseTypeAsync(string typeName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = typeName.ToUpper().Replace(" ", "_");
        if (_licenseTypeCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found license type in cache: {CacheKey}", cacheKey);
            return cached;
        }

        var types = await _unitOfWork.LicenseTypes.GetAllAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var type = types.FirstOrDefault(t => 
            t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (type == null)
        {
            _logger.LogInformation("Creating license type: {TypeName} with Code: {Code}", typeName, cacheKey);
            try
            {
                type = new LU_LicenseType
                {
                    Code = cacheKey,
                    Name = typeName,
                    Description = $"Auto-created: {typeName}",
                    SortOrder = 1
                };
                type = await _unitOfWork.LicenseTypes.AddAsync(type);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for license type {Code}, reloading from database", cacheKey);
                types = await _unitOfWork.LicenseTypes.GetAllAsync();
                type = types.FirstOrDefault(t => t.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (type == null) throw;
            }
        }
        
        // Store in session cache
        _licenseTypeCache[cacheKey] = type;
        
        return type;
    }

    private async Task<LU_SizeOption?> FindOrCreateSizeOptionAsync(string sizeName)
    {
        // Check session cache first to avoid duplicate key violations
        var cacheKey = sizeName.ToUpper().Replace(" ", "_");
        if (_sizeOptionCache.TryGetValue(cacheKey, out var cached))
        {
            _logger.LogDebug("Found size option in cache: {CacheKey}", cacheKey);
            return cached;
        }

        // FIX: Use AsNoTracking() to prevent tracking conflicts
        var sizes = await _context.LU_SizeOptions.AsNoTracking().ToListAsync();
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var size = sizes.FirstOrDefault(s => 
            s.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
        
        if (size == null)
        {
            _logger.LogInformation("Creating size option: {SizeName} with Code: {Code}", sizeName, cacheKey);
            try
            {
                size = new LU_SizeOption
                {
                    Code = cacheKey,
                    Name = sizeName,
                    Description = $"Auto-created: {sizeName}",
                    SortOrder = 1
                };
                size = await _unitOfWork.SizeOptions.AddAsync(size);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                _logger.LogWarning("Duplicate key detected for size option {Code}, reloading from database", cacheKey);
                // FIX: Use AsNoTracking() on reload too
                sizes = await _context.LU_SizeOptions.AsNoTracking().ToListAsync();
                size = sizes.FirstOrDefault(s => s.Code.Equals(cacheKey, StringComparison.OrdinalIgnoreCase));
                if (size == null) throw;
            }
        }
        
        // Store in session cache
        _sizeOptionCache[cacheKey] = size;
        
        return size;
    }


    #region Phase 1: Core Import Methods

    private async Task ImportUsageScenariosAsync(int serviceId, List<UsageScenarioImportModel>? scenarios)
    {
        if (scenarios == null || !scenarios.Any())
        {
            _logger.LogDebug("No usage scenarios to import");
            return;
        }

        _logger.LogInformation("Importing {Count} usage scenarios", scenarios.Count);

        foreach (var scenario in scenarios)
        {
            var entity = new UsageScenario
            {
                ServiceId = serviceId,
                ScenarioNumber = scenario.ScenarioNumber,
                ScenarioTitle = scenario.ScenarioTitle ?? "Unknown Scenario",
                ScenarioDescription = scenario.ScenarioDescription ?? "",
                SortOrder = scenario.SortOrder,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.UsageScenarios.AddAsync(entity);
            _logger.LogDebug("Added usage scenario: {Title}", scenario.ScenarioTitle);
        }
    }

    #endregion

    #region Phase 2: Service I/O and Prerequisites

    private async Task ImportServiceInputsAsync(int serviceId, List<ServiceInputImportModel>? inputs)
    {
        if (inputs == null || !inputs.Any())
        {
            _logger.LogDebug("No service inputs to import");
            return;
        }

        _logger.LogInformation("Importing {Count} service inputs", inputs.Count);

        int sortOrder = 1;
        foreach (var input in inputs)
        {
            // Find or create RequirementLevel
            var reqLevel = await FindOrCreateRequirementLevelAsync(input.RequirementLevel ?? "REQUIRED");

            var entity = new ServiceInput
            {
                ServiceId = serviceId,
                InputName = input.ParameterName ?? "Unknown",
                ParameterName = input.ParameterName ?? "Unknown",
                ParameterDescription = input.Description ?? "",
                Description = input.Description,
                RequirementLevelId = reqLevel?.RequirementLevelId ?? 1,
                DataType = input.DataType,
                DefaultValue = input.DefaultValue,
                ExampleValue = input.ExampleValue,
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.Inputs.AddAsync(entity);
            _logger.LogDebug("Added input: {ParameterName}", input.ParameterName);
        }
    }

    private async Task ImportServiceOutputsAsync(int serviceId, List<OutputCategoryImportModel>? outputs)
    {
        if (outputs == null || !outputs.Any())
        {
            _logger.LogDebug("No service outputs to import");
            return;
        }

        _logger.LogInformation("Importing {Count} output categories", outputs.Count);

        int categorySortOrder = 1;
        foreach (var category in outputs)
        {
            var outputCategory = new ServiceOutputCategory
            {
                ServiceId = serviceId,
                CategoryName = category.CategoryName ?? "General",
                CategoryNumber = category.CategoryNumber,
                SortOrder = categorySortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            outputCategory = await _unitOfWork.OutputCategories.AddAsync(outputCategory);
            await _unitOfWork.SaveChangesAsync(); // Get ID for items

            // Import items
            if (category.Items != null && category.Items.Any())
            {
                int itemSortOrder = 1;
                foreach (var item in category.Items)
                {
                    await _unitOfWork.OutputItems.AddAsync(new ServiceOutputItem
                    {
                        OutputCategoryId = outputCategory.OutputCategoryId,
                        ItemName = item.ItemName ?? "Unknown",
                        ItemDescription = item.ItemDescription ?? "",
                        SortOrder = itemSortOrder++,
                        CreatedDate = DateTime.UtcNow,
                        ModifiedDate = DateTime.UtcNow
                    });
                }
                _logger.LogDebug("Added {Count} items to category: {CategoryName}", 
                    category.Items.Count, category.CategoryName);
            }
        }
    }

    private async Task ImportPrerequisitesAsync(int serviceId, PrerequisitesImportModel? prerequisites)
    {
        if (prerequisites == null)
        {
            _logger.LogDebug("No prerequisites to import");
            return;
        }

        _logger.LogInformation("Importing prerequisites");

        int totalCount = 0;
        totalCount += await ImportPrerequisiteListAsync(serviceId, prerequisites.Organizational, "Organizational", 1);
        totalCount += await ImportPrerequisiteListAsync(serviceId, prerequisites.Technical, "Technical", 100);
        totalCount += await ImportPrerequisiteListAsync(serviceId, prerequisites.Documentation, "Documentation", 200);

        _logger.LogInformation("Imported {TotalCount} prerequisites", totalCount);
    }

    private async Task<int> ImportPrerequisiteListAsync(
        int serviceId,
        List<PrerequisiteItemImportModel>? items,
        string categoryName,
        int baseSortOrder)
    {
        if (items == null || !items.Any())
        {
            return 0;
        }

        // Find or create prerequisite category
        var category = await FindOrCreatePrerequisiteCategoryAsync(categoryName);
        
        // Find requirement level (use from item or default)
        int sortOrder = baseSortOrder;
        foreach (var item in items)
        {
            var reqLevel = await FindOrCreateRequirementLevelAsync(
                item.RequirementLevel ?? "REQUIRED");

            var entity = new ServicePrerequisite
            {
                ServiceId = serviceId,
                PrerequisiteCategoryId = category?.PrerequisiteCategoryId ?? 1,
                PrerequisiteName = item.Name ?? "Unknown",
                PrerequisiteDescription = item.Description ?? "",
                Description = item.Description,
                RequirementLevelId = reqLevel?.RequirementLevelId,
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.Prerequisites.AddAsync(entity);
            _logger.LogDebug("Added prerequisite: {Name} in category: {Category}", 
                item.Name, categoryName);
        }

        return items.Count;
    }

    #endregion

    #region Phase 3: Advanced Features

    private async Task ImportDependenciesAsync(int serviceId, DependenciesImportModel? dependencies)
    {
        if (dependencies == null)
        {
            _logger.LogDebug("No dependencies to import");
            return;
        }

        _logger.LogInformation("Importing dependencies");

        int totalCount = 0;
        totalCount += await ImportDependencyListAsync(serviceId, dependencies.Prerequisite, "Prerequisite");
        totalCount += await ImportDependencyListAsync(serviceId, dependencies.TriggersFor, "TriggersFor");
        totalCount += await ImportDependencyListAsync(serviceId, dependencies.ParallelWith, "ParallelWith");

        _logger.LogInformation("Imported {TotalCount} dependencies", totalCount);
    }

    private async Task<int> ImportDependencyListAsync(
        int serviceId,
        List<DependencyImportModel>? dependencies,
        string dependencyType)
    {
        if (dependencies == null || !dependencies.Any())
        {
            return 0;
        }

        var depType = await FindOrCreateDependencyTypeAsync(dependencyType);

        int sortOrder = 1;
        foreach (var dep in dependencies)
        {
            // Try to find related service by code
            ServiceCatalogItem? targetService = null;
            if (!string.IsNullOrWhiteSpace(dep.ServiceCode))
            {
                targetService = await _unitOfWork.ServiceCatalogs.GetByCodeAsync(dep.ServiceCode);
            }

            // Get requirement level
            var reqLevel = await FindOrCreateRequirementLevelAsync(
                dep.RequirementLevel ?? "REQUIRED");

            var entity = new ServiceDependency
            {
                ServiceId = serviceId,
                DependencyTypeId = depType?.DependencyTypeId ?? 1,
                DependencyName = dep.ServiceName ?? "Unknown",
                DependencyDescription = dep.Notes ?? "",
                RelatedServiceId = targetService?.ServiceId,
                DependentServiceCode = dep.ServiceCode,
                DependentServiceName = dep.ServiceName,
                RequirementLevelId = reqLevel?.RequirementLevelId,
                Notes = dep.Notes,
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.ServiceDependencies.AddAsync(entity);
            _logger.LogDebug("Added dependency: {ServiceName} ({Type})", 
                dep.ServiceName, dependencyType);
        }

        return dependencies.Count;
    }

    private async Task ImportScopeAsync(int serviceId, ScopeImportModel? scope)
    {
        if (scope == null)
        {
            _logger.LogDebug("No scope to import");
            return;
        }

        _logger.LogInformation("Importing scope");

        int totalCategories = 0;
        int totalItems = 0;

        // InScope categories
        if (scope.InScope != null && scope.InScope.Any())
        {
            var inScopeType = await FindOrCreateScopeTypeAsync("In Scope");

            foreach (var category in scope.InScope)
            {
                var scopeCategory = new ServiceScopeCategory
                {
                    ServiceId = serviceId,
                    CategoryName = category.CategoryName ?? "General",
                    ScopeTypeId = inScopeType?.ScopeTypeId ?? 1,
                    CategoryNumber = category.CategoryNumber,
                    SortOrder = category.SortOrder,
                    CreatedDate = DateTime.UtcNow,
                    ModifiedDate = DateTime.UtcNow
                };

                scopeCategory = await _unitOfWork.ScopeCategories.AddAsync(scopeCategory);
                await _unitOfWork.SaveChangesAsync(); // Get ID
                totalCategories++;

                // Import scope items (they are objects!)
                if (category.Items != null && category.Items.Any())
                {
                    var itemIndex = 1;
                    foreach (var item in category.Items)
                    {
                        await _unitOfWork.ScopeItems.AddAsync(new ServiceScopeItem
                        {
                            ScopeCategoryId = scopeCategory.ScopeCategoryId,
                            ItemName = item.ItemName,
                            ItemDescription = item.ItemDescription ?? "",
                            SortOrder = itemIndex++,
                            CreatedDate = DateTime.UtcNow,
                            ModifiedDate = DateTime.UtcNow
                        });
                        totalItems++;
                    }
                }
            }
        }

        // OutOfScope items (they are strings!)
        if (scope.OutOfScope != null && scope.OutOfScope.Any())
        {
            var outScopeType = await FindOrCreateScopeTypeAsync("Out of Scope");

            var outCategory = new ServiceScopeCategory
            {
                ServiceId = serviceId,
                CategoryName = "Out of Scope",
                ScopeTypeId = outScopeType?.ScopeTypeId ?? 1,
                SortOrder = 999,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            outCategory = await _unitOfWork.ScopeCategories.AddAsync(outCategory);
            await _unitOfWork.SaveChangesAsync();
            totalCategories++;

            int sortOrder = 1;
            foreach (var itemName in scope.OutOfScope)
            {
                await _unitOfWork.ScopeItems.AddAsync(new ServiceScopeItem
                {
                    ScopeCategoryId = outCategory.ScopeCategoryId,
                    ItemName = itemName,
                    ItemDescription = "",
                    SortOrder = sortOrder++,
                    CreatedDate = DateTime.UtcNow,
                    ModifiedDate = DateTime.UtcNow
                });
                totalItems++;
            }
        }

        _logger.LogInformation("Imported {Categories} scope categories with {Items} items", 
            totalCategories, totalItems);
    }

    private async Task ImportLicensesAsync(int serviceId, LicensesImportModel? licenses)
    {
        if (licenses == null)
        {
            _logger.LogDebug("No licenses to import");
            return;
        }

        _logger.LogInformation("Importing licenses");

        int totalCount = 0;
        totalCount += await ImportLicenseListAsync(serviceId, licenses.RequiredByCustomer, "REQUIRED");
        totalCount += await ImportLicenseListAsync(serviceId, licenses.RecommendedOptional, "RECOMMENDED");
        totalCount += await ImportLicenseListAsync(serviceId, licenses.ProvidedByServiceProvider, "PROVIDED");

        _logger.LogInformation("Imported {TotalCount} licenses", totalCount);
    }

    private async Task<int> ImportLicenseListAsync(
        int serviceId,
        List<LicenseItemImportModel>? licenses,
        string defaultTypeName)
    {
        if (licenses == null || !licenses.Any())
        {
            return 0;
        }

        int sortOrder = 1;
        foreach (var license in licenses)
        {
            // Use license type from item or default
            var typeName = license.LicenseType ?? defaultTypeName;
            var licenseType = await FindOrCreateLicenseTypeAsync(typeName);

            var entity = new ServiceLicense
            {
                ServiceId = serviceId,
                LicenseTypeId = licenseType?.LicenseTypeId ?? 1,
                LicenseName = license.LicenseName ?? "Unknown License",
                Description = license.Description,
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.ServiceLicenses.AddAsync(entity);
            _logger.LogDebug("Added license: {LicenseName} ({Type})", 
                license.LicenseName, typeName);
        }

        return licenses.Count;
    }

    #endregion

    #region Phase 4: Complete Features

        private async Task ImportStakeholderInteractionAsync(
        int serviceId,
        StakeholderInteractionImportModel? interaction)
    {
        if (interaction == null)
        {
            _logger.LogDebug("No stakeholder interaction to import");
            return;
        }

        _logger.LogInformation("Importing stakeholder interaction");

        // Find or create interaction level
        var interactionLevel = await FindOrCreateInteractionLevelAsync(
            interaction.InteractionLevel ?? "MEDIUM");

        // Create main interaction record
        var entity = new ServiceInteraction
        {
            ServiceId = serviceId,
            InteractionLevelId = interactionLevel?.InteractionLevelId ?? 0,
            InteractionDescription = "",
            CreatedDate = DateTime.UtcNow,
            ModifiedDate = DateTime.UtcNow
        };

        entity = await _unitOfWork.Interactions.AddAsync(entity);
        await _unitOfWork.SaveChangesAsync(); // Get ID

        int totalInvolvements = 0;

        // Import workshop participation (CORRECTED: WorkshopParticipation not WorkshopParticipants)
        if (interaction.WorkshopParticipation != null && interaction.WorkshopParticipation.Any())
        {
            int sortOrder = 1;
            foreach (var participant in interaction.WorkshopParticipation)
            {
                var involvement = new StakeholderInvolvement
                {
                    ServiceId = serviceId,
                    InteractionId = entity.InteractionId,
                    StakeholderRole = participant.RoleName ?? "Unknown",
                    InvolvementType = participant.InvolvementLevel ?? "Workshop",
                    InvolvementDescription = participant.Responsibilities ?? "",
                    Description = participant.Responsibilities,
                    SortOrder = sortOrder++,
                    CreatedDate = DateTime.UtcNow,
                    ModifiedDate = DateTime.UtcNow
                };

                await _unitOfWork.StakeholderInvolvements.AddAsync(involvement);
                totalInvolvements++;
            }

            _logger.LogDebug("Added {Count} workshop participants", 
                interaction.WorkshopParticipation.Count);
        }

        // Import customer requirements (CustomerMustProvide strings)
        if (interaction.CustomerMustProvide != null && interaction.CustomerMustProvide.Any())
        {
            // Note: CustomerRequirement entity might need repository in UnitOfWork
            // For now just logging
            _logger.LogDebug("Customer requirements found: {Count}", 
                interaction.CustomerMustProvide.Count);
        }

        // Import access requirements
        if (interaction.AccessRequirements != null && interaction.AccessRequirements.Any())
        {
            // Note: AccessRequirement entity might need repository in UnitOfWork
            _logger.LogDebug("Access requirements found: {Count}", 
                interaction.AccessRequirements.Count);
        }

        _logger.LogInformation("Imported stakeholder interaction with {Count} involvements", 
            totalInvolvements);
    }



        private async Task ImportTimelineAsync(int serviceId, TimelineImportModel? timeline)
    {
        if (timeline == null || timeline.Phases == null || !timeline.Phases.Any())
        {
            _logger.LogDebug("No timeline to import");
            return;
        }

        _logger.LogInformation("Importing {Count} timeline phases", timeline.Phases.Count);

        int sortOrder = 1;
        foreach (var phase in timeline.Phases)
        {
            var entity = new TimelinePhase
            {
                ServiceId = serviceId,
                PhaseNumber = phase.PhaseNumber ?? sortOrder,
                PhaseName = phase.PhaseName ?? "Unknown Phase",
                Description = phase.Description,
                DurationBySize = null,  // Will create separate records
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            entity = await _unitOfWork.TimelinePhases.AddAsync(entity);
            await _unitOfWork.SaveChangesAsync(); // Get ID

            // Import duration by size (if available)
            if (phase.DurationBySize != null)
            {
                var durations = new Dictionary<string, string?>
                {
                    { "Small", phase.DurationBySize.Small },
                    { "Medium", phase.DurationBySize.Medium },
                    { "Large", phase.DurationBySize.Large }
                };

                foreach (var duration in durations.Where(d => !string.IsNullOrWhiteSpace(d.Value)))
                {
                    // Find or create size option
                    var sizeOption = await FindOrCreateSizeOptionAsync(duration.Key);
                    
                    // Note: PhaseDurationBySize might need repository added to UnitOfWork
                    // For now, storing as string in DurationBySize field
                    _logger.LogDebug("Duration for {Size}: {Duration}", duration.Key, duration.Value);
                }
            }

            _logger.LogDebug("Added timeline phase: {PhaseName}", phase.PhaseName);
        }
    }



        private async Task ImportSizeOptionsAsync(int serviceId, List<SizeOptionImportModel>? sizeOptions)
    {
        if (sizeOptions == null || !sizeOptions.Any())
        {
            _logger.LogDebug("No size options to import");
            return;
        }

        _logger.LogInformation("Importing {Count} size options", sizeOptions.Count);

        // CRITICAL FIX: Batch all ServiceSizeOption inserts into single SaveChanges
        // Step 1: Pre-load all required LU_SizeOptions with AsNoTracking
        var sizeNames = sizeOptions.Select(o => o.GetEffectiveSizeName()).Distinct().ToList();
        var sizeOptionLookup = new Dictionary<string, int>();
        
        foreach (var sizeName in sizeNames)
        {
            var sizeOption = await FindOrCreateSizeOptionAsync(sizeName);
            if (sizeOption != null)
            {
                sizeOptionLookup[sizeName] = sizeOption.SizeOptionId;
            }
        }

        // Step 2: Create all ServiceSizeOption entities (but don't save yet)
        var serviceSizeOptionsToAdd = new List<ServiceSizeOption>();
        
        foreach (var option in sizeOptions)
        {
            var effectiveSizeName = option.GetEffectiveSizeName();
            
            if (!sizeOptionLookup.TryGetValue(effectiveSizeName, out var sizeOptionId))
            {
                _logger.LogWarning("Size option {SizeName} not found, skipping", effectiveSizeName);
                continue;
            }

            var serviceSizeOption = new ServiceSizeOption
            {
                ServiceId = serviceId,
                SizeOptionId = sizeOptionId,
                Description = option.GetEffectiveDescription(),
                Duration = option.Duration,
                EffortRange = option.GetEffectiveEffortRange(),
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            serviceSizeOptionsToAdd.Add(serviceSizeOption);
        }

        // Step 3: Batch insert all ServiceSizeOptions in single transaction
        if (serviceSizeOptionsToAdd.Any())
        {
            await _context.ServiceSizeOptions.AddRangeAsync(serviceSizeOptionsToAdd);
            await _unitOfWork.SaveChangesAsync(); // Single SaveChanges for all ServiceSizeOptions
            _logger.LogInformation("Successfully imported {Count} ServiceSizeOptions", serviceSizeOptionsToAdd.Count);
        }

        // Step 4: Now process related entities (EffortEstimationItems) with proper ServiceSizeOptionId
        for (int i = 0; i < sizeOptions.Count && i < serviceSizeOptionsToAdd.Count; i++)
        {
            var option = sizeOptions[i];
            var serviceSizeOption = serviceSizeOptionsToAdd[i];
            var effectiveSizeName = option.GetEffectiveSizeName();

            // Import team allocations - použití normalizované metody
            var normalizedAllocations = option.GetTeamAllocationsNormalized();
            if (normalizedAllocations.Any())
            {
                int sortOrder = 1;
                foreach (var allocation in normalizedAllocations)
                {
                    var roles = new Dictionary<string, decimal?>
                    {
                        { "Cloud Architects", allocation.CloudArchitects },
                        { "Solution Architects", allocation.SolutionArchitects },
                        { "Technical Leads", allocation.TechnicalLeads },
                        { "Developers", allocation.Developers },
                        { "QA Engineers", allocation.QAEngineers },
                        { "DevOps Engineers", allocation.DevOpsEngineers },
                        { "Security Specialists", allocation.SecuritySpecialists },
                        { "Project Managers", allocation.ProjectManagers },
                        { "Business Analysts", allocation.BusinessAnalysts }
                    };

                    foreach (var role in roles.Where(r => r.Value.HasValue && r.Value > 0))
                    {
                        var effortItem = new EffortEstimationItem
                        {
                            ServiceId = serviceId,
                            ServiceSizeOptionId = serviceSizeOption.ServiceSizeOptionId,
                            ScopeArea = role.Key,
                            Category = effectiveSizeName,
                            BaseHours = (int)(role.Value ?? 0),
                            EstimatedHours = (int)(role.Value ?? 0),
                            SortOrder = sortOrder++,
                            CreatedDate = DateTime.UtcNow,
                            ModifiedDate = DateTime.UtcNow
                        };

                        await _unitOfWork.EffortEstimations.AddAsync(effortItem);
                    }
                }

                _logger.LogDebug("Added size option: {SizeName} with team allocations", effectiveSizeName);
            }

            // Import effort breakdown z nového formátu
            if (option.EffortBreakdown != null && option.EffortBreakdown.Any())
            {
                int sortOrder = 1;
                foreach (var breakdown in option.EffortBreakdown)
                {
                    var effortItem = new EffortEstimationItem
                    {
                        ServiceId = serviceId,
                        ServiceSizeOptionId = serviceSizeOption.ServiceSizeOptionId,
                        ScopeArea = breakdown.ScopeArea ?? "General",
                        Category = "Effort Breakdown",
                        BaseHours = breakdown.BaseHours ?? 0,
                        EstimatedHours = breakdown.BaseHours ?? 0,
                        Notes = breakdown.Notes,
                        SortOrder = sortOrder++,
                        CreatedDate = DateTime.UtcNow,
                        ModifiedDate = DateTime.UtcNow
                    };

                    await _unitOfWork.EffortEstimations.AddAsync(effortItem);
                }
                
                _logger.LogDebug("Added {Count} effort breakdown items for {SizeName}", 
                    option.EffortBreakdown.Count, effectiveSizeName);
            }

            // Import complexity additions z nového formátu
            if (option.ComplexityAdditions != null && option.ComplexityAdditions.Any())
            {
                int sortOrder = 100; // Start from 100 to differentiate from effort breakdown
                foreach (var complexity in option.ComplexityAdditions)
                {
                    var effortItem = new EffortEstimationItem
                    {
                        ServiceId = serviceId,
                        ServiceSizeOptionId = serviceSizeOption.ServiceSizeOptionId,
                        ScopeArea = complexity.Factor ?? "Complexity",
                        Category = "Complexity Addition",
                        BaseHours = complexity.AdditionalHours ?? 0,
                        EstimatedHours = complexity.AdditionalHours ?? 0,
                        Notes = complexity.Condition,
                        SortOrder = sortOrder++,
                        CreatedDate = DateTime.UtcNow,
                        ModifiedDate = DateTime.UtcNow
                    };

                    await _unitOfWork.EffortEstimations.AddAsync(effortItem);
                }
                
                _logger.LogDebug("Added {Count} complexity additions for {SizeName}", 
                    option.ComplexityAdditions.Count, effectiveSizeName);
            }

            // Log examples info (entity for examples might need to be added)
            if (option.Examples != null && option.Examples.Any())
            {
                foreach (var example in option.Examples)
                {
                    _logger.LogDebug("Example: {Title} - {Description}", 
                        example.GetEffectiveTitle(),
                        example.GetEffectiveDescription());
                    
                    // Log characteristics
                    if (example.Characteristics != null)
                    {
                        foreach (var characteristic in example.Characteristics)
                        {
                            _logger.LogDebug("  Characteristic: {Desc}", 
                                characteristic.GetNormalizedDescription());
                        }
                    }
                }
            }
        }
    }



    private async Task ImportResponsibleRolesAsync(
        int serviceId,
        List<ResponsibleRoleImportModel>? roles)
    {
        if (roles == null || !roles.Any())
        {
            _logger.LogDebug("No responsible roles to import");
            return;
        }

        _logger.LogInformation("Importing {Count} responsible roles", roles.Count);

        int sortOrder = 1;
        foreach (var role in roles)
        {
            // For now, set RoleId to 0 or find/create role from role.RoleName
            var entity = new ServiceResponsibleRole
            {
                ServiceId = serviceId,
                RoleId = 0, // TODO: Find or create role by name
                Responsibility = role.RoleName ?? "Unknown",
                IsPrimaryOwner = role.IsPrimaryOwner,
                Responsibilities = role.Responsibilities,
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.ResponsibleRoles.AddAsync(entity);
            _logger.LogDebug("Added responsible role: {RoleName} (Primary: {IsPrimary})", 
                role.RoleName, role.IsPrimaryOwner);
        }
    }

    private async Task ImportMultiCloudConsiderationsAsync(
        int serviceId,
        List<MultiCloudConsiderationImportModel>? considerations)
    {
        if (considerations == null || !considerations.Any())
        {
            _logger.LogDebug("No multi-cloud considerations to import");
            return;
        }

        _logger.LogInformation("Importing {Count} multi-cloud considerations", considerations.Count);

        int sortOrder = 1;
        foreach (var consideration in considerations)
        {
            var entity = new ServiceMultiCloudConsideration
            {
                ServiceId = serviceId,
                ConsiderationTitle = consideration.ConsiderationTitle ?? "Multi-Cloud",
                ConsiderationDescription = consideration.Description ?? "",
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.MultiCloudConsiderations.AddAsync(entity);
            _logger.LogDebug("Added multi-cloud consideration: {Title}", 
                consideration.ConsiderationTitle);
        }
    }

    #endregion
}
