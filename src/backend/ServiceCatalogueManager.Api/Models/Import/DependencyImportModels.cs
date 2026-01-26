using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class DependenciesImportModel
{
    public List<DependencyImportModel>? Prerequisite { get; set; }
    public List<DependencyImportModel>? TriggersFor { get; set; }
    public List<DependencyImportModel>? ParallelWith { get; set; }
}

public class DependencyImportModel
{
    [Required]
    public string ServiceName { get; set; } = string.Empty;

    public string? ServiceCode { get; set; }

    [Required]
    public string RequirementLevel { get; set; } = string.Empty; // "REQUIRED" | "RECOMMENDED" | "OPTIONAL"

    public string? Notes { get; set; }
}
