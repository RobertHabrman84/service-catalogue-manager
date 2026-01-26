using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Components;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf;

public class CatalogPdfTemplate : IDocument
{
    private readonly CatalogPdfData _data;
    public CatalogPdfTemplate(CatalogPdfData data) => _data = data;

    public DocumentMetadata GetMetadata() => new()
    {
        Title = _data.CatalogTitle ?? "Service Catalogue",
        Author = _data.Author ?? "Service Catalogue Manager",
        Creator = "SCM PDF Generator",
        Subject = "Service Catalogue Export"
    };

    public void Compose(IDocumentContainer container)
    {
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(PdfStyles.Page.MarginLeft, Unit.Point);
            page.DefaultTextStyle(x => x.FontSize(PdfStyles.FontSizes.Body));

            page.Header().Element(ComposeHeader);
            page.Content().Element(ComposeContent);
            page.Footer().Element(ComposeFooter);
        });
    }

    private void ComposeHeader(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Text(_data.CatalogTitle ?? "Service Catalogue").Style(PdfStyles.Heading2Style);
            row.ConstantItem(100).AlignRight().Text(DateTime.UtcNow.ToString("MMM yyyy")).Style(PdfStyles.CaptionStyle);
        });
    }

    private void ComposeFooter(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Text($"Generated: {DateTime.UtcNow:MMM dd, yyyy HH:mm}").Style(PdfStyles.CaptionStyle);
            row.RelativeItem().AlignCenter().Text(x =>
            {
                x.Span("Page ").Style(PdfStyles.CaptionStyle);
                x.CurrentPageNumber().Style(PdfStyles.CaptionStyle);
                x.Span(" of ").Style(PdfStyles.CaptionStyle);
                x.TotalPages().Style(PdfStyles.CaptionStyle);
            });
            row.RelativeItem().AlignRight().Text("Service Catalogue Manager").Style(PdfStyles.CaptionStyle);
        });
    }

    private void ComposeContent(IContainer container)
    {
        container.Column(column =>
        {
            // Cover Page
            column.Item().Element(c => CoverPage.Compose(c, new CoverPageData
            {
                DocumentType = "Service Catalogue",
                Title = _data.CatalogTitle ?? "Service Catalogue",
                Subtitle = $"{_data.Services?.Count() ?? 0} Services",
                Author = _data.Author,
                GeneratedDate = DateTime.UtcNow,
                Organization = _data.Organization
            }));

            // Table of Contents
            column.Item().PageBreak();
            column.Item().Element(c => ComposeCatalogToc(c));

            // Summary Statistics
            column.Item().PageBreak();
            column.Item().Element(c => ComposeSummary(c));

            // Services by Category
            var grouped = (_data.Services ?? Enumerable.Empty<CatalogServiceSummary>())
                .GroupBy(s => s.CategoryName ?? "Uncategorized")
                .OrderBy(g => g.Key);

            foreach (var category in grouped)
            {
                column.Item().PageBreak();
                column.Item().Element(c => ComposeCategorySection(c, category.Key, category.ToList()));
            }
        });
    }

    private void ComposeCatalogToc(IContainer container)
    {
        var grouped = (_data.Services ?? Enumerable.Empty<CatalogServiceSummary>())
            .GroupBy(s => s.CategoryName ?? "Uncategorized")
            .OrderBy(g => g.Key);

        container.Column(column =>
        {
            column.Item().SectionTitle("Table of Contents");
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium);

            column.Item().NumberedItem(1, "Summary Statistics");
            
            int num = 2;
            foreach (var category in grouped)
            {
                column.Item().NumberedItem(num++, $"{category.Key} ({category.Count()} services)");
            }
        });
    }

    private void ComposeSummary(IContainer container)
    {
        var services = _data.Services?.ToList() ?? new List<CatalogServiceSummary>();
        var activeCount = services.Count(s => s.IsActive);
        var categoryCounts = services.GroupBy(s => s.CategoryName ?? "Other")
            .Select(g => new { Category = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .ToList();

        container.Column(column =>
        {
            column.Item().SectionTitle("Summary Statistics");

            column.Item().Row(row =>
            {
                row.RelativeItem().Element(c => StatCard(c, "Total Services", services.Count.ToString()));
                row.ConstantItem(PdfStyles.Spacing.Medium);
                row.RelativeItem().Element(c => StatCard(c, "Active", activeCount.ToString(), PdfStyles.Colors.Success));
                row.ConstantItem(PdfStyles.Spacing.Medium);
                row.RelativeItem().Element(c => StatCard(c, "Inactive", (services.Count - activeCount).ToString(), PdfStyles.Colors.Danger));
                row.ConstantItem(PdfStyles.Spacing.Medium);
                row.RelativeItem().Element(c => StatCard(c, "Categories", categoryCounts.Count.ToString()));
            });

            column.Item().PaddingTop(PdfStyles.Spacing.Large);
            column.Item().SubsectionTitle("Services by Category");

            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(1);
                    columns.RelativeColumn(3);
                });

                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("Category").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Count").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Distribution").Style(PdfStyles.LabelStyle);
                });

                foreach (var cat in categoryCounts)
                {
                    var percentage = services.Count > 0 ? (float)cat.Count / services.Count : 0;
                    
                    table.Cell().TableCell().Text(cat.Category).Style(PdfStyles.BodyStyle);
                    table.Cell().TableCell().Text(cat.Count.ToString()).Style(PdfStyles.BodyStyle).Bold();
                    table.Cell().TableCell().PaddingVertical(4).Row(bar =>
                    {
                        bar.RelativeItem(percentage).Height(12).Background(PdfStyles.Colors.PrimaryLight);
                        bar.RelativeItem(1 - percentage).Height(12).Background(PdfStyles.Colors.Background);
                    });
                }
            });
        });
    }

    private void StatCard(IContainer container, string label, string value, string? color = null)
    {
        container.Background(PdfStyles.Colors.Background)
            .Border(1).BorderColor(PdfStyles.Colors.Border)
            .Padding(PdfStyles.Spacing.Medium)
            .Column(col =>
            {
                col.Item().AlignCenter().Text(value)
                    .FontSize(28).FontColor(color ?? PdfStyles.Colors.Primary).Bold();
                col.Item().AlignCenter().Text(label).Style(PdfStyles.SmallStyle);
            });
    }

    private void ComposeCategorySection(IContainer container, string categoryName, List<CatalogServiceSummary> services)
    {
        container.Column(column =>
        {
            column.Item().SectionTitle(categoryName);
            column.Item().Text($"{services.Count} services in this category").Style(PdfStyles.SmallStyle);
            column.Item().PaddingTop(PdfStyles.Spacing.Medium);

            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(80);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(1);
                    columns.RelativeColumn(3);
                });

                table.Header(header =>
                {
                    header.Cell().TableHeaderCell().Text("Code").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Service Name").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Status").Style(PdfStyles.LabelStyle);
                    header.Cell().TableHeaderCell().Text("Description").Style(PdfStyles.LabelStyle);
                });

                foreach (var service in services.OrderBy(s => s.ServiceCode))
                {
                    table.Cell().TableCell().Text(service.ServiceCode).Style(PdfStyles.SmallStyle);
                    table.Cell().TableCell().Text(service.ServiceName).Style(PdfStyles.BodyStyle).SemiBold();
                    table.Cell().TableCell().Element(c => c.StatusBadge(service.IsActive ? "Active" : "Inactive", service.IsActive));
                    table.Cell().TableCell().Text(Truncate(service.Description, 100)).Style(PdfStyles.SmallStyle);
                }
            });
        });
    }

    private static string Truncate(string? text, int maxLength)
    {
        if (string.IsNullOrEmpty(text)) return "-";
        return text.Length <= maxLength ? text : text[..(maxLength - 3)] + "...";
    }
}

public class CatalogPdfData
{
    public string? CatalogTitle { get; set; }
    public string? Author { get; set; }
    public string? Organization { get; set; }
    public IEnumerable<CatalogServiceSummary>? Services { get; set; }
}

public class CatalogServiceSummary
{
    public int ServiceId { get; set; }
    public string ServiceCode { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CategoryName { get; set; }
    public bool IsActive { get; set; }
    public string? Version { get; set; }
}
