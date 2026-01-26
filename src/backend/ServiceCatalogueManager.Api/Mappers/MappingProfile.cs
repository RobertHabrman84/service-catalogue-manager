using AutoMapper;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.DTOs.Lookup;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;

namespace ServiceCatalogueManager.Api.Mappers;

/// <summary>
/// AutoMapper profile for entity to DTO mappings
/// </summary>
public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // ServiceCatalogItem mappings
        CreateMap<ServiceCatalogItem, ServiceCatalogListItemDto>()
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : string.Empty))
            .ForMember(dest => dest.UsageScenariosCount, opt => opt.MapFrom(src => src.UsageScenarios.Count))
            .ForMember(dest => dest.DependenciesCount, opt => opt.MapFrom(src => src.Dependencies.Count));

        CreateMap<ServiceCatalogItem, ServiceCatalogFullDto>()
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : string.Empty));

        CreateMap<ServiceCatalogCreateDto, ServiceCatalogItem>()
            .ForMember(dest => dest.ServiceId, opt => opt.Ignore())
            .ForMember(dest => dest.Category, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedDate, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedBy, opt => opt.Ignore())
            .ForMember(dest => dest.ModifiedDate, opt => opt.Ignore())
            .ForMember(dest => dest.ModifiedBy, opt => opt.Ignore());

        // UsageScenario mappings
        CreateMap<UsageScenario, UsageScenarioDto>().ReverseMap()
            .ForMember(dest => dest.ScenarioId, opt => opt.MapFrom(src => src.ScenarioId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore());

        // ServiceDependency mappings
        CreateMap<ServiceDependency, ServiceDependencyDto>()
            .ForMember(dest => dest.DependencyTypeName, opt => opt.MapFrom(src => src.DependencyType != null ? src.DependencyType.Name : null))
            .ForMember(dest => dest.RequirementLevelName, opt => opt.MapFrom(src => src.RequirementLevel != null ? src.RequirementLevel.Name : null));

        CreateMap<ServiceDependencyDto, ServiceDependency>()
            .ForMember(dest => dest.DependencyId, opt => opt.MapFrom(src => src.DependencyId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.DependencyType, opt => opt.Ignore())
            .ForMember(dest => dest.DependentService, opt => opt.Ignore())
            .ForMember(dest => dest.RequirementLevel, opt => opt.Ignore());

        // ServiceScopeCategory mappings
        CreateMap<ServiceScopeCategory, ServiceScopeCategoryDto>()
            .ForMember(dest => dest.ScopeTypeName, opt => opt.MapFrom(src => src.ScopeType != null ? src.ScopeType.Name : null));

        CreateMap<ServiceScopeCategoryDto, ServiceScopeCategory>()
            .ForMember(dest => dest.ScopeCategoryId, opt => opt.MapFrom(src => src.ScopeCategoryId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.ScopeType, opt => opt.Ignore());

        // ServiceScopeItem mappings
        CreateMap<ServiceScopeItem, ServiceScopeItemDto>().ReverseMap()
            .ForMember(dest => dest.ScopeItemId, opt => opt.MapFrom(src => src.ScopeItemId ?? 0))
            .ForMember(dest => dest.ScopeCategory, opt => opt.Ignore());

        // ServicePrerequisite mappings
        CreateMap<ServicePrerequisite, ServicePrerequisiteDto>()
            .ForMember(dest => dest.PrerequisiteCategoryName, opt => opt.MapFrom(src => src.PrerequisiteCategory != null ? src.PrerequisiteCategory.Name : null));

        CreateMap<ServicePrerequisiteDto, ServicePrerequisite>()
            .ForMember(dest => dest.PrerequisiteId, opt => opt.MapFrom(src => src.PrerequisiteId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.PrerequisiteCategory, opt => opt.Ignore());

        // ServiceInput mappings
        CreateMap<ServiceInput, ServiceInputDto>().ReverseMap()
            .ForMember(dest => dest.InputId, opt => opt.MapFrom(src => src.InputId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore());

        // ServiceInteraction mappings
        CreateMap<ServiceInteraction, ServiceInteractionDto>()
            .ForMember(dest => dest.InteractionLevelName, opt => opt.MapFrom(src => src.InteractionLevel != null ? src.InteractionLevel.Name : null));

        CreateMap<ServiceInteractionDto, ServiceInteraction>()
            .ForMember(dest => dest.InteractionId, opt => opt.MapFrom(src => src.InteractionId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.InteractionLevel, opt => opt.Ignore());

        // TimelinePhase mappings
        CreateMap<TimelinePhase, TimelinePhaseDto>().ReverseMap()
            .ForMember(dest => dest.PhaseId, opt => opt.MapFrom(src => src.PhaseId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore());

        // EffortEstimationItem mappings
        CreateMap<EffortEstimationItem, EffortEstimationItemDto>()
            .ForMember(dest => dest.EffortCategoryName, opt => opt.MapFrom(src => src.EffortCategory != null ? src.EffortCategory.Name : null))
            .ForMember(dest => dest.SizeOptionCode, opt => opt.MapFrom(src => src.SizeOption != null ? src.SizeOption.Code : null));

        CreateMap<EffortEstimationItemDto, EffortEstimationItem>()
            .ForMember(dest => dest.EstimationId, opt => opt.MapFrom(src => src.EstimationId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.EffortCategory, opt => opt.Ignore())
            .ForMember(dest => dest.SizeOption, opt => opt.Ignore());

        // ServiceResponsibleRole mappings
        CreateMap<ServiceResponsibleRole, ServiceResponsibleRoleDto>()
            .ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role != null ? src.Role.Name : null));

        CreateMap<ServiceResponsibleRoleDto, ServiceResponsibleRole>()
            .ForMember(dest => dest.ResponsibleRoleId, opt => opt.MapFrom(src => src.ResponsibleRoleId ?? 0))
            .ForMember(dest => dest.Service, opt => opt.Ignore())
            .ForMember(dest => dest.Role, opt => opt.Ignore());

        // Lookup mappings
        CreateMap<LU_ServiceCategory, ServiceCategoryDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.CategoryId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.ParentCategoryName, opt => opt.MapFrom(src => src.ParentCategory != null ? src.ParentCategory.Name : null));

        CreateMap<LU_SizeOption, SizeOptionDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.SizeOptionId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_CloudProvider, CloudProviderDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.CloudProviderId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_DependencyType, DependencyTypeDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.DependencyTypeId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_RequirementLevel, RequirementLevelDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.RequirementLevelId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_ScopeType, ScopeTypeDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ScopeTypeId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_InteractionLevel, InteractionLevelDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.InteractionLevelId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_PrerequisiteCategory, PrerequisiteCategoryDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PrerequisiteCategoryId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_ToolCategory, ToolCategoryDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ToolCategoryId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_LicenseType, LicenseTypeDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.LicenseTypeId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_Role, RoleDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.RoleId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));

        CreateMap<LU_EffortCategory, EffortCategoryDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.EffortCategoryId))
            .ForMember(dest => dest.Code, opt => opt.MapFrom(src => src.Code))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));
    }
}
