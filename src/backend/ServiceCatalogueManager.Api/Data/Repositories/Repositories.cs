using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;

namespace ServiceCatalogueManager.Api.Data.Repositories;

#region Interfaces

/// <summary>
/// Generic repository interface
/// </summary>
public interface IRepository<TEntity> where TEntity : class
{
    Task<TEntity?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);
    Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default);
    void Update(TEntity entity);
    void Remove(TEntity entity);
    void RemoveRange(IEnumerable<TEntity> entities);
    Task<bool> ExistsAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);
    Task<int> CountAsync(Expression<Func<TEntity, bool>>? predicate = null, CancellationToken cancellationToken = default);
}

/// <summary>
/// Service catalog specific repository interface
/// </summary>
public interface IServiceCatalogRepository : IRepository<ServiceCatalogItem>
{
    Task<ServiceCatalogItem?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
    Task<ServiceCatalogItem?> GetByCodeAsync(string code, CancellationToken cancellationToken = default);
    Task<IEnumerable<ServiceCatalogItem>> GetPagedAsync(int page, int pageSize, string? searchTerm = null, int? categoryId = null, bool? isActive = null, CancellationToken cancellationToken = default);
    Task<int> GetTotalCountAsync(string? searchTerm = null, int? categoryId = null, bool? isActive = null, CancellationToken cancellationToken = default);
    Task<bool> IsCodeUniqueAsync(string code, int? excludeId = null, CancellationToken cancellationToken = default);
}

/// <summary>
/// Unit of Work interface
/// </summary>
public interface IUnitOfWork : IDisposable
{
    IServiceCatalogRepository ServiceCatalogs { get; }
    IRepository<UsageScenario> UsageScenarios { get; }
    IRepository<ServiceDependency> ServiceDependencies { get; }
    IRepository<ServiceScopeCategory> ScopeCategories { get; }
    IRepository<ServicePrerequisite> Prerequisites { get; }
    IRepository<ServiceInput> Inputs { get; }
    IRepository<ServiceInteraction> Interactions { get; }
    IRepository<TimelinePhase> TimelinePhases { get; }
    IRepository<EffortEstimationItem> EffortEstimations { get; }
    IRepository<ServiceResponsibleRole> ResponsibleRoles { get; }
    
    // NEW: Import functionality repositories
    IRepository<LU_ServiceCategory> ServiceCategories { get; }
    IRepository<ServiceToolFramework> ServiceTools { get; }
    IRepository<LU_ToolCategory> ToolCategories { get; }
    IRepository<ServiceOutputCategory> OutputCategories { get; }
    IRepository<ServiceOutputItem> OutputItems { get; }
    IRepository<ServiceScopeItem> ScopeItems { get; }
    IRepository<ServiceLicense> ServiceLicenses { get; }
    IRepository<LU_LicenseType> LicenseTypes { get; }
    IRepository<StakeholderInvolvement> StakeholderInvolvements { get; }
    IRepository<ServiceSizeOption> ServiceSizeOptions { get; }
    IRepository<LU_SizeOption> SizeOptions { get; }
    IRepository<ServiceMultiCloudConsideration> MultiCloudConsiderations { get; }
    IRepository<LU_RequirementLevel> RequirementLevels { get; }
    IRepository<LU_DependencyType> DependencyTypes { get; }
    IRepository<LU_ScopeType> ScopeTypes { get; }
    IRepository<LU_InteractionLevel> InteractionLevels { get; }
    IRepository<LU_PrerequisiteCategory> PrerequisiteCategories { get; }
    IRepository<CustomerRequirement> CustomerRequirements { get; }
    IRepository<AccessRequirement> AccessRequirements { get; }
    IRepository<PhaseDurationBySize> PhaseDurations { get; }
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitTransactionAsync(CancellationToken cancellationToken = default);
    Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
}

#endregion

#region Implementations

/// <summary>
/// Generic repository implementation
/// </summary>
public class Repository<TEntity> : IRepository<TEntity> where TEntity : class
{
    protected readonly ServiceCatalogDbContext _context;
    protected readonly DbSet<TEntity> _dbSet;

    public Repository(ServiceCatalogDbContext context)
    {
        _context = context;
        _dbSet = context.Set<TEntity>();
    }

    public virtual async Task<TEntity?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }

    public virtual async Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.ToListAsync(cancellationToken);
    }

    public virtual async Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(predicate).ToListAsync(cancellationToken);
    }

    public virtual async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        var entry = await _dbSet.AddAsync(entity, cancellationToken);
        return entry.Entity;
    }

    public virtual async Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddRangeAsync(entities, cancellationToken);
    }

    public virtual void Update(TEntity entity)
    {
        _dbSet.Update(entity);
    }

    public virtual void Remove(TEntity entity)
    {
        _dbSet.Remove(entity);
    }

    public virtual void RemoveRange(IEnumerable<TEntity> entities)
    {
        _dbSet.RemoveRange(entities);
    }

    public virtual async Task<bool> ExistsAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbSet.AnyAsync(predicate, cancellationToken);
    }

    public virtual async Task<int> CountAsync(Expression<Func<TEntity, bool>>? predicate = null, CancellationToken cancellationToken = default)
    {
        return predicate == null
            ? await _dbSet.CountAsync(cancellationToken)
            : await _dbSet.CountAsync(predicate, cancellationToken);
    }
}

/// <summary>
/// Service catalog repository implementation
/// </summary>
public class ServiceCatalogRepository : Repository<ServiceCatalogItem>, IServiceCatalogRepository
{
    public ServiceCatalogRepository(ServiceCatalogDbContext context) : base(context) { }

    public async Task<ServiceCatalogItem?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(s => s.Category)
            .Include(s => s.UsageScenarios.OrderBy(u => u.SortOrder))
            .Include(s => s.Dependencies.OrderBy(d => d.SortOrder))
                .ThenInclude(d => d.DependencyType)
            .Include(s => s.Dependencies)
                .ThenInclude(d => d.RequirementLevel)
            .Include(s => s.ScopeCategories.OrderBy(sc => sc.SortOrder))
                .ThenInclude(sc => sc.ScopeType)
            .Include(s => s.Prerequisites.OrderBy(p => p.SortOrder))
                .ThenInclude(p => p.PrerequisiteCategory)
            .Include(s => s.Inputs.OrderBy(i => i.SortOrder))
            .Include(s => s.Interaction)
                .ThenInclude(i => i!.InteractionLevel)
            .Include(s => s.TimelinePhases.OrderBy(t => t.SortOrder))
            .Include(s => s.EffortEstimations)
                .ThenInclude(e => e.EffortCategory)
            .Include(s => s.EffortEstimations)
                .ThenInclude(e => e.SizeOption)
            .Include(s => s.ResponsibleRoles.OrderBy(r => r.SortOrder))
                .ThenInclude(r => r.Role)
            .AsSplitQuery()
            .FirstOrDefaultAsync(s => s.ServiceId == id, cancellationToken);
    }

    public async Task<ServiceCatalogItem?> GetByCodeAsync(string code, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.ServiceCode == code, cancellationToken);
    }

    public async Task<IEnumerable<ServiceCatalogItem>> GetPagedAsync(
        int page, int pageSize, 
        string? searchTerm = null, 
        int? categoryId = null, 
        bool? isActive = null,
        CancellationToken cancellationToken = default)
    {
        var query = BuildFilterQuery(searchTerm, categoryId, isActive);

        return await query
            .Include(s => s.Category)
            .Include(s => s.UsageScenarios)
            .Include(s => s.Dependencies)
            .OrderByDescending(s => s.ModifiedDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetTotalCountAsync(
        string? searchTerm = null, 
        int? categoryId = null, 
        bool? isActive = null,
        CancellationToken cancellationToken = default)
    {
        var query = BuildFilterQuery(searchTerm, categoryId, isActive);
        return await query.CountAsync(cancellationToken);
    }

    public async Task<bool> IsCodeUniqueAsync(string code, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var query = _dbSet.Where(s => s.ServiceCode == code);
        if (excludeId.HasValue)
        {
            query = query.Where(s => s.ServiceId != excludeId.Value);
        }
        return !await query.AnyAsync(cancellationToken);
    }

    private IQueryable<ServiceCatalogItem> BuildFilterQuery(string? searchTerm, int? categoryId, bool? isActive)
    {
        var query = _dbSet.AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            var term = searchTerm.ToLower();
            query = query.Where(s =>
                s.ServiceCode.ToLower().Contains(term) ||
                s.ServiceName.ToLower().Contains(term) ||
                s.Description.ToLower().Contains(term));
        }

        if (categoryId.HasValue)
        {
            query = query.Where(s => s.CategoryId == categoryId.Value);
        }

        if (isActive.HasValue)
        {
            query = query.Where(s => s.IsActive == isActive.Value);
        }

        return query;
    }
}

/// <summary>
/// Unit of Work implementation
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly ServiceCatalogDbContext _context;
    private IServiceCatalogRepository? _serviceCatalogs;
    private IRepository<UsageScenario>? _usageScenarios;
    private IRepository<ServiceDependency>? _serviceDependencies;
    private IRepository<ServiceScopeCategory>? _scopeCategories;
    private IRepository<ServicePrerequisite>? _prerequisites;
    private IRepository<ServiceInput>? _inputs;
    private IRepository<ServiceInteraction>? _interactions;
    private IRepository<TimelinePhase>? _timelinePhases;
    private IRepository<EffortEstimationItem>? _effortEstimations;
    private IRepository<ServiceResponsibleRole>? _responsibleRoles;

    // NEW: Import functionality repository fields
    private IRepository<LU_ServiceCategory>? _serviceCategories;
    private IRepository<ServiceToolFramework>? _serviceTools;
    private IRepository<LU_ToolCategory>? _toolCategories;
    private IRepository<ServiceOutputCategory>? _outputCategories;
    private IRepository<ServiceOutputItem>? _outputItems;
    private IRepository<ServiceScopeItem>? _scopeItems;
    private IRepository<ServiceLicense>? _serviceLicenses;
    private IRepository<LU_LicenseType>? _licenseTypes;
    private IRepository<StakeholderInvolvement>? _stakeholderInvolvements;
    private IRepository<ServiceSizeOption>? _serviceSizeOptions;
    private IRepository<LU_SizeOption>? _sizeOptions;
    private IRepository<ServiceMultiCloudConsideration>? _multiCloudConsiderations;
    private IRepository<LU_RequirementLevel>? _requirementLevels;
    private IRepository<LU_DependencyType>? _dependencyTypes;
    private IRepository<LU_ScopeType>? _scopeTypes;
    private IRepository<LU_InteractionLevel>? _interactionLevels;
    private IRepository<LU_PrerequisiteCategory>? _prerequisiteCategories;
    private IRepository<CustomerRequirement>? _customerRequirements;
    private IRepository<AccessRequirement>? _accessRequirements;
    private IRepository<PhaseDurationBySize>? _phaseDurations;
    private Microsoft.EntityFrameworkCore.Storage.IDbContextTransaction? _transaction;

    public UnitOfWork(ServiceCatalogDbContext context)
    {
        _context = context;
    }

    public IServiceCatalogRepository ServiceCatalogs => 
        _serviceCatalogs ??= new ServiceCatalogRepository(_context);

    public IRepository<UsageScenario> UsageScenarios => 
        _usageScenarios ??= new Repository<UsageScenario>(_context);

    public IRepository<ServiceDependency> ServiceDependencies => 
        _serviceDependencies ??= new Repository<ServiceDependency>(_context);

    public IRepository<ServiceScopeCategory> ScopeCategories => 
        _scopeCategories ??= new Repository<ServiceScopeCategory>(_context);

    public IRepository<ServicePrerequisite> Prerequisites => 
        _prerequisites ??= new Repository<ServicePrerequisite>(_context);

    public IRepository<ServiceInput> Inputs => 
        _inputs ??= new Repository<ServiceInput>(_context);

    public IRepository<ServiceInteraction> Interactions => 
        _interactions ??= new Repository<ServiceInteraction>(_context);

    public IRepository<TimelinePhase> TimelinePhases => 
        _timelinePhases ??= new Repository<TimelinePhase>(_context);

    public IRepository<EffortEstimationItem> EffortEstimations => 
        _effortEstimations ??= new Repository<EffortEstimationItem>(_context);

    public IRepository<ServiceResponsibleRole> ResponsibleRoles => 
        _responsibleRoles ??= new Repository<ServiceResponsibleRole>(_context);

    // NEW: Import functionality repositories
    public IRepository<LU_ServiceCategory> ServiceCategories => 
        _serviceCategories ??= new Repository<LU_ServiceCategory>(_context);

    public IRepository<ServiceToolFramework> ServiceTools => 
        _serviceTools ??= new Repository<ServiceToolFramework>(_context);

    public IRepository<LU_ToolCategory> ToolCategories => 
        _toolCategories ??= new Repository<LU_ToolCategory>(_context);

    public IRepository<ServiceOutputCategory> OutputCategories => 
        _outputCategories ??= new Repository<ServiceOutputCategory>(_context);

    public IRepository<ServiceOutputItem> OutputItems => 
        _outputItems ??= new Repository<ServiceOutputItem>(_context);

    public IRepository<ServiceScopeItem> ScopeItems => 
        _scopeItems ??= new Repository<ServiceScopeItem>(_context);

    public IRepository<ServiceLicense> ServiceLicenses => 
        _serviceLicenses ??= new Repository<ServiceLicense>(_context);

    public IRepository<LU_LicenseType> LicenseTypes => 
        _licenseTypes ??= new Repository<LU_LicenseType>(_context);

    public IRepository<StakeholderInvolvement> StakeholderInvolvements => 
        _stakeholderInvolvements ??= new Repository<StakeholderInvolvement>(_context);

    public IRepository<ServiceSizeOption> ServiceSizeOptions => 
        _serviceSizeOptions ??= new Repository<ServiceSizeOption>(_context);

    public IRepository<LU_SizeOption> SizeOptions => 
        _sizeOptions ??= new Repository<LU_SizeOption>(_context);

    public IRepository<ServiceMultiCloudConsideration> MultiCloudConsiderations => 
        _multiCloudConsiderations ??= new Repository<ServiceMultiCloudConsideration>(_context);

    public IRepository<LU_RequirementLevel> RequirementLevels => 
        _requirementLevels ??= new Repository<LU_RequirementLevel>(_context);

    public IRepository<LU_DependencyType> DependencyTypes => 
        _dependencyTypes ??= new Repository<LU_DependencyType>(_context);

    public IRepository<LU_ScopeType> ScopeTypes => 
        _scopeTypes ??= new Repository<LU_ScopeType>(_context);

    public IRepository<LU_InteractionLevel> InteractionLevels => 
        _interactionLevels ??= new Repository<LU_InteractionLevel>(_context);

    public IRepository<LU_PrerequisiteCategory> PrerequisiteCategories => 
        _prerequisiteCategories ??= new Repository<LU_PrerequisiteCategory>(_context);

    public IRepository<CustomerRequirement> CustomerRequirements => 
        _customerRequirements ??= new Repository<CustomerRequirement>(_context);

    public IRepository<AccessRequirement> AccessRequirements => 
        _accessRequirements ??= new Repository<AccessRequirement>(_context);

    public IRepository<PhaseDurationBySize> PhaseDurations => 
        _phaseDurations ??= new Repository<PhaseDurationBySize>(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        // Skip transactions when using EF Core InMemory provider (transactions are not supported)
        // See https://go.microsoft.com/fwlink/?LinkId=800142
        var provider = _context.Database.ProviderName;
        if (!string.IsNullOrEmpty(provider) && provider.Contains("InMemory"))
        {
            // No-op for InMemory database
            return;
        }

        _transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
    }

    public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}

#endregion
