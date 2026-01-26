namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServicePrerequisite : BaseEntity, ISortable
{
    public int PrerequisiteId { get; set; }
    public int ServiceId { get; set; }
    public int PrerequisiteCategoryId { get; set; }
    public string PrerequisiteName { get; set; } = string.Empty;
    public string PrerequisiteDescription { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? RequirementLevelId { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_PrerequisiteCategory? PrerequisiteCategory { get; set; }
}
