using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Models.Requests;
using ServiceCatalogueManager.Api.Models.Responses;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Implementation of IServiceCatalogService
/// </summary>
public class ServiceCatalogService : IServiceCatalogService
{
    private readonly ServiceCatalogDbContext _context;
    private readonly IMapper _mapper;
    private readonly ILogger<ServiceCatalogService> _logger;
    private readonly ICacheService _cacheService;

    public ServiceCatalogService(
        ServiceCatalogDbContext context,
        IMapper mapper,
        ILogger<ServiceCatalogService> logger,
        ICacheService cacheService)
    {
        _context = context;
        _mapper = mapper;
        _logger = logger;
        _cacheService = cacheService;
    }

    public async Task<PagedResponse<ServiceCatalogListItemDto>> GetServicesAsync(GetServicesRequest request, CancellationToken cancellationToken = default)
    {
        var query = _context.ServiceCatalogItems
            .Include(s => s.Category)
            .AsQueryable();

        // Apply filters
        if (request.IsActive.HasValue)
        {
            query = query.Where(s => s.IsActive == request.IsActive.Value);
        }

        if (request.CategoryId.HasValue)
        {
            query = query.Where(s => s.CategoryId == request.CategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var searchTerm = request.SearchTerm.ToLower();
            query = query.Where(s =>
                s.ServiceCode.ToLower().Contains(searchTerm) ||
                s.ServiceName.ToLower().Contains(searchTerm) ||
                s.Description.ToLower().Contains(searchTerm));
        }

        // Get total count
        var totalCount = await query.CountAsync(cancellationToken);

        // Apply sorting
        query = request.SortBy?.ToLower() switch
        {
            "name" => request.SortDescending ? query.OrderByDescending(s => s.ServiceName) : query.OrderBy(s => s.ServiceName),
            "code" => request.SortDescending ? query.OrderByDescending(s => s.ServiceCode) : query.OrderBy(s => s.ServiceCode),
            "modified" => request.SortDescending ? query.OrderByDescending(s => s.ModifiedDate) : query.OrderBy(s => s.ModifiedDate),
            "created" => request.SortDescending ? query.OrderByDescending(s => s.CreatedDate) : query.OrderBy(s => s.CreatedDate),
            _ => query.OrderByDescending(s => s.ModifiedDate)
        };

        // Apply pagination
        var items = await query
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        var dtos = _mapper.Map<List<ServiceCatalogListItemDto>>(items);

        return PagedResponse<ServiceCatalogListItemDto>.Create(
            dtos,
            request.Page,
            request.PageSize,
            totalCount
        );
    }

    public async Task<ServiceCatalogItemDto?> GetServiceByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var cacheKey = $"service_{id}";
        var cached = await _cacheService.GetAsync<ServiceCatalogItemDto>(cacheKey, cancellationToken);
        if (cached != null)
        {
            return cached;
        }

        var entity = await _context.ServiceCatalogItems
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.ServiceId == id, cancellationToken);

        if (entity == null)
        {
            return null;
        }

        var dto = _mapper.Map<ServiceCatalogItemDto>(entity);
        await _cacheService.SetAsync(cacheKey, dto, TimeSpan.FromMinutes(5), cancellationToken);

        return dto;
    }

    public async Task<ServiceCatalogItemDto?> GetServiceByCodeAsync(string code, CancellationToken cancellationToken = default)
    {
        var entity = await _context.ServiceCatalogItems
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.ServiceCode == code, cancellationToken);

        return entity == null ? null : _mapper.Map<ServiceCatalogItemDto>(entity);
    }

    public async Task<ServiceCatalogFullDto?> GetServiceFullAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await _context.ServiceCatalogItems
            .Include(s => s.Category)
            .Include(s => s.UsageScenarios.OrderBy(u => u.SortOrder))
            .Include(s => s.Dependencies.OrderBy(d => d.SortOrder))
                .ThenInclude(d => d.DependencyType)
            .Include(s => s.Dependencies)
                .ThenInclude(d => d.RequirementLevel)
            .Include(s => s.ScopeCategories.OrderBy(c => c.SortOrder))
                .ThenInclude(c => c.Items.OrderBy(i => i.SortOrder))
            .Include(s => s.ScopeCategories)
                .ThenInclude(c => c.ScopeType)
            .Include(s => s.Prerequisites.OrderBy(p => p.SortOrder))
                .ThenInclude(p => p.PrerequisiteCategory)
            .Include(s => s.CloudCapabilities.OrderBy(c => c.SortOrder))
                .ThenInclude(c => c.CloudProvider)
            .Include(s => s.Tools.OrderBy(t => t.SortOrder))
                .ThenInclude(t => t.ToolCategory)
            .Include(s => s.Licenses.OrderBy(l => l.SortOrder))
                .ThenInclude(l => l.LicenseType)
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.InteractionLevel)
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.CustomerRequirements.OrderBy(r => r.SortOrder))
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.AccessRequirements.OrderBy(r => r.SortOrder))
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.StakeholderInvolvements.OrderBy(s => s.SortOrder))
            .Include(s => s.Inputs.OrderBy(i => i.SortOrder))
                .ThenInclude(i => i.RequirementLevel)
            .Include(s => s.OutputCategories.OrderBy(o => o.SortOrder))
                .ThenInclude(o => o.Items.OrderBy(i => i.SortOrder))
            .Include(s => s.TimelinePhases.OrderBy(p => p.SortOrder))
            .Include(s => s.SizeOptions)
                .ThenInclude(o => o.SizeOption)
            .Include(s => s.ResponsibleRoles.OrderBy(r => r.SortOrder))
                .ThenInclude(r => r.Role)
            .Include(s => s.MultiCloudConsiderations.OrderBy(m => m.SortOrder))
            .AsSplitQuery()
            .FirstOrDefaultAsync(s => s.ServiceId == id, cancellationToken);

        return entity == null ? null : _mapper.Map<ServiceCatalogFullDto>(entity);
    }

    public async Task<ServiceCatalogItemDto> CreateServiceAsync(ServiceCatalogCreateDto request, string? userId = null, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Creating new service with code: {ServiceCode}", request.ServiceCode);

        var entity = _mapper.Map<ServiceCatalogItem>(request);
        entity.CreatedBy = userId;
        entity.ModifiedBy = userId;

        _context.ServiceCatalogItems.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Created service with ID: {ServiceId}", entity.ServiceId);

        return _mapper.Map<ServiceCatalogItemDto>(entity);
    }

    public async Task<ServiceCatalogItemDto?> UpdateServiceAsync(int id, ServiceCatalogUpdateDto request, string? userId = null, CancellationToken cancellationToken = default)
    {
        var entity = await _context.ServiceCatalogItems
            .Include(s => s.UsageScenarios)
            .Include(s => s.Dependencies)
            .Include(s => s.ScopeCategories)
                .ThenInclude(c => c.Items)
            .Include(s => s.Prerequisites)
            .Include(s => s.CloudCapabilities)
            .Include(s => s.Tools)
            .Include(s => s.Licenses)
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.CustomerRequirements)
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.AccessRequirements)
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.StakeholderInvolvements)
            .Include(s => s.Inputs)
            .Include(s => s.OutputCategories)
                .ThenInclude(o => o.Items)
            .Include(s => s.TimelinePhases)
            .Include(s => s.SizeOptions)
            .Include(s => s.ResponsibleRoles)
            .Include(s => s.MultiCloudConsiderations)
            .FirstOrDefaultAsync(s => s.ServiceId == id, cancellationToken);

        if (entity == null)
        {
            return null;
        }

        _mapper.Map(request, entity);
        entity.ModifiedBy = userId;

        await _context.SaveChangesAsync(cancellationToken);

        // Invalidate cache
        await _cacheService.RemoveAsync($"service_{id}", cancellationToken);

        _logger.LogInformation("Updated service with ID: {ServiceId}", id);

        return _mapper.Map<ServiceCatalogItemDto>(entity);
    }

    public async Task<bool> DeleteServiceAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await _context.ServiceCatalogItems.FindAsync(new object[] { id }, cancellationToken);

        if (entity == null)
        {
            return false;
        }

        // Soft delete
        entity.IsActive = false;
        await _context.SaveChangesAsync(cancellationToken);

        // Invalidate cache
        await _cacheService.RemoveAsync($"service_{id}", cancellationToken);

        _logger.LogInformation("Soft deleted service with ID: {ServiceId}", id);

        return true;
    }

    public async Task<bool> ServiceCodeExistsAsync(string code, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var query = _context.ServiceCatalogItems.Where(s => s.ServiceCode == code);

        if (excludeId.HasValue)
        {
            query = query.Where(s => s.ServiceId != excludeId.Value);
        }

        return await query.AnyAsync(cancellationToken);
    }

    public async Task<PagedResponse<ServiceCatalogListItemDto>> SearchServicesAsync(string searchTerm, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var request = new GetServicesRequest
        {
            SearchTerm = searchTerm,
            Page = page,
            PageSize = pageSize,
            IsActive = true
        };

        return await GetServicesAsync(request, cancellationToken);
    }
}
