using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Usage Scenarios component for PDF documents
/// </summary>
public static class UsageScenarios
{
    public static void Compose(IContainer container, IEnumerable<UsageScenarioData> scenarios)
    {
        var scenarioList = scenarios?.ToList() ?? new List<UsageScenarioData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Usage Scenarios");

            if (!scenarioList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No usage scenarios defined."));
                return;
            }

            int index = 1;
            foreach (var scenario in scenarioList.OrderBy(s => s.SortOrder))
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                    .Element(c => ComposeScenario(c, scenario, index++));
            }
        });
    }

    private static void ComposeScenario(IContainer container, UsageScenarioData scenario, int index)
    {
        container.CardContainer().Column(column =>
        {
            // Header with number and name
            column.Item().Row(row =>
            {
                row.ConstantItem(30)
                    .Background(PdfStyles.Colors.Primary)
                    .AlignCenter()
                    .AlignMiddle()
                    .Text(index.ToString())
                    .FontSize(14)
                    .FontColor(PdfStyles.Colors.White)
                    .Bold();

                row.ConstantItem(PdfStyles.Spacing.Medium);

                row.RelativeItem().AlignMiddle()
                    .Text(scenario.ScenarioName)
                    .Style(PdfStyles.Heading3Style);
            });

            // Description
            if (!string.IsNullOrEmpty(scenario.Description))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Small)
                    .Text(scenario.Description)
                    .Style(PdfStyles.BodyStyle);
            }

            // Actors
            if (!string.IsNullOrEmpty(scenario.Actors))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Small).Row(row =>
                {
                    row.ConstantItem(80)
                        .Text("Actors:").Style(PdfStyles.LabelStyle);
                    row.RelativeItem()
                        .Text(scenario.Actors).Style(PdfStyles.BodyStyle);
                });
            }

            // Trigger
            if (!string.IsNullOrEmpty(scenario.Trigger))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.XSmall).Row(row =>
                {
                    row.ConstantItem(80)
                        .Text("Trigger:").Style(PdfStyles.LabelStyle);
                    row.RelativeItem()
                        .Text(scenario.Trigger).Style(PdfStyles.BodyStyle);
                });
            }

            // Preconditions
            if (!string.IsNullOrEmpty(scenario.Preconditions))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.XSmall).Row(row =>
                {
                    row.ConstantItem(80)
                        .Text("Preconditions:").Style(PdfStyles.LabelStyle);
                    row.RelativeItem()
                        .Text(scenario.Preconditions).Style(PdfStyles.BodyStyle);
                });
            }

            // Main Flow
            if (!string.IsNullOrEmpty(scenario.MainFlow))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium);
                column.Item().SubsectionTitle("Main Flow");
                column.Item().Text(scenario.MainFlow).Style(PdfStyles.BodyStyle);
            }

            // Alternative Flow
            if (!string.IsNullOrEmpty(scenario.AlternativeFlow))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Small);
                column.Item().SubsectionTitle("Alternative Flow");
                column.Item().Text(scenario.AlternativeFlow).Style(PdfStyles.BodyStyle);
            }

            // Postconditions
            if (!string.IsNullOrEmpty(scenario.Postconditions))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Small).Row(row =>
                {
                    row.ConstantItem(100)
                        .Text("Postconditions:").Style(PdfStyles.LabelStyle);
                    row.RelativeItem()
                        .Text(scenario.Postconditions).Style(PdfStyles.BodyStyle);
                });
            }
        });
    }

    private static void EmptyState(IContainer container, string message)
    {
        container.Background(PdfStyles.Colors.Background)
            .Padding(PdfStyles.Spacing.Large)
            .AlignCenter()
            .Text(message)
            .Style(PdfStyles.SmallStyle)
            .Italic();
    }
}

/// <summary>
/// Data model for Usage Scenario
/// </summary>
public class UsageScenarioData
{
    public int ScenarioId { get; set; }
    public string ScenarioName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Actors { get; set; }
    public string? Trigger { get; set; }
    public string? Preconditions { get; set; }
    public string? MainFlow { get; set; }
    public string? AlternativeFlow { get; set; }
    public string? Postconditions { get; set; }
    public int SortOrder { get; set; }
}
