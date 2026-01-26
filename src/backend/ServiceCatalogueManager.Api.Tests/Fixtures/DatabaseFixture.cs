// =============================================================================
// SERVICE CATALOGUE MANAGER - DATABASE FIXTURE
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Fixtures;

public class DatabaseFixture : IAsyncLifetime
{
    private readonly string _connectionString;
    private DbContextOptions<ServiceCatalogDbContext> _options = null!;

    public DatabaseFixture()
    {
        _connectionString = $"Data Source=TestDb_{Guid.NewGuid()}.db";
    }

    public async Task InitializeAsync()
    {
        _options = new DbContextOptionsBuilder<ServiceCatalogDbContext>()
            .UseSqlite(_connectionString)
            .Options;

        using var context = CreateContext();
        await context.Database.EnsureCreatedAsync();
        await SeedLookupDataAsync(context);
    }

    public Task DisposeAsync()
    {
        using var context = CreateContext();
        context.Database.EnsureDeleted();
        return Task.CompletedTask;
    }

    public ServiceCatalogDbContext CreateContext()
    {
        return new ServiceCatalogDbContext(_options);
    }

    public async Task SeedTestDataAsync()
    {
        using var context = CreateContext();
        if (!await context.ServiceCatalogItems.AnyAsync())
        {
            var services = TestDataBuilder.CreateTestServices(5);
            context.ServiceCatalogItems.AddRange(services);
            await context.SaveChangesAsync();
        }
    }

    public async Task<ServiceCatalogItem> CreateTestServiceAsync(
        string? code = null, string? name = null)
    {
        using var context = CreateContext();
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

    private static async Task SeedLookupDataAsync(ServiceCatalogDbContext context)
    {
        if (!await context.ServiceStatuses.AnyAsync())
        {
            context.ServiceStatuses.AddRange(
                new ServiceStatus { Code = "DRAFT", Name = "Draft", IsActive = true, DisplayOrder = 1 },
                new ServiceStatus { Code = "ACTIVE", Name = "Active", IsActive = true, DisplayOrder = 2 },
                new ServiceStatus { Code = "DEPRECATED", Name = "Deprecated", IsActive = true, DisplayOrder = 3 }
            );
        }

        if (!await context.ServiceCategories.AnyAsync())
        {
            context.ServiceCategories.AddRange(
                new ServiceCategory { Code = "APP", Name = "Application", IsActive = true, DisplayOrder = 1 },
                new ServiceCategory { Code = "INFRA", Name = "Infrastructure", IsActive = true, DisplayOrder = 2 }
            );
        }

        await context.SaveChangesAsync();
    }
}
