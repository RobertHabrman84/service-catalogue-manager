// =============================================================================
// SERVICE CATALOGUE MANAGER - LOOKUP FUNCTIONS INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Functions;

[Collection("FunctionApp")]
public class LookupFunctionsTests : IClassFixture<FunctionAppFixture>
{
    private readonly FunctionAppFixture _fixture;

    public LookupFunctionsTests(FunctionAppFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetStatuses_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/statuses");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        content.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task GetCategories_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/categories");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetBusinessUnits_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/business-units");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetRoles_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/roles");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetDependencyTypes_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/dependency-types");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetCloudProviders_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/cloud-providers");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetAllLookups_ShouldReturnAllData()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        content.Should().Contain("statuses");
        content.Should().Contain("categories");
    }

    [Fact]
    public async Task GetStatuses_ShouldReturnActiveOnly()
    {
        var response = await _fixture.Client.GetAsync("/api/lookups/statuses?activeOnly=true");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetLookups_ShouldBeCacheable()
    {
        var response1 = await _fixture.Client.GetAsync("/api/lookups/statuses");
        var response2 = await _fixture.Client.GetAsync("/api/lookups/statuses");

        response1.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        response2.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }
}
