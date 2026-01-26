using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class UsageScenarioImportModel
{
    [Required]
    [Range(1, int.MaxValue)]
    public int ScenarioNumber { get; set; }

    [Required]
    [MinLength(1)]
    public string ScenarioTitle { get; set; } = string.Empty;

    [Required]
    [MinLength(1)]
    public string ScenarioDescription { get; set; } = string.Empty;

    public int SortOrder { get; set; }
}
