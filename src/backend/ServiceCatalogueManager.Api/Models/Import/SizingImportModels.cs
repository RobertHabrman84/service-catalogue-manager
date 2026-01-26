namespace ServiceCatalogueManager.Api.Models.Import;

public class SizingExampleImportModel
{
    public int ExampleNumber { get; set; }          // ✅ ADDED
    public string ExampleTitle { get; set; } = string.Empty;  // ✅ ADDED
    public string? Description { get; set; }
    public List<ExampleCharacteristicImportModel>? Characteristics { get; set; }
}

public class ExampleCharacteristicImportModel
{
    public string CharacteristicDescription { get; set; } = string.Empty;
}

public class SizingParameterImportModel
{
    public string ParameterName { get; set; } = string.Empty;
    public string? Value { get; set; }              // ✅ ADDED
    public string? Unit { get; set; }               // ✅ ADDED
}

public class SizingCriterionImportModel
{
    public string CriteriaName { get; set; } = string.Empty;
    public string? Criteria { get; set; }
}

public class ScopeDependencyImportModel
{
    public string DependencyDescription { get; set; } = string.Empty;
}
