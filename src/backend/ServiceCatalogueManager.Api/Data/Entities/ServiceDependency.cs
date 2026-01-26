namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceDependency : BaseEntity
{
    public int DependencyId { get; set; }
    public int ServiceId { get; set; }
    public int DependencyTypeId { get; set; }
    public string DependencyName { get; set; } = string.Empty;
    public string DependencyDescription { get; set; } = string.Empty;
    public int? RelatedServiceId { get; set; }
    public string? DependentServiceCode { get; set; }
    public string? DependentServiceName { get; set; }
    public int? RequirementLevelId { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_DependencyType? DependencyType { get; set; }
    public virtual ServiceCatalogItem? RelatedService { get; set; }
    public virtual ServiceCatalogItem? DependentService => RelatedService;
    public virtual LU_RequirementLevel? RequirementLevel { get; set; }
}
