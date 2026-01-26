namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceScopeCategory : BaseEntity, ISortable
{
    public int ScopeCategoryId { get; set; }
    public int ServiceId { get; set; }
    public int ScopeTypeId { get; set; }
    public int? CategoryNumber { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_ScopeType? ScopeType { get; set; }
    public virtual ICollection<ServiceScopeItem> Items { get; set; } = new List<ServiceScopeItem>();
}
