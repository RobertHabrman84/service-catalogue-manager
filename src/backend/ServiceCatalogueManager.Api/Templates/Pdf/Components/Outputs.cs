using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Outputs
{
    public static void Compose(IContainer container, IEnumerable<OutputData> outputs)
    {
        var outputList = outputs?.ToList() ?? new List<OutputData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Outputs");

            if (!outputList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No outputs defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

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
                    header.Cell().TableHeaderCell().Text("Output Name").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Data Type").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Format").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Description").Style(PdfStyles.LabelStyle);
                });

                foreach (var output in outputList.OrderBy(o => o.SortOrder))
                {
                    table.Cell().TableCell().Text(output.OutputName).Style(PdfStyles.BodyStyle).SemiBold();
                    table.Cell().TableCell().Text(output.DataType ?? "-").Style(PdfStyles.SmallStyle);
                    table.Cell().TableCell().Text(output.Format ?? "-").Style(PdfStyles.SmallStyle);
                    table.Cell().TableCell().Text(output.Description ?? "-").Style(PdfStyles.SmallStyle);
                }
            });
        });
    }
}

public class OutputData
{
    public int OutputId { get; set; }
    public string OutputName { get; set; } = string.Empty;
    public string? DataType { get; set; }
    public string? Format { get; set; }
    public string? Description { get; set; }
    public string? Destination { get; set; }
    public int SortOrder { get; set; }
}
