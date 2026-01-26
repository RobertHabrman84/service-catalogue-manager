using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class ServiceInputImportModel
{
    [Required]
    public string ParameterName { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Required]
    public string RequirementLevel { get; set; } = string.Empty; // "REQUIRED" | "RECOMMENDED" | "OPTIONAL"

    public string? DataType { get; set; }

    public string? DefaultValue { get; set; }

    public string? ExampleValue { get; set; }
}
