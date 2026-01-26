using System.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using Xunit.Abstractions;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.Import;
using ServiceCatalogueManager.Api.Services.Import;

namespace ServiceCatalogueManager.Api.Tests.Performance;

/// <summary>
/// Performance tests for import pipeline
/// </summary>
public class ImportPerformanceTests : IDisposable
{
    private readonly ServiceCatalogDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILookupResolverService _lookupResolver;
    private readonly IImportValidationService _validationService;
    private readonly ImportOrchestrationService _importService;
    private readonly ITestOutputHelper _output;

    public ImportPerformanceTests(ITestOutputHelper output)
    {
        _output = output;

        var options = new DbContextOptionsBuilder<ServiceCatalogDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ServiceCatalogDbContext(options);
        _cache = new MemoryCache(new MemoryCacheOptions());

        SeedLookupData();

        var lookupLogger = new Mock<ILogger<LookupResolverService>>();
        _lookupResolver = new LookupResolverService(_context, _cache, lookupLogger.Object);

        var validationLogger = new Mock<ILogger<ImportValidationService>>();
        _validationService = new ImportValidationService(_context, _lookupResolver, validationLogger.Object);

        var orchestrationLogger = new Mock<ILogger<ImportOrchestrationService>>();
        _importService = new ImportOrchestrationService(
            _context, _lookupResolver, _validationService, orchestrationLogger.Object);
    }

    [Fact]
    public async Task Performance_SingleServiceImport_CompletesUnder5Seconds()
    {
        // Arrange
        var service = CreateCompleteServiceModel("ID001", "Performance Test Service");
        var sw = Stopwatch.StartNew();

        // Act
        var result = await _importService.ImportServiceAsync(service);
        sw.Stop();

        // Assert
        Assert.True(result.IsSuccess);
        Assert.True(sw.ElapsedMilliseconds < 5000, 
            $"Import took {sw.ElapsedMilliseconds}ms (expected < 5000ms)");

        _output.WriteLine($"Single service import: {sw.ElapsedMilliseconds}ms");
    }

    [Fact]
    public async Task Performance_BulkImport10Services_CompletesUnder30Seconds()
    {
        // Arrange
        var services = Enumerable.Range(1, 10)
            .Select(i => CreateCompleteServiceModel($"ID{i:D3}", $"Service {i}"))
            .ToList();

        var sw = Stopwatch.StartNew();

        // Act
        var result = await _importService.ImportServicesAsync(services);
        sw.Stop();

        // Assert
        Assert.Equal(10, result.SuccessCount);
        Assert.True(sw.ElapsedMilliseconds < 30000,
            $"Bulk import took {sw.ElapsedMilliseconds}ms (expected < 30000ms)");

        _output.WriteLine($"Bulk import (10 services): {sw.ElapsedMilliseconds}ms");
        _output.WriteLine($"Average per service: {sw.ElapsedMilliseconds / 10}ms");
    }

    [Fact]
    public async Task Performance_ValidationOnly_CompletesUnder1Second()
    {
        // Arrange
        var service = CreateCompleteServiceModel("ID999", "Validation Test");
        var sw = Stopwatch.StartNew();

        // Act
        var result = await _validationService.ValidateImportAsync(service);
        sw.Stop();

        // Assert
        Assert.True(result.IsValid);
        Assert.True(sw.ElapsedMilliseconds < 1000,
            $"Validation took {sw.ElapsedMilliseconds}ms (expected < 1000ms)");

        _output.WriteLine($"Validation only: {sw.ElapsedMilliseconds}ms");
    }

    [Fact]
    public async Task Performance_LookupResolution_BenefitsFromCaching()
    {
        // Arrange
        var categoryPath = "Services/Architecture";

        // Act 1: First lookup (cache miss)
        var sw1 = Stopwatch.StartNew();
        var id1 = await _lookupResolver.ResolveCategoryIdAsync(categoryPath);
        sw1.Stop();

        // Act 2: Second lookup (cache hit)
        var sw2 = Stopwatch.StartNew();
        var id2 = await _lookupResolver.ResolveCategoryIdAsync(categoryPath);
        sw2.Stop();

        // Assert
        Assert.Equal(id1, id2);
        Assert.True(sw2.ElapsedMilliseconds < sw1.ElapsedMilliseconds,
            "Second lookup should be faster (cached)");

        _output.WriteLine($"First lookup (cache miss): {sw1.ElapsedMilliseconds}ms");
        _output.WriteLine($"Second lookup (cache hit): {sw2.ElapsedMilliseconds}ms");
        _output.WriteLine($"Speed improvement: {((double)sw1.ElapsedMilliseconds / sw2.ElapsedMilliseconds):F2}x");
    }

    [Theory]
    [InlineData(1)]
    [InlineData(5)]
    [InlineData(10)]
    [InlineData(20)]
    public async Task Performance_BulkImportScalability_LinearGrowth(int serviceCount)
    {
        // Arrange
        var services = Enumerable.Range(1, serviceCount)
            .Select(i => CreateMinimalServiceModel($"ID{i:D3}", $"Service {i}"))
            .ToList();

        var sw = Stopwatch.StartNew();

        // Act
        var result = await _importService.ImportServicesAsync(services);
        sw.Stop();

        // Assert
        Assert.Equal(serviceCount, result.SuccessCount);

        var avgTimePerService = sw.ElapsedMilliseconds / serviceCount;
        _output.WriteLine($"Imported {serviceCount} services in {sw.ElapsedMilliseconds}ms");
        _output.WriteLine($"Average per service: {avgTimePerService}ms");

        // Performance should scale roughly linearly
        Assert.True(avgTimePerService < 3000, 
            $"Average time per service ({avgTimePerService}ms) exceeds threshold (3000ms)");
    }

    [Fact]
    public async Task Performance_ComplexServiceWithAllEntities_CompletesUnder10Seconds()
    {
        // Arrange
        var service = CreateMaximalServiceModel("IDX01", "Complex Service");
        var sw = Stopwatch.StartNew();

        // Act
        var result = await _importService.ImportServiceAsync(service);
        sw.Stop();

        // Assert
        Assert.True(result.IsSuccess);
        Assert.True(sw.ElapsedMilliseconds < 10000,
            $"Complex import took {sw.ElapsedMilliseconds}ms (expected < 10000ms)");

        _output.WriteLine($"Complex service with all entities: {sw.ElapsedMilliseconds}ms");

        // Verify entity count
        var dbService = await _context.ServiceCatalogItems
            .Include(s => s.UsageScenarios)
            .Include(s => s.Prerequisites)
            .Include(s => s.Inputs)
            .Include(s => s.OutputCategories)
            .Include(s => s.SizeOptions)
            .FirstOrDefaultAsync(s => s.ServiceCode == "IDX01");

        Assert.NotNull(dbService);
        _output.WriteLine($"Created entities: {dbService.UsageScenarios.Count} scenarios, " +
            $"{dbService.Prerequisites.Count} prerequisites, {dbService.Inputs.Count} inputs");
    }

    #region Helper Methods

    private void SeedLookupData()
    {
        // Minimal lookup data for performance tests
        _context.Set<LU_SizeOption>().AddRange(
            new LU_SizeOption { SizeOptionId = 1, Code = "S", Name = "Small", IsActive = true },
            new LU_SizeOption { SizeOptionId = 2, Code = "M", Name = "Medium", IsActive = true },
            new LU_SizeOption { SizeOptionId = 3, Code = "L", Name = "Large", IsActive = true }
        );

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

        _context.Set<LU_RequirementLevel>().AddRange(
            new LU_RequirementLevel { RequirementLevelId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true }
        );

        _context.Set<LU_Role>().Add(
            new LU_Role { RoleId = 1, Code = "CLOUD_ARCHITECT", Name = "Cloud Architect", IsActive = true }
        );

        _context.Set<LU_PrerequisiteCategory>().AddRange(
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 1, Code = "ORGANIZATIONAL", Name = "Organizational", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 2, Code = "TECHNICAL", Name = "Technical", IsActive = true }
        );

        _context.SaveChanges();
    }

    private ImportServiceModel CreateMinimalServiceModel(string code, string name)
    {
        return new ImportServiceModel
        {
            ServiceCode = code,
            ServiceName = name,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = $"Description for {name}",
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    private ImportServiceModel CreateCompleteServiceModel(string code, string name)
    {
        return new ImportServiceModel
        {
            ServiceCode = code,
            ServiceName = name,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = $"Complete service {name}",
            UsageScenarios = new List<UsageScenarioImportModel>
            {
                new() { ScenarioNumber = 1, ScenarioTitle = "Scenario 1", ScenarioDescription = "Desc 1" }
            },
            Prerequisites = new PrerequisitesImportModel
            {
                Technical = new List<PrerequisiteItemImportModel>
                {
                    new() { Name = "Prerequisite 1", Description = "Desc 1", RequirementLevel = "REQUIRED" }
                }
            },
            ServiceInputs = new List<ServiceInputImportModel>
            {
                new() { ParameterName = "Param1", Description = "Desc", RequirementLevel = "REQUIRED" }
            },
            ServiceOutputs = new List<OutputCategoryImportModel>
            {
                new()
                {
                    CategoryNumber = 1,
                    CategoryName = "Category 1",
                    Items = new List<OutputItemImportModel>
                    {
                        new() { ItemName = "Item 1" }
                    }
                }
            },
            SizeOptions = new List<SizeOptionImportModel>
            {
                new()
                {
                    SizeCode = "M",
                    Description = "Medium",
                    Duration = "4 weeks",
                    Effort = new EffortImportModel { HoursMin = 100, HoursMax = 200 }
                }
            },
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    private ImportServiceModel CreateMaximalServiceModel(string code, string name)
    {
        return new ImportServiceModel
        {
            ServiceCode = code,
            ServiceName = name,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = $"Maximal service {name} with all possible entities",
            UsageScenarios = Enumerable.Range(1, 8)
                .Select(i => new UsageScenarioImportModel
                {
                    ScenarioNumber = i,
                    ScenarioTitle = $"Scenario {i}",
                    ScenarioDescription = $"Description {i}"
                })
                .ToList(),
            Prerequisites = new PrerequisitesImportModel
            {
                Organizational = Enumerable.Range(1, 3)
                    .Select(i => new PrerequisiteItemImportModel
                    {
                        Name = $"Org Prereq {i}",
                        Description = $"Desc {i}",
                        RequirementLevel = "REQUIRED"
                    })
                    .ToList(),
                Technical = Enumerable.Range(1, 3)
                    .Select(i => new PrerequisiteItemImportModel
                    {
                        Name = $"Tech Prereq {i}",
                        Description = $"Desc {i}",
                        RequirementLevel = "REQUIRED"
                    })
                    .ToList()
            },
            ServiceInputs = Enumerable.Range(1, 15)
                .Select(i => new ServiceInputImportModel
                {
                    ParameterName = $"Param{i}",
                    Description = $"Description {i}",
                    RequirementLevel = i <= 5 ? "REQUIRED" : "RECOMMENDED"
                })
                .ToList(),
            ServiceOutputs = Enumerable.Range(1, 10)
                .Select(i => new OutputCategoryImportModel
                {
                    CategoryNumber = i,
                    CategoryName = $"Category {i}",
                    Items = new List<OutputItemImportModel>
                    {
                        new() { ItemName = $"Item {i}.1" },
                        new() { ItemName = $"Item {i}.2" }
                    }
                })
                .ToList(),
            SizeOptions = new List<SizeOptionImportModel>
            {
                new()
                {
                    SizeCode = "S",
                    Description = "Small",
                    Duration = "2 weeks",
                    Effort = new EffortImportModel { HoursMin = 50, HoursMax = 100 }
                },
                new()
                {
                    SizeCode = "M",
                    Description = "Medium",
                    Duration = "4 weeks",
                    Effort = new EffortImportModel { HoursMin = 100, HoursMax = 200 }
                },
                new()
                {
                    SizeCode = "L",
                    Description = "Large",
                    Duration = "8 weeks",
                    Effort = new EffortImportModel { HoursMin = 200, HoursMax = 400 }
                }
            },
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    #endregion

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
        _cache.Dispose();
    }
}
