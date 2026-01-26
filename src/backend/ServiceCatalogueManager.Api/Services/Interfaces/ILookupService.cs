using ServiceCatalogueManager.Api.Models.DTOs.Lookup;

namespace ServiceCatalogueManager.Api.Services.Interfaces;

/// <summary>
/// Service for managing lookup data
/// </summary>
public interface ILookupService
{
    Task<AllLookupsDto> GetAllLookupsAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<ServiceCategoryDto>> GetCategoriesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<SizeOptionDto>> GetSizeOptionsAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<CloudProviderDto>> GetCloudProvidersAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<DependencyTypeDto>> GetDependencyTypesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<PrerequisiteCategoryDto>> GetPrerequisiteCategoriesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<LicenseTypeDto>> GetLicenseTypesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<ToolCategoryDto>> GetToolCategoriesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<ScopeTypeDto>> GetScopeTypesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<InteractionLevelDto>> GetInteractionLevelsAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<RequirementLevelDto>> GetRequirementLevelsAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<RoleDto>> GetRolesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<EffortCategoryDto>> GetEffortCategoriesAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<object>> GetServicesListAsync(CancellationToken cancellationToken = default);
}
