namespace ServiceCatalogueManager.Api.Configuration;

/// <summary>
/// Azure AD configuration options
/// </summary>
public class AzureAdOptions
{
    public const string SectionName = "AzureAd";

    public string Instance { get; set; } = "https://login.microsoftonline.com/";
    public string TenantId { get; set; } = string.Empty;
    public string ClientId { get; set; } = string.Empty;
    public string ClientSecret { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public string[] Scopes { get; set; } = Array.Empty<string>();
}

/// <summary>
/// Database configuration options
/// </summary>
public class DatabaseOptions
{
    public const string SectionName = "AzureSQL";

    public string ConnectionString { get; set; } = string.Empty;
    public int CommandTimeout { get; set; } = 30;
    public int MaxRetryCount { get; set; } = 3;
    public int MaxRetryDelaySeconds { get; set; } = 30;
    public bool EnableSensitiveDataLogging { get; set; } = false;
}

/// <summary>
/// Blob storage configuration options
/// </summary>
public class StorageOptions
{
    public const string SectionName = "AzureStorage";

    public string ConnectionString { get; set; } = string.Empty;
    public string ExportContainer { get; set; } = "exports";
    public string TemplateContainer { get; set; } = "templates";
    public int SasTokenValidityHours { get; set; } = 24;
}

/// <summary>
/// UuBookKit integration configuration options
/// </summary>
public class UuBookKitOptions
{
    public const string SectionName = "UuBookKit";

    public bool Enabled { get; set; } = false;
    public string BaseUrl { get; set; } = string.Empty;
    public string BookUri { get; set; } = string.Empty;
    public string AccessCode1 { get; set; } = string.Empty;
    public string AccessCode2 { get; set; } = string.Empty;
    public int TimeoutSeconds { get; set; } = 30;
    public int MaxRetries { get; set; } = 3;
}

/// <summary>
/// Export configuration options
/// </summary>
public class ExportOptions
{
    public const string SectionName = "Export";

    public string CompanyName { get; set; } = "Your Company";
    public string CompanyLogo { get; set; } = string.Empty;
    public string DefaultFooter { get; set; } = "Confidential";
    public int MaxServicesPerExport { get; set; } = 50;
    public int ExportRetentionDays { get; set; } = 7;
}

/// <summary>
/// Caching configuration options
/// </summary>
public class CacheOptions
{
    public const string SectionName = "Cache";

    public bool Enabled { get; set; } = true;
    public int DefaultExpirationMinutes { get; set; } = 30;
    public int LookupExpirationMinutes { get; set; } = 60;
    public int ServiceExpirationMinutes { get; set; } = 10;
}

/// <summary>
/// Logging configuration options
/// </summary>
public class LoggingOptions
{
    public const string SectionName = "Logging";

    public string MinimumLevel { get; set; } = "Information";
    public bool EnableRequestLogging { get; set; } = true;
    public bool EnablePerformanceLogging { get; set; } = true;
    public int SlowRequestThresholdMs { get; set; } = 1000;
}

/// <summary>
/// Feature flags configuration
/// </summary>
public class FeatureFlags
{
    public const string SectionName = "Features";

    public bool EnableUuBookKitSync { get; set; } = false;
    public bool EnablePdfExport { get; set; } = true;
    public bool EnableMarkdownExport { get; set; } = true;
    public bool EnableBulkOperations { get; set; } = true;
    public bool EnableServiceCloning { get; set; } = true;
    public bool EnableFullTextSearch { get; set; } = true;
}

/// <summary>
/// CORS configuration options
/// </summary>
public class CorsOptions
{
    public const string SectionName = "Cors";

    public string[] AllowedOrigins { get; set; } = Array.Empty<string>();
    public string[] AllowedMethods { get; set; } = { "GET", "POST", "PUT", "DELETE", "OPTIONS" };
    public string[] AllowedHeaders { get; set; } = { "Content-Type", "Authorization", "X-Correlation-ID" };
    public bool AllowCredentials { get; set; } = true;
    public int MaxAgeSeconds { get; set; } = 86400;
}
