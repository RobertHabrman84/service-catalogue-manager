using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Sizing
{
    public static void Compose(IContainer container, IEnumerable<SizingOptionData> options)
    {
        var optionList = options?.ToList() ?? new List<SizingOptionData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Sizing Options");

            if (!optionList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No sizing options defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            column.Item().Row(row =>
            {
                foreach (var option in optionList.OrderBy(o => o.SortOrder))
                {
                    row.RelativeItem().Padding(PdfStyles.Spacing.XSmall)
                        .Element(c => ComposeSizingCard(c, option));
                }
            });
        });
    }

    private static void ComposeSizingCard(IContainer container, SizingOptionData option)
    {
        var isRecommended = option.IsRecommended;
        var borderColor = isRecommended ? PdfStyles.Colors.Primary : PdfStyles.Colors.Border;

        container.Border(isRecommended ? 2 : 1).BorderColor(borderColor)
            .Column(col =>
            {
                col.Item().Background(isRecommended ? PdfStyles.Colors.Primary : PdfStyles.Colors.TableHeader)
                    .Padding(PdfStyles.Spacing.Small).AlignCenter()
                    .Text(option.SizeName)
                    .FontColor(isRecommended ? PdfStyles.Colors.White : PdfStyles.Colors.TextPrimary)
                    .Bold();

                col.Item().Padding(PdfStyles.Spacing.Small).Column(innerCol =>
                {
                    if (!string.IsNullOrEmpty(option.Description))
                        innerCol.Item().Text(option.Description).Style(PdfStyles.SmallStyle);

                    innerCol.Item().PaddingTop(PdfStyles.Spacing.Small);
                    
                    if (!string.IsNullOrEmpty(option.Users))
                        innerCol.Item().LabelValue("Users", option.Users);
                    if (!string.IsNullOrEmpty(option.Storage))
                        innerCol.Item().LabelValue("Storage", option.Storage);
                    if (!string.IsNullOrEmpty(option.Compute))
                        innerCol.Item().LabelValue("Compute", option.Compute);

                    if (option.MonthlyCost.HasValue)
                    {
                        innerCol.Item().PaddingTop(PdfStyles.Spacing.Medium).AlignCenter()
                            .Text($"${option.MonthlyCost:N0}/mo")
                            .FontSize(16).FontColor(PdfStyles.Colors.Primary).Bold();
                    }
                });

                if (isRecommended)
                    col.Item().Background(PdfStyles.Colors.Success).Padding(4).AlignCenter()
                        .Text("RECOMMENDED").FontSize(8).FontColor(PdfStyles.Colors.White).Bold();
            });
    }
}

public class SizingOptionData
{
    public int SizingId { get; set; }
    public string SizeName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Users { get; set; }
    public string? Storage { get; set; }
    public string? Compute { get; set; }
    public decimal? MonthlyCost { get; set; }
    public bool IsRecommended { get; set; }
    public int SortOrder { get; set; }
}
