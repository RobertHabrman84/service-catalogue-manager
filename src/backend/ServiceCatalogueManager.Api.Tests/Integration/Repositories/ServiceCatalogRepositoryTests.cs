// =============================================================================
// SERVICE CATALOGUE MANAGER - SERVICE CATALOG REPOSITORY INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Repositories;

public class ServiceCatalogRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;
    private readonly IFixture _autoFixture;

    public ServiceCatalogRepositoryTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
        _autoFixture = new Fixture().Customize(new AutoMoqCustomization());
    }

    [Fact]
    public async Task GetAllAsync_ShouldReturnAllServices()
    {
        await _fixture.SeedTestDataAsync();
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        var result = await repository.GetAllAsync();

        result.Should().NotBeNull();
        result.Should().HaveCountGreaterThan(0);
    }

    [Fact]
    public async Task GetByIdAsync_WithValidId_ShouldReturnService()
    {
        var service = await _fixture.CreateTestServiceAsync();
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        var result = await repository.GetByIdAsync(service.Id);

        result.Should().NotBeNull();
        result!.Id.Should().Be(service.Id);
    }

    [Fact]
    public async Task GetByIdAsync_WithInvalidId_ShouldReturnNull()
    {
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        var result = await repository.GetByIdAsync(99999);

        result.Should().BeNull();
    }

    [Fact]
    public async Task GetByCodeAsync_WithValidCode_ShouldReturnService()
    {
        var service = await _fixture.CreateTestServiceAsync();
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        var result = await repository.GetByCodeAsync(service.ServiceCode);

        result.Should().NotBeNull();
        result!.ServiceCode.Should().Be(service.ServiceCode);
    }

    [Fact]
    public async Task AddAsync_ShouldPersistService()
    {
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);
        var service = new ServiceCatalogItem
        {
            ServiceCode = $"ADD-{Guid.NewGuid():N}".Substring(0, 15),
            ServiceName = "Added Service",
            StatusId = 1,
            CategoryId = 1
        };

        var result = await repository.AddAsync(service);
        await context.SaveChangesAsync();

        result.Should().NotBeNull();
        result.Id.Should().BeGreaterThan(0);
    }

    [Fact]
    public async Task UpdateAsync_ShouldModifyService()
    {
        var service = await _fixture.CreateTestServiceAsync();
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        service.ServiceName = "Updated Name";
        await repository.UpdateAsync(service);
        await context.SaveChangesAsync();

        var updated = await repository.GetByIdAsync(service.Id);
        updated!.ServiceName.Should().Be("Updated Name");
    }

    [Fact]
    public async Task DeleteAsync_ShouldRemoveService()
    {
        var service = await _fixture.CreateTestServiceAsync();
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        await repository.DeleteAsync(service);
        await context.SaveChangesAsync();

        var deleted = await repository.GetByIdAsync(service.Id);
        deleted.Should().BeNull();
    }

    [Fact]
    public async Task SearchAsync_ShouldReturnMatchingServices()
    {
        await _fixture.CreateTestServiceAsync("SRCH-001", "Searchable Service");
        using var context = _fixture.CreateContext();
        var repository = new ServiceCatalogRepository(context);

        var result = await repository.SearchAsync("Searchable");

        result.Should().NotBeEmpty();
    }
}
