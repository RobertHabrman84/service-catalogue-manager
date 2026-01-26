using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class TimelineImportModel
{
    public List<TimelinePhaseImportModel>? Phases { get; set; }
}

public class TimelinePhaseImportModel
{
    [Required]
    public string PhaseName { get; set; } = string.Empty;

    public int? PhaseNumber { get; set; }

    public string? Description { get; set; }

    public PhaseDurationBySizeImportModel? DurationBySize { get; set; }
}

public class PhaseDurationBySizeImportModel
{
    public string? Small { get; set; }
    public string? Medium { get; set; }
    public string? Large { get; set; }
}
