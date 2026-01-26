namespace ServiceCatalogueManager.Api.Models.Import;

// Main wrapper class matching expected structure
public class ScopeImportModel
{
    public List<ScopeCategoryImportModel>? InScope { get; set; }
    public List<string>? OutOfScope { get; set; }
}

public class ScopeCategoryImportModel
{
    public string CategoryName { get; set; } = string.Empty;
    public int? CategoryNumber { get; set; }
    public int SortOrder { get; set; }
    public List<ScopeItemImportModel>? Items { get; set; }
}

public class ScopeItemImportModel
{
    public string ItemName { get; set; } = string.Empty;
    public string ItemDescription { get; set; } = string.Empty;
}
