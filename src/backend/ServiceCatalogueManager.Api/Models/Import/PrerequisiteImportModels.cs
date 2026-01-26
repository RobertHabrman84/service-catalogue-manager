namespace ServiceCatalogueManager.Api.Models.Import;

public class PrerequisitesImportModel
{
    public List<PrerequisiteItemImportModel>? Organizational { get; set; }
    public List<PrerequisiteItemImportModel>? Technical { get; set; }
    public List<PrerequisiteItemImportModel>? Documentation { get; set; }
}

public class PrerequisiteItemImportModel
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? RequirementLevel { get; set; } // "REQUIRED" | "RECOMMENDED" | "OPTIONAL"
}
