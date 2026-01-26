namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceInput : BaseEntity, ISortable
{
    public int InputId { get; set; }
    public int ServiceId { get; set; }
    public string InputName { get; set; } = string.Empty;
    public string ParameterName { get; set; } = string.Empty;
    public string ParameterDescription { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int RequirementLevelId { get; set; }
    public string? DataType { get; set; }
    public string? DefaultValue { get; set; }
    public string? ExampleValue { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_RequirementLevel? RequirementLevel { get; set; }
}
