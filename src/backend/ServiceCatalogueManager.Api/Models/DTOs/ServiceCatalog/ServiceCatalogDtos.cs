namespace ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;

/// <summary>
/// Summary DTO for list views
/// </summary>
public record ServiceCatalogListItemDto
{
    public int ServiceId { get; init; }
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public string CategoryName { get; init; } = string.Empty;
    public int CategoryId { get; init; }
    public string Description { get; init; } = string.Empty;
    public bool IsActive { get; init; }
    public DateTime CreatedDate { get; init; }
    public DateTime ModifiedDate { get; init; }
    public string? CreatedBy { get; init; }
    public string? ModifiedBy { get; init; }
    public int UsageScenariosCount { get; init; }
    public int DependenciesCount { get; init; }
}

/// <summary>
/// Basic DTO for service item (used in create/update responses)
/// </summary>
public record ServiceCatalogItemDto
{
    public int ServiceId { get; init; }
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public int CategoryId { get; init; }
    public string? CategoryName { get; init; }
    public string Description { get; init; } = string.Empty;
    public string? Notes { get; init; }
    public bool IsActive { get; init; }
    public DateTime CreatedDate { get; init; }
    public DateTime ModifiedDate { get; init; }
    public string? CreatedBy { get; init; }
    public string? ModifiedBy { get; init; }
}

/// <summary>
/// Full DTO with all details
/// </summary>
public record ServiceCatalogFullDto
{
    public int ServiceId { get; init; }
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public int CategoryId { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public string? Notes { get; init; }
    public bool IsActive { get; init; }
    public DateTime CreatedDate { get; init; }
    public DateTime ModifiedDate { get; init; }
    public string? CreatedBy { get; init; }
    public string? ModifiedBy { get; init; }

    // Related collections
    public ICollection<UsageScenarioDto> UsageScenarios { get; init; } = new List<UsageScenarioDto>();
    public ICollection<ServiceDependencyDto> Dependencies { get; init; } = new List<ServiceDependencyDto>();
    public ICollection<ServiceScopeCategoryDto> ScopeCategories { get; init; } = new List<ServiceScopeCategoryDto>();
    public ICollection<ServicePrerequisiteDto> Prerequisites { get; init; } = new List<ServicePrerequisiteDto>();
    public ICollection<ServiceInputDto> Inputs { get; init; } = new List<ServiceInputDto>();
    public ICollection<ServiceOutputCategoryDto> OutputCategories { get; init; } = new List<ServiceOutputCategoryDto>();
    public ICollection<TimelinePhaseDto> TimelinePhases { get; init; } = new List<TimelinePhaseDto>();
    public ICollection<ServiceSizeOptionDto> SizeOptions { get; init; } = new List<ServiceSizeOptionDto>();
    public ICollection<EffortEstimationItemDto> EffortEstimations { get; init; } = new List<EffortEstimationItemDto>();
    public ICollection<ServiceResponsibleRoleDto> ResponsibleRoles { get; init; } = new List<ServiceResponsibleRoleDto>();
    public ICollection<ServiceTeamAllocationDto> TeamAllocations { get; init; } = new List<ServiceTeamAllocationDto>();
    public ICollection<ServiceMultiCloudConsiderationDto> MultiCloudConsiderations { get; init; } = new List<ServiceMultiCloudConsiderationDto>();
    public ICollection<SizingExampleDto> SizingExamples { get; init; } = new List<SizingExampleDto>();
    public ServiceInteractionDto? Interaction { get; init; }
}

/// <summary>
/// DTO for creating/updating service
/// </summary>
public record ServiceCatalogCreateDto
{
    public string ServiceCode { get; init; } = string.Empty;
    public string ServiceName { get; init; } = string.Empty;
    public string Version { get; init; } = "v1.0";
    public int CategoryId { get; init; }
    public string Description { get; init; } = string.Empty;
    public string? Notes { get; init; }
    public bool IsActive { get; init; } = true;

    public ICollection<UsageScenarioDto> UsageScenarios { get; init; } = new List<UsageScenarioDto>();
    public ICollection<ServiceDependencyDto> Dependencies { get; init; } = new List<ServiceDependencyDto>();
    public ICollection<ServiceScopeCategoryDto> ScopeCategories { get; init; } = new List<ServiceScopeCategoryDto>();
    public ICollection<ServicePrerequisiteDto> Prerequisites { get; init; } = new List<ServicePrerequisiteDto>();
    public ICollection<ServiceInputDto> Inputs { get; init; } = new List<ServiceInputDto>();
    public ICollection<ServiceOutputCategoryDto> OutputCategories { get; init; } = new List<ServiceOutputCategoryDto>();
    public ICollection<TimelinePhaseDto> TimelinePhases { get; init; } = new List<TimelinePhaseDto>();
    public ICollection<ServiceSizeOptionDto> SizeOptions { get; init; } = new List<ServiceSizeOptionDto>();
    public ICollection<EffortEstimationItemDto> EffortEstimations { get; init; } = new List<EffortEstimationItemDto>();
    public ICollection<ServiceResponsibleRoleDto> ResponsibleRoles { get; init; } = new List<ServiceResponsibleRoleDto>();
    public ICollection<ServiceTeamAllocationDto> TeamAllocations { get; init; } = new List<ServiceTeamAllocationDto>();
    public ICollection<ServiceMultiCloudConsiderationDto> MultiCloudConsiderations { get; init; } = new List<ServiceMultiCloudConsiderationDto>();
    public ICollection<SizingExampleDto> SizingExamples { get; init; } = new List<SizingExampleDto>();
    public ServiceInteractionDto? Interaction { get; init; }
}

public record ServiceCatalogUpdateDto : ServiceCatalogCreateDto
{
    public int ServiceId { get; init; }
}

// Related DTOs
public record UsageScenarioDto
{
    public int? ScenarioId { get; init; }
    public int ScenarioNumber { get; init; }
    public string ScenarioTitle { get; init; } = string.Empty;
    public string ScenarioDescription { get; init; } = string.Empty;
    public int SortOrder { get; init; }
}

public record ServiceDependencyDto
{
    public int? DependencyId { get; init; }
    public int DependencyTypeId { get; init; }
    public string? DependencyTypeName { get; init; }
    public int? DependentServiceId { get; init; }
    public string? DependentServiceName { get; init; }
    public int? RequirementLevelId { get; init; }
    public string? RequirementLevelName { get; init; }
    public string? Notes { get; init; }
    public int SortOrder { get; init; }
}

public record ServiceScopeCategoryDto
{
    public int? ScopeCategoryId { get; init; }
    public int ScopeTypeId { get; init; }
    public string? ScopeTypeName { get; init; }
    public string? CategoryNumber { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public int SortOrder { get; init; }
    public ICollection<ServiceScopeItemDto> Items { get; init; } = new List<ServiceScopeItemDto>();
}

public record ServiceScopeItemDto
{
    public int? ScopeItemId { get; init; }
    public string ItemDescription { get; init; } = string.Empty;
    public int SortOrder { get; init; }
}

public record ServicePrerequisiteDto
{
    public int? PrerequisiteId { get; init; }
    public int PrerequisiteCategoryId { get; init; }
    public string? PrerequisiteCategoryName { get; init; }
    public string PrerequisiteDescription { get; init; } = string.Empty;
    public int SortOrder { get; init; }
}

public record ServiceInputDto
{
    public int? InputId { get; init; }
    public string InputName { get; init; } = string.Empty;
    public string? InputDescription { get; init; }
    public bool IsRequired { get; init; }
    public int SortOrder { get; init; }
}

public record ServiceOutputCategoryDto
{
    public int? OutputCategoryId { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public int SortOrder { get; init; }
    public ICollection<ServiceOutputItemDto> Items { get; init; } = new List<ServiceOutputItemDto>();
}

public record ServiceOutputItemDto
{
    public int? OutputItemId { get; init; }
    public string ItemName { get; init; } = string.Empty;
    public string? ItemDescription { get; init; }
    public int SortOrder { get; init; }
}

public record TimelinePhaseDto
{
    public int? PhaseId { get; init; }
    public string PhaseName { get; init; } = string.Empty;
    public string? PhaseDescription { get; init; }
    public int SortOrder { get; init; }
    public ICollection<TimelinePhaseDurationDto> Durations { get; init; } = new List<TimelinePhaseDurationDto>();
}

public record TimelinePhaseDurationDto
{
    public int? DurationId { get; init; }
    public int SizeOptionId { get; init; }
    public string? SizeOptionCode { get; init; }
    public int DurationDays { get; init; }
}

public record ServiceSizeOptionDto
{
    public int? ServiceSizeId { get; init; }
    public int SizeOptionId { get; init; }
    public string? SizeCode { get; init; }
    public string? SizeName { get; init; }
    public string? ScopeDescription { get; init; }
    public int SortOrder { get; init; }
}

public record EffortEstimationItemDto
{
    public int? EstimationId { get; init; }
    public int EffortCategoryId { get; init; }
    public string? EffortCategoryName { get; init; }
    public int SizeOptionId { get; init; }
    public string? SizeOptionCode { get; init; }
    public decimal EffortDays { get; init; }
    public string? Notes { get; init; }
}

public record ServiceResponsibleRoleDto
{
    public int? ResponsibleRoleId { get; init; }
    public int RoleId { get; init; }
    public string? RoleName { get; init; }
    public bool IsPrimary { get; init; }
    public string? Responsibilities { get; init; }
    public int SortOrder { get; init; }
}

public record ServiceTeamAllocationDto
{
    public int? AllocationId { get; init; }
    public int RoleId { get; init; }
    public string? RoleName { get; init; }
    public int SizeOptionId { get; init; }
    public string? SizeOptionCode { get; init; }
    public decimal AllocationPercentage { get; init; }
}

public record ServiceMultiCloudConsiderationDto
{
    public int? ConsiderationId { get; init; }
    public int CloudProviderId { get; init; }
    public string? CloudProviderName { get; init; }
    public string? Considerations { get; init; }
    public string? Limitations { get; init; }
    public int SortOrder { get; init; }
}

public record SizingExampleDto
{
    public int? ExampleId { get; init; }
    public int SizeOptionId { get; init; }
    public string? SizeOptionCode { get; init; }
    public string ExampleName { get; init; } = string.Empty;
    public string? ExampleDescription { get; init; }
    public int SortOrder { get; init; }
}

public record ServiceInteractionDto
{
    public int? InteractionId { get; init; }
    public int InteractionLevelId { get; init; }
    public string? InteractionLevelName { get; init; }
    public ICollection<CustomerRequirementDto> CustomerRequirements { get; init; } = new List<CustomerRequirementDto>();
    public ICollection<AccessRequirementDto> AccessRequirements { get; init; } = new List<AccessRequirementDto>();
    public ICollection<StakeholderInvolvementDto> StakeholderInvolvements { get; init; } = new List<StakeholderInvolvementDto>();
}

public record CustomerRequirementDto
{
    public int? RequirementId { get; init; }
    public string RequirementDescription { get; init; } = string.Empty;
    public int SortOrder { get; init; }
}

public record AccessRequirementDto
{
    public int? AccessId { get; init; }
    public string AccessDescription { get; init; } = string.Empty;
    public int SortOrder { get; init; }
}

public record StakeholderInvolvementDto
{
    public int? InvolvementId { get; init; }
    public string StakeholderRole { get; init; } = string.Empty;
    public string? InvolvementDescription { get; init; }
    public int SortOrder { get; init; }
}
