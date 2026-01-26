using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Tools component for PDF documents
/// </summary>
public static class Tools
{
    public static void Compose(IContainer container, IEnumerable<ToolData> tools)
    {
        var toolList = tools?.ToList() ?? new List<ToolData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Tools & Technologies");

            if (!toolList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No tools defined."));
                return;
            }

            // Group by category
            var grouped = toolList.GroupBy(t => t.CategoryName ?? "Other")
                .OrderBy(g => g.Key);

            foreach (var group in grouped)
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                    .Element(c => ComposeToolCategory(c, group.Key, group.ToList()));
            }
        });
    }

    private static void ComposeToolCategory(IContainer container, string categoryName, List<ToolData> tools)
    {
        container.Column(column =>
        {
            // Category header
            column.Item()
                .Background(PdfStyles.Colors.Background)
                .Padding(PdfStyles.Spacing.Small)
                .Row(row =>
                {
                    var icon = categoryName.ToLower() switch
                    {
                        "development" => "🛠️",
                        "testing" => "🧪",
                        "monitoring" => "📊",
                        "deployment" or "ci/cd" => "🚀",
                        "communication" => "💬",
                        "documentation" => "📝",
                        "security" => "🔒",
                        "database" => "🗄️",
                        _ => "🔧"
                    };

                    row.ConstantItem(25).Text(icon).FontSize(14);
                    row.RelativeItem()
                        .Text(categoryName)
                        .Style(PdfStyles.Heading3Style);
                    row.ConstantItem(40)
                        .AlignRight()
                        .Text($"{tools.Count} tools")
                        .Style(PdfStyles.CaptionStyle);
                });

            // Tools grid (2 columns)
            column.Item().PaddingTop(PdfStyles.Spacing.Small).Row(row =>
            {
                var leftTools = tools.Take((tools.Count + 1) / 2).ToList();
                var rightTools = tools.Skip((tools.Count + 1) / 2).ToList();

                row.RelativeItem().Column(leftCol =>
                {
                    foreach (var tool in leftTools)
                    {
                        leftCol.Item().PaddingBottom(PdfStyles.Spacing.Small)
                            .Element(c => ComposeToolCard(c, tool));
                    }
                });

                row.ConstantItem(PdfStyles.Spacing.Medium);

                row.RelativeItem().Column(rightCol =>
                {
                    foreach (var tool in rightTools)
                    {
                        rightCol.Item().PaddingBottom(PdfStyles.Spacing.Small)
                            .Element(c => ComposeToolCard(c, tool));
                    }
                });
            });
        });
    }

    private static void ComposeToolCard(IContainer container, ToolData tool)
    {
        container.Border(1)
            .BorderColor(PdfStyles.Colors.Border)
            .Padding(PdfStyles.Spacing.Small)
            .Column(column =>
            {
                // Tool name and version
                column.Item().Row(row =>
                {
                    row.RelativeItem()
                        .Text(tool.ToolName)
                        .Style(PdfStyles.BodyStyle)
                        .SemiBold();

                    if (!string.IsNullOrEmpty(tool.Version))
                    {
                        row.ConstantItem(50)
                            .AlignRight()
                            .Background(PdfStyles.Colors.PrimaryLight)
                            .Padding(1)
                            .PaddingHorizontal(4)
                            .Text($"v{tool.Version}")
                            .FontSize(7)
                            .FontColor(PdfStyles.Colors.White);
                    }
                });

                // Description
                if (!string.IsNullOrEmpty(tool.Description))
                {
                    column.Item().PaddingTop(2)
                        .Text(tool.Description)
                        .Style(PdfStyles.CaptionStyle);
                }

                // URL
                if (!string.IsNullOrEmpty(tool.Url))
                {
                    column.Item().PaddingTop(2)
                        .Text(tool.Url)
                        .Style(PdfStyles.LinkStyle)
                        .FontSize(8);
                }

                // Purpose badge
                if (!string.IsNullOrEmpty(tool.Purpose))
                {
                    column.Item().PaddingTop(4)
                        .Container()
                        .Background(PdfStyles.Colors.Background)
                        .Padding(2)
                        .PaddingHorizontal(4)
                        .Text(tool.Purpose)
                        .FontSize(7)
                        .FontColor(PdfStyles.Colors.TextSecondary);
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
/// Data model for Tool
/// </summary>
public class ToolData
{
    public int ToolId { get; set; }
    public string ToolName { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public string? Description { get; set; }
    public string? Version { get; set; }
    public string? Url { get; set; }
    public string? Purpose { get; set; }
    public int SortOrder { get; set; }
}
