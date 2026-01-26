using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Effort
{
    public static void Compose(IContainer container, IEnumerable<EffortItemData> items)
    {
        var itemList = items?.ToList() ?? new List<EffortItemData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Effort Estimation");

            if (!itemList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No effort estimation defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            var totalHours = itemList.Sum(i => i.EstimatedHours);
            var totalDays = totalHours / 8.0;

            column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                .Background(PdfStyles.Colors.Background).Padding(PdfStyles.Spacing.Medium)
                .Row(row =>
                {
                    row.RelativeItem().Column(c =>
                    {
                        c.Item().Text("Total Hours").Style(PdfStyles.CaptionStyle);
                        c.Item().Text($"{totalHours:N0}h").FontSize(20).FontColor(PdfStyles.Colors.Primary).Bold();
                    });
                    row.RelativeItem().Column(c =>
                    {
                        c.Item().Text("Total Days").Style(PdfStyles.CaptionStyle);
                        c.Item().Text($"{totalDays:N1}d").FontSize(20).FontColor(PdfStyles.Colors.Primary).Bold();
                    });
                    row.RelativeItem().Column(c =>
                    {
                        c.Item().Text("Work Items").Style(PdfStyles.CaptionStyle);
                        c.Item().Text(itemList.Count.ToString()).FontSize(20).FontColor(PdfStyles.Colors.Primary).Bold();
                    });
                });

            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(1);
                    columns.RelativeColumn(1);
                    columns.RelativeColumn(3);
                });

                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("Activity").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Role").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Hours").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Notes").Style(PdfStyles.LabelStyle);
                });

                foreach (var item in itemList.OrderBy(i => i.SortOrder))
                {
                    table.Cell().TableCell().Text(item.ActivityName).Style(PdfStyles.BodyStyle);
                    table.Cell().TableCell().Text(item.RoleName ?? "-").Style(PdfStyles.SmallStyle);
                    table.Cell().TableCell().Text($"{item.EstimatedHours}h").Style(PdfStyles.BodyStyle).Bold();
                    table.Cell().TableCell().Text(item.Notes ?? "-").Style(PdfStyles.SmallStyle);
                }
            });
        });
    }
}

public class EffortItemData
{
    public int EffortId { get; set; }
    public string ActivityName { get; set; } = string.Empty;
    public string? RoleName { get; set; }
    public int EstimatedHours { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
}
