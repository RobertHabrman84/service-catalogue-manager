namespace ServiceCatalogueManager.Api.Data.Entities;

public class UsageScenario : BaseEntity, ISortable
{
    public int ScenarioId { get; set; }
    public int ServiceId { get; set; }
    public int ScenarioNumber { get; set; }
    public string ScenarioTitle { get; set; } = string.Empty;
    public string ScenarioDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}
