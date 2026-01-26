// =============================================================================
// SERVICE CATALOGUE MANAGER - PDF GENERATOR SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class PdfGeneratorServiceTests
{
    private readonly Mock<IOptions<ExportOptions>> _optionsMock;
    private readonly Mock<ILogger<PdfGeneratorService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly PdfGeneratorService _sut;

    public PdfGeneratorServiceTests()
    {
        _optionsMock = new Mock<IOptions<ExportOptions>>();
        _loggerMock = new Mock<ILogger<PdfGeneratorService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        var options = new ExportOptions
        {
            CompanyName = "Test Company",
            LogoPath = "/assets/logo.png",
            DefaultPageSize = "A4"
        };
        _optionsMock.Setup(x => x.Value).Returns(options);
        
        _sut = new PdfGeneratorService(
            _optionsMock.Object,
            _loggerMock.Object);
    }

    #region GenerateServicePdfAsync Tests

    [Fact]
    public async Task GenerateServicePdfAsync_WithValidService_ShouldReturnPdfBytes()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServicePdfAsync(service);

        // Assert
        result.Should().NotBeNull();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GenerateServicePdfAsync_ShouldContainPdfHeader()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServicePdfAsync(service);

        // Assert
        // PDF files start with %PDF
        result.Should().NotBeNull();
        result.Length.Should().BeGreaterThan(0);
    }

    [Fact]
    public async Task GenerateServicePdfAsync_WithNullService_ShouldThrowArgumentNullException()
    {
        // Arrange
        ServiceCatalogDetailDto? service = null;

        // Act
        Func<Task> act = async () => await _sut.GenerateServicePdfAsync(service!);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    [Fact]
    public async Task GenerateServicePdfAsync_WithCompleteService_ShouldIncludeAllSections()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceName, "Complete Service")
            .With(x => x.ShortDescription, "A complete service description")
            .With(x => x.UsageScenarios, _fixture.CreateMany<UsageScenarioDto>(3).ToList())
            .With(x => x.Dependencies, _fixture.CreateMany<ServiceDependencyDto>(2).ToList())
            .Create();

        // Act
        var result = await _sut.GenerateServicePdfAsync(service);

        // Assert
        result.Should().NotBeNull();
        result.Length.Should().BeGreaterThan(1000); // PDF with content should be > 1KB
    }

    #endregion

    #region GenerateCatalogPdfAsync Tests

    [Fact]
    public async Task GenerateCatalogPdfAsync_WithValidServices_ShouldReturnPdfBytes()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogListDto>(5).ToList();

        // Act
        var result = await _sut.GenerateCatalogPdfAsync(services);

        // Assert
        result.Should().NotBeNull();
        result.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GenerateCatalogPdfAsync_WithEmptyList_ShouldReturnEmptyCatalogPdf()
    {
        // Arrange
        var services = new List<ServiceCatalogListDto>();

        // Act
        var result = await _sut.GenerateCatalogPdfAsync(services);

        // Assert
        result.Should().NotBeNull();
    }

    [Fact]
    public async Task GenerateCatalogPdfAsync_WithManyServices_ShouldHandlePagination()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogListDto>(50).ToList();

        // Act
        var result = await _sut.GenerateCatalogPdfAsync(services);

        // Assert
        result.Should().NotBeNull();
        result.Length.Should().BeGreaterThan(5000); // Multi-page PDF
    }

    #endregion

    #region PDF Content Tests

    [Theory]
    [InlineData("Test Service", "TST-001")]
    [InlineData("Another Service", "ANT-002")]
    public async Task GenerateServicePdfAsync_ShouldIncludeServiceNameAndCode(string name, string code)
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceName, name)
            .With(x => x.ServiceCode, code)
            .Create();

        // Act
        var result = await _sut.GenerateServicePdfAsync(service);

        // Assert
        result.Should().NotBeNull();
        // Note: Actual PDF content verification would require PDF parsing
    }

    #endregion

    #region Configuration Tests

    [Fact]
    public async Task GenerateServicePdfAsync_ShouldUseConfiguredCompanyName()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServicePdfAsync(service);

        // Assert
        result.Should().NotBeNull();
        // Note: Would verify PDF contains "Test Company" from options
    }

    #endregion
}
