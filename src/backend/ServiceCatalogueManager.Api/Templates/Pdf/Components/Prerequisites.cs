using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Prerequisites component for PDF documents
/// </summary>
public static class Prerequisites
{
    public static void Compose(IContainer container, IEnumerable<PrerequisiteData> prerequisites)
    {
        var prereqList = prerequisites?.ToList() ?? new List<PrerequisiteData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Prerequisites");

            if (!prereqList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No prerequisites defined."));
                return;
            }

            // Group by type
            var grouped = prereqList.GroupBy(p => p.PrerequisiteTypeName ?? "General")
                .OrderBy(g => g.Key);

            foreach (var group in grouped)
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                    .Element(c => ComposePrerequisiteGroup(c, group.Key, group.ToList()));
            }
        });
    }

    private static void ComposePrerequisiteGroup(IContainer container, string typeName, List<PrerequisiteData> prereqs)
    {
        container.Column(column =>
        {
            // Group header with icon
            column.Item().Row(row =>
            {
                var icon = typeName.ToLower() switch
                {
                    "infrastructure" => "🖥️",
                    "software" => "💿",
                    "access" or "permission" => "🔐",
                    "knowledge" or "skill" => "📚",
                    "hardware" => "⚙️",
                    _ => "📋"
                };

                row.ConstantItem(25).Text(icon).FontSize(14);
                row.RelativeItem()
                    .Text(typeName)
                    .Style(PdfStyles.Heading3Style);
            });

            // Prerequisites list
            column.Item().PaddingTop(PdfStyles.Spacing.Small)
                .PaddingLeft(PdfStyles.Spacing.Large)
                .Column(listCol =>
                {
                    foreach (var prereq in prereqs.OrderBy(p => p.SortOrder))
                    {
                        listCol.Item().PaddingBottom(PdfStyles.Spacing.Small)
                            .Element(c => ComposePrerequisiteItem(c, prereq));
                    }
                });
        });
    }

    private static void ComposePrerequisiteItem(IContainer container, PrerequisiteData prereq)
    {
        container.Row(row =>
        {
            // Checkbox style indicator
            row.ConstantItem(20).AlignTop()
                .Container()
                .Width(14)
                .Height(14)
                .Border(1)
                .BorderColor(PdfStyles.Colors.Border)
                .AlignCenter()
                .AlignMiddle()
                .Text(prereq.IsMandatory ? "●" : "○")
                .FontSize(8)
                .FontColor(prereq.IsMandatory ? PdfStyles.Colors.Danger : PdfStyles.Colors.TextMuted);

            row.RelativeItem().Column(col =>
            {
                // Name with mandatory badge
                col.Item().Row(nameRow =>
                {
                    nameRow.AutoItem()
                        .Text(prereq.PrerequisiteName)
                        .Style(PdfStyles.BodyStyle)
                        .SemiBold();

                    if (prereq.IsMandatory)
                    {
                        nameRow.ConstantItem(5);
                        nameRow.AutoItem()
                            .Background("#FEE2E2")
                            .Padding(1)
                            .PaddingHorizontal(4)
                            .Text("Required")
                            .FontSize(7)
                            .FontColor("#991B1B");
                    }
                });

                // Description
                if (!string.IsNullOrEmpty(prereq.Description))
                {
                    col.Item().PaddingTop(2)
                        .Text(prereq.Description)
                        .Style(PdfStyles.SmallStyle);
                }

                // Additional info
                if (!string.IsNullOrEmpty(prereq.Version) || !string.IsNullOrEmpty(prereq.Notes))
                {
                    col.Item().PaddingTop(2).Row(infoRow =>
                    {
                        if (!string.IsNullOrEmpty(prereq.Version))
                        {
                            infoRow.AutoItem()
                                .Text($"Version: {prereq.Version}")
                                .Style(PdfStyles.CaptionStyle);
                        }
                        if (!string.IsNullOrEmpty(prereq.Notes))
                        {
                            if (!string.IsNullOrEmpty(prereq.Version))
                                infoRow.ConstantItem(10);
                            infoRow.AutoItem()
                                .Text($"Note: {prereq.Notes}")
                                .Style(PdfStyles.CaptionStyle)
                                .Italic();
                        }
                    });
                }
            });
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
/// Data model for Prerequisite
/// </summary>
public class PrerequisiteData
{
    public int PrerequisiteId { get; set; }
    public string PrerequisiteName { get; set; } = string.Empty;
    public string? PrerequisiteTypeName { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
    public string? Version { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
}
