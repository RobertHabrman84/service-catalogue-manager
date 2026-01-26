using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Scope component for PDF documents - shows what's in/out of scope
/// </summary>
public static class Scope
{
    public static void Compose(IContainer container, ScopeData data)
    {
        container.Column(column =>
        {
            column.Item().SectionTitle("Scope");

            // In Scope / Out of Scope side by side
            column.Item().Row(row =>
            {
                // In Scope
                row.RelativeItem().Element(c => ComposeScopeSection(
                    c, 
                    "In Scope", 
                    data.InScopeItems, 
                    PdfStyles.Colors.Success,
                    "✓"));

                row.ConstantItem(PdfStyles.Spacing.Medium);

                // Out of Scope
                row.RelativeItem().Element(c => ComposeScopeSection(
                    c, 
                    "Out of Scope", 
                    data.OutOfScopeItems, 
                    PdfStyles.Colors.Danger,
                    "✗"));
            });

            // Scope categories if available
            if (data.Categories?.Any() == true)
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Large);
                column.Item().SubsectionTitle("Scope by Category");

                column.Item().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(1);  // Category
                        columns.RelativeColumn(2);  // Description
                        columns.RelativeColumn(1);  // Status
                    });

                    table.Header(header =>
                    {
                        header.Cell().TableHeaderCell().Text("Category").Style(PdfStyles.LabelStyle);
                        header.Cell().TableHeaderCell().Text("Description").Style(PdfStyles.LabelStyle);
                        header.Cell().TableHeaderCell().Text("Status").Style(PdfStyles.LabelStyle);
                    });

                    foreach (var category in data.Categories.OrderBy(c => c.SortOrder))
                    {
                        table.Cell().TableCell().Text(category.CategoryName).Style(PdfStyles.BodyStyle);
                        table.Cell().TableCell().Text(category.Description ?? "-").Style(PdfStyles.SmallStyle);
                        table.Cell().TableCell().Element(c => ScopeStatusBadge(c, category.IsInScope));
                    }
                });
            }
        });
    }

    private static void ComposeScopeSection(
        IContainer container, 
        string title, 
        IEnumerable<string>? items,
        string accentColor,
        string icon)
    {
        var itemList = items?.ToList() ?? new List<string>();

        container.Border(1)
            .BorderColor(PdfStyles.Colors.Border)
            .Column(column =>
            {
                // Header
                column.Item()
                    .BorderBottom(2)
                    .BorderColor(accentColor)
                    .Padding(PdfStyles.Spacing.Small)
                    .Row(row =>
                    {
                        row.ConstantItem(20)
                            .Text(icon)
                            .FontSize(14)
                            .FontColor(accentColor);
                        row.RelativeItem()
                            .Text(title)
                            .Style(PdfStyles.Heading3Style);
                    });

                // Items
                column.Item().Padding(PdfStyles.Spacing.Small).Column(itemsCol =>
                {
                    if (!itemList.Any())
                    {
                        itemsCol.Item()
                            .Text("No items defined")
                            .Style(PdfStyles.SmallStyle)
                            .Italic();
                    }
                    else
                    {
                        foreach (var item in itemList)
                        {
                            itemsCol.Item().PaddingBottom(PdfStyles.Spacing.XSmall)
                                .BulletPoint(item);
                        }
                    }
                });
            });
    }

    private static void ScopeStatusBadge(IContainer container, bool isInScope)
    {
        var (bgColor, textColor, text) = isInScope 
            ? ("#D1FAE5", "#065F46", "In Scope")
            : ("#FEE2E2", "#991B1B", "Out of Scope");

        container.Background(bgColor)
            .Padding(2)
            .PaddingHorizontal(6)
            .Text(text)
            .FontSize(PdfStyles.FontSizes.Caption)
            .FontColor(textColor);
    }
}

/// <summary>
/// Data model for Scope
/// </summary>
public class ScopeData
{
    public IEnumerable<string>? InScopeItems { get; set; }
    public IEnumerable<string>? OutOfScopeItems { get; set; }
    public IEnumerable<ScopeCategoryData>? Categories { get; set; }
}

/// <summary>
/// Data model for Scope Category
/// </summary>
public class ScopeCategoryData
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsInScope { get; set; }
    public int SortOrder { get; set; }
}
