namespace ServiceCatalogueManager.Api.Models.Import;

public class SizeOptionImportModel
{
    public string SizeName { get; set; } = string.Empty;
    public string? Duration { get; set; }
    public string? EffortRange { get; set; }
    public List<TeamAllocationImportModel>? TeamAllocations { get; set; }
    public List<SizingExampleImportModel>? Examples { get; set; }
}

public class TeamAllocationImportModel
{
    public string? SizeName { get; set; }
    // ✅ ADDED ALL 9 role properties
    public decimal? CloudArchitects { get; set; }
    public decimal? SolutionArchitects { get; set; }
    public decimal? TechnicalLeads { get; set; }
    public decimal? Developers { get; set; }
    public decimal? QAEngineers { get; set; }
    public decimal? DevOpsEngineers { get; set; }
    public decimal? SecuritySpecialists { get; set; }
    public decimal? ProjectManagers { get; set; }
    public decimal? BusinessAnalysts { get; set; }
}
