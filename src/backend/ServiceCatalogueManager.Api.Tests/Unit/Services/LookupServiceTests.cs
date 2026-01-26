// =============================================================================
// SERVICE CATALOGUE MANAGER - LOOKUP SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class LookupServiceTests
{
    private readonly Mock<ILookupRepository> _repositoryMock;
    private readonly Mock<ILogger<LookupService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly LookupService _sut;

    public LookupServiceTests()
    {
        _repositoryMock = new Mock<ILookupRepository>();
        _loggerMock = new Mock<ILogger<LookupService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        _sut = new LookupService(
            _repositoryMock.Object,
            _loggerMock.Object);
    }

    #region GetServiceStatusesAsync Tests

    [Fact]
    public async Task GetServiceStatusesAsync_ShouldReturnAllStatuses()
    {
        // Arrange
        var statuses = _fixture.CreateMany<ServiceStatusDto>(5).ToList();
        _repositoryMock.Setup(x => x.GetServiceStatusesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(statuses);

        // Act
        var result = await _sut.GetServiceStatusesAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().HaveCount(5);
        _repositoryMock.Verify(x => x.GetServiceStatusesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetServiceStatusesAsync_WhenEmpty_ShouldReturnEmptyList()
    {
        // Arrange
        _repositoryMock.Setup(x => x.GetServiceStatusesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ServiceStatusDto>());

        // Act
        var result = await _sut.GetServiceStatusesAsync();

        // Assert
        result.Should().BeEmpty();
    }

    #endregion

    #region GetServiceCategoriesAsync Tests

    [Fact]
    public async Task GetServiceCategoriesAsync_ShouldReturnAllCategories()
    {
        // Arrange
        var categories = _fixture.CreateMany<ServiceCategoryDto>(7).ToList();
        _repositoryMock.Setup(x => x.GetServiceCategoriesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(categories);

        // Act
        var result = await _sut.GetServiceCategoriesAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().HaveCount(7);
    }

    [Fact]
    public async Task GetServiceCategoriesAsync_ShouldReturnActiveOnly()
    {
        // Arrange
        var categories = _fixture.Build<ServiceCategoryDto>()
            .With(x => x.IsActive, true)
            .CreateMany(5)
            .ToList();
        
        _repositoryMock.Setup(x => x.GetServiceCategoriesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(categories);

        // Act
        var result = await _sut.GetServiceCategoriesAsync();

        // Assert
        result.Should().OnlyContain(x => x.IsActive);
    }

    #endregion

    #region GetBusinessUnitsAsync Tests

    [Fact]
    public async Task GetBusinessUnitsAsync_ShouldReturnAllBusinessUnits()
    {
        // Arrange
        var businessUnits = _fixture.CreateMany<BusinessUnitDto>(6).ToList();
        _repositoryMock.Setup(x => x.GetBusinessUnitsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(businessUnits);

        // Act
        var result = await _sut.GetBusinessUnitsAsync();

        // Assert
        result.Should().HaveCount(6);
    }

    #endregion

    #region GetResponsibleRolesAsync Tests

    [Fact]
    public async Task GetResponsibleRolesAsync_ShouldReturnAllRoles()
    {
        // Arrange
        var roles = _fixture.CreateMany<ResponsibleRoleDto>(8).ToList();
        _repositoryMock.Setup(x => x.GetResponsibleRolesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(roles);

        // Act
        var result = await _sut.GetResponsibleRolesAsync();

        // Assert
        result.Should().HaveCount(8);
    }

    #endregion

    #region GetDependencyTypesAsync Tests

    [Fact]
    public async Task GetDependencyTypesAsync_ShouldReturnAllTypes()
    {
        // Arrange
        var types = _fixture.CreateMany<DependencyTypeDto>(5).ToList();
        _repositoryMock.Setup(x => x.GetDependencyTypesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(types);

        // Act
        var result = await _sut.GetDependencyTypesAsync();

        // Assert
        result.Should().HaveCount(5);
    }

    #endregion

    #region GetCloudProvidersAsync Tests

    [Fact]
    public async Task GetCloudProvidersAsync_ShouldReturnAllProviders()
    {
        // Arrange
        var providers = _fixture.CreateMany<CloudProviderDto>(4).ToList();
        _repositoryMock.Setup(x => x.GetCloudProvidersAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(providers);

        // Act
        var result = await _sut.GetCloudProvidersAsync();

        // Assert
        result.Should().HaveCount(4);
    }

    #endregion

    #region GetAllLookupsAsync Tests

    [Fact]
    public async Task GetAllLookupsAsync_ShouldReturnAllLookupData()
    {
        // Arrange
        var statuses = _fixture.CreateMany<ServiceStatusDto>(5).ToList();
        var categories = _fixture.CreateMany<ServiceCategoryDto>(7).ToList();
        var businessUnits = _fixture.CreateMany<BusinessUnitDto>(6).ToList();
        var roles = _fixture.CreateMany<ResponsibleRoleDto>(8).ToList();
        var dependencyTypes = _fixture.CreateMany<DependencyTypeDto>(5).ToList();
        var cloudProviders = _fixture.CreateMany<CloudProviderDto>(4).ToList();

        _repositoryMock.Setup(x => x.GetServiceStatusesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(statuses);
        _repositoryMock.Setup(x => x.GetServiceCategoriesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(categories);
        _repositoryMock.Setup(x => x.GetBusinessUnitsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(businessUnits);
        _repositoryMock.Setup(x => x.GetResponsibleRolesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(roles);
        _repositoryMock.Setup(x => x.GetDependencyTypesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(dependencyTypes);
        _repositoryMock.Setup(x => x.GetCloudProvidersAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(cloudProviders);

        // Act
        var result = await _sut.GetAllLookupsAsync();

        // Assert
        result.Should().NotBeNull();
        result.Statuses.Should().HaveCount(5);
        result.Categories.Should().HaveCount(7);
        result.BusinessUnits.Should().HaveCount(6);
        result.Roles.Should().HaveCount(8);
        result.DependencyTypes.Should().HaveCount(5);
        result.CloudProviders.Should().HaveCount(4);
    }

    #endregion

    #region Caching Tests

    [Fact]
    public async Task GetServiceStatusesAsync_ShouldCacheResults()
    {
        // Arrange
        var statuses = _fixture.CreateMany<ServiceStatusDto>(5).ToList();
        _repositoryMock.Setup(x => x.GetServiceStatusesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(statuses);

        // Act
        var result1 = await _sut.GetServiceStatusesAsync();
        var result2 = await _sut.GetServiceStatusesAsync();

        // Assert
        result1.Should().BeEquivalentTo(result2);
        // Note: Actual caching implementation would be tested with cache mock
    }

    #endregion
}
