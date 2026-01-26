using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Licenses component for PDF documents
/// </summary>
public static class Licenses
{
    public static void Compose(IContainer container, IEnumerable<LicenseData> licenses)
    {
        var licenseList = licenses?.ToList() ?? new List<LicenseData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Licenses");

            if (!licenseList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No licenses defined."));
                return;
            }

            // Summary stats
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                .Element(c => ComposeLicenseSummary(c, licenseList));

            // License table
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);    // Name
                    columns.RelativeColumn(1);    // Type
                    columns.RelativeColumn(1);    // Quantity
                    columns.RelativeColumn(1.5f); // Expiry
                    columns.RelativeColumn(1);    // Cost
                });

                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("License").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Type").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Qty").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Expiry").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Cost").Style(PdfStyles.LabelStyle);
                });

                foreach (var license in licenseList.OrderBy(l => l.SortOrder))
                {
                    table.Cell().TableCell().Text(license.LicenseName).Style(PdfStyles.BodyStyle);
                    table.Cell().TableCell().Element(c => LicenseTypeBadge(c, license.LicenseTypeName));
                    table.Cell().TableCell().Text(license.Quantity?.ToString() ?? "-").Style(PdfStyles.SmallStyle);
                    table.Cell().TableCell().Element(c => ExpiryCell(c, license.ExpiryDate));
                    table.Cell().TableCell().Text(FormatCost(license.AnnualCost)).Style(PdfStyles.SmallStyle);
                }
            });

            // Notes
            var licensesWithNotes = licenseList.Where(l => !string.IsNullOrEmpty(l.Notes)).ToList();
            if (licensesWithNotes.Any())
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium);
                column.Item().SubsectionTitle("License Notes");
                
                foreach (var license in licensesWithNotes)
                {
                    column.Item().PaddingBottom(PdfStyles.Spacing.Small)
                        .Row(row =>
                        {
                            row.ConstantItem(120)
                                .Text($"{license.LicenseName}:")
                                .Style(PdfStyles.LabelStyle);
                            row.RelativeItem()
                                .Text(license.Notes)
                                .Style(PdfStyles.SmallStyle)
                                .Italic();
                        });
                }
            }
        });
    }

    private static void ComposeLicenseSummary(IContainer container, List<LicenseData> licenses)
    {
        var totalCost = licenses.Sum(l => l.AnnualCost ?? 0);
        var expiringCount = licenses.Count(l => l.ExpiryDate.HasValue && l.ExpiryDate.Value < DateTime.UtcNow.AddMonths(3));

        container.Background(PdfStyles.Colors.Background)
            .Padding(PdfStyles.Spacing.Medium)
            .Row(row =>
            {
                row.RelativeItem().Column(col =>
                {
                    col.Item().Text("Total Licenses").Style(PdfStyles.CaptionStyle);
                    col.Item().Text(licenses.Count.ToString())
                        .FontSize(20)
                        .FontColor(PdfStyles.Colors.Primary)
                        .Bold();
                });

                row.RelativeItem().Column(col =>
                {
                    col.Item().Text("Annual Cost").Style(PdfStyles.CaptionStyle);
                    col.Item().Text(FormatCost(totalCost))
                        .FontSize(20)
                        .FontColor(PdfStyles.Colors.Primary)
                        .Bold();
                });

                row.RelativeItem().Column(col =>
                {
                    col.Item().Text("Expiring Soon").Style(PdfStyles.CaptionStyle);
                    col.Item().Text(expiringCount.ToString())
                        .FontSize(20)
                        .FontColor(expiringCount > 0 ? PdfStyles.Colors.Warning : PdfStyles.Colors.Success)
                        .Bold();
                });
            });
    }

    private static void LicenseTypeBadge(IContainer container, string? type)
    {
        var (bgColor, textColor) = type?.ToLower() switch
        {
            "commercial" => ("#DBEAFE", "#1E40AF"),
            "open source" or "oss" => ("#D1FAE5", "#065F46"),
            "subscription" => ("#E0E7FF", "#3730A3"),
            "perpetual" => ("#FEF3C7", "#92400E"),
            "trial" => ("#FEE2E2", "#991B1B"),
            _ => (PdfStyles.Colors.Background, PdfStyles.Colors.TextSecondary)
        };

        container.Background(bgColor)
            .Padding(1)
            .PaddingHorizontal(4)
            .Text(type ?? "Unknown")
            .FontSize(PdfStyles.FontSizes.Caption)
            .FontColor(textColor);
    }

    private static void ExpiryCell(IContainer container, DateTime? expiryDate)
    {
        if (!expiryDate.HasValue)
        {
            container.Text("N/A").Style(PdfStyles.SmallStyle);
            return;
        }

        var daysUntilExpiry = (expiryDate.Value - DateTime.UtcNow).Days;
        var textColor = daysUntilExpiry switch
        {
            < 0 => PdfStyles.Colors.Danger,
            < 30 => PdfStyles.Colors.Danger,
            < 90 => PdfStyles.Colors.Warning,
            _ => PdfStyles.Colors.TextPrimary
        };

        container.Text(expiryDate.Value.ToString("MMM dd, yyyy"))
            .FontSize(PdfStyles.FontSizes.Small)
            .FontColor(textColor);
    }

    private static string FormatCost(decimal? cost)
    {
        if (!cost.HasValue || cost.Value == 0)
            return "Free";
        return $"${cost.Value:N0}/yr";
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
/// Data model for License
/// </summary>
public class LicenseData
{
    public int LicenseId { get; set; }
    public string LicenseName { get; set; } = string.Empty;
    public string? LicenseTypeName { get; set; }
    public int? Quantity { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public decimal? AnnualCost { get; set; }
    public string? Vendor { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
}
