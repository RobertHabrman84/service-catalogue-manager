namespace ServiceCatalogueManager.Api.Models.Import;

public class StakeholderInteractionImportModel
{
    public string? InteractionLevel { get; set; } // "LOW" | "MEDIUM" | "HIGH"
    public List<string>? CustomerMustProvide { get; set; }
    public List<StakeholderRoleImportModel>? WorkshopParticipation { get; set; }
    public List<AccessRequirementImportModel>? AccessRequirements { get; set; }
}

public class StakeholderRoleImportModel
{
    public string? RoleName { get; set; }
    public string? InvolvementLevel { get; set; } // "REQUIRED" | "RECOMMENDED" | "OPTIONAL" | "AS_NEEDED"
    public string? Responsibilities { get; set; }
}

public class AccessRequirementImportModel
{
    public string? RequirementType { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
}
