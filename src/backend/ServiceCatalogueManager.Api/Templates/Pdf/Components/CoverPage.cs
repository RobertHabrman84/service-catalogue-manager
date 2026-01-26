using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Cover page component for PDF documents
/// </summary>
public static class CoverPage
{
    public static void Compose(IContainer container, CoverPageData data)
    {
        container.Column(column =>
        {
            // Top spacing
            column.Item().Height(100);

            // Logo placeholder
            column.Item().AlignCenter().Width(120).Height(60)
                .Background(PdfStyles.Colors.Primary)
                .AlignCenter()
                .AlignMiddle()
                .Text("SCM")
                .FontSize(24)
                .FontColor(PdfStyles.Colors.White)
                .Bold();

            column.Item().Height(40);

            // Document type
            column.Item().AlignCenter()
                .Text(data.DocumentType)
                .Style(PdfStyles.SubtitleStyle);

            column.Item().Height(20);

            // Main title
            column.Item().AlignCenter()
                .Text(data.Title)
                .Style(PdfStyles.TitleStyle);

            // Subtitle (if any)
            if (!string.IsNullOrEmpty(data.Subtitle))
            {
                column.Item().Height(10);
                column.Item().AlignCenter()
                    .Text(data.Subtitle)
                    .Style(PdfStyles.SubtitleStyle);
            }

            // Version badge
            if (!string.IsNullOrEmpty(data.Version))
            {
                column.Item().Height(20);
                column.Item().AlignCenter()
                    .Container()
                    .Background(PdfStyles.Colors.PrimaryLight)
                    .Padding(8)
                    .PaddingHorizontal(16)
                    .Text($"Version {data.Version}")
                    .FontColor(PdfStyles.Colors.White)
                    .FontSize(12);
            }

            // Spacer
            column.Item().ExtendVertical();

            // Metadata section
            column.Item().AlignCenter().Width(300).Column(metaCol =>
            {
                if (!string.IsNullOrEmpty(data.Category))
                {
                    metaCol.Item().Row(row =>
                    {
                        row.RelativeItem().AlignRight().PaddingRight(10)
                            .Text("Category:").Style(PdfStyles.LabelStyle);
                        row.RelativeItem()
                            .Text(data.Category).Style(PdfStyles.ValueStyle);
                    });
                    metaCol.Item().Height(5);
                }

                if (!string.IsNullOrEmpty(data.Author))
                {
                    metaCol.Item().Row(row =>
                    {
                        row.RelativeItem().AlignRight().PaddingRight(10)
                            .Text("Author:").Style(PdfStyles.LabelStyle);
                        row.RelativeItem()
                            .Text(data.Author).Style(PdfStyles.ValueStyle);
                    });
                    metaCol.Item().Height(5);
                }

                metaCol.Item().Row(row =>
                {
                    row.RelativeItem().AlignRight().PaddingRight(10)
                        .Text("Generated:").Style(PdfStyles.LabelStyle);
                    row.RelativeItem()
                        .Text(data.GeneratedDate.ToString("MMMM dd, yyyy")).Style(PdfStyles.ValueStyle);
                });

                if (data.Status != null)
                {
                    metaCol.Item().Height(10);
                    metaCol.Item().AlignCenter()
                        .Container()
                        .StatusBadge(data.Status, data.IsActive);
                }
            });

            column.Item().Height(40);

            // Footer
            column.Item().AlignCenter()
                .Text(data.Organization ?? "Service Catalogue Manager")
                .Style(PdfStyles.CaptionStyle);

            column.Item().Height(5);

            column.Item().AlignCenter()
                .Text(data.Confidentiality ?? "Internal Use Only")
                .FontSize(8)
                .FontColor(PdfStyles.Colors.TextMuted);
        });
    }
}

/// <summary>
/// Data model for cover page
/// </summary>
public class CoverPageData
{
    public string DocumentType { get; set; } = "Service Catalogue";
    public string Title { get; set; } = string.Empty;
    public string? Subtitle { get; set; }
    public string? Version { get; set; }
    public string? Category { get; set; }
    public string? Author { get; set; }
    public DateTime GeneratedDate { get; set; } = DateTime.UtcNow;
    public string? Status { get; set; }
    public bool IsActive { get; set; } = true;
    public string? Organization { get; set; }
    public string? Confidentiality { get; set; }
}
