namespace ServiceCatalogueManager.Api.Data.Entities;

/// <summary>
/// Pricing configuration for a service
/// </summary>
public class ServicePricingConfig : BaseEntity
{
    public int PricingConfigId { get; set; }
    public int ServiceId { get; set; }
    public decimal Margin { get; set; } = 15;
    public decimal RiskPremium { get; set; } = 5;
    public decimal Contingency { get; set; } = 5;
    public decimal Discount { get; set; } = 0;
    public int HoursPerDay { get; set; } = 8;
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Role rates for pricing calculation
/// </summary>
public class ServiceRoleRate : BaseEntity, ISortable
{
    public int RoleRateId { get; set; }
    public int ServiceId { get; set; }
    public string RoleCode { get; set; } = string.Empty;
    public string RoleName { get; set; } = string.Empty;
    public decimal DailyRate { get; set; }
    public bool IsPrimary { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Base effort configuration (kickoff, discovery, handover)
/// </summary>
public class ServiceBaseEffort : BaseEntity, ISortable
{
    public int BaseEffortId { get; set; }
    public int ServiceId { get; set; }
    public string EffortCode { get; set; } = string.Empty; // kickoff, discovery, handover
    public string Label { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Hours { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Context multipliers that affect effort calculation
/// </summary>
public class ServiceContextMultiplier : BaseEntity, ISortable
{
    public int MultiplierId { get; set; }
    public int ServiceId { get; set; }
    public string MultiplierCode { get; set; } = string.Empty;
    public string MultiplierName { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<ServiceContextMultiplierValue> Values { get; set; } = new List<ServiceContextMultiplierValue>();
}

/// <summary>
/// Values for context multipliers
/// </summary>
public class ServiceContextMultiplierValue : BaseEntity, ISortable
{
    public int ValueId { get; set; }
    public int MultiplierId { get; set; }
    public string ValueCode { get; set; } = string.Empty;
    public string ValueLabel { get; set; } = string.Empty;
    public decimal MultiplierValue { get; set; } // e.g., 0.15, -0.10
    public int SortOrder { get; set; }
    public virtual ServiceContextMultiplier? Multiplier { get; set; }
}

/// <summary>
/// Scope areas with hours for calculator
/// </summary>
public class ServiceScopeArea : BaseEntity, ISortable
{
    public int ScopeAreaId { get; set; }
    public int ServiceId { get; set; }
    public string AreaCode { get; set; } = string.Empty;
    public string AreaName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Category { get; set; }
    public int Hours { get; set; }
    public bool IsRequired { get; set; }
    public string? RequiresAreaCodes { get; set; } // Comma-separated list of required area codes
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Compliance/complexity factors for calculator
/// </summary>
public class ServiceComplianceFactor : BaseEntity, ISortable
{
    public int FactorId { get; set; }
    public int ServiceId { get; set; }
    public string FactorCode { get; set; } = string.Empty;
    public string FactorLabel { get; set; } = string.Empty;
    public int Hours { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Parameter sections for calculator configuration
/// </summary>
public class ServiceCalculatorSection : BaseEntity, ISortable
{
    public int SectionId { get; set; }
    public int ServiceId { get; set; }
    public string SectionCode { get; set; } = string.Empty;
    public string SectionLabel { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<ServiceCalculatorGroup> Groups { get; set; } = new List<ServiceCalculatorGroup>();
}

/// <summary>
/// Parameter groups within a section
/// </summary>
public class ServiceCalculatorGroup : BaseEntity, ISortable
{
    public int GroupId { get; set; }
    public int SectionId { get; set; }
    public string GroupTitle { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceCalculatorSection? Section { get; set; }
    public virtual ICollection<ServiceCalculatorParameter> Parameters { get; set; } = new List<ServiceCalculatorParameter>();
}

/// <summary>
/// Calculator parameters with options
/// </summary>
public class ServiceCalculatorParameter : BaseEntity, ISortable
{
    public int ParameterId { get; set; }
    public int GroupId { get; set; }
    public string ParameterCode { get; set; } = string.Empty;
    public string ParameterLabel { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public string? DefaultValue { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCalculatorGroup? Group { get; set; }
    public virtual ICollection<ServiceCalculatorParameterOption> Options { get; set; } = new List<ServiceCalculatorParameterOption>();
}

/// <summary>
/// Options for calculator parameters
/// </summary>
public class ServiceCalculatorParameterOption : BaseEntity, ISortable
{
    public int OptionId { get; set; }
    public int ParameterId { get; set; }
    public string OptionValue { get; set; } = string.Empty;
    public string OptionLabel { get; set; } = string.Empty;
    public string? SizeImpact { get; set; } // S, M, L
    public int? ComplexityHours { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCalculatorParameter? Parameter { get; set; }
}

/// <summary>
/// Predefined scenarios for calculator
/// </summary>
public class ServiceCalculatorScenario : BaseEntity, ISortable
{
    public int ScenarioId { get; set; }
    public int ServiceId { get; set; }
    public string ScenarioCode { get; set; } = string.Empty;
    public string ScenarioName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ParameterValuesJson { get; set; } // JSON object with parameter values
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Project phases with duration by size
/// </summary>
public class ServiceCalculatorPhase : BaseEntity, ISortable
{
    public int PhaseId { get; set; }
    public int ServiceId { get; set; }
    public string PhaseCode { get; set; } = string.Empty;
    public string PhaseName { get; set; } = string.Empty;
    public string? DurationSmall { get; set; }
    public string? DurationMedium { get; set; }
    public string? DurationLarge { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Team composition by size (S, M, L)
/// </summary>
public class ServiceTeamComposition : BaseEntity, ISortable
{
    public int CompositionId { get; set; }
    public int ServiceId { get; set; }
    public string SizeCode { get; set; } = string.Empty; // S, M, L
    public string RoleCode { get; set; } = string.Empty;
    public decimal FteAllocation { get; set; } // e.g., 0.8, 1.0
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}

/// <summary>
/// Sizing criteria descriptions (S, M, L effort and duration)
/// </summary>
public class ServiceSizingCriteria : BaseEntity
{
    public int SizingCriteriaId { get; set; }
    public int ServiceId { get; set; }
    public string SizeCode { get; set; } = string.Empty; // S, M, L
    public string? Duration { get; set; } // e.g., "2-3 weeks"
    public string? Effort { get; set; } // e.g., "40-60 hours"
    public string? Description { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
}
