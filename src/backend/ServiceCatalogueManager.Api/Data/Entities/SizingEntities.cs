namespace ServiceCatalogueManager.Api.Data.Entities;

public class SizingCriteriaValue : BaseEntity
{
    public int CriteriaValueId { get; set; }
    public int CriteriaId { get; set; }
    public int SizeOptionId { get; set; }
    public string CriteriaValue { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public virtual SizingCriteria? Criteria { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
}

public class SizingParameterValue : BaseEntity, ISortable
{
    public int ParameterValueId { get; set; }
    public int ParameterId { get; set; }
    public string ValueCondition { get; set; } = string.Empty;
    public string? ResultSize { get; set; }
    public int? HoursAdjustment { get; set; }
    public string? AdjustmentDisplay { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
    public virtual SizingParameter? Parameter { get; set; }
}
