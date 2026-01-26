// =============================================================================
// SERVICE CATALOGUE MANAGER - LOOKUP REPOSITORY INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Repositories;

public class LookupRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public LookupRepositoryTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetServiceStatusesAsync_ShouldReturnStatuses()
    {
        using var context = _fixture.CreateContext();
        var repository = new LookupRepository(context);
        var result = await repository.GetServiceStatusesAsync();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetServiceCategoriesAsync_ShouldReturnCategories()
    {
        using var context = _fixture.CreateContext();
        var repository = new LookupRepository(context);
        var result = await repository.GetServiceCategoriesAsync();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetBusinessUnitsAsync_ShouldReturnBusinessUnits()
    {
        using var context = _fixture.CreateContext();
        var repository = new LookupRepository(context);
        var result = await repository.GetBusinessUnitsAsync();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetResponsibleRolesAsync_ShouldReturnRoles()
    {
        using var context = _fixture.CreateContext();
        var repository = new LookupRepository(context);
        var result = await repository.GetResponsibleRolesAsync();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetActiveStatusesOnly_ShouldFilterInactive()
    {
        using var context = _fixture.CreateContext();
        var repository = new LookupRepository(context);
        var result = await repository.GetServiceStatusesAsync(activeOnly: true);
        result.Should().OnlyContain(s => s.IsActive);
    }
}
