using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Examples
{
    public static void Compose(IContainer container, IEnumerable<ExampleData> examples)
    {
        var exampleList = examples?.ToList() ?? new List<ExampleData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Examples");

            if (!exampleList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No examples defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            int num = 1;
            foreach (var example in exampleList.OrderBy(e => e.SortOrder))
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                    .Element(c => ComposeExample(c, example, num++));
            }
        });
    }

    private static void ComposeExample(IContainer container, ExampleData example, int num)
    {
        container.Border(1).BorderColor(PdfStyles.Colors.Border).Column(col =>
        {
            col.Item().Background(PdfStyles.Colors.Background)
                .Padding(PdfStyles.Spacing.Small).Row(row =>
                {
                    row.ConstantItem(25).Background(PdfStyles.Colors.Primary)
                        .AlignCenter().AlignMiddle()
                        .Text(num.ToString()).FontSize(10).FontColor(PdfStyles.Colors.White).Bold();
                    row.ConstantItem(PdfStyles.Spacing.Small);
                    row.RelativeItem().Text(example.ExampleName).Style(PdfStyles.Heading3Style);
                });

            col.Item().Padding(PdfStyles.Spacing.Small).Column(innerCol =>
            {
                if (!string.IsNullOrEmpty(example.Description))
                    innerCol.Item().Text(example.Description).Style(PdfStyles.BodyStyle);

                if (!string.IsNullOrEmpty(example.Scenario))
                {
                    innerCol.Item().PaddingTop(PdfStyles.Spacing.Small);
                    innerCol.Item().Text("Scenario:").Style(PdfStyles.LabelStyle);
                    innerCol.Item().Text(example.Scenario).Style(PdfStyles.SmallStyle);
                }

                if (!string.IsNullOrEmpty(example.ExpectedResult))
                {
                    innerCol.Item().PaddingTop(PdfStyles.Spacing.Small);
                    innerCol.Item().Text("Expected Result:").Style(PdfStyles.LabelStyle);
                    innerCol.Item().Text(example.ExpectedResult).Style(PdfStyles.SmallStyle);
                }
            });
        });
    }
}

public class ExampleData
{
    public int ExampleId { get; set; }
    public string ExampleName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Scenario { get; set; }
    public string? ExpectedResult { get; set; }
    public int SortOrder { get; set; }
}
