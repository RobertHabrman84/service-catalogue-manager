using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Services.Import;

namespace ServiceCatalogueManager.Api.Tests.Services.Import;

public class LookupResolverServiceTests : IDisposable
{
    private readonly ServiceCatalogDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly Mock<ILogger<LookupResolverService>> _loggerMock;
    private readonly LookupResolverService _service;

    public LookupResolverServiceTests()
    {
        // Setup in-memory database
        var options = new DbContextOptionsBuilder<ServiceCatalogDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ServiceCatalogDbContext(options);
        _cache = new MemoryCache(new MemoryCacheOptions());
        _loggerMock = new Mock<ILogger<LookupResolverService>>();

        _service = new LookupResolverService(_context, _cache, _loggerMock.Object);

        // Seed test data
        SeedTestData();
    }

    private void SeedTestData()
    {
        // Size options
        _context.Set<LU_SizeOption>().AddRange(
            new LU_SizeOption { SizeOptionId = 1, Code = "S", Name = "Small", IsActive = true },
            new LU_SizeOption { SizeOptionId = 2, Code = "M", Name = "Medium", IsActive = true },
            new LU_SizeOption { SizeOptionId = 3, Code = "L", Name = "Large", IsActive = true },
            new LU_SizeOption { SizeOptionId = 4, Code = "XL", Name = "Extra Large", IsActive = true },
            new LU_SizeOption { SizeOptionId = 5, Code = "XXL", Name = "Extra Extra Large", IsActive = true }
        );

        // Dependency types
        _context.Set<LU_DependencyType>().AddRange(
            new LU_DependencyType { DependencyTypeId = 1, Code = "PREREQUISITE", Name = "Prerequisite", IsActive = true },
            new LU_DependencyType { DependencyTypeId = 2, Code = "TRIGGERS_FOR", Name = "Triggers For", IsActive = true },
            new LU_DependencyType { DependencyTypeId = 3, Code = "PARALLEL_WITH", Name = "Parallel With", IsActive = true }
        );

        // Requirement levels
        _context.Set<LU_RequirementLevel>().AddRange(
            new LU_RequirementLevel { RequirementLevelId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 3, Code = "OPTIONAL", Name = "Optional", IsActive = true }
        );

        // Roles
        _context.Set<LU_Role>().AddRange(
            new LU_Role { RoleId = 1, Code = "CLOUD_ARCHITECT", Name = "Cloud Architect", IsActive = true },
            new LU_Role { RoleId = 2, Code = "SOLUTION_ARCHITECT", Name = "Solution Architect", IsActive = true },
            new LU_Role { RoleId = 3, Code = "PROJECT_MANAGER", Name = "Project Manager", IsActive = true }
        );

        // Categories
        _context.Set<LU_ServiceCategory>().AddRange(
            new LU_ServiceCategory 
            { 
                CategoryId = 1, 
                Code = "SERVICES", 
                Name = "Services", 
                CategoryPath = "Services",
                IsActive = true 
            },
            new LU_ServiceCategory 
            { 
                CategoryId = 2, 
                Code = "ARCHITECTURE", 
                Name = "Architecture", 
                ParentCategoryId = 1,
                CategoryPath = "Services/Architecture",
                IsActive = true 
            },
            new LU_ServiceCategory 
            { 
                CategoryId = 3, 
                Code = "TECHNICAL_ARCH", 
                Name = "Technical Architecture", 
                ParentCategoryId = 2,
                CategoryPath = "Services/Architecture/Technical Architecture",
                IsActive = true 
            }
        );

        // Tool categories
        _context.Set<LU_ToolCategory>().AddRange(
            new LU_ToolCategory { ToolCategoryId = 1, Code = "CLOUD_PLATFORMS", Name = "Cloud Platforms", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 2, Code = "DESIGN_TOOLS", Name = "Design Tools", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 3, Code = "AUTOMATION", Name = "Automation Tools", IsActive = true }
        );

        // License types
        _context.Set<LU_LicenseType>().AddRange(
            new LU_LicenseType { LicenseTypeId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_LicenseType { LicenseTypeId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true },
            new LU_LicenseType { LicenseTypeId = 3, Code = "PROVIDED", Name = "Provided by Service Provider", IsActive = true }
        );

        // Interaction levels
        _context.Set<LU_InteractionLevel>().AddRange(
            new LU_InteractionLevel { InteractionLevelId = 1, Code = "LOW", Name = "Low", IsActive = true },
            new LU_InteractionLevel { InteractionLevelId = 2, Code = "MEDIUM", Name = "Medium", IsActive = true },
            new LU_InteractionLevel { InteractionLevelId = 3, Code = "HIGH", Name = "High", IsActive = true }
        );

        // Prerequisite categories
        _context.Set<LU_PrerequisiteCategory>().AddRange(
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 1, Code = "ORGANIZATIONAL", Name = "Organizational", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 2, Code = "TECHNICAL", Name = "Technical", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 3, Code = "DOCUMENTATION", Name = "Documentation", IsActive = true }
        );

        // Scope types
        _context.Set<LU_ScopeType>().AddRange(
            new LU_ScopeType { ScopeTypeId = 1, Code = "IN_SCOPE", Name = "In Scope", IsActive = true },
            new LU_ScopeType { ScopeTypeId = 2, Code = "OUT_OF_SCOPE", Name = "Out of Scope", IsActive = true }
        );

        // Cloud providers
        _context.Set<LU_CloudProvider>().AddRange(
            new LU_CloudProvider { CloudProviderId = 1, Code = "AZURE", Name = "Azure", IsActive = true },
            new LU_CloudProvider { CloudProviderId = 2, Code = "AWS", Name = "AWS", IsActive = true },
            new LU_CloudProvider { CloudProviderId = 3, Code = "GCP", Name = "GCP", IsActive = true }
        );

        _context.SaveChanges();
    }

    [Fact]
    public async Task ResolveSizeOptionIdAsync_ValidCode_ReturnsId()
    {
        // Act
        var result = await _service.ResolveSizeOptionIdAsync("M");

        // Assert
        Assert.NotNull(result);
        Assert.Equal(2, result.Value);
    }

    [Theory]
    [InlineData("s")]
    [InlineData("S")]
    [InlineData(" S ")]
    public async Task ResolveSizeOptionIdAsync_CaseInsensitive_ReturnsId(string sizeCode)
    {
        // Act
        var result = await _service.ResolveSizeOptionIdAsync(sizeCode);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(1, result.Value);
    }

    [Fact]
    public async Task ResolveSizeOptionIdAsync_InvalidCode_ReturnsNull()
    {
        // Act
        var result = await _service.ResolveSizeOptionIdAsync("XXXL");

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task ResolveSizeOptionIdAsync_NullCode_ReturnsNull()
    {
        // Act
        var result = await _service.ResolveSizeOptionIdAsync(null!);

        // Assert
        Assert.Null(result);
    }

    [Theory]
    [InlineData("PREREQUISITE", 1)]
    [InlineData("Prerequisite", 1)]
    [InlineData("TRIGGERS_FOR", 2)]
    [InlineData("Triggers for", 2)]
    [InlineData("TriggersFor", 2)]
    [InlineData("PARALLEL_WITH", 3)]
    [InlineData("Parallel With", 3)]
    [InlineData("ParallelWith", 3)]
    public async Task ResolveDependencyTypeIdAsync_Variations_ReturnsCorrectId(string typeCode, int expectedId)
    {
        // Act
        var result = await _service.ResolveDependencyTypeIdAsync(typeCode);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("REQUIRED", 1)]
    [InlineData("RECOMMENDED", 2)]
    [InlineData("OPTIONAL", 3)]
    public async Task ResolveRequirementLevelIdAsync_ValidLevel_ReturnsId(string levelCode, int expectedId)
    {
        // Act
        var result = await _service.ResolveRequirementLevelIdAsync(levelCode);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("CLOUD_ARCHITECT", 1)]
    [InlineData("Cloud Architect", 1)]
    [InlineData("SOLUTION_ARCHITECT", 2)]
    [InlineData("Solution Architect", 2)]
    public async Task ResolveRoleIdAsync_ByCodeOrName_ReturnsId(string roleCode, int expectedId)
    {
        // Act
        var result = await _service.ResolveRoleIdAsync(roleCode);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("Services/Architecture/Technical Architecture", 3)]
    [InlineData("Services/Architecture", 2)]
    [InlineData("Services", 1)]
    public async Task ResolveCategoryIdAsync_ByPath_ReturnsId(string categoryPath, int expectedId)
    {
        // Act
        var result = await _service.ResolveCategoryIdAsync(categoryPath);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Fact]
    public async Task ResolveCategoryIdAsync_CaseInsensitive_ReturnsId()
    {
        // Act
        var result = await _service.ResolveCategoryIdAsync("services/architecture");

        // Assert
        Assert.NotNull(result);
        Assert.Equal(2, result.Value);
    }

    [Theory]
    [InlineData("Cloud Platforms", 1)]
    [InlineData("Design Tools", 2)]
    [InlineData("Automation Tools", 3)]
    public async Task ResolveToolCategoryIdAsync_ByName_ReturnsId(string categoryName, int expectedId)
    {
        // Act
        var result = await _service.ResolveToolCategoryIdAsync(categoryName);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("LOW", 1)]
    [InlineData("MEDIUM", 2)]
    [InlineData("HIGH", 3)]
    public async Task ResolveInteractionLevelIdAsync_ValidLevel_ReturnsId(string levelCode, int expectedId)
    {
        // Act
        var result = await _service.ResolveInteractionLevelIdAsync(levelCode);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("ORGANIZATIONAL", 1)]
    [InlineData("Organizational", 1)]
    [InlineData("ORGANISATIONAL", 1)] // British spelling
    [InlineData("TECHNICAL", 2)]
    [InlineData("DOCUMENTATION", 3)]
    public async Task ResolvePrerequisiteCategoryIdAsync_Variations_ReturnsId(string categoryName, int expectedId)
    {
        // Act
        var result = await _service.ResolvePrerequisiteCategoryIdAsync(categoryName);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Theory]
    [InlineData("AZURE", 1)]
    [InlineData("Azure", 1)]
    [InlineData("AWS", 2)]
    [InlineData("GCP", 3)]
    public async Task ResolveCloudProviderIdAsync_ValidProvider_ReturnsId(string providerName, int expectedId)
    {
        // Act
        var result = await _service.ResolveCloudProviderIdAsync(providerName);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedId, result.Value);
    }

    [Fact]
    public async Task ResolveSizeOptionIdAsync_UsesCaching()
    {
        // First call - should hit database
        var result1 = await _service.ResolveSizeOptionIdAsync("L");

        // Second call - should use cache
        var result2 = await _service.ResolveSizeOptionIdAsync("L");

        // Assert
        Assert.Equal(result1, result2);
        Assert.Equal(3, result1.Value);
    }

    [Fact]
    public async Task ResolveRequirementLevelIdAsync_InvalidLevel_ReturnsNull()
    {
        // Act
        var result = await _service.ResolveRequirementLevelIdAsync("INVALID");

        // Assert
        Assert.Null(result);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
        _cache.Dispose();
    }
}
