namespace ServiceCatalogueManager.Api.Models.DTOs.Lookup;

/// <summary>
/// Base lookup DTO
/// </summary>
public record LookupItemDto
{
    public int Id { get; init; }
    public string Code { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? Description { get; init; }
    public int SortOrder { get; init; }
    public bool IsActive { get; init; }
}

/// <summary>
/// Service category with hierarchy
/// </summary>
public record ServiceCategoryDto : LookupItemDto
{
    public int? ParentCategoryId { get; init; }
    public string? ParentCategoryName { get; init; }
    public string? CategoryPath { get; init; }
    public int Level { get; init; }
    public ICollection<ServiceCategoryDto> Children { get; init; } = new List<ServiceCategoryDto>();
}

/// <summary>
/// Size option (S, M, L, XL)
/// </summary>
public record SizeOptionDto : LookupItemDto
{
    public string? ColorCode { get; init; }
}

/// <summary>
/// Cloud provider
/// </summary>
public record CloudProviderDto : LookupItemDto
{
    public string? LogoUrl { get; init; }
}

/// <summary>
/// Dependency type
/// </summary>
public record DependencyTypeDto : LookupItemDto;

/// <summary>
/// Requirement level
/// </summary>
public record RequirementLevelDto : LookupItemDto;

/// <summary>
/// Scope type (In Scope / Out of Scope)
/// </summary>
public record ScopeTypeDto : LookupItemDto;

/// <summary>
/// Interaction level
/// </summary>
public record InteractionLevelDto : LookupItemDto;

/// <summary>
/// Prerequisite category
/// </summary>
public record PrerequisiteCategoryDto : LookupItemDto;

/// <summary>
/// Tool category
/// </summary>
public record ToolCategoryDto : LookupItemDto;

/// <summary>
/// License type
/// </summary>
public record LicenseTypeDto : LookupItemDto;

/// <summary>
/// Role
/// </summary>
public record RoleDto : LookupItemDto;

/// <summary>
/// Effort category
/// </summary>
public record EffortCategoryDto : LookupItemDto;

/// <summary>
/// All lookups combined
/// </summary>
public record AllLookupsDto
{
    public ICollection<ServiceCategoryDto> Categories { get; init; } = new List<ServiceCategoryDto>();
    public ICollection<SizeOptionDto> SizeOptions { get; init; } = new List<SizeOptionDto>();
    public ICollection<CloudProviderDto> CloudProviders { get; init; } = new List<CloudProviderDto>();
    public ICollection<DependencyTypeDto> DependencyTypes { get; init; } = new List<DependencyTypeDto>();
    public ICollection<RequirementLevelDto> RequirementLevels { get; init; } = new List<RequirementLevelDto>();
    public ICollection<ScopeTypeDto> ScopeTypes { get; init; } = new List<ScopeTypeDto>();
    public ICollection<InteractionLevelDto> InteractionLevels { get; init; } = new List<InteractionLevelDto>();
    public ICollection<PrerequisiteCategoryDto> PrerequisiteCategories { get; init; } = new List<PrerequisiteCategoryDto>();
    public ICollection<ToolCategoryDto> ToolCategories { get; init; } = new List<ToolCategoryDto>();
    public ICollection<LicenseTypeDto> LicenseTypes { get; init; } = new List<LicenseTypeDto>();
    public ICollection<RoleDto> Roles { get; init; } = new List<RoleDto>();
    public ICollection<EffortCategoryDto> EffortCategories { get; init; } = new List<EffortCategoryDto>();
}
