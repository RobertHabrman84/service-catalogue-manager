// =============================================================================
// SERVICE CATALOGUE MANAGER - SERVICE CATALOG FUNCTIONS INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Functions;

[Collection("FunctionApp")]
public class ServiceCatalogFunctionsTests : IClassFixture<FunctionAppFixture>
{
    private readonly FunctionAppFixture _fixture;
    private readonly IFixture _autoFixture;

    public ServiceCatalogFunctionsTests(FunctionAppFixture fixture)
    {
        _fixture = fixture;
        _autoFixture = new Fixture().Customize(new AutoMoqCustomization());
    }

    [Fact]
    public async Task GetServices_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/services");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetServiceById_WithValidId_ShouldReturnService()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.GetAsync($"/api/services/{service.Id}");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetServiceById_WithInvalidId_ShouldReturnNotFound()
    {
        var response = await _fixture.Client.GetAsync("/api/services/99999");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreateService_WithValidData_ShouldReturnCreated()
    {
        var request = new CreateServiceRequest
        {
            ServiceCode = $"TST-{Guid.NewGuid():N}".Substring(0, 15),
            ServiceName = "Integration Test Service",
            ShortDescription = "Test description",
            StatusId = 1,
            CategoryId = 1
        };

        var response = await _fixture.Client.PostAsJsonAsync("/api/services", request);
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.Created);
    }

    [Fact]
    public async Task CreateService_WithDuplicateCode_ShouldReturnConflict()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var request = new CreateServiceRequest
        {
            ServiceCode = service.ServiceCode,
            ServiceName = "Duplicate Service",
            StatusId = 1,
            CategoryId = 1
        };

        var response = await _fixture.Client.PostAsJsonAsync("/api/services", request);
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task UpdateService_WithValidData_ShouldReturnOk()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var request = new UpdateServiceRequest
        {
            ServiceName = "Updated Name",
            Version = "2.0.0",
            StatusId = 1,
            CategoryId = 1
        };

        var response = await _fixture.Client.PutAsJsonAsync($"/api/services/{service.Id}", request);
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task DeleteService_WithValidId_ShouldReturnNoContent()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.DeleteAsync($"/api/services/{service.Id}");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task SearchServices_WithQuery_ShouldReturnFilteredResults()
    {
        await _fixture.CreateTestServiceAsync("SearchTest-001", "Searchable Service");
        var response = await _fixture.Client.GetAsync("/api/services?search=Searchable");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }
}
