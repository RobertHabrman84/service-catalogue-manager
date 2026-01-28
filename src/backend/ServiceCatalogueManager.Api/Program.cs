using Microsoft.Azure.Functions.Worker;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Repositories;
using ServiceCatalogueManager.Api.Mappers;
using ServiceCatalogueManager.Api.Middleware;
using ServiceCatalogueManager.Api.Services.Implementations;
using ServiceCatalogueManager.Api.Services.Interfaces;
using ServiceCatalogueManager.Api.Services.Import;
using FluentValidation;
using Azure.Storage.Blobs;
using ServiceCatalogueManager.Api.Configuration;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication(builder =>
    {
        builder.UseMiddleware<ExceptionHandlingMiddleware>();
        builder.UseMiddleware<RequestLoggingMiddleware>();
        builder.UseMiddleware<CorrelationIdMiddleware>();
    })
    .ConfigureAppConfiguration((context, config) =>
    {
        config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
              .AddJsonFile($"appsettings.{context.HostingEnvironment.EnvironmentName}.json", optional: true, reloadOnChange: true)
              .AddEnvironmentVariables();
    })
    .ConfigureServices((context, services) =>
    {
        var configuration = context.Configuration;

        // Application Insights
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

        // Database
        services.AddDbContext<ServiceCatalogDbContext>(options =>
        {
            var connectionString = configuration.GetConnectionString("AzureSQL")
                ?? configuration["AzureSQL__ConnectionString"];
            
            // Use In-Memory database fallback for development
            if (string.IsNullOrEmpty(connectionString) || 
                connectionString.Contains("localhost") || 
                context.HostingEnvironment.IsDevelopment())
            {
                Console.WriteLine("⚠️  Using IN-MEMORY database for development");
                options.UseInMemoryDatabase("ServiceCatalogueDevDb");
            }
            else
            {
                options.UseSqlServer(connectionString, sqlOptions =>
                {
                    sqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(30),
                        errorNumbersToAdd: null);
                    sqlOptions.CommandTimeout(30);
                });
            }
        });

        // Blob Storage
        services.AddSingleton(sp =>
        {
            var connectionString = configuration.GetConnectionString("BlobStorage")
                ?? configuration["BlobStorage__ConnectionString"];
            return new BlobServiceClient(connectionString);
        });

        // Configuration Options
        services.Configure<AzureAdOptions>(configuration.GetSection("AzureAd"));
        services.Configure<UuBookKitOptions>(configuration.GetSection("UuBookKit"));
        services.Configure<StorageOptions>(configuration.GetSection("BlobStorage"));
        services.Configure<DatabaseOptions>(configuration.GetSection("Database"));
        services.Configure<ExportOptions>(configuration.GetSection("Export"));
        services.Configure<CacheOptions>(configuration.GetSection("Cache"));

        // Repositories
        services.AddScoped<IServiceCatalogRepository, ServiceCatalogRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Services
        services.AddScoped<IServiceCatalogService, ServiceCatalogService>();
        services.AddScoped<ILookupService, LookupService>();
        services.AddScoped<IExportService, ExportService>();
        
        // Import Services
        services.AddScoped<IImportOrchestrationService, ImportOrchestrationService>();
        services.AddScoped<IImportValidationService, ImportValidationService>();
        services.AddScoped<CategoryHelper>();
        services.AddScoped<ToolsHelper>();
        
        // Cache Service
        services.AddSingleton<ICacheService, InMemoryCacheService>();

        // Export & Document Generation Services
        services.AddScoped<IPdfGeneratorService, PdfGeneratorService>();
        services.AddScoped<IMarkdownGeneratorService, MarkdownGeneratorService>();
        services.AddScoped<IBlobStorageService, BlobStorageService>();
        services.AddScoped<IUuBookKitService, UuBookKitService>();
        
        // AutoMapper
        services.AddAutoMapper(typeof(MappingProfile).Assembly);

        // FluentValidation
        services.AddValidatorsFromAssemblyContaining<Program>();

        // HTTP Clients with Retry Policy
        services.AddHttpClient("UuBookKit", client =>
        {
            var baseUrl = configuration["UuBookKit__ApiUrl"];
            if (!string.IsNullOrEmpty(baseUrl))
            {
                client.BaseAddress = new Uri(baseUrl);
            }
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            client.Timeout = TimeSpan.FromSeconds(30);
        })
        .AddStandardResilienceHandler(); // .NET 8+ standard resilience with retry

        // Memory Cache
        services.AddMemoryCache();

        // Logging
        services.AddLogging(logging =>
        {
            logging.AddConsole();
            logging.SetMinimumLevel(LogLevel.Information);
        });
    })
    .Build();

await host.RunAsync();
