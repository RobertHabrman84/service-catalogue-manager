using System.Security.Claims;
using FluentValidation;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Mappers;
using ServiceCatalogueManager.Api.Services.Implementations;
using ServiceCatalogueManager.Api.Services.Interfaces;
using ServiceCatalogueManager.Api.Validators;

namespace ServiceCatalogueManager.Api.Extensions;

/// <summary>
/// Extension methods for IServiceCollection
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Add database context with connection string
    /// </summary>
    public static IServiceCollection AddDatabase(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<ServiceCatalogDbContext>(options =>
            options.UseSqlServer(connectionString, sqlOptions =>
            {
                sqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 3,
                    maxRetryDelay: TimeSpan.FromSeconds(30),
                    errorNumbersToAdd: null);
                sqlOptions.CommandTimeout(30);
            }));

        return services;
    }

    /// <summary>
    /// Add application services
    /// </summary>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IServiceCatalogService, ServiceCatalogService>();
        services.AddScoped<ILookupService, LookupService>();
        services.AddScoped<IExportService, ExportService>();
        
        return services;
    }

    /// <summary>
    /// Add AutoMapper
    /// </summary>
    public static IServiceCollection AddMapping(this IServiceCollection services)
    {
        services.AddAutoMapper(typeof(MappingProfile));
        return services;
    }

    /// <summary>
    /// Add FluentValidation validators
    /// </summary>
    public static IServiceCollection AddValidators(this IServiceCollection services)
    {
        services.AddValidatorsFromAssemblyContaining<ServiceCatalogCreateValidator>();
        return services;
    }

    /// <summary>
    /// Add caching
    /// </summary>
    public static IServiceCollection AddCaching(this IServiceCollection services)
    {
        services.AddMemoryCache();
        return services;
    }
}

/// <summary>
/// Extension methods for HttpRequestData
/// </summary>
public static class HttpRequestDataExtensions
{
    /// <summary>
    /// Get user ID from claims
    /// </summary>
    public static string? GetUserId(this HttpRequestData request)
    {
        return request.FunctionContext.Items.TryGetValue("UserId", out var userId) 
            ? userId?.ToString() 
            : null;
    }

    /// <summary>
    /// Get user email from claims
    /// </summary>
    public static string? GetUserEmail(this HttpRequestData request)
    {
        return request.FunctionContext.Items.TryGetValue("UserEmail", out var email) 
            ? email?.ToString() 
            : null;
    }

    /// <summary>
    /// Get correlation ID
    /// </summary>
    public static string GetCorrelationId(this HttpRequestData request)
    {
        if (request.Headers.TryGetValues("X-Correlation-ID", out var values))
        {
            return values.First();
        }
        return Guid.NewGuid().ToString();
    }

    /// <summary>
    /// Check if request is authenticated
    /// </summary>
    public static bool IsAuthenticated(this HttpRequestData request)
    {
        return request.FunctionContext.Items.ContainsKey("UserId");
    }

    /// <summary>
    /// Get query parameter value
    /// </summary>
    public static string? GetQueryParameter(this HttpRequestData request, string name)
    {
        var query = System.Web.HttpUtility.ParseQueryString(request.Url.Query);
        return query[name];
    }

    /// <summary>
    /// Get query parameter as int
    /// </summary>
    public static int? GetQueryParameterInt(this HttpRequestData request, string name)
    {
        var value = request.GetQueryParameter(name);
        return int.TryParse(value, out var result) ? result : null;
    }

    /// <summary>
    /// Get query parameter as bool
    /// </summary>
    public static bool? GetQueryParameterBool(this HttpRequestData request, string name)
    {
        var value = request.GetQueryParameter(name);
        return bool.TryParse(value, out var result) ? result : null;
    }
}

/// <summary>
/// Extension methods for strings
/// </summary>
public static class StringExtensions
{
    /// <summary>
    /// Truncate string to specified length
    /// </summary>
    public static string Truncate(this string value, int maxLength)
    {
        if (string.IsNullOrEmpty(value)) return value;
        return value.Length <= maxLength ? value : value[..maxLength];
    }

    /// <summary>
    /// Convert to slug-friendly string
    /// </summary>
    public static string ToSlug(this string value)
    {
        if (string.IsNullOrEmpty(value)) return value;
        
        return System.Text.RegularExpressions.Regex.Replace(
            value.ToLowerInvariant().Trim(),
            @"[^a-z0-9\-]",
            "-"
        ).Trim('-');
    }

    /// <summary>
    /// Check if string is a valid email
    /// </summary>
    public static bool IsValidEmail(this string value)
    {
        if (string.IsNullOrEmpty(value)) return false;
        try
        {
            var addr = new System.Net.Mail.MailAddress(value);
            return addr.Address == value;
        }
        catch
        {
            return false;
        }
    }
}

/// <summary>
/// Extension methods for IEnumerable
/// </summary>
public static class EnumerableExtensions
{
    /// <summary>
    /// Batch items into chunks
    /// </summary>
    public static IEnumerable<IEnumerable<T>> Batch<T>(this IEnumerable<T> source, int size)
    {
        T[]? bucket = null;
        var count = 0;

        foreach (var item in source)
        {
            bucket ??= new T[size];
            bucket[count++] = item;

            if (count != size) continue;

            yield return bucket;
            bucket = null;
            count = 0;
        }

        if (bucket != null && count > 0)
        {
            yield return bucket.Take(count);
        }
    }

    /// <summary>
    /// Check if collection is null or empty
    /// </summary>
    public static bool IsNullOrEmpty<T>(this IEnumerable<T>? source)
    {
        return source == null || !source.Any();
    }
}
