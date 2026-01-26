namespace ServiceCatalogueManager.Api.Data.Entities;

public class TimelinePhase : BaseEntity, ISortable
{
    public int PhaseId { get; set; }
    public int ServiceId { get; set; }
    public int PhaseNumber { get; set; }
    public string PhaseName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? DurationBySize { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual ICollection<PhaseDurationBySize> DurationsBySize { get; set; } = new List<PhaseDurationBySize>();
}

public class PhaseDurationBySize : BaseEntity
{
    public int DurationId { get; set; }
    public int PhaseDurationId { get; set; }
    public int PhaseId { get; set; }
    public int SizeOptionId { get; set; }
    public string Duration { get; set; } = string.Empty;
    public virtual TimelinePhase? Phase { get; set; }
    public virtual LU_SizeOption? SizeOption { get; set; }
}
