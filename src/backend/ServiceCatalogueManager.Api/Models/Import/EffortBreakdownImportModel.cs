namespace ServiceCatalogueManager.Api.Models.Import;

// Alias for backward compatibility
public class EffortImportModel : EffortBreakdownImportModel
{
}

public class EffortBreakdownImportModel
{
    public decimal? Hours { get; set; }
    public decimal? HoursMin { get; set; }
    public decimal? HoursMax { get; set; }
    public List<EffortBreakdownItemImportModel>? Items { get; set; }
    public List<ComplexityAdditionImportModel>? ComplexityAdditions { get; set; }
}

public class EffortBreakdownItemImportModel
{
    public string Category { get; set; } = string.Empty;
    public decimal? EstimatedHours { get; set; }
}

public class ComplexityAdditionImportModel
{
    public string Factor { get; set; } = string.Empty;
    public decimal AdditionalHours { get; set; }
    public string? Description { get; set; }
}
