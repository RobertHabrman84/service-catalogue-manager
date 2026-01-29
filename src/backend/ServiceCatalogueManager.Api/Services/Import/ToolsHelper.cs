namespace ServiceCatalogueManager.Api.Services.Import;

using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.Import;
using Microsoft.Extensions.Logging;

/// <summary>
/// Helper for tools and frameworks import - FIXED VERSION  
/// Simplified to work with actual entities
/// </summary>
public class ToolsHelper
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ToolsHelper> _logger;
    
    // Session cache to avoid duplicate key violations
    private readonly Dictionary<string, LU_ToolCategory> _toolCategoryCache = new();

    public ToolsHelper(IUnitOfWork unitOfWork, ILogger<ToolsHelper> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    /// <summary>
    /// Import tools - SIMPLIFIED: Just create tools, don't try to parse complex structures
    /// </summary>
    public async Task ImportToolsAsync(int serviceId, ToolsAndEnvironmentImportModel? toolsModel)
    {
        if (toolsModel == null)
        {
            _logger.LogDebug("No tools to import");
            return;
        }

        int totalCount = 0;

        // Import each tool category
        totalCount += await ImportToolCategoryAsync(serviceId, toolsModel.CloudPlatforms, "Cloud Platform");
        totalCount += await ImportToolCategoryAsync(serviceId, toolsModel.DesignTools, "Design Tools");
        totalCount += await ImportToolCategoryAsync(serviceId, toolsModel.AutomationTools, "Automation Tools");
        totalCount += await ImportToolCategoryAsync(serviceId, toolsModel.CollaborationTools, "Collaboration Tools");
        totalCount += await ImportToolCategoryAsync(serviceId, toolsModel.Other, "Other");

        _logger.LogInformation("Imported {TotalCount} tools", totalCount);
    }

    private async Task<int> ImportToolCategoryAsync(int serviceId, List<ToolItemImportModel>? tools, string categoryName)
    {
        if (tools == null || !tools.Any())
        {
            return 0;
        }

        // Find or create tool category
        var toolCategory = await FindOrCreateToolCategoryAsync(categoryName);
        
        int sortOrder = 1;
        foreach (var tool in tools)
        {
            var entity = new ServiceToolFramework
            {
                ServiceId = serviceId,
                ToolCategoryId = toolCategory.ToolCategoryId,
                ToolName = tool.ToolName ?? "Unknown Tool",
                Description = tool.Version ?? tool.Purpose ?? "",
                SortOrder = sortOrder++,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };

            await _unitOfWork.ServiceTools.AddAsync(entity);
            _logger.LogDebug("Added tool: {ToolName} to category: {Category}", tool.ToolName, categoryName);
        }

        return tools.Count;
    }

    private async Task<LU_ToolCategory> FindOrCreateToolCategoryAsync(string categoryName)
    {
        // Generate the code that would be created for this category name
        var categoryCode = categoryName.ToUpper().Replace(" ", "_");
        
        // Check session cache first to avoid duplicate key violations
        if (_toolCategoryCache.TryGetValue(categoryCode, out var cached))
        {
            _logger.LogDebug("Found tool category in cache: {CacheKey}", categoryCode);
            return cached;
        }
        
        var categories = await _unitOfWork.ToolCategories.GetAllAsync();
        
        // IMPORTANT: Search by Code (which has UNIQUE constraint), not by Name
        var category = categories.FirstOrDefault(c => 
            c.Code.Equals(categoryCode, StringComparison.OrdinalIgnoreCase));

        if (category == null)
        {
            _logger.LogInformation("Creating tool category: {CategoryName} with code: {CategoryCode}", categoryName, categoryCode);
            
            try
            {
                category = new LU_ToolCategory
                {
                    Code = categoryCode,
                    Name = categoryName,
                    Description = $"Auto-created category: {categoryName}",
                    SortOrder = 1
                };

                category = await _unitOfWork.ToolCategories.AddAsync(category);
                await _unitOfWork.SaveChangesAsync();

                _logger.LogInformation("Created tool category ID: {CategoryId} with code: {Code}", category.ToolCategoryId, category.Code);
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message?.Contains("UNIQUE") == true || ex.InnerException?.Message?.Contains("duplicate") == true)
            {
                // Race condition - category was created by another process/thread, reload from DB
                _logger.LogWarning("Duplicate key detected for tool category {Code}, reloading from database", categoryCode);
                categories = await _unitOfWork.ToolCategories.GetAllAsync();
                category = categories.FirstOrDefault(c => 
                    c.Code.Equals(categoryCode, StringComparison.OrdinalIgnoreCase));
                
                if (category == null)
                {
                    _logger.LogError("Failed to find tool category {Code} after duplicate key error", categoryCode);
                    throw;
                }
                
                _logger.LogInformation("Successfully recovered tool category {Code} from database after duplicate key", categoryCode);
            }
        }
        else
        {
            _logger.LogDebug("Found existing tool category: {CategoryName} (ID: {CategoryId}, Code: {Code})", 
                category.Name, category.ToolCategoryId, category.Code);
        }
        
        // Store in session cache
        _toolCategoryCache[categoryCode] = category;

        return category;
    }
}
