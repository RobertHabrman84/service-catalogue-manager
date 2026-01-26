using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Service Overview component showing basic service information
/// </summary>
public static class ServiceOverview
{
    public static void Compose(IContainer container, ServiceOverviewData data)
    {
        container.Column(column =>
        {
            column.Item().SectionTitle("Service Overview");

            // Main info card
            column.Item().CardContainer().Column(cardCol =>
            {
                // Service name and code
                cardCol.Item().Row(row =>
                {
                    row.RelativeItem().Text(data.ServiceName).Style(PdfStyles.Heading2Style);
                    row.ConstantItem(100).AlignRight()
                        .Text(data.ServiceCode)
                        .FontSize(PdfStyles.FontSizes.Small)
                        .FontColor(PdfStyles.Colors.TextMuted)
                        .Bold();
                });

                // Status badge
                cardCol.Item().PaddingTop(PdfStyles.Spacing.Small).Row(row =>
                {
                    row.AutoItem().Container().StatusBadge(
                        data.IsActive ? "Active" : "Inactive",
                        data.IsActive);
                    
                    if (!string.IsNullOrEmpty(data.Version))
                    {
                        row.ConstantItem(10);
                        row.AutoItem()
                            .Background(PdfStyles.Colors.Background)
                            .Padding(PdfStyles.Spacing.XSmall)
                            .PaddingHorizontal(PdfStyles.Spacing.Small)
                            .Text($"v{data.Version}")
                            .FontSize(PdfStyles.FontSizes.Caption)
                            .FontColor(PdfStyles.Colors.TextSecondary);
                    }
                });

                cardCol.Item().Divider();

                // Description
                if (!string.IsNullOrEmpty(data.Description))
                {
                    cardCol.Item().Text(data.Description).Style(PdfStyles.BodyStyle);
                    cardCol.Item().PaddingBottom(PdfStyles.Spacing.Medium);
                }

                // Key info grid
                cardCol.Item().Row(row =>
                {
                    row.RelativeItem().Column(leftCol =>
                    {
                        leftCol.Item().LabelValue("Category", data.CategoryName);
                        leftCol.Item().PaddingTop(PdfStyles.Spacing.Small)
                            .LabelValue("Subcategory", data.SubcategoryName);
                    });

                    row.RelativeItem().Column(rightCol =>
                    {
                        rightCol.Item().LabelValue("Owner", data.OwnerName);
                        rightCol.Item().PaddingTop(PdfStyles.Spacing.Small)
                            .LabelValue("Last Updated", data.ModifiedDate?.ToString("MMM dd, yyyy") ?? "-");
                    });
                });
            });

            // Statistics row
            if (data.ShowStatistics)
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium).Row(row =>
                {
                    row.RelativeItem().Element(c => StatisticCard(c, "Usage Scenarios", data.UsageScenariosCount.ToString()));
                    row.ConstantItem(PdfStyles.Spacing.Medium);
                    row.RelativeItem().Element(c => StatisticCard(c, "Dependencies", data.DependenciesCount.ToString()));
                    row.ConstantItem(PdfStyles.Spacing.Medium);
                    row.RelativeItem().Element(c => StatisticCard(c, "Prerequisites", data.PrerequisitesCount.ToString()));
                    row.ConstantItem(PdfStyles.Spacing.Medium);
                    row.RelativeItem().Element(c => StatisticCard(c, "Tools", data.ToolsCount.ToString()));
                });
            }
        });
    }

    private static void StatisticCard(IContainer container, string label, string value)
    {
        container.Background(PdfStyles.Colors.Background)
            .Border(1)
            .BorderColor(PdfStyles.Colors.Border)
            .Padding(PdfStyles.Spacing.Medium)
            .Column(column =>
            {
                column.Item().AlignCenter()
                    .Text(value)
                    .FontSize(24)
                    .FontColor(PdfStyles.Colors.Primary)
                    .Bold();
                column.Item().AlignCenter()
                    .Text(label)
                    .Style(PdfStyles.SmallStyle);
            });
    }
}

/// <summary>
/// Data model for Service Overview component
/// </summary>
public class ServiceOverviewData
{
    public string ServiceName { get; set; } = string.Empty;
    public string ServiceCode { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Version { get; set; }
    public bool IsActive { get; set; } = true;
    public string? CategoryName { get; set; }
    public string? SubcategoryName { get; set; }
    public string? OwnerName { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool ShowStatistics { get; set; } = true;
    public int UsageScenariosCount { get; set; }
    public int DependenciesCount { get; set; }
    public int PrerequisitesCount { get; set; }
    public int ToolsCount { get; set; }
}
