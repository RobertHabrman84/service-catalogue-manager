// =============================================================================
// SERVICE CATALOGUE MANAGER - MAPPING PROFILE TESTS
// =============================================================================

using AutoMapper;

namespace ServiceCatalogueManager.Api.Tests.Unit.Mappers;

public class MappingProfileTests
{
    private readonly IMapper _mapper;
    private readonly IFixture _fixture;

    public MappingProfileTests()
    {
        var config = new MapperConfiguration(cfg => cfg.AddProfile<MappingProfile>());
        _mapper = config.CreateMapper();
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        _fixture.Behaviors.OfType<ThrowingRecursionBehavior>().ToList()
            .ForEach(b => _fixture.Behaviors.Remove(b));
        _fixture.Behaviors.Add(new OmitOnRecursionBehavior());
    }

    [Fact]
    public void Configuration_ShouldBeValid()
    {
        var config = new MapperConfiguration(cfg => cfg.AddProfile<MappingProfile>());
        config.AssertConfigurationIsValid();
    }

    [Fact]
    public void Map_ServiceCatalogItem_To_ServiceCatalogListDto_ShouldMapCorrectly()
    {
        var entity = _fixture.Create<ServiceCatalogItem>();
        var dto = _mapper.Map<ServiceCatalogListDto>(entity);

        dto.Should().NotBeNull();
        dto.Id.Should().Be(entity.Id);
        dto.ServiceCode.Should().Be(entity.ServiceCode);
        dto.ServiceName.Should().Be(entity.ServiceName);
    }

    [Fact]
    public void Map_ServiceCatalogItem_To_ServiceCatalogDetailDto_ShouldMapCorrectly()
    {
        var entity = _fixture.Create<ServiceCatalogItem>();
        var dto = _mapper.Map<ServiceCatalogDetailDto>(entity);

        dto.Should().NotBeNull();
        dto.Id.Should().Be(entity.Id);
        dto.ServiceCode.Should().Be(entity.ServiceCode);
        dto.Version.Should().Be(entity.Version);
    }

    [Fact]
    public void Map_CreateServiceRequest_To_ServiceCatalogItem_ShouldMapCorrectly()
    {
        var request = _fixture.Create<CreateServiceRequest>();
        var entity = _mapper.Map<ServiceCatalogItem>(request);

        entity.Should().NotBeNull();
        entity.ServiceCode.Should().Be(request.ServiceCode);
        entity.ServiceName.Should().Be(request.ServiceName);
    }

    [Fact]
    public void Map_ListOfServices_ShouldMapAllItems()
    {
        var entities = _fixture.CreateMany<ServiceCatalogItem>(5).ToList();
        var dtos = _mapper.Map<List<ServiceCatalogListDto>>(entities);

        dtos.Should().HaveCount(5);
    }

    [Fact]
    public void Map_NullEntity_ShouldReturnNull()
    {
        ServiceCatalogItem? entity = null;
        var dto = _mapper.Map<ServiceCatalogListDto>(entity);
        dto.Should().BeNull();
    }

    [Fact]
    public void Map_EntityWithNullProperties_ShouldHandleGracefully()
    {
        var entity = new ServiceCatalogItem
        {
            Id = 1,
            ServiceCode = "TST-001",
            ServiceName = "Test",
            ShortDescription = null
        };

        var dto = _mapper.Map<ServiceCatalogDetailDto>(entity);
        dto.Should().NotBeNull();
        dto.ShortDescription.Should().BeNull();
    }
}
