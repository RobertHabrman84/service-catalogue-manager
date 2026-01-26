using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// PDF generation service using QuestPDF
/// </summary>
public class PdfGeneratorService : IPdfGeneratorService
{
    private readonly ILogger<PdfGeneratorService> _logger;

    public PdfGeneratorService(ILogger<PdfGeneratorService> logger)
    {
        _logger = logger;
        
        // QuestPDF license configuration
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public async Task<byte[]> GenerateServicePdfAsync(ServiceCatalogFullDto service, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Generating PDF for service: {ServiceCode}", service.ServiceCode);

        return await Task.Run(() =>
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    // Header
                    page.Header().Row(row =>
                    {
                        row.RelativeItem().Column(column =>
                        {
                            column.Item().Text(service.ServiceName)
                                .FontSize(20)
                                .Bold()
                                .FontColor(Colors.Blue.Darken2);
                            
                            column.Item().Text($"Code: {service.ServiceCode}")
                                .FontSize(12)
                                .FontColor(Colors.Grey.Darken1);
                        });
                    });

                    // Content
                    page.Content().Column(column =>
                    {
                        column.Spacing(10);

                        // Overview Section
                        AddSection(column, "Overview", () =>
                        {
                            column.Item().Text($"Category: {service.CategoryName}");
                            column.Item().Text($"Version: {service.Version}");
                            column.Item().Text($"Status: {(service.IsActive ? "Active" : "Inactive")}");
                            
                            if (!string.IsNullOrEmpty(service.Description))
                            {
                                column.Item().PaddingTop(5).Text("Description:");
                                column.Item().Text(service.Description);
                            }
                        });

                        // Usage Scenarios
                        if (service.UsageScenarios?.Any() == true)
                        {
                            AddSection(column, "Usage Scenarios", () =>
                            {
                                foreach (var scenario in service.UsageScenarios)
                                {
                                    column.Item().Text($"• {scenario.ScenarioTitle}").Bold();
                                    if (!string.IsNullOrEmpty(scenario.ScenarioDescription))
                                    {
                                        column.Item().PaddingLeft(15).Text(scenario.ScenarioDescription);
                                    }
                                }
                            });
                        }

                        // Prerequisites
                        if (service.Prerequisites?.Any() == true)
                        {
                            AddSection(column, "Prerequisites", () =>
                            {
                                foreach (var prereq in service.Prerequisites)
                                {
                                    column.Item().Text($"• {prereq.PrerequisiteName}");
                                }
                            });
                        }

                        // Dependencies
                        if (service.Dependencies?.Any() == true)
                        {
                            AddSection(column, "Dependencies", () =>
                            {
                                foreach (var dep in service.Dependencies)
                                {
                                    column.Item().Text($"• {dep.DependencyName} ({dep.DependencyTypeName})");
                                }
                            });
                        }

                        // Size Options
                        if (service.SizeOptions?.Any() == true)
                        {
                            AddSection(column, "Size Options", () =>
                            {
                                foreach (var size in service.SizeOptions)
                                {
                                    column.Item().Text($"• {size.SizeName}: {size.EstimatedDays} days");
                                }
                            });
                        }
                    });

                    // Footer
                    page.Footer().Row(row =>
                    {
                        row.RelativeItem().Text(text =>
                        {
                            text.Span("Generated: ");
                            text.Span(DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm UTC")).Bold();
                        });
                        
                        row.RelativeItem().AlignRight().Text(text =>
                        {
                            text.CurrentPageNumber();
                            text.Span(" / ");
                            text.TotalPages();
                        });
                    });
                });
            });

            return document.GeneratePdf();
        }, cancellationToken);
    }

    public async Task<byte[]> GenerateCatalogPdfAsync(IEnumerable<ServiceCatalogFullDto> services, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Generating catalog PDF for {Count} services", services.Count());

        return await Task.Run(() =>
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    // Header
                    page.Header().Row(row =>
                    {
                        row.RelativeItem().Text("Service Catalog")
                            .FontSize(24)
                            .Bold()
                            .FontColor(Colors.Blue.Darken2);
                    });

                    // Content
                    page.Content().Column(column =>
                    {
                        column.Spacing(15);

                        foreach (var service in services)
                        {
                            column.Item().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingBottom(10);
                            
                            column.Item().Text(service.ServiceName)
                                .FontSize(16)
                                .Bold();
                            
                            column.Item().Text($"Code: {service.ServiceCode} | Category: {service.CategoryName}");
                            
                            if (!string.IsNullOrEmpty(service.Description))
                            {
                                column.Item().PaddingTop(5).Text(service.Description);
                            }
                        }
                    });

                    // Footer
                    page.Footer().Row(row =>
                    {
                        row.RelativeItem().Text($"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm UTC}");
                        row.RelativeItem().AlignRight().Text(text =>
                        {
                            text.CurrentPageNumber();
                            text.Span(" / ");
                            text.TotalPages();
                        });
                    });
                });
            });

            return document.GeneratePdf();
        }, cancellationToken);
    }

    private static void AddSection(ColumnDescriptor column, string title, Action content)
    {
        column.Item().PaddingTop(10).Text(title)
            .FontSize(14)
            .Bold()
            .FontColor(Colors.Blue.Darken1);
        
        column.Item().PaddingLeft(10).Column(sectionColumn =>
        {
            content();
        });
    }
}
