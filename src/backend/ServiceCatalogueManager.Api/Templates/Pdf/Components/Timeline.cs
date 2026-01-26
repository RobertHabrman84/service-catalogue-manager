using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Timeline
{
    public static void Compose(IContainer container, IEnumerable<TimelinePhaseData> phases)
    {
        var phaseList = phases?.ToList() ?? new List<TimelinePhaseData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Timeline");

            if (!phaseList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No timeline phases defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            var totalDuration = phaseList.Sum(p => p.DurationDays);
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                .Text($"Total Duration: {totalDuration} days").Style(PdfStyles.BodyStyle).Bold();

            int phaseNum = 1;
            foreach (var phase in phaseList.OrderBy(p => p.SortOrder))
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Small)
                    .Element(c => ComposePhase(c, phase, phaseNum++, totalDuration));
            }
        });
    }

    private static void ComposePhase(IContainer container, TimelinePhaseData phase, int num, int total)
    {
        var widthPercent = total > 0 ? (float)phase.DurationDays / total : 0;
        
        container.Row(row =>
        {
            row.ConstantItem(30).Background(PdfStyles.Colors.Primary)
                .AlignCenter().AlignMiddle()
                .Text(num.ToString()).FontSize(12).FontColor(PdfStyles.Colors.White).Bold();

            row.ConstantItem(PdfStyles.Spacing.Small);

            row.RelativeItem().Border(1).BorderColor(PdfStyles.Colors.Border)
                .Padding(PdfStyles.Spacing.Small).Column(col =>
                {
                    col.Item().Row(r =>
                    {
                        r.RelativeItem().Text(phase.PhaseName).Style(PdfStyles.Heading3Style);
                        r.ConstantItem(80).AlignRight()
                            .Text($"{phase.DurationDays} days").Style(PdfStyles.SmallStyle);
                    });

                    if (!string.IsNullOrEmpty(phase.Description))
                        col.Item().PaddingTop(4).Text(phase.Description).Style(PdfStyles.SmallStyle);

                    col.Item().PaddingTop(PdfStyles.Spacing.Small)
                        .Height(8).Row(bar =>
                        {
                            bar.RelativeItem((float)widthPercent).Background(PdfStyles.Colors.PrimaryLight);
                            bar.RelativeItem(1 - widthPercent).Background(PdfStyles.Colors.Background);
                        });
                });
        });
    }
}

public class TimelinePhaseData
{
    public int PhaseId { get; set; }
    public string PhaseName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DurationDays { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int SortOrder { get; set; }
}
