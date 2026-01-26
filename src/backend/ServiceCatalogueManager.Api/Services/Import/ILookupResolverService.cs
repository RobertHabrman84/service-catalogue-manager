namespace ServiceCatalogueManager.Api.Services.Import;

/// <summary>
/// Service for resolving lookup table IDs from friendly names
/// </summary>
public interface ILookupResolverService
{
    Task<int?> ResolveCategoryIdAsync(string categoryPath);
    Task<int?> ResolveSizeOptionIdAsync(string sizeCode);
    Task<int?> ResolveDependencyTypeIdAsync(string typeCode);
    Task<int?> ResolveRequirementLevelIdAsync(string levelCode);
    Task<int?> ResolveRoleIdAsync(string roleCode);
    Task<int?> ResolveToolCategoryIdAsync(string categoryName);
    Task<int?> ResolveLicenseTypeIdAsync(string typeCode);
    Task<int?> ResolveInteractionLevelIdAsync(string levelCode);
    Task<int?> ResolvePrerequisiteCategoryIdAsync(string categoryName);
    Task<int?> ResolveScopeTypeIdAsync(string typeName);
    Task<int?> ResolveCloudProviderIdAsync(string providerName);
}
