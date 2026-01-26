using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;

namespace ServiceCatalogueManager.Api.Services.Import;

/// <summary>
/// Service for resolving lookup table IDs from friendly names with caching
/// </summary>
public class LookupResolverService : ILookupResolverService
{
    private readonly ServiceCatalogDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<LookupResolverService> _logger;
    
    // Cache settings
    private static readonly TimeSpan CacheExpiration = TimeSpan.FromMinutes(30);
    private const string CachePrefixCategory = "lookup_category_";
    private const string CachePrefixSize = "lookup_size_";
    private const string CachePrefixDependencyType = "lookup_deptype_";
    private const string CachePrefixRequirementLevel = "lookup_reqlevel_";
    private const string CachePrefixRole = "lookup_role_";
    private const string CachePrefixToolCategory = "lookup_toolcat_";
    private const string CachePrefixLicenseType = "lookup_license_";
    private const string CachePrefixInteractionLevel = "lookup_intlevel_";
    private const string CachePrefixPrerequisiteCategory = "lookup_prereqcat_";
    private const string CachePrefixScopeType = "lookup_scope_";
    private const string CachePrefixCloudProvider = "lookup_cloud_";

    public LookupResolverService(
        ServiceCatalogDbContext context,
        IMemoryCache cache,
        ILogger<LookupResolverService> logger)
    {
        _context = context;
        _cache = cache;
        _logger = logger;
    }

    public async Task<int?> ResolveCategoryIdAsync(string categoryPath)
    {
        if (string.IsNullOrWhiteSpace(categoryPath))
            return null;

        var cacheKey = $"{CachePrefixCategory}{categoryPath.ToLowerInvariant()}";
        
        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Category ID for '{CategoryPath}' retrieved from cache", categoryPath);
            return cachedId;
        }

        // Try exact match on CategoryPath first
        var category = await _context.Set<LU_ServiceCategory>()
            .Where(c => c.IsActive)
            .FirstOrDefaultAsync(c => c.CategoryPath == categoryPath);

        // If not found, try case-insensitive match
        if (category == null)
        {
            category = await _context.Set<LU_ServiceCategory>()
                .Where(c => c.IsActive)
                .FirstOrDefaultAsync(c => c.CategoryPath!.ToLower() == categoryPath.ToLower());
        }

        if (category != null)
        {
            _cache.Set(cacheKey, category.CategoryId, CacheExpiration);
            _logger.LogInformation("Resolved category '{CategoryPath}' to ID {CategoryId}", 
                categoryPath, category.CategoryId);
            return category.CategoryId;
        }

        _logger.LogWarning("Category not found: {CategoryPath}", categoryPath);
        return null;
    }

    public async Task<int?> ResolveSizeOptionIdAsync(string sizeCode)
    {
        if (string.IsNullOrWhiteSpace(sizeCode))
            return null;

        var normalizedCode = NormalizeSizeCode(sizeCode);
        var cacheKey = $"{CachePrefixSize}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Size option ID for '{SizeCode}' retrieved from cache", sizeCode);
            return cachedId;
        }

        var sizeOption = await _context.Set<LU_SizeOption>()
            .Where(s => s.IsActive)
            .FirstOrDefaultAsync(s => s.Code.ToUpper() == normalizedCode);

        if (sizeOption != null)
        {
            _cache.Set(cacheKey, sizeOption.SizeOptionId, CacheExpiration);
            _logger.LogInformation("Resolved size option '{SizeCode}' to ID {SizeId}", 
                sizeCode, sizeOption.SizeOptionId);
            return sizeOption.SizeOptionId;
        }

        _logger.LogWarning("Size option not found: {SizeCode}", sizeCode);
        return null;
    }

    public async Task<int?> ResolveDependencyTypeIdAsync(string typeCode)
    {
        if (string.IsNullOrWhiteSpace(typeCode))
            return null;

        var normalizedCode = NormalizeDependencyType(typeCode);
        var cacheKey = $"{CachePrefixDependencyType}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Dependency type ID for '{TypeCode}' retrieved from cache", typeCode);
            return cachedId;
        }

        var dependencyType = await _context.Set<LU_DependencyType>()
            .Where(d => d.IsActive)
            .FirstOrDefaultAsync(d => d.Code.ToUpper() == normalizedCode);

        if (dependencyType != null)
        {
            _cache.Set(cacheKey, dependencyType.DependencyTypeId, CacheExpiration);
            _logger.LogInformation("Resolved dependency type '{TypeCode}' to ID {TypeId}", 
                typeCode, dependencyType.DependencyTypeId);
            return dependencyType.DependencyTypeId;
        }

        _logger.LogWarning("Dependency type not found: {TypeCode}", typeCode);
        return null;
    }

    public async Task<int?> ResolveRequirementLevelIdAsync(string levelCode)
    {
        if (string.IsNullOrWhiteSpace(levelCode))
            return null;

        var normalizedCode = NormalizeRequirementLevel(levelCode);
        var cacheKey = $"{CachePrefixRequirementLevel}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Requirement level ID for '{LevelCode}' retrieved from cache", levelCode);
            return cachedId;
        }

        var requirementLevel = await _context.Set<LU_RequirementLevel>()
            .Where(r => r.IsActive)
            .FirstOrDefaultAsync(r => r.Code.ToUpper() == normalizedCode);

        if (requirementLevel != null)
        {
            _cache.Set(cacheKey, requirementLevel.RequirementLevelId, CacheExpiration);
            _logger.LogInformation("Resolved requirement level '{LevelCode}' to ID {LevelId}", 
                levelCode, requirementLevel.RequirementLevelId);
            return requirementLevel.RequirementLevelId;
        }

        _logger.LogWarning("Requirement level not found: {LevelCode}", levelCode);
        return null;
    }

    public async Task<int?> ResolveRoleIdAsync(string roleCode)
    {
        if (string.IsNullOrWhiteSpace(roleCode))
            return null;

        var normalizedCode = NormalizeRoleCode(roleCode);
        var cacheKey = $"{CachePrefixRole}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Role ID for '{RoleCode}' retrieved from cache", roleCode);
            return cachedId;
        }

        // Try by Code first
        var role = await _context.Set<LU_Role>()
            .Where(r => r.IsActive)
            .FirstOrDefaultAsync(r => r.Code.ToUpper() == normalizedCode);

        // If not found by Code, try by Name
        if (role == null)
        {
            role = await _context.Set<LU_Role>()
                .Where(r => r.IsActive)
                .FirstOrDefaultAsync(r => r.Name.ToUpper() == roleCode.ToUpper());
        }

        if (role != null)
        {
            _cache.Set(cacheKey, role.RoleId, CacheExpiration);
            _logger.LogInformation("Resolved role '{RoleCode}' to ID {RoleId}", 
                roleCode, role.RoleId);
            return role.RoleId;
        }

        _logger.LogWarning("Role not found: {RoleCode}", roleCode);
        return null;
    }

    public async Task<int?> ResolveToolCategoryIdAsync(string categoryName)
    {
        if (string.IsNullOrWhiteSpace(categoryName))
            return null;

        var normalizedName = categoryName.ToLowerInvariant().Trim();
        var cacheKey = $"{CachePrefixToolCategory}{normalizedName}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Tool category ID for '{CategoryName}' retrieved from cache", categoryName);
            return cachedId;
        }

        var toolCategory = await _context.Set<LU_ToolCategory>()
            .Where(t => t.IsActive)
            .FirstOrDefaultAsync(t => t.Name.ToLower() == normalizedName);

        // Try by Code if Name didn't match
        if (toolCategory == null)
        {
            toolCategory = await _context.Set<LU_ToolCategory>()
                .Where(t => t.IsActive)
                .FirstOrDefaultAsync(t => t.Code.ToLower() == normalizedName);
        }

        if (toolCategory != null)
        {
            _cache.Set(cacheKey, toolCategory.ToolCategoryId, CacheExpiration);
            _logger.LogInformation("Resolved tool category '{CategoryName}' to ID {CategoryId}", 
                categoryName, toolCategory.ToolCategoryId);
            return toolCategory.ToolCategoryId;
        }

        _logger.LogWarning("Tool category not found: {CategoryName}", categoryName);
        return null;
    }

    public async Task<int?> ResolveLicenseTypeIdAsync(string typeCode)
    {
        if (string.IsNullOrWhiteSpace(typeCode))
            return null;

        var normalizedCode = NormalizeLicenseType(typeCode);
        var cacheKey = $"{CachePrefixLicenseType}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("License type ID for '{TypeCode}' retrieved from cache", typeCode);
            return cachedId;
        }

        var licenseType = await _context.Set<LU_LicenseType>()
            .Where(l => l.IsActive)
            .FirstOrDefaultAsync(l => l.Code.ToUpper() == normalizedCode);

        if (licenseType != null)
        {
            _cache.Set(cacheKey, licenseType.LicenseTypeId, CacheExpiration);
            _logger.LogInformation("Resolved license type '{TypeCode}' to ID {TypeId}", 
                typeCode, licenseType.LicenseTypeId);
            return licenseType.LicenseTypeId;
        }

        _logger.LogWarning("License type not found: {TypeCode}", typeCode);
        return null;
    }

    public async Task<int?> ResolveInteractionLevelIdAsync(string levelCode)
    {
        if (string.IsNullOrWhiteSpace(levelCode))
            return null;

        var normalizedCode = levelCode.ToUpper().Trim();
        var cacheKey = $"{CachePrefixInteractionLevel}{normalizedCode}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Interaction level ID for '{LevelCode}' retrieved from cache", levelCode);
            return cachedId;
        }

        var interactionLevel = await _context.Set<LU_InteractionLevel>()
            .Where(i => i.IsActive)
            .FirstOrDefaultAsync(i => i.Code.ToUpper() == normalizedCode);

        if (interactionLevel != null)
        {
            _cache.Set(cacheKey, interactionLevel.InteractionLevelId, CacheExpiration);
            _logger.LogInformation("Resolved interaction level '{LevelCode}' to ID {LevelId}", 
                levelCode, interactionLevel.InteractionLevelId);
            return interactionLevel.InteractionLevelId;
        }

        _logger.LogWarning("Interaction level not found: {LevelCode}", levelCode);
        return null;
    }

    public async Task<int?> ResolvePrerequisiteCategoryIdAsync(string categoryName)
    {
        if (string.IsNullOrWhiteSpace(categoryName))
            return null;

        var normalizedName = NormalizePrerequisiteCategory(categoryName);
        var cacheKey = $"{CachePrefixPrerequisiteCategory}{normalizedName}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Prerequisite category ID for '{CategoryName}' retrieved from cache", categoryName);
            return cachedId;
        }

        var category = await _context.Set<LU_PrerequisiteCategory>()
            .Where(p => p.IsActive)
            .FirstOrDefaultAsync(p => p.Code.ToUpper() == normalizedName);

        // Try by Name if Code didn't match
        if (category == null)
        {
            category = await _context.Set<LU_PrerequisiteCategory>()
                .Where(p => p.IsActive)
                .FirstOrDefaultAsync(p => p.Name.ToUpper() == normalizedName);
        }

        if (category != null)
        {
            _cache.Set(cacheKey, category.PrerequisiteCategoryId, CacheExpiration);
            _logger.LogInformation("Resolved prerequisite category '{CategoryName}' to ID {CategoryId}", 
                categoryName, category.PrerequisiteCategoryId);
            return category.PrerequisiteCategoryId;
        }

        _logger.LogWarning("Prerequisite category not found: {CategoryName}", categoryName);
        return null;
    }

    public async Task<int?> ResolveScopeTypeIdAsync(string typeName)
    {
        if (string.IsNullOrWhiteSpace(typeName))
            return null;

        var normalizedName = typeName.ToUpper().Trim();
        var cacheKey = $"{CachePrefixScopeType}{normalizedName}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Scope type ID for '{TypeName}' retrieved from cache", typeName);
            return cachedId;
        }

        var scopeType = await _context.Set<LU_ScopeType>()
            .Where(s => s.IsActive)
            .FirstOrDefaultAsync(s => s.Code.ToUpper() == normalizedName || s.Name.ToUpper() == normalizedName);

        if (scopeType != null)
        {
            _cache.Set(cacheKey, scopeType.ScopeTypeId, CacheExpiration);
            _logger.LogInformation("Resolved scope type '{TypeName}' to ID {TypeId}", 
                typeName, scopeType.ScopeTypeId);
            return scopeType.ScopeTypeId;
        }

        _logger.LogWarning("Scope type not found: {TypeName}", typeName);
        return null;
    }

    public async Task<int?> ResolveCloudProviderIdAsync(string providerName)
    {
        if (string.IsNullOrWhiteSpace(providerName))
            return null;

        var normalizedName = providerName.ToLowerInvariant().Trim();
        var cacheKey = $"{CachePrefixCloudProvider}{normalizedName}";

        if (_cache.TryGetValue<int>(cacheKey, out var cachedId))
        {
            _logger.LogDebug("Cloud provider ID for '{ProviderName}' retrieved from cache", providerName);
            return cachedId;
        }

        var provider = await _context.Set<LU_CloudProvider>()
            .Where(c => c.IsActive)
            .FirstOrDefaultAsync(c => c.Name.ToLower() == normalizedName || c.Code.ToLower() == normalizedName);

        if (provider != null)
        {
            _cache.Set(cacheKey, provider.CloudProviderId, CacheExpiration);
            _logger.LogInformation("Resolved cloud provider '{ProviderName}' to ID {ProviderId}", 
                providerName, provider.CloudProviderId);
            return provider.CloudProviderId;
        }

        _logger.LogWarning("Cloud provider not found: {ProviderName}", providerName);
        return null;
    }

    #region Normalization Helpers

    private static string NormalizeSizeCode(string sizeCode)
    {
        // S, M, L, XL, XXL
        return sizeCode.ToUpper().Trim();
    }

    private static string NormalizeDependencyType(string typeCode)
    {
        // Handle variations: "Prerequisite" → "PREREQUISITE", "Triggers for" → "TRIGGERS_FOR"
        var normalized = typeCode.ToUpper().Trim()
            .Replace(" ", "_")
            .Replace("-", "_");

        return normalized switch
        {
            "PREREQUISITE" => "PREREQUISITE",
            "TRIGGERS_FOR" => "TRIGGERS_FOR",
            "TRIGGERSFOR" => "TRIGGERS_FOR",
            "TRIGGERS" => "TRIGGERS_FOR",
            "PARALLEL_WITH" => "PARALLEL_WITH",
            "PARALLELWITH" => "PARALLEL_WITH",
            "PARALLEL" => "PARALLEL_WITH",
            _ => normalized
        };
    }

    private static string NormalizeRequirementLevel(string levelCode)
    {
        // REQUIRED, RECOMMENDED, OPTIONAL
        return levelCode.ToUpper().Trim();
    }

    private static string NormalizeRoleCode(string roleCode)
    {
        // Normalize spaces and special characters
        return roleCode.ToUpper().Trim()
            .Replace("  ", " ")
            .Replace("-", "_");
    }

    private static string NormalizeLicenseType(string typeCode)
    {
        // REQUIRED, RECOMMENDED, OPTIONAL, PROVIDED
        return typeCode.ToUpper().Trim();
    }

    private static string NormalizePrerequisiteCategory(string categoryName)
    {
        // ORGANIZATIONAL, TECHNICAL, DOCUMENTATION
        var normalized = categoryName.ToUpper().Trim();
        
        return normalized switch
        {
            "ORGANIZATIONAL" => "ORGANIZATIONAL",
            "TECHNICAL" => "TECHNICAL",
            "DOCUMENTATION" => "DOCUMENTATION",
            "ORGANISATIONAL" => "ORGANIZATIONAL", // British spelling
            _ => normalized
        };
    }

    #endregion
}
