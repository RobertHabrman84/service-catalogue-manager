using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Models.DTOs.Export;
using ServiceCatalogueManager.Api.Models.Responses;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Functions.Export;

/// <summary>
/// Azure Functions for Export operations
/// </summary>
public class ExportFunctions
{
    private readonly IExportService _exportService;
    private readonly ILogger<ExportFunctions> _logger;

    public ExportFunctions(
        IExportService exportService,
        ILogger<ExportFunctions> logger)
    {
        _exportService = exportService;
        _logger = logger;
    }

    /// <summary>
    /// Export services to PDF
    /// </summary>
    [Function("ExportToPdf")]
    public async Task<HttpResponseData> ExportToPdf(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "export/pdf")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Exporting services to PDF");

        var exportRequest = await req.ReadFromJsonAsync<ExportRequestDto>(cancellationToken);
        exportRequest = exportRequest with { Format = ExportFormat.Pdf };

        var result = await _exportService.ExportAsync(exportRequest!, cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", result.ContentType);
        response.Headers.Add("Content-Disposition", $"attachment; filename=\"{result.FileName}\"");
        await response.Body.WriteAsync(result.Content, cancellationToken);
        return response;
    }

    /// <summary>
    /// Export services to Markdown
    /// </summary>
    [Function("ExportToMarkdown")]
    public async Task<HttpResponseData> ExportToMarkdown(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "export/markdown")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Exporting services to Markdown");

        var exportRequest = await req.ReadFromJsonAsync<ExportRequestDto>(cancellationToken);
        exportRequest = exportRequest with { Format = ExportFormat.Markdown };

        var result = await _exportService.ExportAsync(exportRequest!, cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", result.ContentType);
        response.Headers.Add("Content-Disposition", $"attachment; filename=\"{result.FileName}\"");
        await response.Body.WriteAsync(result.Content, cancellationToken);
        return response;
    }

    /// <summary>
    /// Export single service to PDF
    /// </summary>
    [Function("ExportServiceToPdf")]
    public async Task<HttpResponseData> ExportServiceToPdf(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/{id:int}/export/pdf")] HttpRequestData req,
        int id,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Exporting service {ServiceId} to PDF", id);

        var result = await _exportService.ExportServiceAsync(id, ExportFormat.Pdf, cancellationToken);

        if (result == null)
        {
            var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
            await notFoundResponse.WriteAsJsonAsync(ApiResponse<ExportResultDto>.Fail($"Service with ID {id} not found"), cancellationToken);
            return notFoundResponse;
        }

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", result.ContentType);
        response.Headers.Add("Content-Disposition", $"attachment; filename=\"{result.FileName}\"");
        await response.Body.WriteAsync(result.Content, cancellationToken);
        return response;
    }

    /// <summary>
    /// Export single service to Markdown
    /// </summary>
    [Function("ExportServiceToMarkdown")]
    public async Task<HttpResponseData> ExportServiceToMarkdown(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "services/{id:int}/export/markdown")] HttpRequestData req,
        int id,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Exporting service {ServiceId} to Markdown", id);

        var result = await _exportService.ExportServiceAsync(id, ExportFormat.Markdown, cancellationToken);

        if (result == null)
        {
            var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
            await notFoundResponse.WriteAsJsonAsync(ApiResponse<ExportResultDto>.Fail($"Service with ID {id} not found"), cancellationToken);
            return notFoundResponse;
        }

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", result.ContentType);
        response.Headers.Add("Content-Disposition", $"attachment; filename=\"{result.FileName}\"");
        await response.Body.WriteAsync(result.Content, cancellationToken);
        return response;
    }

    /// <summary>
    /// Save export to blob storage and return download URL
    /// </summary>
    [Function("SaveExport")]
    public async Task<HttpResponseData> SaveExport(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "export/save")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Saving export to blob storage");

        var exportRequest = await req.ReadFromJsonAsync<ExportRequestDto>(cancellationToken);
        var result = await _exportService.SaveExportAsync(exportRequest!, cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<SavedExportDto>.Ok(result, "Export saved successfully"), cancellationToken);
        return response;
    }

    /// <summary>
    /// Get export history
    /// </summary>
    [Function("GetExportHistory")]
    public async Task<HttpResponseData> GetExportHistory(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "export/history")] HttpRequestData req,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Getting export history");

        var history = await _exportService.GetExportHistoryAsync(cancellationToken);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(ApiResponse<IEnumerable<ExportHistoryItemDto>>.Ok(history), cancellationToken);
        return response;
    }
}
