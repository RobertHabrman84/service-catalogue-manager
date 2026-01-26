namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceScopeItem : BaseEntity, ISortable
{
    public int ScopeItemId { get; set; }
    public int ScopeCategoryId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public string ItemDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceScopeCategory? ScopeCategory { get; set; }
}

public class ServiceToolFramework : BaseEntity, ISortable
{
    public int ToolId { get; set; }
    public int ServiceId { get; set; }
    public int ToolCategoryId { get; set; }
    public string ToolName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_ToolCategory? ToolCategory { get; set; }
}

public class ServiceLicense : BaseEntity, ISortable
{
    public int LicenseId { get; set; }
    public int ServiceId { get; set; }
    public int LicenseTypeId { get; set; }
    public string LicenseName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_LicenseType? LicenseType { get; set; }
}

public class StakeholderInvolvement : BaseEntity, ISortable
{
    public int InvolvementId { get; set; }
    public int ServiceId { get; set; }
    public int? InteractionId { get; set; }
    public string StakeholderRole { get; set; } = string.Empty;
    public string InvolvementType { get; set; } = string.Empty;
    public string InvolvementDescription { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ServiceInteraction? Interaction { get; set; }
}

public class ServiceOutputCategory : BaseEntity, ISortable
{
    public int OutputCategoryId { get; set; }
    public int ServiceId { get; set; }
    public int? CategoryNumber { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<ServiceOutputItem> Items { get; set; } = new List<ServiceOutputItem>();
}

public class ServiceOutputItem : BaseEntity, ISortable
{
    public int OutputItemId { get; set; }
    public int OutputCategoryId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public string ItemDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceOutputCategory? OutputCategory { get; set; }
}

public class ServiceSizeOption : BaseEntity
{
    public int ServiceSizeOptionId { get; set; }
    public int ServiceId { get; set; }
    public int SizeOptionId { get; set; }
    public string? Description { get; set; }
    public string? Duration { get; set; }
    public int? DurationInDays { get; set; }
    public string? EffortRange { get; set; }
    public string? TeamSize { get; set; }
    public string? Complexity { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
}

public class EffortEstimation : BaseEntity
{
    public int EffortEstimationId { get; set; }
    public int ServiceSizeOptionId { get; set; }
    public int? Hours { get; set; }
    public int? HoursMin { get; set; }
    public int? HoursMax { get; set; }
    public virtual ServiceSizeOption? ServiceSizeOption { get; set; }
}

public class TechnicalComplexityAddition : BaseEntity, ISortable
{
    public int ComplexityAdditionId { get; set; }
    public int AdditionId { get; set; }
    public int ServiceId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public string AdditionName { get; set; } = string.Empty;
    public string? Factor { get; set; }
    public string? Condition { get; set; }
    public int AdditionalHours { get; set; }
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

public class ServiceTeamAllocation : BaseEntity
{
    public int TeamAllocationId { get; set; }
    public int ServiceId { get; set; }
    public int SizeOptionId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public decimal? CloudArchitects { get; set; }
    public decimal? SolutionArchitects { get; set; }
    public decimal? TechnicalLeads { get; set; }
    public decimal? Developers { get; set; }
    public decimal? QAEngineers { get; set; }
    public decimal? DevOpsEngineers { get; set; }
    public decimal? SecuritySpecialists { get; set; }
    public decimal? ProjectManagers { get; set; }
    public decimal? BusinessAnalysts { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
}
