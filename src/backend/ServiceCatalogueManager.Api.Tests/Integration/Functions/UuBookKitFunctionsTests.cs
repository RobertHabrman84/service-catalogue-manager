// =============================================================================
// SERVICE CATALOGUE MANAGER - UUBOOKKIT FUNCTIONS INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Functions;

[Collection("FunctionApp")]
public class UuBookKitFunctionsTests : IClassFixture<FunctionAppFixture>
{
    private readonly FunctionAppFixture _fixture;

    public UuBookKitFunctionsTests(FunctionAppFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task PublishPage_WithValidService_ShouldReturnOk()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var request = new { PageId = "test-page-001" };
        var response = await _fixture.Client.PostAsJsonAsync($"/api/uubookkit/publish/{service.Id}", request);
        response.StatusCode.Should().BeOneOf(System.Net.HttpStatusCode.OK, System.Net.HttpStatusCode.Accepted);
    }

    [Fact]
    public async Task PublishPage_WithInvalidService_ShouldReturnNotFound()
    {
        var request = new { PageId = "test-page-001" };
        var response = await _fixture.Client.PostAsJsonAsync("/api/uubookkit/publish/99999", request);
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreatePage_WithValidService_ShouldReturnCreated()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.PostAsync($"/api/uubookkit/create/{service.Id}", null);
        response.StatusCode.Should().BeOneOf(System.Net.HttpStatusCode.Created, System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetPublishStatus_WithValidPageId_ShouldReturnStatus()
    {
        var response = await _fixture.Client.GetAsync("/api/uubookkit/status/test-page-001");
        response.StatusCode.Should().BeOneOf(System.Net.HttpStatusCode.OK, System.Net.HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task SyncCatalog_ShouldReturnOk()
    {
        var response = await _fixture.Client.PostAsync("/api/uubookkit/sync", null);
        response.StatusCode.Should().BeOneOf(System.Net.HttpStatusCode.OK, System.Net.HttpStatusCode.Accepted);
    }

    [Fact]
    public async Task GetSyncStatus_ShouldReturnStatus()
    {
        var response = await _fixture.Client.GetAsync("/api/uubookkit/sync/status");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }
}
