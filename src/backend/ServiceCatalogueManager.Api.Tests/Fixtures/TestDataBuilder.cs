// =============================================================================
// SERVICE CATALOGUE MANAGER - TEST DATA BUILDER
// =============================================================================

using Bogus;

namespace ServiceCatalogueManager.Api.Tests.Fixtures;

public static class TestDataBuilder
{
    private static readonly Faker _faker = new("en");

    public static ServiceCatalogItem CreateTestService(int? id = null)
    {
        return new ServiceCatalogItem
        {
            Id = id ?? 0,
            ServiceCode = $"{_faker.Random.AlphaNumeric(3).ToUpper()}-{_faker.Random.Number(100, 999)}",
            ServiceName = _faker.Commerce.ProductName(),
            ShortDescription = _faker.Lorem.Sentence(),
            LongDescription = _faker.Lorem.Paragraphs(2),
            Version = $"{_faker.Random.Number(1, 5)}.{_faker.Random.Number(0, 9)}.{_faker.Random.Number(0, 9)}",
            StatusId = _faker.Random.Number(1, 3),
            CategoryId = _faker.Random.Number(1, 2),
            ServiceOwner = _faker.Name.FullName(),
            ServiceOwnerEmail = _faker.Internet.Email(),
            TechnicalContact = _faker.Name.FullName(),
            TechnicalContactEmail = _faker.Internet.Email(),
            IsPublic = _faker.Random.Bool(),
            CreatedAt = _faker.Date.Past(1)
        };
    }

    public static List<ServiceCatalogItem> CreateTestServices(int count)
    {
        return Enumerable.Range(1, count)
            .Select(i => CreateTestService(i))
            .ToList();
    }

    public static UsageScenario CreateTestUsageScenario(int serviceId)
    {
        return new UsageScenario
        {
            ServiceId = serviceId,
            Title = _faker.Lorem.Sentence(3),
            Description = _faker.Lorem.Paragraph(),
            ActorRole = _faker.Name.JobTitle(),
            Steps = _faker.Lorem.Paragraphs(2),
            ExpectedOutcome = _faker.Lorem.Sentence(),
            DisplayOrder = _faker.Random.Number(1, 10)
        };
    }

    public static ServiceDependency CreateTestDependency(int serviceId, int? dependsOnId = null)
    {
        return new ServiceDependency
        {
            ServiceId = serviceId,
            DependsOnServiceId = dependsOnId,
            DependencyTypeId = _faker.Random.Number(1, 5),
            Description = _faker.Lorem.Sentence(),
            IsRequired = _faker.Random.Bool()
        };
    }

    public static CreateServiceRequest CreateTestCreateRequest()
    {
        return new CreateServiceRequest
        {
            ServiceCode = $"{_faker.Random.AlphaNumeric(3).ToUpper()}-{_faker.Random.Number(100, 999)}",
            ServiceName = _faker.Commerce.ProductName(),
            ShortDescription = _faker.Lorem.Sentence(),
            LongDescription = _faker.Lorem.Paragraphs(2),
            StatusId = 1,
            CategoryId = 1,
            ServiceOwnerEmail = _faker.Internet.Email()
        };
    }

    public static UpdateServiceRequest CreateTestUpdateRequest()
    {
        return new UpdateServiceRequest
        {
            ServiceName = _faker.Commerce.ProductName(),
            ShortDescription = _faker.Lorem.Sentence(),
            Version = $"{_faker.Random.Number(1, 5)}.{_faker.Random.Number(0, 9)}.{_faker.Random.Number(0, 9)}",
            StatusId = _faker.Random.Number(1, 3),
            CategoryId = _faker.Random.Number(1, 2)
        };
    }
}
