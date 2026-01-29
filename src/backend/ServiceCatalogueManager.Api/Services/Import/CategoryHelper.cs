namespace ServiceCatalogueManager.Api.Services.Import;

using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Data.Entities;
using Microsoft.Extensions.Logging;

/// <summary>
/// Helper for category management - FIXED VERSION
/// </summary>
public class CategoryHelper
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CategoryHelper> _logger;
    
    // Session cache to avoid duplicate key violations
    // Key format: "ParentId|CategoryName" or "null|CategoryName" for root
    private readonly Dictionary<string, LU_ServiceCategory> _categoryCache = new();

    public CategoryHelper(IUnitOfWork unitOfWork, ILogger<CategoryHelper> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    /// <summary>
    /// Find or create hierarchical category from path (e.g., "Services/Architecture/Technical")
    /// </summary>
    public async Task<int> FindOrCreateCategoryAsync(string categoryPath)
    {
        if (string.IsNullOrWhiteSpace(categoryPath))
        {
            _logger.LogWarning("Empty category path, returning default category ID=1");
            return 1;
        }

        var parts = categoryPath.Split('/', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (parts.Length == 0)
        {
            _logger.LogWarning("No valid category parts found, returning default category ID=1");
            return 1;
        }

        int? parentId = null;
        int currentCategoryId = 1;

        foreach (var part in parts)
        {
            var categoryCode = part.ToUpper().Replace(" ", "_");
            var cacheKey = $"{parentId?.ToString() ?? "null"}|{categoryCode}";
            
            // Check session cache first
            if (_categoryCache.TryGetValue(cacheKey, out var cachedCategory))
            {
                currentCategoryId = cachedCategory.CategoryId;
                parentId = currentCategoryId;
                _logger.LogDebug("Found category in cache: {CategoryName} (ID: {CategoryId})", part, currentCategoryId);
                continue;
            }

            var existingCategories = await _unitOfWork.ServiceCategories.GetAllAsync();
            
            // IMPORTANT: Search by Code first (UNIQUE with parent), then Name as fallback
            var category = existingCategories.FirstOrDefault(c => 
                c.Code.Equals(categoryCode, StringComparison.OrdinalIgnoreCase) &&
                c.ParentCategoryId == parentId);
            
            // Fallback to Name if Code doesn't match (for backwards compatibility)
            if (category == null)
            {
                category = existingCategories.FirstOrDefault(c => 
                    c.Name.Equals(part, StringComparison.OrdinalIgnoreCase) &&
                    c.ParentCategoryId == parentId);
            }

            if (category == null)
            {
                _logger.LogInformation("Creating category: {CategoryName} with Code: {Code} and parent ID: {ParentId}", 
                    part, categoryCode, parentId);
                
                try
                {
                    category = new LU_ServiceCategory
                    {
                        Code = categoryCode,
                        Name = part,
                        Description = $"Auto-created category: {part}",
                        ParentCategoryId = parentId,
                        SortOrder = 1,
                        CreatedDate = DateTime.UtcNow,
                        ModifiedDate = DateTime.UtcNow
                    };

                    category = await _unitOfWork.ServiceCategories.AddAsync(category);
                    await _unitOfWork.SaveChangesAsync();
                    
                    currentCategoryId = category.CategoryId;
                    _logger.LogInformation("Created category ID: {CategoryId} with Code: {Code}", currentCategoryId, categoryCode);
                }
                catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
                {
                    // Race condition - category was created by another process/thread, reload from DB
                    _logger.LogWarning("Duplicate key detected for category {Code} with parent {ParentId}, reloading from database", 
                        categoryCode, parentId);
                    
                    existingCategories = await _unitOfWork.ServiceCategories.GetAllAsync();
                    category = existingCategories.FirstOrDefault(c => 
                        c.Code.Equals(categoryCode, StringComparison.OrdinalIgnoreCase) &&
                        c.ParentCategoryId == parentId);
                    
                    if (category == null)
                    {
                        // Try by Name as final fallback
                        category = existingCategories.FirstOrDefault(c => 
                            c.Name.Equals(part, StringComparison.OrdinalIgnoreCase) &&
                            c.ParentCategoryId == parentId);
                    }
                    
                    if (category == null)
                    {
                        _logger.LogError("Failed to find category {Code} with parent {ParentId} after duplicate key error", 
                            categoryCode, parentId);
                        throw;
                    }
                    
                    currentCategoryId = category.CategoryId;
                    _logger.LogInformation("Successfully recovered category {Code} from database after duplicate key (ID: {CategoryId})", 
                        categoryCode, currentCategoryId);
                }
            }
            else
            {
                currentCategoryId = category.CategoryId;
                _logger.LogDebug("Found existing category: {CategoryName} (ID: {CategoryId}, Code: {Code})", 
                    part, currentCategoryId, category.Code);
            }
            
            // Store in session cache
            _categoryCache[cacheKey] = category;

            parentId = currentCategoryId;
        }

        return currentCategoryId;
    }
}
