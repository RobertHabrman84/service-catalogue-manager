// =============================================================================
// SERVICE CATALOGUE MANAGER - EXPORT SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class ExportServiceTests
{
    private readonly Mock<IServiceCatalogService> _catalogServiceMock;
    private readonly Mock<IPdfGeneratorService> _pdfServiceMock;
    private readonly Mock<IMarkdownGeneratorService> _markdownServiceMock;
    private readonly Mock<IBlobStorageService> _blobServiceMock;
    private readonly Mock<ILogger<ExportService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly ExportService _sut;

    public ExportServiceTests()
    {
        _catalogServiceMock = new Mock<IServiceCatalogService>();
        _pdfServiceMock = new Mock<IPdfGeneratorService>();
        _markdownServiceMock = new Mock<IMarkdownGeneratorService>();
        _blobServiceMock = new Mock<IBlobStorageService>();
        _loggerMock = new Mock<ILogger<ExportService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        _sut = new ExportService(
            _catalogServiceMock.Object,
            _pdfServiceMock.Object,
            _markdownServiceMock.Object,
            _blobServiceMock.Object,
            _loggerMock.Object);
    }

    #region ExportToPdfAsync Tests

    [Fact]
    public async Task ExportToPdfAsync_WithValidServiceId_ShouldReturnPdfBytes()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pdfBytes = _fixture.Create<byte[]>();
        var serviceId = 1;

        _catalogServiceMock.Setup(x => x.GetByIdAsync(serviceId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);
        _pdfServiceMock.Setup(x => x.GenerateServicePdfAsync(service, It.IsAny<CancellationToken>()))
            .ReturnsAsync(pdfBytes);

        // Act
        var result = await _sut.ExportToPdfAsync(serviceId);

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEquivalentTo(pdfBytes);
        _pdfServiceMock.Verify(x => x.GenerateServicePdfAsync(service, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task ExportToPdfAsync_WithInvalidServiceId_ShouldThrowNotFoundException()
    {
        // Arrange
        var invalidId = 999;
        _catalogServiceMock.Setup(x => x.GetByIdAsync(invalidId, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new NotFoundException($"Service with ID {invalidId} not found"));

        // Act
        Func<Task> act = async () => await _sut.ExportToPdfAsync(invalidId);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    [Fact]
    public async Task ExportToPdfAsync_ShouldGenerateValidPdf()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pdfBytes = new byte[] { 0x25, 0x50, 0x44, 0x46 }; // PDF magic bytes
        var serviceId = 1;

        _catalogServiceMock.Setup(x => x.GetByIdAsync(serviceId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);
        _pdfServiceMock.Setup(x => x.GenerateServicePdfAsync(service, It.IsAny<CancellationToken>()))
            .ReturnsAsync(pdfBytes);

        // Act
        var result = await _sut.ExportToPdfAsync(serviceId);

        // Assert
        result.Should().StartWith(new byte[] { 0x25, 0x50, 0x44, 0x46 }); // %PDF
    }

    #endregion

    #region ExportToMarkdownAsync Tests

    [Fact]
    public async Task ExportToMarkdownAsync_WithValidServiceId_ShouldReturnMarkdownContent()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var markdown = "# Service Documentation\n\nThis is the service content.";
        var serviceId = 1;

        _catalogServiceMock.Setup(x => x.GetByIdAsync(serviceId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);
        _markdownServiceMock.Setup(x => x.GenerateServiceMarkdownAsync(service, It.IsAny<CancellationToken>()))
            .ReturnsAsync(markdown);

        // Act
        var result = await _sut.ExportToMarkdownAsync(serviceId);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("# Service Documentation");
    }

    [Fact]
    public async Task ExportToMarkdownAsync_ShouldContainServiceDetails()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceName, "Test Service")
            .With(x => x.ServiceCode, "TST-001")
            .Create();
        var markdown = $"# {service.ServiceName}\n\nCode: {service.ServiceCode}";
        var serviceId = 1;

        _catalogServiceMock.Setup(x => x.GetByIdAsync(serviceId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);
        _markdownServiceMock.Setup(x => x.GenerateServiceMarkdownAsync(service, It.IsAny<CancellationToken>()))
            .ReturnsAsync(markdown);

        // Act
        var result = await _sut.ExportToMarkdownAsync(serviceId);

        // Assert
        result.Should().Contain("Test Service");
        result.Should().Contain("TST-001");
    }

    #endregion

    #region ExportCatalogToPdfAsync Tests

    [Fact]
    public async Task ExportCatalogToPdfAsync_ShouldReturnPdfBytes()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogListDto>(5).ToList();
        var pdfBytes = _fixture.Create<byte[]>();

        _catalogServiceMock.Setup(x => x.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(services);
        _pdfServiceMock.Setup(x => x.GenerateCatalogPdfAsync(services, It.IsAny<CancellationToken>()))
            .ReturnsAsync(pdfBytes);

        // Act
        var result = await _sut.ExportCatalogToPdfAsync();

        // Assert
        result.Should().NotBeNull();
        _pdfServiceMock.Verify(x => x.GenerateCatalogPdfAsync(services, It.IsAny<CancellationToken>()), Times.Once);
    }

    #endregion

    #region SaveExportToBlobAsync Tests

    [Fact]
    public async Task SaveExportToBlobAsync_ShouldReturnBlobUrl()
    {
        // Arrange
        var content = _fixture.Create<byte[]>();
        var fileName = "export.pdf";
        var expectedUrl = $"https://storage.blob.core.windows.net/exports/{fileName}";

        _blobServiceMock.Setup(x => x.UploadAsync(content, fileName, It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedUrl);

        // Act
        var result = await _sut.SaveExportToBlobAsync(content, fileName);

        // Assert
        result.Should().Be(expectedUrl);
        _blobServiceMock.Verify(x => x.UploadAsync(content, fileName, It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    #endregion

    #region GetExportHistoryAsync Tests

    [Fact]
    public async Task GetExportHistoryAsync_ShouldReturnExportHistory()
    {
        // Arrange
        var history = _fixture.CreateMany<ExportHistoryDto>(10).ToList();
        _blobServiceMock.Setup(x => x.GetExportHistoryAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(history);

        // Act
        var result = await _sut.GetExportHistoryAsync();

        // Assert
        result.Should().HaveCount(10);
    }

    [Fact]
    public async Task GetExportHistoryAsync_WithLimit_ShouldReturnLimitedResults()
    {
        // Arrange
        var limit = 5;
        var history = _fixture.CreateMany<ExportHistoryDto>(limit).ToList();
        _blobServiceMock.Setup(x => x.GetExportHistoryAsync(limit, It.IsAny<CancellationToken>()))
            .ReturnsAsync(history);

        // Act
        var result = await _sut.GetExportHistoryAsync(limit);

        // Assert
        result.Should().HaveCount(limit);
    }

    #endregion
}
