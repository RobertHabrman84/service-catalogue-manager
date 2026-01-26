using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Models.DTOs.Lookup;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Lookup service implementation with caching
/// </summary>
public class LookupService : ILookupService
{
    private readonly ServiceCatalogDbContext _dbContext;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;
    private readonly ILogger<LookupService> _logger;
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(30);

    public LookupService(
        ServiceCatalogDbContext dbContext,
        IMapper mapper,
        IMemoryCache cache,
        ILogger<LookupService> logger)
    {
        _dbContext = dbContext;
        _mapper = mapper;
        _cache = cache;
        _logger = logger;
    }

    public async Task<AllLookupsDto> GetAllLookupsAsync(CancellationToken cancellationToken = default)
    {
        const string cacheKey = "all_lookups";

        if (_cache.TryGetValue(cacheKey, out AllLookupsDto? cached) && cached != null)
        {
            _logger.LogDebug("Returning cached lookups");
            return cached;
        }

        _logger.LogInformation("Loading all lookups from database");

        var lookups = new AllLookupsDto
        {
            Categories = (await GetCategoriesAsync(cancellationToken)).ToList(),
            SizeOptions = (await GetSizeOptionsAsync(cancellationToken)).ToList(),
            CloudProviders = (await GetCloudProvidersAsync(cancellationToken)).ToList(),
            DependencyTypes = (await GetDependencyTypesAsync(cancellationToken)).ToList(),
            RequirementLevels = (await GetRequirementLevelsAsync(cancellationToken)).ToList(),
            ScopeTypes = (await GetScopeTypesAsync(cancellationToken)).ToList(),
            InteractionLevels = (await GetInteractionLevelsAsync(cancellationToken)).ToList(),
            PrerequisiteCategories = (await GetPrerequisiteCategoriesAsync(cancellationToken)).ToList(),
            ToolCategories = (await GetToolCategoriesAsync(cancellationToken)).ToList(),
            LicenseTypes = (await GetLicenseTypesAsync(cancellationToken)).ToList(),
            Roles = (await GetRolesAsync(cancellationToken)).ToList(),
            EffortCategories = (await GetEffortCategoriesAsync(cancellationToken)).ToList()
        };

        _cache.Set(cacheKey, lookups, CacheDuration);
        return lookups;
    }

    public async Task<IEnumerable<ServiceCategoryDto>> GetCategoriesAsync(CancellationToken cancellationToken = default)
    {
        var categories = await _dbContext.LU_ServiceCategories
            .Include(c => c.ParentCategory)
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<ServiceCategoryDto>>(categories);
    }

    public async Task<IEnumerable<SizeOptionDto>> GetSizeOptionsAsync(CancellationToken cancellationToken = default)
    {
        var options = await _dbContext.LU_SizeOptions
            .Where(o => o.IsActive)
            .OrderBy(o => o.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<SizeOptionDto>>(options);
    }

    public async Task<IEnumerable<CloudProviderDto>> GetCloudProvidersAsync(CancellationToken cancellationToken = default)
    {
        var providers = await _dbContext.LU_CloudProviders
            .Where(p => p.IsActive)
            .OrderBy(p => p.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<CloudProviderDto>>(providers);
    }

    public async Task<IEnumerable<DependencyTypeDto>> GetDependencyTypesAsync(CancellationToken cancellationToken = default)
    {
        var types = await _dbContext.LU_DependencyTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<DependencyTypeDto>>(types);
    }

    public async Task<IEnumerable<RequirementLevelDto>> GetRequirementLevelsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _dbContext.LU_RequirementLevels
            .Where(l => l.IsActive)
            .OrderBy(l => l.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<RequirementLevelDto>>(levels);
    }

    public async Task<IEnumerable<ScopeTypeDto>> GetScopeTypesAsync(CancellationToken cancellationToken = default)
    {
        var types = await _dbContext.LU_ScopeTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<ScopeTypeDto>>(types);
    }

    public async Task<IEnumerable<InteractionLevelDto>> GetInteractionLevelsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _dbContext.LU_InteractionLevels
            .Where(l => l.IsActive)
            .OrderBy(l => l.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<InteractionLevelDto>>(levels);
    }

    public async Task<IEnumerable<PrerequisiteCategoryDto>> GetPrerequisiteCategoriesAsync(CancellationToken cancellationToken = default)
    {
        var categories = await _dbContext.LU_PrerequisiteCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<PrerequisiteCategoryDto>>(categories);
    }

    public async Task<IEnumerable<ToolCategoryDto>> GetToolCategoriesAsync(CancellationToken cancellationToken = default)
    {
        var categories = await _dbContext.LU_ToolCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<ToolCategoryDto>>(categories);
    }

    public async Task<IEnumerable<LicenseTypeDto>> GetLicenseTypesAsync(CancellationToken cancellationToken = default)
    {
        var types = await _dbContext.LU_LicenseTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<LicenseTypeDto>>(types);
    }

    public async Task<IEnumerable<RoleDto>> GetRolesAsync(CancellationToken cancellationToken = default)
    {
        var roles = await _dbContext.LU_Roles
            .Where(r => r.IsActive)
            .OrderBy(r => r.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<RoleDto>>(roles);
    }

    public async Task<IEnumerable<EffortCategoryDto>> GetEffortCategoriesAsync(CancellationToken cancellationToken = default)
    {
        var categories = await _dbContext.LU_EffortCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ToListAsync(cancellationToken);

        return _mapper.Map<IEnumerable<EffortCategoryDto>>(categories);
    }

    public async Task<IEnumerable<object>> GetServicesListAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var services = await _dbContext.ServiceCatalogItems
                .Where(s => s.IsActive)
                .Select(s => new
                {
                    s.Id,
                    s.ServiceCode,
                    s.ServiceName,
                    s.Description
                })
                .OrderBy(s => s.ServiceName)
                .ToListAsync(cancellationToken);

            return services;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to get services list from database, returning empty list");
            return Array.Empty<object>();
        }
    }

    public void InvalidateCache()
    {
        _cache.Remove("all_lookups");
        _logger.LogInformation("Lookup cache invalidated");
    }
}
