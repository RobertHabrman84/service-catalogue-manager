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
            var existingCategories = await _unitOfWork.ServiceCategories.GetAllAsync();
            var category = existingCategories.FirstOrDefault(c => 
                c.Name == part &&  // ✅ FIXED: Use Name property from LookupBase
                c.ParentCategoryId == parentId);

            if (category == null)
            {
                _logger.LogInformation("Creating category: {CategoryName} with parent ID: {ParentId}", part, parentId);
                
                category = new LU_ServiceCategory
                {
                    Code = part.ToUpper().Replace(" ", "_"),
                    Name = part,  // ✅ FIXED: Use Name property from LookupBase
                    Description = $"Auto-created category: {part}",
                    ParentCategoryId = parentId,
                    SortOrder = 1,
                    CreatedDate = DateTime.UtcNow,
                    ModifiedDate = DateTime.UtcNow
                };

                category = await _unitOfWork.ServiceCategories.AddAsync(category);
                await _unitOfWork.SaveChangesAsync();
                
                currentCategoryId = category.CategoryId;
                _logger.LogInformation("Created category ID: {CategoryId}", currentCategoryId);
            }
            else
            {
                currentCategoryId = category.CategoryId;
                _logger.LogDebug("Found existing category ID: {CategoryId}", currentCategoryId);
            }

            parentId = currentCategoryId;
        }

        return currentCategoryId;
    }
}
