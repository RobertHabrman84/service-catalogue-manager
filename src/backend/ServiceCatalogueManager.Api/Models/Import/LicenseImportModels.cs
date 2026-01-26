namespace ServiceCatalogueManager.Api.Models.Import;

public class LicensesImportModel
{
    public List<LicenseItemImportModel>? RequiredByCustomer { get; set; }
    public List<LicenseItemImportModel>? RecommendedOptional { get; set; }
    public List<LicenseItemImportModel>? ProvidedByServiceProvider { get; set; }
}

public class LicenseItemImportModel
{
    public string? LicenseName { get; set; }
    public string? LicenseType { get; set; } // "REQUIRED" | "RECOMMENDED" | "OPTIONAL" | "PROVIDED"
    public string? Description { get; set; }
    public string? Notes { get; set; }
}
