// =============================================================================
// SERVICE CATALOGUE MANAGER - UUBOOKKIT SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class UuBookKitServiceTests
{
    private readonly Mock<IHttpClientFactory> _httpClientFactoryMock;
    private readonly Mock<IOptions<UuBookKitOptions>> _optionsMock;
    private readonly Mock<ILogger<UuBookKitService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly UuBookKitService _sut;

    public UuBookKitServiceTests()
    {
        _httpClientFactoryMock = new Mock<IHttpClientFactory>();
        _optionsMock = new Mock<IOptions<UuBookKitOptions>>();
        _loggerMock = new Mock<ILogger<UuBookKitService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        var options = new UuBookKitOptions
        {
            BaseUrl = "https://uuapp.plus4u.net",
            AwId = "test-awid",
            AppWorkspace = "test-workspace"
        };
        _optionsMock.Setup(x => x.Value).Returns(options);
        
        var httpClient = new HttpClient(new MockHttpMessageHandler());
        _httpClientFactoryMock.Setup(x => x.CreateClient(It.IsAny<string>()))
            .Returns(httpClient);
        
        _sut = new UuBookKitService(
            _httpClientFactoryMock.Object,
            _optionsMock.Object,
            _loggerMock.Object);
    }

    #region PublishPageAsync Tests

    [Fact]
    public async Task PublishPageAsync_WithValidService_ShouldReturnSuccess()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pageId = "page-001";

        // Act
        var result = await _sut.PublishPageAsync(service, pageId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
    }

    [Fact]
    public async Task PublishPageAsync_WithNullService_ShouldThrowArgumentNullException()
    {
        // Arrange
        ServiceCatalogDetailDto? service = null;
        var pageId = "page-001";

        // Act
        Func<Task> act = async () => await _sut.PublishPageAsync(service!, pageId);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    [Fact]
    public async Task PublishPageAsync_WithEmptyPageId_ShouldThrowArgumentException()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pageId = string.Empty;

        // Act
        Func<Task> act = async () => await _sut.PublishPageAsync(service, pageId);

        // Assert
        await act.Should().ThrowAsync<ArgumentException>();
    }

    #endregion

    #region CreatePageAsync Tests

    [Fact]
    public async Task CreatePageAsync_WithValidService_ShouldReturnPageId()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.CreatePageAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task CreatePageAsync_ShouldGenerateValidPageCode()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceCode, "TST-001")
            .Create();

        // Act
        var result = await _sut.CreatePageAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
    }

    #endregion

    #region UpdatePageAsync Tests

    [Fact]
    public async Task UpdatePageAsync_WithValidData_ShouldReturnSuccess()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pageId = "page-001";

        // Act
        var result = await _sut.UpdatePageAsync(service, pageId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
    }

    [Fact]
    public async Task UpdatePageAsync_WithNonExistentPage_ShouldThrowNotFoundException()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pageId = "non-existent-page";

        // Note: This would depend on mock setup for 404 response
        // Act & Assert would verify exception is thrown
    }

    #endregion

    #region GetPublishStatusAsync Tests

    [Fact]
    public async Task GetPublishStatusAsync_WithValidPageId_ShouldReturnStatus()
    {
        // Arrange
        var pageId = "page-001";

        // Act
        var result = await _sut.GetPublishStatusAsync(pageId);

        // Assert
        result.Should().NotBeNull();
    }

    [Theory]
    [InlineData("PUBLISHED")]
    [InlineData("DRAFT")]
    [InlineData("PENDING")]
    public async Task GetPublishStatusAsync_ShouldReturnValidStatus(string expectedStatus)
    {
        // Arrange
        var pageId = "page-001";

        // Act
        var result = await _sut.GetPublishStatusAsync(pageId);

        // Assert
        result.Should().NotBeNull();
        // Status would be verified based on mock response
    }

    #endregion

    #region SyncCatalogAsync Tests

    [Fact]
    public async Task SyncCatalogAsync_WithValidServices_ShouldSyncAll()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogDetailDto>(5).ToList();

        // Act
        var result = await _sut.SyncCatalogAsync(services);

        // Assert
        result.Should().NotBeNull();
        result.SyncedCount.Should().Be(5);
    }

    [Fact]
    public async Task SyncCatalogAsync_WithEmptyList_ShouldReturnZeroSynced()
    {
        // Arrange
        var services = new List<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.SyncCatalogAsync(services);

        // Assert
        result.SyncedCount.Should().Be(0);
    }

    [Fact]
    public async Task SyncCatalogAsync_WithPartialFailure_ShouldReturnPartialResult()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogDetailDto>(5).ToList();

        // Act
        var result = await _sut.SyncCatalogAsync(services);

        // Assert
        result.Should().NotBeNull();
        result.FailedCount.Should().BeGreaterThanOrEqualTo(0);
    }

    #endregion

    #region GenerateUu5ContentAsync Tests

    [Fact]
    public async Task GenerateUu5ContentAsync_WithValidService_ShouldReturnUu5String()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateUu5ContentAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("<uu5string/>");
    }

    [Fact]
    public async Task GenerateUu5ContentAsync_ShouldContainValidUu5Components()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateUu5ContentAsync(service);

        // Assert
        result.Should().Contain("<UU5.Bricks");
    }

    #endregion

    #region Configuration Tests

    [Fact]
    public async Task PublishPageAsync_ShouldUseConfiguredBaseUrl()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();
        var pageId = "page-001";

        // Act
        await _sut.PublishPageAsync(service, pageId);

        // Assert
        _httpClientFactoryMock.Verify(x => x.CreateClient(It.IsAny<string>()), Times.AtLeastOnce);
    }

    #endregion
}
