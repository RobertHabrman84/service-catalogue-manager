using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Services.Import;

namespace ServiceCatalogueManager.Api.Tests.Services.Import;

public class ImportValidationServiceTests : IDisposable
{
    private readonly ServiceCatalogDbContext _context;
    private readonly Mock<ILookupResolverService> _lookupResolverMock;
    private readonly Mock<ILogger<ImportValidationService>> _loggerMock;
    private readonly ImportValidationService _service;

    public ImportValidationServiceTests()
    {
        var options = new DbContextOptionsBuilder<ServiceCatalogDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ServiceCatalogDbContext(options);
        _lookupResolverMock = new Mock<ILookupResolverService>();
        _loggerMock = new Mock<ILogger<ImportValidationService>>();

        _service = new ImportValidationService(_context, _lookupResolverMock.Object, _loggerMock.Object);

        SetupDefaultMocks();
        SeedTestData();
    }

    private void SetupDefaultMocks()
    {
        // Setup default successful lookups
        _lookupResolverMock
            .Setup(x => x.ResolveCategoryIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);

        _lookupResolverMock
            .Setup(x => x.ResolveSizeOptionIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);

        _lookupResolverMock
            .Setup(x => x.ResolveRequirementLevelIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);

        _lookupResolverMock
            .Setup(x => x.ResolveRoleIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);

        _lookupResolverMock
            .Setup(x => x.ResolvePrerequisiteCategoryIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);

        _lookupResolverMock
            .Setup(x => x.ResolveInteractionLevelIdAsync(It.IsAny<string>()))
            .ReturnsAsync(1);
    }

    private void SeedTestData()
    {
        // Add existing service for duplicate testing
        _context.ServiceCatalogItems.Add(new ServiceCatalogItem
        {
            ServiceId = 1,
            ServiceCode = "ID999",
            ServiceName = "Existing Service",
            CategoryId = 1,
            Description = "Test service"
        });

        _context.SaveChanges();
    }

    [Fact]
    public async Task ValidateImportAsync_ValidModel_ReturnsValid()
    {
        // Arrange
        var model = CreateValidModel();

        // Act
        var result = await _service.ValidateImportAsync(model);

        // Assert
        Assert.True(result.IsValid);
        Assert.Empty(result.Errors);
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public async Task ValidateBusinessRulesAsync_EmptyServiceCode_ReturnsError(string? serviceCode)
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = serviceCode!;

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.NotEmpty(errors);
    }

    [Theory]
    [InlineData("INVALID")]
    [InlineData("ID12")]
    [InlineData("ID1234")]
    [InlineData("id001")]
    [InlineData("ID00A")]
    public async Task ValidateBusinessRulesAsync_InvalidServiceCodeFormat_ReturnsError(string serviceCode)
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = serviceCode;

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Field == nameof(model.ServiceCode) && e.Code == "INVALID_FORMAT");
    }

    [Theory]
    [InlineData("ID001")]
    [InlineData("ID123")]
    [InlineData("ID999")]
    public async Task ValidateBusinessRulesAsync_ValidServiceCodeFormat_PassesValidation(string serviceCode)
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = serviceCode;

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.DoesNotContain(errors, e => e.Field == nameof(model.ServiceCode) && e.Code == "INVALID_FORMAT");
    }

    [Fact]
    public async Task ValidateBusinessRulesAsync_CategoryNotFound_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        _lookupResolverMock
            .Setup(x => x.ResolveCategoryIdAsync(model.Category))
            .ReturnsAsync((int?)null);

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Field == nameof(model.Category) && e.Code == "NOT_FOUND");
    }

    [Fact]
    public async Task ValidateBusinessRulesAsync_DuplicateScenarioNumbers_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.UsageScenarios = new List<UsageScenarioImportModel>
        {
            new() { ScenarioNumber = 1, ScenarioTitle = "Scenario 1", ScenarioDescription = "Desc 1" },
            new() { ScenarioNumber = 1, ScenarioTitle = "Scenario 2", ScenarioDescription = "Desc 2" }
        };

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Field == nameof(model.UsageScenarios) && e.Code == "DUPLICATE_SCENARIO");
    }

    [Fact]
    public async Task ValidateBusinessRulesAsync_DuplicateSizeCodes_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.SizeOptions = new List<SizeOptionImportModel>
        {
            new() { SizeCode = "M", Description = "Medium 1", Duration = "4 weeks", Effort = new EffortImportModel() },
            new() { SizeCode = "M", Description = "Medium 2", Duration = "6 weeks", Effort = new EffortImportModel() }
        };

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Field == nameof(model.SizeOptions) && e.Code == "DUPLICATE_SIZE");
    }

    [Fact]
    public async Task ValidateBusinessRulesAsync_HoursMinGreaterThanMax_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.SizeOptions = new List<SizeOptionImportModel>
        {
            new()
            {
                SizeCode = "M",
                Description = "Medium",
                Duration = "4 weeks",
                Effort = new EffortImportModel
                {
                    HoursMin = 200,
                    HoursMax = 100
                }
            }
        };

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "INVALID_RANGE");
    }

    [Fact]
    public async Task ValidateBusinessRulesAsync_NegativeHours_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.SizeOptions = new List<SizeOptionImportModel>
        {
            new()
            {
                SizeCode = "M",
                Description = "Medium",
                Duration = "4 weeks",
                Effort = new EffortImportModel { Hours = -100 }
            }
        };

        // Act
        var errors = await _service.ValidateBusinessRulesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "NEGATIVE_VALUE");
    }

    [Fact]
    public async Task ValidateLookupsAsync_SizeOptionNotFound_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.SizeOptions = new List<SizeOptionImportModel>
        {
            new() { SizeCode = "INVALID", Description = "Test", Duration = "1 week", Effort = new EffortImportModel() }
        };

        _lookupResolverMock
            .Setup(x => x.ResolveSizeOptionIdAsync("INVALID"))
            .ReturnsAsync((int?)null);

        // Act
        var errors = await _service.ValidateLookupsAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "LOOKUP_NOT_FOUND" && e.Message.Contains("INVALID"));
    }

    [Fact]
    public async Task ValidateLookupsAsync_RequirementLevelNotFound_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceInputs = new List<ServiceInputImportModel>
        {
            new() { ParameterName = "Test", RequirementLevel = "INVALID" }
        };

        _lookupResolverMock
            .Setup(x => x.ResolveRequirementLevelIdAsync("INVALID"))
            .ReturnsAsync((int?)null);

        // Act
        var errors = await _service.ValidateLookupsAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "LOOKUP_NOT_FOUND" && e.Message.Contains("INVALID"));
    }

    [Fact]
    public async Task ValidateLookupsAsync_RoleNotFound_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "INVALID_ROLE", IsPrimaryOwner = true }
        };

        _lookupResolverMock
            .Setup(x => x.ResolveRoleIdAsync("INVALID_ROLE"))
            .ReturnsAsync((int?)null);

        // Act
        var errors = await _service.ValidateLookupsAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "LOOKUP_NOT_FOUND" && e.Message.Contains("INVALID_ROLE"));
    }

    [Fact]
    public async Task ValidateDuplicatesAsync_DuplicateServiceCode_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = "ID999"; // Exists in test data

        // Act
        var errors = await _service.ValidateDuplicatesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "DUPLICATE_SERVICE_CODE");
    }

    [Fact]
    public async Task ValidateDuplicatesAsync_UniqueServiceCode_PassesValidation()
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = "ID001"; // Does not exist

        // Act
        var errors = await _service.ValidateDuplicatesAsync(model);

        // Assert
        Assert.Empty(errors);
    }

    [Fact]
    public async Task ValidateReferencesAsync_ReferencedServiceNotFound_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.Dependencies = new DependenciesImportModel
        {
            Prerequisite = new List<DependencyImportModel>
            {
                new()
                {
                    ServiceCode = "ID998",
                    ServiceName = "Non-existent Service",
                    RequirementLevel = "REQUIRED"
                }
            }
        };

        // Act
        var errors = await _service.ValidateReferencesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "REFERENCE_NOT_FOUND");
    }

    [Fact]
    public async Task ValidateReferencesAsync_CircularReference_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ServiceCode = "ID001";
        model.Dependencies = new DependenciesImportModel
        {
            Prerequisite = new List<DependencyImportModel>
            {
                new()
                {
                    ServiceCode = "ID001", // Same as current service
                    ServiceName = "Self",
                    RequirementLevel = "REQUIRED"
                }
            }
        };

        // Act
        var errors = await _service.ValidateReferencesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "CIRCULAR_REFERENCE");
    }

    [Fact]
    public async Task ValidateReferencesAsync_NoPrimaryOwner_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "Role1", IsPrimaryOwner = false },
            new() { RoleName = "Role2", IsPrimaryOwner = false }
        };

        // Act
        var errors = await _service.ValidateReferencesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "MISSING_PRIMARY_OWNER");
    }

    [Fact]
    public async Task ValidateReferencesAsync_MultiplePrimaryOwners_ReturnsError()
    {
        // Arrange
        var model = CreateValidModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "Role1", IsPrimaryOwner = true },
            new() { RoleName = "Role2", IsPrimaryOwner = true }
        };

        // Act
        var errors = await _service.ValidateReferencesAsync(model);

        // Assert
        Assert.Contains(errors, e => e.Code == "MULTIPLE_PRIMARY_OWNERS");
    }

    [Fact]
    public async Task ValidateReferencesAsync_OnePrimaryOwner_PassesValidation()
    {
        // Arrange
        var model = CreateValidModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "Role1", IsPrimaryOwner = true },
            new() { RoleName = "Role2", IsPrimaryOwner = false }
        };

        // Act
        var errors = await _service.ValidateReferencesAsync(model);

        // Assert
        Assert.DoesNotContain(errors, e => e.Code == "MISSING_PRIMARY_OWNER" || e.Code == "MULTIPLE_PRIMARY_OWNERS");
    }

    private ImportServiceModel CreateValidModel()
    {
        return new ImportServiceModel
        {
            ServiceCode = "ID001",
            ServiceName = "Test Service",
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = "Test service description",
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
