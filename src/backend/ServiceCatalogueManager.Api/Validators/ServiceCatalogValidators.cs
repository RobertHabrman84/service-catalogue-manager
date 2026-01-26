using FluentValidation;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;

namespace ServiceCatalogueManager.Api.Validators;

/// <summary>
/// Validator for ServiceCatalogCreateDto
/// </summary>
public class ServiceCatalogCreateValidator : AbstractValidator<ServiceCatalogCreateDto>
{
    public ServiceCatalogCreateValidator()
    {
        RuleFor(x => x.ServiceCode)
            .NotEmpty().WithMessage("Service code is required")
            .MaximumLength(50).WithMessage("Service code must not exceed 50 characters")
            .Matches(@"^[A-Z0-9\-]+$").WithMessage("Service code must contain only uppercase letters, numbers, and hyphens");

        RuleFor(x => x.ServiceName)
            .NotEmpty().WithMessage("Service name is required")
            .MaximumLength(200).WithMessage("Service name must not exceed 200 characters");

        RuleFor(x => x.Version)
            .NotEmpty().WithMessage("Version is required")
            .MaximumLength(20).WithMessage("Version must not exceed 20 characters")
            .Matches(@"^v\d+\.\d+").WithMessage("Version must be in format 'vX.Y' (e.g., v1.0)");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Category is required");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required")
            .MaximumLength(4000).WithMessage("Description must not exceed 4000 characters");

        RuleFor(x => x.Notes)
            .MaximumLength(4000).WithMessage("Notes must not exceed 4000 characters")
            .When(x => !string.IsNullOrEmpty(x.Notes));

        // Usage scenarios validation
        RuleForEach(x => x.UsageScenarios).SetValidator(new UsageScenarioValidator());

        // Dependencies validation
        RuleForEach(x => x.Dependencies).SetValidator(new ServiceDependencyValidator());

        // Scope categories validation
        RuleForEach(x => x.ScopeCategories).SetValidator(new ServiceScopeCategoryValidator());
    }
}

/// <summary>
/// Validator for ServiceCatalogUpdateDto
/// </summary>
public class ServiceCatalogUpdateValidator : AbstractValidator<ServiceCatalogUpdateDto>
{
    public ServiceCatalogUpdateValidator()
    {
        Include(new ServiceCatalogCreateValidator());

        RuleFor(x => x.ServiceId)
            .GreaterThan(0).WithMessage("Service ID is required");
    }
}

/// <summary>
/// Validator for UsageScenarioDto
/// </summary>
public class UsageScenarioValidator : AbstractValidator<UsageScenarioDto>
{
    public UsageScenarioValidator()
    {
        RuleFor(x => x.ScenarioNumber)
            .GreaterThan(0).WithMessage("Scenario number must be greater than 0");

        RuleFor(x => x.ScenarioTitle)
            .NotEmpty().WithMessage("Scenario title is required")
            .MaximumLength(200).WithMessage("Scenario title must not exceed 200 characters");

        RuleFor(x => x.ScenarioDescription)
            .NotEmpty().WithMessage("Scenario description is required")
            .MaximumLength(2000).WithMessage("Scenario description must not exceed 2000 characters");
    }
}

/// <summary>
/// Validator for ServiceDependencyDto
/// </summary>
public class ServiceDependencyValidator : AbstractValidator<ServiceDependencyDto>
{
    public ServiceDependencyValidator()
    {
        RuleFor(x => x.DependencyTypeId)
            .GreaterThan(0).WithMessage("Dependency type is required");

        RuleFor(x => x)
            .Must(x => x.DependentServiceId.HasValue || !string.IsNullOrEmpty(x.DependentServiceName))
            .WithMessage("Either dependent service ID or name must be provided");

        RuleFor(x => x.DependentServiceName)
            .MaximumLength(200).WithMessage("Dependent service name must not exceed 200 characters")
            .When(x => !string.IsNullOrEmpty(x.DependentServiceName));

        RuleFor(x => x.Notes)
            .MaximumLength(1000).WithMessage("Notes must not exceed 1000 characters")
            .When(x => !string.IsNullOrEmpty(x.Notes));
    }
}

/// <summary>
/// Validator for ServiceScopeCategoryDto
/// </summary>
public class ServiceScopeCategoryValidator : AbstractValidator<ServiceScopeCategoryDto>
{
    public ServiceScopeCategoryValidator()
    {
        RuleFor(x => x.ScopeTypeId)
            .GreaterThan(0).WithMessage("Scope type is required");

        RuleFor(x => x.CategoryName)
            .NotEmpty().WithMessage("Category name is required")
            .MaximumLength(200).WithMessage("Category name must not exceed 200 characters");

        RuleFor(x => x.Items)
            .NotEmpty().WithMessage("At least one scope item is required");

        RuleForEach(x => x.Items).SetValidator(new ServiceScopeItemValidator());
    }
}

/// <summary>
/// Validator for ServiceScopeItemDto
/// </summary>
public class ServiceScopeItemValidator : AbstractValidator<ServiceScopeItemDto>
{
    public ServiceScopeItemValidator()
    {
        RuleFor(x => x.ItemDescription)
            .NotEmpty().WithMessage("Item description is required")
            .MaximumLength(500).WithMessage("Item description must not exceed 500 characters");
    }
}

/// <summary>
/// Validator for ServicePrerequisiteDto
/// </summary>
public class ServicePrerequisiteValidator : AbstractValidator<ServicePrerequisiteDto>
{
    public ServicePrerequisiteValidator()
    {
        RuleFor(x => x.PrerequisiteCategoryId)
            .GreaterThan(0).WithMessage("Prerequisite category is required");

        RuleFor(x => x.PrerequisiteDescription)
            .NotEmpty().WithMessage("Prerequisite description is required")
            .MaximumLength(500).WithMessage("Prerequisite description must not exceed 500 characters");
    }
}

/// <summary>
/// Validator for EffortEstimationItemDto
/// </summary>
public class EffortEstimationItemValidator : AbstractValidator<EffortEstimationItemDto>
{
    public EffortEstimationItemValidator()
    {
        RuleFor(x => x.EffortCategoryId)
            .GreaterThan(0).WithMessage("Effort category is required");

        RuleFor(x => x.SizeOptionId)
            .GreaterThan(0).WithMessage("Size option is required");

        RuleFor(x => x.EffortDays)
            .GreaterThanOrEqualTo(0).WithMessage("Effort days must be non-negative")
            .LessThanOrEqualTo(999).WithMessage("Effort days must not exceed 999");
    }
}

/// <summary>
/// Validator for TimelinePhaseDto
/// </summary>
public class TimelinePhaseValidator : AbstractValidator<TimelinePhaseDto>
{
    public TimelinePhaseValidator()
    {
        RuleFor(x => x.PhaseName)
            .NotEmpty().WithMessage("Phase name is required")
            .MaximumLength(100).WithMessage("Phase name must not exceed 100 characters");

        RuleFor(x => x.PhaseDescription)
            .MaximumLength(500).WithMessage("Phase description must not exceed 500 characters")
            .When(x => !string.IsNullOrEmpty(x.PhaseDescription));

        RuleForEach(x => x.Durations).SetValidator(new TimelinePhaseDurationValidator());
    }
}

/// <summary>
/// Validator for TimelinePhaseDurationDto
/// </summary>
public class TimelinePhaseDurationValidator : AbstractValidator<TimelinePhaseDurationDto>
{
    public TimelinePhaseDurationValidator()
    {
        RuleFor(x => x.SizeOptionId)
            .GreaterThan(0).WithMessage("Size option is required");

        RuleFor(x => x.DurationDays)
            .GreaterThanOrEqualTo(0).WithMessage("Duration days must be non-negative")
            .LessThanOrEqualTo(365).WithMessage("Duration days must not exceed 365");
    }
}
