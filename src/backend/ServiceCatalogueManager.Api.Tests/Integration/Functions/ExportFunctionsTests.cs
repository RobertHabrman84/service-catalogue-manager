// =============================================================================
// SERVICE CATALOGUE MANAGER - EXPORT FUNCTIONS INTEGRATION TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Integration.Functions;

[Collection("FunctionApp")]
public class ExportFunctionsTests : IClassFixture<FunctionAppFixture>
{
    private readonly FunctionAppFixture _fixture;

    public ExportFunctionsTests(FunctionAppFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task ExportServiceToPdf_WithValidId_ShouldReturnPdf()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.GetAsync($"/api/export/pdf/{service.Id}");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        response.Content.Headers.ContentType?.MediaType.Should().Be("application/pdf");
    }

    [Fact]
    public async Task ExportServiceToPdf_WithInvalidId_ShouldReturnNotFound()
    {
        var response = await _fixture.Client.GetAsync("/api/export/pdf/99999");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task ExportServiceToMarkdown_WithValidId_ShouldReturnMarkdown()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.GetAsync($"/api/export/markdown/{service.Id}");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        response.Content.Headers.ContentType?.MediaType.Should().Be("text/markdown");
    }

    [Fact]
    public async Task ExportCatalogToPdf_ShouldReturnPdf()
    {
        var response = await _fixture.Client.GetAsync("/api/export/catalog/pdf");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
        response.Content.Headers.ContentType?.MediaType.Should().Be("application/pdf");
    }

    [Fact]
    public async Task ExportCatalogToMarkdown_ShouldReturnMarkdown()
    {
        var response = await _fixture.Client.GetAsync("/api/export/catalog/markdown");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetExportHistory_ShouldReturnOk()
    {
        var response = await _fixture.Client.GetAsync("/api/export/history");
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    }

    [Fact]
    public async Task ExportToPdf_ShouldSetCorrectFileName()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.GetAsync($"/api/export/pdf/{service.Id}");
        var contentDisposition = response.Content.Headers.ContentDisposition;
        contentDisposition?.FileName.Should().Contain(".pdf");
    }

    [Fact]
    public async Task ExportToMarkdown_ShouldSetCorrectFileName()
    {
        var service = await _fixture.CreateTestServiceAsync();
        var response = await _fixture.Client.GetAsync($"/api/export/markdown/{service.Id}");
        var contentDisposition = response.Content.Headers.ContentDisposition;
        contentDisposition?.FileName.Should().Contain(".md");
    }
}
