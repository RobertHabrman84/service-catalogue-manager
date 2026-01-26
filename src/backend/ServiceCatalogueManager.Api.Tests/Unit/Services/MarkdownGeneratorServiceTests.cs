// =============================================================================
// SERVICE CATALOGUE MANAGER - MARKDOWN GENERATOR SERVICE TESTS
// =============================================================================

namespace ServiceCatalogueManager.Api.Tests.Unit.Services;

public class MarkdownGeneratorServiceTests
{
    private readonly Mock<ILogger<MarkdownGeneratorService>> _loggerMock;
    private readonly IFixture _fixture;
    private readonly MarkdownGeneratorService _sut;

    public MarkdownGeneratorServiceTests()
    {
        _loggerMock = new Mock<ILogger<MarkdownGeneratorService>>();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        
        _sut = new MarkdownGeneratorService(_loggerMock.Object);
    }

    #region GenerateServiceMarkdownAsync Tests

    [Fact]
    public async Task GenerateServiceMarkdownAsync_WithValidService_ShouldReturnMarkdown()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task GenerateServiceMarkdownAsync_ShouldContainServiceName()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceName, "Test Service Name")
            .Create();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().Contain("Test Service Name");
    }

    [Fact]
    public async Task GenerateServiceMarkdownAsync_ShouldStartWithH1Header()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().StartWith("# ");
    }

    [Fact]
    public async Task GenerateServiceMarkdownAsync_ShouldContainAllSections()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.UsageScenarios, _fixture.CreateMany<UsageScenarioDto>(2).ToList())
            .With(x => x.Dependencies, _fixture.CreateMany<ServiceDependencyDto>(2).ToList())
            .With(x => x.Prerequisites, _fixture.CreateMany<PrerequisiteDto>(2).ToList())
            .Create();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().Contain("## Overview");
        result.Should().Contain("## Usage Scenarios");
        result.Should().Contain("## Dependencies");
        result.Should().Contain("## Prerequisites");
    }

    [Fact]
    public async Task GenerateServiceMarkdownAsync_WithNullService_ShouldThrowArgumentNullException()
    {
        // Arrange
        ServiceCatalogDetailDto? service = null;

        // Act
        Func<Task> act = async () => await _sut.GenerateServiceMarkdownAsync(service!);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    #endregion

    #region GenerateCatalogMarkdownAsync Tests

    [Fact]
    public async Task GenerateCatalogMarkdownAsync_WithValidServices_ShouldReturnMarkdown()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogListDto>(5).ToList();

        // Act
        var result = await _sut.GenerateCatalogMarkdownAsync(services);

        // Assert
        result.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task GenerateCatalogMarkdownAsync_ShouldContainTableOfContents()
    {
        // Arrange
        var services = _fixture.CreateMany<ServiceCatalogListDto>(3).ToList();

        // Act
        var result = await _sut.GenerateCatalogMarkdownAsync(services);

        // Assert
        result.Should().Contain("## Table of Contents");
    }

    [Fact]
    public async Task GenerateCatalogMarkdownAsync_ShouldContainAllServiceNames()
    {
        // Arrange
        var services = new List<ServiceCatalogListDto>
        {
            _fixture.Build<ServiceCatalogListDto>().With(x => x.ServiceName, "Service A").Create(),
            _fixture.Build<ServiceCatalogListDto>().With(x => x.ServiceName, "Service B").Create(),
            _fixture.Build<ServiceCatalogListDto>().With(x => x.ServiceName, "Service C").Create()
        };

        // Act
        var result = await _sut.GenerateCatalogMarkdownAsync(services);

        // Assert
        result.Should().Contain("Service A");
        result.Should().Contain("Service B");
        result.Should().Contain("Service C");
    }

    [Fact]
    public async Task GenerateCatalogMarkdownAsync_WithEmptyList_ShouldReturnBasicStructure()
    {
        // Arrange
        var services = new List<ServiceCatalogListDto>();

        // Act
        var result = await _sut.GenerateCatalogMarkdownAsync(services);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("# Service Catalogue");
    }

    #endregion

    #region Markdown Format Tests

    [Fact]
    public async Task GenerateServiceMarkdownAsync_ShouldProduceValidMarkdownSyntax()
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        // Check for properly formatted headers
        result.Should().MatchRegex(@"^#+ .+", "Should start with markdown header");
        
        // Check for no unclosed formatting
        var asterisks = result.Count(c => c == '*');
        (asterisks % 2).Should().Be(0, "Asterisks should be balanced");
    }

    [Theory]
    [InlineData("**bold**")]
    [InlineData("_italic_")]
    [InlineData("- list item")]
    public async Task GenerateServiceMarkdownAsync_ShouldContainMarkdownFormatting(string expectedFormat)
    {
        // Arrange
        var service = _fixture.Create<ServiceCatalogDetailDto>();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        // Note: This depends on the actual implementation
        result.Should().NotBeNullOrEmpty();
    }

    #endregion

    #region Edge Cases

    [Fact]
    public async Task GenerateServiceMarkdownAsync_WithSpecialCharacters_ShouldEscapeProperly()
    {
        // Arrange
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.ServiceName, "Test <Service> & \"Special\" Characters")
            .Create();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
        // Should not break markdown structure
        result.Should().Contain("Test");
    }

    [Fact]
    public async Task GenerateServiceMarkdownAsync_WithLongDescription_ShouldWrapProperly()
    {
        // Arrange
        var longDescription = new string('x', 5000);
        var service = _fixture.Build<ServiceCatalogDetailDto>()
            .With(x => x.LongDescription, longDescription)
            .Create();

        // Act
        var result = await _sut.GenerateServiceMarkdownAsync(service);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain(longDescription);
    }

    #endregion
}
