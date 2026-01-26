using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Dependencies component for PDF documents
/// </summary>
public static class Dependencies
{
    public static void Compose(IContainer container, IEnumerable<DependencyData> dependencies)
    {
        var depList = dependencies?.ToList() ?? new List<DependencyData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Dependencies");

            if (!depList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No dependencies defined."));
                return;
            }

            // Group by type
            var grouped = depList.GroupBy(d => d.DependencyTypeName ?? "Other")
                .OrderBy(g => g.Key);

            foreach (var group in grouped)
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                    .Element(c => ComposeDependencyGroup(c, group.Key, group.ToList()));
            }
        });
    }

    private static void ComposeDependencyGroup(IContainer container, string typeName, List<DependencyData> deps)
    {
        container.Column(column =>
        {
            // Group header
            column.Item().Background(PdfStyles.Colors.TableHeader)
                .Padding(PdfStyles.Spacing.Small)
                .Row(row =>
                {
                    row.RelativeItem()
                        .Text(typeName)
                        .Style(PdfStyles.Heading3Style);
                    row.ConstantItem(40)
                        .AlignRight()
                        .Text($"({deps.Count})")
                        .Style(PdfStyles.SmallStyle);
                });

            // Dependencies table
            column.Item().Table(table =>
            {
                // Define columns
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);    // Name
                    columns.RelativeColumn(1);    // Criticality
                    columns.RelativeColumn(3);    // Description
                });

                // Header
                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("Dependency").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Criticality").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Description").Style(PdfStyles.LabelStyle);
                });

                // Rows
                foreach (var dep in deps.OrderBy(d => d.SortOrder))
                {
                    table.Cell().TableCell().Text(dep.DependencyName).Style(PdfStyles.BodyStyle);
                    table.Cell().TableCell().Element(c => CriticalityBadge(c, dep.CriticalityLevel));
                    table.Cell().TableCell().Text(dep.Description ?? "-").Style(PdfStyles.SmallStyle);
                }
            });
        });
    }

    private static void CriticalityBadge(IContainer container, string? level)
    {
        var (bgColor, textColor) = level?.ToLower() switch
        {
            "critical" => ("#FEE2E2", "#991B1B"),   // Red
            "high" => ("#FEF3C7", "#92400E"),       // Amber
            "medium" => ("#FEF9C3", "#854D0E"),     // Yellow
            "low" => ("#D1FAE5", "#065F46"),        // Green
            _ => (PdfStyles.Colors.Background, PdfStyles.Colors.TextSecondary)
        };

        container.Background(bgColor)
            .Padding(2)
            .PaddingHorizontal(6)
            .Text(level ?? "Unknown")
            .FontSize(PdfStyles.FontSizes.Caption)
            .FontColor(textColor);
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
/// Data model for Dependency
/// </summary>
public class DependencyData
{
    public int DependencyId { get; set; }
    public string DependencyName { get; set; } = string.Empty;
    public string? DependencyTypeName { get; set; }
    public string? Description { get; set; }
    public string? CriticalityLevel { get; set; }
    public string? Version { get; set; }
    public string? Url { get; set; }
    public int SortOrder { get; set; }
}
