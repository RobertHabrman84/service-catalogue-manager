namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceInteraction : BaseEntity
{
    public int InteractionId { get; set; }
    public int ServiceId { get; set; }
    public int InteractionLevelId { get; set; }
    public string InteractionDescription { get; set; } = string.Empty;
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_InteractionLevel? InteractionLevel { get; set; }
    public virtual ICollection<CustomerRequirement> CustomerRequirements { get; set; } = new List<CustomerRequirement>();
    public virtual ICollection<AccessRequirement> AccessRequirements { get; set; } = new List<AccessRequirement>();
    public virtual ICollection<StakeholderInvolvement> StakeholderInvolvements { get; set; } = new List<StakeholderInvolvement>();
}

public class CustomerRequirement : BaseEntity, ISortable
{
    public int RequirementId { get; set; }
    public int InteractionId { get; set; }
    public string RequirementDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceInteraction? Interaction { get; set; }
}

public class AccessRequirement : BaseEntity, ISortable
{
    public int AccessId { get; set; }
    public int InteractionId { get; set; }
    public string AccessDescription { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public virtual ServiceInteraction? Interaction { get; set; }
}
