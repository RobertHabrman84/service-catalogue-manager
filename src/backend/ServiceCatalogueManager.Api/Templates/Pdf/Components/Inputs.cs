using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Inputs component for PDF documents
/// </summary>
public static class Inputs
{
    public static void Compose(IContainer container, IEnumerable<InputData> inputs)
    {
        var inputList = inputs?.ToList() ?? new List<InputData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Inputs");

            if (!inputList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No inputs defined."));
                return;
            }

            // Summary
            var requiredCount = inputList.Count(i => i.IsRequired);
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                .Row(row =>
                {
                    row.AutoItem()
                        .Text($"Total: {inputList.Count} inputs")
                        .Style(PdfStyles.SmallStyle);
                    row.ConstantItem(20);
                    row.AutoItem()
                        .Text($"Required: {requiredCount}")
                        .Style(PdfStyles.SmallStyle)
                        .FontColor(PdfStyles.Colors.Danger);
                });

            // Inputs table
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);    // Name
                    columns.RelativeColumn(1);    // Type
                    columns.RelativeColumn(0.8f); // Required
                    columns.RelativeColumn(3);    // Description
                });

                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("Input Name").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Data Type").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Required").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Description").Style(PdfStyles.LabelStyle);
                });

                foreach (var input in inputList.OrderBy(i => i.SortOrder))
                {
                    table.Cell().TableCell().Column(col =>
                    {
                        col.Item().Text(input.InputName).Style(PdfStyles.BodyStyle).SemiBold();
                        if (!string.IsNullOrEmpty(input.Source))
                        {
                            col.Item().Text($"Source: {input.Source}")
                                .Style(PdfStyles.CaptionStyle);
                        }
                    });
                    
                    table.Cell().TableCell().Element(c => DataTypeBadge(c, input.DataType));
                    table.Cell().TableCell().Element(c => RequiredBadge(c, input.IsRequired));
                    table.Cell().TableCell().Column(col =>
                    {
                        col.Item().Text(input.Description ?? "-").Style(PdfStyles.SmallStyle);
                        if (!string.IsNullOrEmpty(input.ValidationRules))
                        {
                            col.Item().PaddingTop(2)
                                .Text($"Validation: {input.ValidationRules}")
                                .Style(PdfStyles.CaptionStyle)
                                .Italic();
                        }
                        if (!string.IsNullOrEmpty(input.DefaultValue))
                        {
                            col.Item().PaddingTop(2)
                                .Text($"Default: {input.DefaultValue}")
                                .Style(PdfStyles.CaptionStyle);
                        }
                    });
                }
            });

            // Sample input format
            if (inputList.Any(i => !string.IsNullOrEmpty(i.SampleValue)))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium);
                column.Item().SubsectionTitle("Sample Input Values");
                
                column.Item().Background(PdfStyles.Colors.Background)
                    .Border(1)
                    .BorderColor(PdfStyles.Colors.Border)
                    .Padding(PdfStyles.Spacing.Small)
                    .Column(sampleCol =>
                    {
                        foreach (var input in inputList.Where(i => !string.IsNullOrEmpty(i.SampleValue)))
                        {
                            sampleCol.Item().PaddingBottom(PdfStyles.Spacing.XSmall)
                                .Row(row =>
                                {
                                    row.ConstantItem(150)
                                        .Text($"{input.InputName}:")
                                        .Style(PdfStyles.LabelStyle);
                                    row.RelativeItem()
                                        .Text(input.SampleValue)
                                        .FontFamily("Courier")
                                        .FontSize(PdfStyles.FontSizes.Small);
                                });
                        }
                    });
            }
        });
    }

    private static void DataTypeBadge(IContainer container, string? dataType)
    {
        var bgColor = dataType?.ToLower() switch
        {
            "string" or "text" => "#DBEAFE",
            "number" or "integer" or "decimal" => "#D1FAE5",
            "boolean" or "bool" => "#FEF3C7",
            "date" or "datetime" => "#E0E7FF",
            "json" or "object" => "#FCE7F3",
            "array" or "list" => "#CFFAFE",
            "file" or "binary" => "#F3E8FF",
            _ => PdfStyles.Colors.Background
        };

        container.Background(bgColor)
            .Padding(1)
            .PaddingHorizontal(4)
            .Text(dataType ?? "Any")
            .FontSize(PdfStyles.FontSizes.Caption)
            .FontColor(PdfStyles.Colors.TextSecondary);
    }

    private static void RequiredBadge(IContainer container, bool isRequired)
    {
        if (isRequired)
        {
            container.Background("#FEE2E2")
                .Padding(1)
                .PaddingHorizontal(4)
                .Text("Required")
                .FontSize(PdfStyles.FontSizes.Caption)
                .FontColor("#991B1B");
        }
        else
        {
            container.Text("Optional")
                .Style(PdfStyles.CaptionStyle);
        }
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
/// Data model for Input
/// </summary>
public class InputData
{
    public int InputId { get; set; }
    public string InputName { get; set; } = string.Empty;
    public string? DataType { get; set; }
    public bool IsRequired { get; set; }
    public string? Description { get; set; }
    public string? Source { get; set; }
    public string? ValidationRules { get; set; }
    public string? DefaultValue { get; set; }
    public string? SampleValue { get; set; }
    public int SortOrder { get; set; }
}
