namespace ServiceCatalogueManager.Api.Data.Entities;

public class EffortEstimationItem : BaseEntity, ISortable
{
    // Primary Key
    public int EstimationItemId { get; set; }
    
    // Foreign Keys
    public int? EstimationId { get; set; }        // ✅ ADDED for DbContext line 292
    public int ServiceId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public int? EffortCategoryId { get; set; }    // ✅ ADDED for navigation
    public int? SizeOptionId { get; set; }        // ✅ ADDED for navigation
    
    // Data Properties
    public string ScopeArea { get; set; } = string.Empty;
    public string? Category { get; set; }
    public int BaseHours { get; set; }
    public int? EstimatedHours { get; set; }
    public decimal? EffortDays { get; set; }      // ✅ ADDED for DbContext line 293
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
    
    // Navigation Properties ✅ ADDED for Repositories & MappingProfile
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual EffortEstimation? Estimation { get; set; }
    public virtual LU_EffortCategory? EffortCategory { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
}
