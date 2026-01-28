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
        var categories = await _unitOfWork.ToolCategories.GetAllAsync();
        var category = categories.FirstOrDefault(c => 
            c.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));  // ✅ FIXED: Use Name property

        if (category == null)
        {
            _logger.LogInformation("Creating tool category: {CategoryName}", categoryName);

            category = new LU_ToolCategory
            {
                Code = categoryName.ToUpper().Replace(" ", "_"),
                Name = categoryName,  // ✅ FIXED: Use Name property from LookupBase
                Description = $"Auto-created category: {categoryName}",
                SortOrder = 1
            };

            category = await _unitOfWork.ToolCategories.AddAsync(category);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Created tool category ID: {CategoryId}", category.ToolCategoryId);
        }

        return category;
    }
}
