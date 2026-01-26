namespace ServiceCatalogueManager.Api.Data.Entities;

/// <summary>
/// Main service catalog item entity
/// </summary>
public class ServiceCatalogItem : BaseEntity
{
    public int ServiceId { get; set; }
    public string ServiceCode { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public string Version { get; set; } = "v1.0";
    public int CategoryId { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public virtual LU_ServiceCategory? Category { get; set; }
    public virtual ICollection<UsageScenario> UsageScenarios { get; set; } = new List<UsageScenario>();
    public virtual ICollection<ServiceDependency> Dependencies { get; set; } = new List<ServiceDependency>();
    public virtual ICollection<ServiceScopeCategory> ScopeCategories { get; set; } = new List<ServiceScopeCategory>();
    public virtual ICollection<ServicePrerequisite> Prerequisites { get; set; } = new List<ServicePrerequisite>();
    public virtual ICollection<CloudProviderCapability> CloudCapabilities { get; set; } = new List<CloudProviderCapability>();
    public virtual ICollection<ServiceToolFramework> Tools { get; set; } = new List<ServiceToolFramework>();
    public virtual ICollection<ServiceLicense> Licenses { get; set; } = new List<ServiceLicense>();
    public virtual ServiceInteraction? Interaction { get; set; }
    public virtual ICollection<ServiceInput> Inputs { get; set; } = new List<ServiceInput>();
    public virtual ICollection<ServiceOutputCategory> OutputCategories { get; set; } = new List<ServiceOutputCategory>();
    public virtual ICollection<TimelinePhase> TimelinePhases { get; set; } = new List<TimelinePhase>();
    public virtual ICollection<ServiceSizeOption> SizeOptions { get; set; } = new List<ServiceSizeOption>();
    public virtual ICollection<SizingCriteria> SizingCriteria { get; set; } = new List<SizingCriteria>();
    public virtual ICollection<SizingParameter> SizingParameters { get; set; } = new List<SizingParameter>();
    public virtual ICollection<EffortEstimationItem> EffortEstimations { get; set; } = new List<EffortEstimationItem>();
    public virtual ICollection<TechnicalComplexityAddition> ComplexityAdditions { get; set; } = new List<TechnicalComplexityAddition>();
    public virtual ICollection<ScopeDependency> ScopeDependencies { get; set; } = new List<ScopeDependency>();
    public virtual ICollection<SizingExample> SizingExamples { get; set; } = new List<SizingExample>();
    public virtual ICollection<ServiceResponsibleRole> ResponsibleRoles { get; set; } = new List<ServiceResponsibleRole>();
    public virtual ICollection<ServiceTeamAllocation> TeamAllocations { get; set; } = new List<ServiceTeamAllocation>();
    public virtual ICollection<ServiceMultiCloudConsideration> MultiCloudConsiderations { get; set; } = new List<ServiceMultiCloudConsideration>();
}
