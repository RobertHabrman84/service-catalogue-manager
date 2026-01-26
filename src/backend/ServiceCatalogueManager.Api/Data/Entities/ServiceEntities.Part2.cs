namespace ServiceCatalogueManager.Api.Data.Entities;

public class SizingExample : BaseEntity, ISortable
{
    public int ExampleId { get; set; }
    public int ServiceId { get; set; }
    public int SizeOptionId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public int ExampleNumber { get; set; }
    public string ExampleTitle { get; set; } = string.Empty;
    public string ExampleName => ExampleTitle;
    public string? Description { get; set; }
    public string? Scenario { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
    public virtual ICollection<SizingExampleCharacteristic> Characteristics { get; set; } = new List<SizingExampleCharacteristic>();
}

public class SizingExampleCharacteristic : BaseEntity, ISortable
{
    public int CharacteristicId { get; set; }
    public int ExampleId { get; set; }
    public string CharacteristicDescription { get; set; } = string.Empty;
    public string? Characteristic { get; set; }
    public int SortOrder { get; set; }
    public virtual SizingExample? Example { get; set; }
}

public class ScopeDependency : BaseEntity, ISortable
{
    public int DependencyId { get; set; }
    public int ScopeDependencyId { get; set; }
    public int ServiceId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public string DependencyDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

public class SizingParameter : BaseEntity, ISortable
{
    public int ParameterId { get; set; }
    public int ServiceId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public string ParameterCategory { get; set; } = string.Empty;
    public string ParameterName { get; set; } = string.Empty;
    public string? Value { get; set; }
    public string? Unit { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<SizingParameterValue> Values { get; set; } = new List<SizingParameterValue>();
}

public class SizingCriteria : BaseEntity, ISortable
{
    public int CriteriaId { get; set; }
    public int ServiceId { get; set; }
    public int? ServiceSizeOptionId { get; set; }
    public string CriteriaName { get; set; } = string.Empty;
    public string? Criteria { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<SizingCriteriaValue> Values { get; set; } = new List<SizingCriteriaValue>();
}

public class ServiceMultiCloudConsideration : BaseEntity, ISortable
{
    public int ConsiderationId { get; set; }
    public int ServiceId { get; set; }
    public string ConsiderationTitle { get; set; } = string.Empty;
    public string? ConsiderationDescription { get; set; }
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

public class CloudProviderCapability : BaseEntity, ISortable
{
    public int CapabilityId { get; set; }
    public int ServiceId { get; set; }
    public int CloudProviderId { get; set; }
    public string CapabilityType { get; set; } = string.Empty;
    public string CapabilityName { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_CloudProvider? CloudProvider { get; set; }
}
