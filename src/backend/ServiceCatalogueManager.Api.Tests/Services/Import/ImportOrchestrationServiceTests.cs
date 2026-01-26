using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Services.Import;

namespace ServiceCatalogueManager.Api.Tests.Services.Import;

public class ImportOrchestrationServiceTests : IDisposable
{
    private readonly ServiceCatalogDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILookupResolverService _lookupResolver;
    private readonly IImportValidationService _validationService;
    private readonly Mock<ILogger<ImportOrchestrationService>> _loggerMock;
    private readonly ImportOrchestrationService _service;

    public ImportOrchestrationServiceTests()
    {
        var options = new DbContextOptionsBuilder<ServiceCatalogDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ServiceCatalogDbContext(options);
        _cache = new MemoryCache(new MemoryCacheOptions());
        _loggerMock = new Mock<ILogger<ImportOrchestrationService>>();

        // Seed lookup data
        SeedLookupData();

        // Create real instances of dependent services
        var lookupResolverLogger = new Mock<ILogger<LookupResolverService>>();
        _lookupResolver = new LookupResolverService(_context, _cache, lookupResolverLogger.Object);

        var validationLogger = new Mock<ILogger<ImportValidationService>>();
        _validationService = new ImportValidationService(_context, _lookupResolver, validationLogger.Object);

        _service = new ImportOrchestrationService(_context, _lookupResolver, _validationService, _loggerMock.Object);
    }

    private void SeedLookupData()
    {
        // Size options
        _context.Set<LU_SizeOption>().AddRange(
            new LU_SizeOption { SizeOptionId = 1, Code = "S", Name = "Small", IsActive = true },
            new LU_SizeOption { SizeOptionId = 2, Code = "M", Name = "Medium", IsActive = true },
            new LU_SizeOption { SizeOptionId = 3, Code = "L", Name = "Large", IsActive = true }
        );

        // Categories
        _context.Set<LU_ServiceCategory>().Add(
            new LU_ServiceCategory
            {
                CategoryId = 1,
                Code = "ARCH",
                Name = "Architecture",
                CategoryPath = "Services/Architecture",
                IsActive = true
            }
        );

        // Dependency types
        _context.Set<LU_DependencyType>().AddRange(
            new LU_DependencyType { DependencyTypeId = 1, Code = "PREREQUISITE", Name = "Prerequisite", IsActive = true },
            new LU_DependencyType { DependencyTypeId = 2, Code = "TRIGGERS_FOR", Name = "Triggers For", IsActive = true }
        );

        // Requirement levels
        _context.Set<LU_RequirementLevel>().AddRange(
            new LU_RequirementLevel { RequirementLevelId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true }
        );

        // Roles
        _context.Set<LU_Role>().Add(
            new LU_Role { RoleId = 1, Code = "CLOUD_ARCHITECT", Name = "Cloud Architect", IsActive = true }
        );

        // Prerequisite categories
        _context.Set<LU_PrerequisiteCategory>().AddRange(
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 1, Code = "ORGANIZATIONAL", Name = "Organizational", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 2, Code = "TECHNICAL", Name = "Technical", IsActive = true }
        );

        // Tool categories
        _context.Set<LU_ToolCategory>().Add(
            new LU_ToolCategory { ToolCategoryId = 1, Code = "CLOUD_PLATFORMS", Name = "Cloud Platforms", IsActive = true }
        );

        // License types
        _context.Set<LU_LicenseType>().Add(
            new LU_LicenseType { LicenseTypeId = 1, Code = "REQUIRED", Name = "Required", IsActive = true }
        );

        // Interaction levels
        _context.Set<LU_InteractionLevel>().Add(
            new LU_InteractionLevel { InteractionLevelId = 1, Code = "HIGH", Name = "High", IsActive = true }
        );

        // Scope types
        _context.Set<LU_ScopeType>().AddRange(
            new LU_ScopeType { ScopeTypeId = 1, Code = "IN_SCOPE", Name = "In Scope", IsActive = true },
            new LU_ScopeType { ScopeTypeId = 2, Code = "OUT_OF_SCOPE", Name = "Out of Scope", IsActive = true }
        );

        _context.SaveChanges();
    }

    [Fact]
    public async Task ImportServiceAsync_ValidService_ImportsSuccessfully()
    {
        // Arrange
        var model = CreateValidServiceModel();

        // Act
        var result = await _service.ImportServiceAsync(model);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.True(result.ServiceId > 0);
        Assert.Equal("ID001", result.ServiceCode);

        // Verify service was created
        var service = await _context.ServiceCatalogItems
            .FirstOrDefaultAsync(s => s.ServiceCode == "ID001");
        Assert.NotNull(service);
        Assert.Equal("Test Service", service.ServiceName);
    }

    [Fact]
    public async Task ImportServiceAsync_WithUsageScenarios_CreatesScenarios()
    {
        // Arrange
        var model = CreateValidServiceModel();
        model.UsageScenarios = new List<UsageScenarioImportModel>
        {
            new() { ScenarioNumber = 1, ScenarioTitle = "Scenario 1", ScenarioDescription = "Description 1" },
            new() { ScenarioNumber = 2, ScenarioTitle = "Scenario 2", ScenarioDescription = "Description 2" }
        };

        // Act
        var result = await _service.ImportServiceAsync(model);

        // Assert
        Assert.True(result.IsSuccess);

        var scenarios = await _context.Set<UsageScenario>()
            .Where(s => s.ServiceId == result.ServiceId)
            .ToListAsync();

        Assert.Equal(2, scenarios.Count);
        Assert.Contains(scenarios, s => s.ScenarioNumber == 1);
        Assert.Contains(scenarios, s => s.ScenarioNumber == 2);
    }

    [Fact]
    public async Task ImportServiceAsync_WithSizeOptions_CreatesSizeOptions()
    {
        // Arrange
        var model = CreateValidServiceModel();
        model.SizeOptions = new List<SizeOptionImportModel>
        {
            new()
            {
                SizeCode = "M",
                Description = "Medium size",
                Duration = "4-6 weeks",
                Effort = new EffortImportModel { HoursMin = 100, HoursMax = 200 }
            }
        };

        // Act
        var result = await _service.ImportServiceAsync(model);

        // Assert
        Assert.True(result.IsSuccess);

        var sizeOptions = await _context.Set<ServiceSizeOption>()
            .Where(s => s.ServiceId == result.ServiceId)
            .ToListAsync();

        Assert.Single(sizeOptions);
        Assert.Equal(2, sizeOptions[0].SizeOptionId); // M = ID 2
    }

    [Fact]
    public async Task ImportServiceAsync_WithResponsibleRoles_CreatesRoles()
    {
        // Arrange
        var model = CreateValidServiceModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "Cloud Architect", IsPrimaryOwner = true, Responsibilities = "Lead design" }
        };

        // Act
        var result = await _service.ImportServiceAsync(model);

        // Assert
        Assert.True(result.IsSuccess);

        var roles = await _context.Set<ServiceResponsibleRole>()
            .Where(r => r.ServiceId == result.ServiceId)
            .ToListAsync();

        Assert.Single(roles);
        Assert.True(roles[0].IsPrimaryOwner);
    }

    [Fact]
    public async Task ImportServiceAsync_InvalidService_RollsBackTransaction()
    {
        // Arrange - Create service with invalid data (no primary owner)
        var model = CreateValidServiceModel();
        model.ResponsibleRoles = new List<ResponsibleRoleImportModel>
        {
            new() { RoleName = "Cloud Architect", IsPrimaryOwner = false }
        };

        // Act
        var result = await _service.ImportServiceAsync(model);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.NotEmpty(result.Errors);

        // Verify nothing was created
        var serviceCount = await _context.ServiceCatalogItems.CountAsync();
        Assert.Equal(0, serviceCount);
    }

    [Fact]
    public async Task ImportServiceAsync_DuplicateServiceCode_ReturnsError()
    {
        // Arrange - Create first service
        var model1 = CreateValidServiceModel();
        var result1 = await _service.ImportServiceAsync(model1);
        Assert.True(result1.IsSuccess);

        // Try to create second service with same code
        var model2 = CreateValidServiceModel();

        // Act
        var result2 = await _service.ImportServiceAsync(model2);

        // Assert
        Assert.False(result2.IsSuccess);
        Assert.Contains(result2.Errors, e => e.Code == "DUPLICATE_SERVICE_CODE");
    }

    [Fact]
    public async Task ImportServicesAsync_MultipleServices_ImportsAll()
    {
        // Arrange
        var models = new List<ImportServiceModel>
        {
            CreateValidServiceModel("ID001", "Service 1"),
            CreateValidServiceModel("ID002", "Service 2"),
            CreateValidServiceModel("ID003", "Service 3")
        };

        // Act
        var result = await _service.ImportServicesAsync(models);

        // Assert
        Assert.Equal(3, result.TotalCount);
        Assert.Equal(3, result.SuccessCount);
        Assert.Equal(0, result.FailCount);

        var services = await _context.ServiceCatalogItems.ToListAsync();
        Assert.Equal(3, services.Count);
    }

    [Fact]
    public async Task ImportServicesAsync_SomeInvalid_ImportsValidOnly()
    {
        // Arrange
        var models = new List<ImportServiceModel>
        {
            CreateValidServiceModel("ID001", "Service 1"),
            CreateInvalidServiceModel("INVALID", "Service 2"), // Invalid code format
            CreateValidServiceModel("ID003", "Service 3")
        };

        // Act
        var result = await _service.ImportServicesAsync(models);

        // Assert
        Assert.Equal(3, result.TotalCount);
        Assert.Equal(2, result.SuccessCount);
        Assert.Equal(1, result.FailCount);

        var services = await _context.ServiceCatalogItems.ToListAsync();
        Assert.Equal(2, services.Count);
    }

    [Fact]
    public async Task ValidateImportAsync_ValidService_ReturnsValid()
    {
        // Arrange
        var model = CreateValidServiceModel();

        // Act
        var result = await _service.ValidateImportAsync(model);

        // Assert
        Assert.True(result.IsValid);
        Assert.Empty(result.Errors);
    }

    private ImportServiceModel CreateValidServiceModel(
        string serviceCode = "ID001", 
        string serviceName = "Test Service")
    {
        return new ImportServiceModel
        {
            ServiceCode = serviceCode,
            ServiceName = serviceName,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = "Test service description",
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    private ImportServiceModel CreateInvalidServiceModel(string serviceCode, string serviceName)
    {
        return new ImportServiceModel
        {
            ServiceCode = serviceCode,
            ServiceName = serviceName,
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
        _cache.Dispose();
    }
}
