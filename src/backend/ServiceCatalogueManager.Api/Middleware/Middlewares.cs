using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker.Middleware;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Exceptions;
using ServiceCatalogueManager.Api.Models.Responses;

namespace ServiceCatalogueManager.Api.Middleware;

/// <summary>
/// Exception handling middleware for Azure Functions
/// </summary>
public class ExceptionHandlingMiddleware : IFunctionsWorkerMiddleware
{
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(ILogger<ExceptionHandlingMiddleware> logger)
    {
        _logger = logger;
    }

    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception in function {FunctionName}", context.FunctionDefinition.Name);
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(FunctionContext context, Exception exception)
    {
        var httpReqData = await context.GetHttpRequestDataAsync();
        if (httpReqData == null) return;

        HttpStatusCode statusCode;
        object errorResponse;

        switch (exception)
        {
            case NotFoundException ex:
                statusCode = HttpStatusCode.NotFound;
                errorResponse = CreateErrorResponse(ex, 404);
                break;
            case ValidationException ex:
                statusCode = HttpStatusCode.BadRequest;
                errorResponse = CreateValidationErrorResponse(ex);
                break;
            case UnauthorizedException ex:
                statusCode = HttpStatusCode.Unauthorized;
                errorResponse = CreateErrorResponse(ex, 401);
                break;
            case ForbiddenException ex:
                statusCode = HttpStatusCode.Forbidden;
                errorResponse = CreateErrorResponse(ex, 403);
                break;
            case ConflictException ex:
                statusCode = HttpStatusCode.Conflict;
                errorResponse = CreateErrorResponse(ex, 409);
                break;
            default:
                statusCode = HttpStatusCode.InternalServerError;
                errorResponse = CreateErrorResponse(exception, 500);
                break;
        }

        var response = httpReqData.CreateResponse(statusCode);
        await response.WriteAsJsonAsync(errorResponse);
        context.GetInvocationResult().Value = response;
    }

    private static ErrorResponse CreateErrorResponse(Exception ex, int statusCode)
    {
        return new ErrorResponse
        {
            Type = ex.GetType().Name,
            Title = ex.Message,
            Status = statusCode,
            Detail = statusCode == 500 ? "An unexpected error occurred" : ex.Message,
            TraceId = Activity.Current?.Id ?? Guid.NewGuid().ToString()
        };
    }

    private static ValidationErrorResponse CreateValidationErrorResponse(ValidationException ex)
    {
        return new ValidationErrorResponse
        {
            Errors = ex.Errors
        };
    }
}

/// <summary>
/// Correlation ID middleware for request tracking
/// </summary>
public class CorrelationIdMiddleware : IFunctionsWorkerMiddleware
{
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        var correlationId = GetOrCreateCorrelationId(context);
        context.Items["CorrelationId"] = correlationId;

        using (_logger.BeginScope(new Dictionary<string, object> { ["CorrelationId"] = correlationId }))
        {
            await next(context);
        }

        // Add correlation ID to response headers
        await AddCorrelationIdToResponse(context, correlationId);
    }

    private readonly ILogger<CorrelationIdMiddleware> _logger;

    public CorrelationIdMiddleware(ILogger<CorrelationIdMiddleware> logger)
    {
        _logger = logger;
    }

    private static string GetOrCreateCorrelationId(FunctionContext context)
    {
        var httpReqData = context.GetHttpRequestDataAsync().GetAwaiter().GetResult();
        if (httpReqData != null && httpReqData.Headers.TryGetValues(CorrelationIdHeader, out var values))
        {
            return values.First();
        }
        return Guid.NewGuid().ToString();
    }

    private static Task AddCorrelationIdToResponse(FunctionContext context, string correlationId)
    {
        var result = context.GetInvocationResult();
        if (result.Value is HttpResponseData response)
        {
            response.Headers.Add(CorrelationIdHeader, correlationId);
        }
        return Task.CompletedTask;
    }
}

/// <summary>
/// Logging middleware for request/response logging
/// </summary>
public class RequestLoggingMiddleware : IFunctionsWorkerMiddleware
{
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(ILogger<RequestLoggingMiddleware> logger)
    {
        _logger = logger;
    }

    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        var sw = System.Diagnostics.Stopwatch.StartNew();
        var httpReqData = await context.GetHttpRequestDataAsync();

        _logger.LogInformation(
            "Function {FunctionName} started - Method: {Method}, Path: {Path}",
            context.FunctionDefinition.Name,
            httpReqData?.Method ?? "N/A",
            httpReqData?.Url.PathAndQuery ?? "N/A");

        await next(context);

        sw.Stop();

        var result = context.GetInvocationResult();
        var statusCode = (result.Value as HttpResponseData)?.StatusCode ?? HttpStatusCode.OK;

        _logger.LogInformation(
            "Function {FunctionName} completed - StatusCode: {StatusCode}, Duration: {Duration}ms",
            context.FunctionDefinition.Name,
            (int)statusCode,
            sw.ElapsedMilliseconds);
    }
}

// Dummy Activity class for compatibility
internal static class Activity
{
    public static ActivityInfo? Current => null;
}

internal class ActivityInfo
{
    public string? Id { get; set; }
}
