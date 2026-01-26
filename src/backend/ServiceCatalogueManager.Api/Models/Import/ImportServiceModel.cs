using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

/// <summary>
/// Main model for importing a service catalog item from JSON
/// </summary>
public class ImportServiceModel
{
    [Required]
    [RegularExpression(@"^ID\d{3}$", ErrorMessage = "ServiceCode must match pattern ID0XX (e.g., ID001)")]
    public string ServiceCode { get; set; } = string.Empty;

    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string ServiceName { get; set; } = string.Empty;

    public string Version { get; set; } = "v1.0";

    [Required]
    public string Category { get; set; } = string.Empty;

    [Required]
    [MinLength(1)]
    public string Description { get; set; } = string.Empty;

    public string? Notes { get; set; }

    public List<UsageScenarioImportModel>? UsageScenarios { get; set; }

    public DependenciesImportModel? Dependencies { get; set; }

    public ScopeImportModel? Scope { get; set; }

    public PrerequisitesImportModel? Prerequisites { get; set; }

    public ToolsAndEnvironmentImportModel? ToolsAndEnvironment { get; set; }

    public LicensesImportModel? Licenses { get; set; }

    public StakeholderInteractionImportModel? StakeholderInteraction { get; set; }

    public List<ServiceInputImportModel>? ServiceInputs { get; set; }

    public List<OutputCategoryImportModel>? ServiceOutputs { get; set; }

    public TimelineImportModel? Timeline { get; set; }

    public List<SizeOptionImportModel>? SizeOptions { get; set; }

    public List<ResponsibleRoleImportModel>? ResponsibleRoles { get; set; }

    public List<MultiCloudConsiderationImportModel>? MultiCloudConsiderations { get; set; }
}
