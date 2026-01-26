using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class MultiCloud
{
    public static void Compose(IContainer container, MultiCloudData data)
    {
        container.Column(column =>
        {
            column.Item().SectionTitle("Multi-Cloud Considerations");

            if (data?.CloudProviders?.Any() != true)
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No multi-cloud configuration defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            column.Item().Row(row =>
            {
                foreach (var provider in data.CloudProviders.OrderBy(p => p.SortOrder))
                {
                    row.RelativeItem().Padding(PdfStyles.Spacing.XSmall)
                        .Element(c => ComposeProviderCard(c, provider));
                }
            });

            if (!string.IsNullOrEmpty(data.MigrationNotes))
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium);
                column.Item().InfoBox("Migration Notes", data.MigrationNotes);
            }
        });
    }

    private static void ComposeProviderCard(IContainer container, CloudProviderData provider)
    {
        var (bgColor, textColor) = provider.ProviderName?.ToLower() switch
        {
            "azure" => ("#0078D4", "#FFFFFF"),
            "aws" => ("#FF9900", "#000000"),
            "gcp" or "google" => ("#4285F4", "#FFFFFF"),
            _ => (PdfStyles.Colors.Primary, PdfStyles.Colors.White)
        };

        container.Border(1).BorderColor(PdfStyles.Colors.Border).Column(col =>
        {
            col.Item().Background(bgColor).Padding(PdfStyles.Spacing.Small).AlignCenter()
                .Text(provider.ProviderName ?? "Unknown").FontColor(textColor).Bold();

            col.Item().Padding(PdfStyles.Spacing.Small).Column(innerCol =>
            {
                if (provider.IsSupported)
                {
                    innerCol.Item().Row(r =>
                    {
                        r.ConstantItem(15).Text("✓").FontColor(PdfStyles.Colors.Success);
                        r.RelativeItem().Text("Supported").Style(PdfStyles.SmallStyle);
                    });
                }
                else
                {
                    innerCol.Item().Row(r =>
                    {
                        r.ConstantItem(15).Text("✗").FontColor(PdfStyles.Colors.Danger);
                        r.RelativeItem().Text("Not Supported").Style(PdfStyles.SmallStyle);
                    });
                }

                if (!string.IsNullOrEmpty(provider.Services))
                {
                    innerCol.Item().PaddingTop(PdfStyles.Spacing.Small);
                    innerCol.Item().Text("Services:").Style(PdfStyles.LabelStyle);
                    innerCol.Item().Text(provider.Services).Style(PdfStyles.CaptionStyle);
                }

                if (!string.IsNullOrEmpty(provider.Notes))
                {
                    innerCol.Item().PaddingTop(PdfStyles.Spacing.Small);
                    innerCol.Item().Text(provider.Notes).Style(PdfStyles.CaptionStyle).Italic();
                }
            });
        });
    }
}

public class MultiCloudData
{
    public IEnumerable<CloudProviderData>? CloudProviders { get; set; }
    public string? MigrationNotes { get; set; }
}

public class CloudProviderData
{
    public int ProviderId { get; set; }
    public string? ProviderName { get; set; }
    public bool IsSupported { get; set; }
    public string? Services { get; set; }
    public string? Notes { get; set; }
    public int SortOrder { get; set; }
}
