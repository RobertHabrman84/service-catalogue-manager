// =============================================================================
// SERVICE CATALOGUE MANAGER - FUNCTION APP FIXTURE
// =============================================================================

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http.Json;

namespace ServiceCatalogueManager.Api.Tests.Fixtures;

public class FunctionAppFixture : IAsyncLifetime
{
    private WebApplicationFactory<Program>? _factory;
    public HttpClient Client { get; private set; } = null!;
    private ServiceCatalogDbContext? _dbContext;

    public async Task InitializeAsync()
    {
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Remove existing DbContext
                    var descriptor = services.SingleOrDefault(
                        d => d.ServiceType == typeof(DbContextOptions<ServiceCatalogDbContext>));
                    if (descriptor != null) services.Remove(descriptor);

                    // Add in-memory database
                    services.AddDbContext<ServiceCatalogDbContext>(options =>
                        options.UseInMemoryDatabase($"TestDb_{Guid.NewGuid()}"));
                });
            });

        Client = _factory.CreateClient();

        // Seed initial data
        using var scope = _factory.Services.CreateScope();
        _dbContext = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();
        await SeedTestDataAsync();
    }

    public Task DisposeAsync()
    {
        Client?.Dispose();
        _factory?.Dispose();
        return Task.CompletedTask;
    }

    public async Task<ServiceCatalogItem> CreateTestServiceAsync(
        string? code = null, string? name = null)
    {
        using var scope = _factory!.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();

        var service = new ServiceCatalogItem
        {
            ServiceCode = code ?? $"TST-{Guid.NewGuid():N}".Substring(0, 15),
            ServiceName = name ?? $"Test Service {DateTime.Now.Ticks}",
            ShortDescription = "Test description",
            StatusId = 1,
            CategoryId = 1,
            Version = "1.0.0"
        };

        context.ServiceCatalogItems.Add(service);
        await context.SaveChangesAsync();
        return service;
    }

    private async Task SeedTestDataAsync()
    {
        if (_dbContext == null) return;

        _dbContext.ServiceStatuses.AddRange(
            new ServiceStatus { Id = 1, Code = "DRAFT", Name = "Draft", IsActive = true },
            new ServiceStatus { Id = 2, Code = "ACTIVE", Name = "Active", IsActive = true },
            new ServiceStatus { Id = 3, Code = "DEPRECATED", Name = "Deprecated", IsActive = true }
        );

        _dbContext.ServiceCategories.AddRange(
            new ServiceCategory { Id = 1, Code = "APP", Name = "Application", IsActive = true },
            new ServiceCategory { Id = 2, Code = "INFRA", Name = "Infrastructure", IsActive = true }
        );

        _dbContext.BusinessUnits.AddRange(
            new BusinessUnit { Id = 1, Code = "DEV", Name = "Development", IsActive = true },
            new BusinessUnit { Id = 2, Code = "OPS", Name = "Operations", IsActive = true }
        );

        await _dbContext.SaveChangesAsync();
    }
}

[CollectionDefinition("FunctionApp")]
public class FunctionAppCollection : ICollectionFixture<FunctionAppFixture> { }
