// =============================================================================
// SERVICE CATALOGUE MANAGER - SERVICE CATALOG SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class ServiceCatalogServiceTests
{
    private readonly Mock<IServiceCatalogRepository> _repositoryMock;
    private readonly Mock<ILogger<ServiceCatalogService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly ServiceCatalogService _sut;

    public ServiceCatalogServiceTests()
    {
        _repositoryMock = new Mock<IServiceCatalogRepository>();
        _loggerMock = new Mock<ILogger<ServiceCatalogService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        _sut = new ServiceCatalogService(
            _repositoryMock.Object,
            _loggerMock.Object);
    }

    #region GetAllAsync Tests

    [Fact]
    public async Task GetAllAsync_ShouldReturnAllServices()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogItem>(5).ToList();
        _repositoryMock.Setup(x => x.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(services);

        // Act
        var result = await _sut.GetAllAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().HaveCount(5);
        _repositoryMock.Verify(x => x.GetAllAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetAllAsync_WhenNoServices_ShouldReturnEmptyList()
    {
        // Arrange
        _repositoryMock.Setup(x => x.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ServiceCatalogItem>());

        // Act
        var result = await _sut.GetAllAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEmpty();
    }

    #endregion

    #region GetByIdAsync Tests

    [Fact]
    public async Task GetByIdAsync_WithValidId_ShouldReturnService()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogItem>();
        _repositoryMock.Setup(x => x.GetByIdAsync(service.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);

        // Act
        var result = await _sut.GetByIdAsync(service.Id);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(service.Id);
    }

    [Fact]
    public async Task GetByIdAsync_WithInvalidId_ShouldThrowNotFoundException()
    {
        // Arrange
        var invalidId = 999;
        _repositoryMock.Setup(x => x.GetByIdAsync(invalidId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ServiceCatalogItem?)null);

        // Act
        Func<Task> act = async () => await _sut.GetByIdAsync(invalidId);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>()
            .WithMessage($"*{invalidId}*");
    }

    #endregion

    #region GetByCodeAsync Tests

    [Fact]
    public async Task GetByCodeAsync_WithValidCode_ShouldReturnService()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogItem>();
        _repositoryMock.Setup(x => x.GetByCodeAsync(service.ServiceCode, It.IsAny<CancellationToken>()))
            .ReturnsAsync(service);

        // Act
        var result = await _sut.GetByCodeAsync(service.ServiceCode);

        // Assert
        result.Should().NotBeNull();
        result.ServiceCode.Should().Be(service.ServiceCode);
    }

    [Fact]
    public async Task GetByCodeAsync_WithInvalidCode_ShouldThrowNotFoundException()
    {
        // Arrange
        var invalidCode = "INVALID-CODE";
        _repositoryMock.Setup(x => x.GetByCodeAsync(invalidCode, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ServiceCatalogItem?)null);

        // Act
        Func<Task> act = async () => await _sut.GetByCodeAsync(invalidCode);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    #endregion

    #region CreateAsync Tests

    [Fact]
    public async Task CreateAsync_WithValidRequest_ShouldReturnCreatedService()
    {
        // Arrange
        var request = _fixture.Create<CreateServiceRequest>();
        var createdService = _fixture.Build<ServiceCatalogItem>()
            .With(x => x.ServiceCode, request.ServiceCode)
            .With(x => x.ServiceName, request.ServiceName)
            .Create();

        _repositoryMock.Setup(x => x.GetByCodeAsync(request.ServiceCode, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ServiceCatalogItem?)null);
        _repositoryMock.Setup(x => x.AddAsync(It.IsAny<ServiceCatalogItem>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(createdService);

        // Act
        var result = await _sut.CreateAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.ServiceCode.Should().Be(request.ServiceCode);
        _repositoryMock.Verify(x => x.AddAsync(It.IsAny<ServiceCatalogItem>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task CreateAsync_WithDuplicateCode_ShouldThrowConflictException()
    {
        // Arrange
        var existingService = _fixture.Create<ServiceCatalogItem>();
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, existingService.ServiceCode)
            .Create();

        _repositoryMock.Setup(x => x.GetByCodeAsync(request.ServiceCode, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingService);

        // Act
        Func<Task> act = async () => await _sut.CreateAsync(request);

        // Assert
        await act.Should().ThrowAsync<ConflictException>()
            .WithMessage($"*{request.ServiceCode}*");
    }

    #endregion

    #region UpdateAsync Tests

    [Fact]
    public async Task UpdateAsync_WithValidRequest_ShouldReturnUpdatedService()
    {
        // Arrange
        var existingService = _fixture.Create<ServiceCatalogItem>();
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Updated Name")
            .Create();

        _repositoryMock.Setup(x => x.GetByIdAsync(existingService.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingService);
        _repositoryMock.Setup(x => x.UpdateAsync(It.IsAny<ServiceCatalogItem>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingService);

        // Act
        var result = await _sut.UpdateAsync(existingService.Id, request);

        // Assert
        result.Should().NotBeNull();
        _repositoryMock.Verify(x => x.UpdateAsync(It.IsAny<ServiceCatalogItem>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task UpdateAsync_WithInvalidId_ShouldThrowNotFoundException()
    {
        // Arrange
        var invalidId = 999;
        var request = _fixture.Create<UpdateServiceRequest>();

        _repositoryMock.Setup(x => x.GetByIdAsync(invalidId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ServiceCatalogItem?)null);

        // Act
        Func<Task> act = async () => await _sut.UpdateAsync(invalidId, request);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    #endregion

    #region DeleteAsync Tests

    [Fact]
    public async Task DeleteAsync_WithValidId_ShouldDeleteService()
    {
        // Arrange
        var existingService = _fixture.Create<ServiceCatalogItem>();
        _repositoryMock.Setup(x => x.GetByIdAsync(existingService.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingService);
        _repositoryMock.Setup(x => x.DeleteAsync(existingService, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        await _sut.DeleteAsync(existingService.Id);

        // Assert
        _repositoryMock.Verify(x => x.DeleteAsync(existingService, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task DeleteAsync_WithInvalidId_ShouldThrowNotFoundException()
    {
        // Arrange
        var invalidId = 999;
        _repositoryMock.Setup(x => x.GetByIdAsync(invalidId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ServiceCatalogItem?)null);

        // Act
        Func<Task> act = async () => await _sut.DeleteAsync(invalidId);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    #endregion

    #region SearchAsync Tests

    [Theory]
    [InlineData("test", 5)]
    [InlineData("service", 3)]
    [InlineData("nonexistent", 0)]
    public async Task SearchAsync_WithSearchTerm_ShouldReturnMatchingServices(string searchTerm, int expectedCount)
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogItem>(expectedCount).ToList();
        _repositoryMock.Setup(x => x.SearchAsync(searchTerm, It.IsAny<CancellationToken>()))
            .ReturnsAsync(services);

        // Act
        var result = await _sut.SearchAsync(searchTerm);

        // Assert
        result.Should().HaveCount(expectedCount);
    }

    #endregion
}
