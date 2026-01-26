// =============================================================================
// SERVICE CATALOGUE MANAGER - DB CONTEXT INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Database;

public class DbContextTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public DbContextTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public void CanCreateDbContext()
    {
        using var context = _fixture.CreateContext();
        context.Should().NotBeNull();
    }

    [Fact]
    public async Task CanConnectToDatabase()
    {
        using var context = _fixture.CreateContext();
        var canConnect = await context.Database.CanConnectAsync();
        canConnect.Should().BeTrue();
    }

    [Fact]
    public async Task ServiceCatalogItems_ShouldExist()
    {
        using var context = _fixture.CreateContext();
        var exists = await context.ServiceCatalogItems.AnyAsync();
        exists.Should().BeTrue();
    }

    [Fact]
    public async Task CanInsertAndRetrieveService()
    {
        using var context = _fixture.CreateContext();
        var service = new ServiceCatalogItem
        {
            ServiceCode = $"CTX-{Guid.NewGuid():N}".Substring(0, 15),
            ServiceName = "Context Test Service",
            StatusId = 1,
            CategoryId = 1
        };

        context.ServiceCatalogItems.Add(service);
        await context.SaveChangesAsync();

        var retrieved = await context.ServiceCatalogItems.FindAsync(service.Id);
        retrieved.Should().NotBeNull();
        retrieved!.ServiceCode.Should().Be(service.ServiceCode);
    }

    [Fact]
    public async Task NavigationProperties_ShouldLoadCorrectly()
    {
        await _fixture.SeedTestDataAsync();
        using var context = _fixture.CreateContext();

        var service = await context.ServiceCatalogItems
            .Include(s => s.Status)
            .Include(s => s.Category)
            .FirstOrDefaultAsync();

        service.Should().NotBeNull();
        service!.Status.Should().NotBeNull();
        service.Category.Should().NotBeNull();
    }

    [Fact]
    public async Task Timestamps_ShouldBeSetAutomatically()
    {
        using var context = _fixture.CreateContext();
        var service = new ServiceCatalogItem
        {
            ServiceCode = $"TS-{Guid.NewGuid():N}".Substring(0, 15),
            ServiceName = "Timestamp Test",
            StatusId = 1,
            CategoryId = 1
        };

        context.ServiceCatalogItems.Add(service);
        await context.SaveChangesAsync();

        service.CreatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromMinutes(1));
    }

    [Fact]
    public async Task ConcurrentUpdates_ShouldBeHandled()
    {
        var service = await _fixture.CreateTestServiceAsync();
        
        using var context1 = _fixture.CreateContext();
        using var context2 = _fixture.CreateContext();

        var service1 = await context1.ServiceCatalogItems.FindAsync(service.Id);
        var service2 = await context2.ServiceCatalogItems.FindAsync(service.Id);

        service1!.ServiceName = "Update 1";
        service2!.ServiceName = "Update 2";

        await context1.SaveChangesAsync();

        var act = async () => await context2.SaveChangesAsync();
        await act.Should().ThrowAsync<DbUpdateConcurrencyException>();
    }
}
