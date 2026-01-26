using System.Text;
using Microsoft.Extensions.Logging;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Models.DTOs.Export;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Export service implementation
/// </summary>
public class ExportService : IExportService
{
    private readonly IServiceCatalogService _serviceCatalogService;
    private readonly IBlobStorageService _blobStorageService;
    private readonly ILogger<ExportService> _logger;

    public ExportService(
        IServiceCatalogService serviceCatalogService,
        IBlobStorageService blobStorageService,
        ILogger<ExportService> logger)
    {
        _serviceCatalogService = serviceCatalogService;
        _blobStorageService = blobStorageService;
        _logger = logger;

        QuestPDF.Settings.License = LicenseType.Community;
    }

    public async Task<ExportResultDto> ExportAsync(ExportRequestDto request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Exporting {Count} services to {Format}", request.ServiceIds?.Length ?? 0, request.Format);

        var services = new List<ServiceCatalogFullDto>();
        if (request.ServiceIds?.Any() == true)
        {
            foreach (var id in request.ServiceIds)
            {
                var service = await _serviceCatalogService.GetServiceFullAsync(id, cancellationToken);
                if (service != null)
                    services.Add(service);
            }
        }

        return request.Format switch
        {
            ExportFormat.Pdf => GeneratePdfExport(services, request.Options),
            ExportFormat.Markdown => GenerateMarkdownExport(services, request.Options),
            ExportFormat.UuBookKit => GenerateUuBookKitExport(services, request.Options),
            _ => throw new ArgumentOutOfRangeException(nameof(request.Format))
        };
    }

    public async Task<ExportResultDto?> ExportServiceAsync(int serviceId, ExportFormat format, CancellationToken cancellationToken = default)
    {
        var service = await _serviceCatalogService.GetServiceByIdAsync(serviceId, cancellationToken);
        if (service == null) return null;

        var request = new ExportRequestDto
        {
            ServiceIds = new[] { serviceId },
            Format = format,
            Options = new ExportOptions()
        };

        return await ExportAsync(request, cancellationToken);
    }

    public async Task<SavedExportDto> SaveExportAsync(ExportRequestDto request, CancellationToken cancellationToken = default)
    {
        var export = await ExportAsync(request, cancellationToken);
        var exportId = Guid.NewGuid().ToString("N");
        var blobName = $"exports/{exportId}/{export.FileName}";

        await _blobStorageService.UploadAsync("exports", blobName, export.Content, export.ContentType, cancellationToken);
        var downloadUrl = await _blobStorageService.GetSasUrlAsync("exports", blobName, TimeSpan.FromHours(24), cancellationToken);

        return new SavedExportDto
        {
            ExportId = exportId,
            DownloadUrl = downloadUrl,
            ExpiresAt = DateTime.UtcNow.AddHours(24)
        };
    }

    public Task<IEnumerable<ExportHistoryItemDto>> GetExportHistoryAsync(CancellationToken cancellationToken = default)
    {
        // Would normally fetch from database
        return Task.FromResult(Enumerable.Empty<ExportHistoryItemDto>());
    }

    private ExportResultDto GeneratePdfExport(List<ServiceCatalogFullDto> services, ExportOptions options)
    {
        var document = Document.Create(container =>
        {
            foreach (var service in services)
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(50);
                    page.DefaultTextStyle(x => x.FontSize(10));

                    page.Header().Element(c => ComposeHeader(c, service, options));
                    page.Content().Element(c => ComposeContent(c, service, options));
                    page.Footer().Element(c => ComposeFooter(c, options));
                });
            }
        });

        var pdfBytes = document.GeneratePdf();
        var fileName = services.Count == 1
            ? $"{services[0].ServiceCode}_v{services[0].Version}.pdf"
            : $"ServiceCatalog_Export_{DateTime.UtcNow:yyyyMMdd_HHmmss}.pdf";

        return new ExportResultDto
        {
            FileName = fileName,
            ContentType = "application/pdf",
            Content = pdfBytes,
            FileSizeBytes = pdfBytes.Length,
            ServiceCount = services.Count,
            Format = ExportFormat.Pdf
        };
    }

    private static void ComposeHeader(IContainer container, ServiceCatalogFullDto service, ExportOptions options)
    {
        container.Row(row =>
        {
            row.RelativeItem().Column(column =>
            {
                column.Item().Text(service.ServiceName).Bold().FontSize(18);
                column.Item().Text($"{service.ServiceCode} | {service.Version}").FontSize(12).FontColor(Colors.Grey.Medium);
            });

            if (!string.IsNullOrEmpty(options.CustomHeader))
            {
                row.ConstantItem(150).AlignRight().Text(options.CustomHeader).FontSize(8);
            }
        });
    }

    private static void ComposeContent(IContainer container, ServiceCatalogFullDto service, ExportOptions options)
    {
        container.PaddingVertical(20).Column(column =>
        {
            column.Spacing(15);

            // Description
            column.Item().Text("Description").Bold().FontSize(12);
            column.Item().Text(service.Description);

            // Usage Scenarios
            if (options.IncludeUsageScenarios && service.UsageScenarios.Any())
            {
                column.Item().Text("Usage Scenarios").Bold().FontSize(12);
                foreach (var scenario in service.UsageScenarios.OrderBy(s => s.SortOrder))
                {
                    column.Item().Text($"{scenario.ScenarioNumber}. {scenario.ScenarioTitle}").SemiBold();
                    column.Item().PaddingLeft(20).Text(scenario.ScenarioDescription);
                }
            }

            // Dependencies
            if (options.IncludeDependencies && service.Dependencies.Any())
            {
                column.Item().Text("Dependencies").Bold().FontSize(12);
                column.Item().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(2);
                        columns.RelativeColumn(2);
                        columns.RelativeColumn(1);
                    });

                    table.Header(header =>
                    {
                        header.Cell().Text("Type").Bold();
                        header.Cell().Text("Service").Bold();
                        header.Cell().Text("Level").Bold();
                    });

                    foreach (var dep in service.Dependencies.OrderBy(d => d.SortOrder))
                    {
                        table.Cell().Text(dep.DependencyTypeName ?? "");
                        table.Cell().Text(dep.DependentServiceName ?? "");
                        table.Cell().Text(dep.RequirementLevelName ?? "");
                    }
                });
            }

            // Notes
            if (options.IncludeNotes && !string.IsNullOrEmpty(service.Notes))
            {
                column.Item().Text("Notes").Bold().FontSize(12);
                column.Item().Text(service.Notes);
            }
        });
    }

    private static void ComposeFooter(IContainer container, ExportOptions options)
    {
        container.Row(row =>
        {
            if (options.IncludePageNumbers)
            {
                row.RelativeItem().AlignLeft().Text(x =>
                {
                    x.Span("Page ");
                    x.CurrentPageNumber();
                    x.Span(" of ");
                    x.TotalPages();
                });
            }

            row.RelativeItem().AlignRight().Text($"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC").FontSize(8);
        });
    }

    private ExportResultDto GenerateMarkdownExport(List<ServiceCatalogFullDto> services, ExportOptions options)
    {
        var sb = new StringBuilder();

        foreach (var service in services)
        {
            sb.AppendLine($"# {service.ServiceName}");
            sb.AppendLine();
            sb.AppendLine($"**Code:** {service.ServiceCode} | **Version:** {service.Version} | **Category:** {service.CategoryName}");
            sb.AppendLine();
            sb.AppendLine("## Description");
            sb.AppendLine();
            sb.AppendLine(service.Description);
            sb.AppendLine();

            if (options.IncludeUsageScenarios && service.UsageScenarios.Any())
            {
                sb.AppendLine("## Usage Scenarios");
                sb.AppendLine();
                foreach (var scenario in service.UsageScenarios.OrderBy(s => s.SortOrder))
                {
                    sb.AppendLine($"### {scenario.ScenarioNumber}. {scenario.ScenarioTitle}");
                    sb.AppendLine();
                    sb.AppendLine(scenario.ScenarioDescription);
                    sb.AppendLine();
                }
            }

            if (options.IncludeDependencies && service.Dependencies.Any())
            {
                sb.AppendLine("## Dependencies");
                sb.AppendLine();
                sb.AppendLine("| Type | Service | Level | Notes |");
                sb.AppendLine("|------|---------|-------|-------|");
                foreach (var dep in service.Dependencies.OrderBy(d => d.SortOrder))
                {
                    sb.AppendLine($"| {dep.DependencyTypeName} | {dep.DependentServiceName} | {dep.RequirementLevelName} | {dep.Notes} |");
                }
                sb.AppendLine();
            }

            if (options.IncludeNotes && !string.IsNullOrEmpty(service.Notes))
            {
                sb.AppendLine("## Notes");
                sb.AppendLine();
                sb.AppendLine(service.Notes);
                sb.AppendLine();
            }

            sb.AppendLine("---");
            sb.AppendLine();
        }

        var content = Encoding.UTF8.GetBytes(sb.ToString());
        var fileName = services.Count == 1
            ? $"{services[0].ServiceCode}_v{services[0].Version}.md"
            : $"ServiceCatalog_Export_{DateTime.UtcNow:yyyyMMdd_HHmmss}.md";

        return new ExportResultDto
        {
            FileName = fileName,
            ContentType = "text/markdown",
            Content = content,
            FileSizeBytes = content.Length,
            ServiceCount = services.Count,
            Format = ExportFormat.Markdown
        };
    }

    private ExportResultDto GenerateUuBookKitExport(List<ServiceCatalogFullDto> services, ExportOptions options)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<uu5string/>");

        foreach (var service in services)
        {
            sb.AppendLine($"<UU5.Bricks.Header level=\"1\">{service.ServiceName}</UU5.Bricks.Header>");
            sb.AppendLine($"<UU5.Bricks.P><UU5.Bricks.Strong>Code:</UU5.Bricks.Strong> {service.ServiceCode} | <UU5.Bricks.Strong>Version:</UU5.Bricks.Strong> {service.Version}</UU5.Bricks.P>");
            sb.AppendLine($"<UU5.Bricks.Section header=\"Description\">");
            sb.AppendLine($"<UU5.Bricks.P>{service.Description}</UU5.Bricks.P>");
            sb.AppendLine("</UU5.Bricks.Section>");
        }

        var content = Encoding.UTF8.GetBytes(sb.ToString());
        var fileName = $"ServiceCatalog_UuBookKit_{DateTime.UtcNow:yyyyMMdd_HHmmss}.uu5";

        return new ExportResultDto
        {
            FileName = fileName,
            ContentType = "text/plain",
            Content = content,
            FileSizeBytes = content.Length,
            ServiceCount = services.Count,
            Format = ExportFormat.UuBookKit
        };
    }
}
