using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Models.Requests;
using ServiceCatalogueManager.Api.Models.Responses;

namespace ServiceCatalogueManager.Api.Services.Interfaces;

/// <summary>
/// Service for managing service catalog items
/// </summary>
public interface IServiceCatalogService
{
    /// <summary>
    /// Get paginated list of services
    /// </summary>
    Task<PagedResponse<ServiceCatalogListItemDto>> GetServicesAsync(GetServicesRequest request, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get service by ID
    /// </summary>
    Task<ServiceCatalogItemDto?> GetServiceByIdAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get service by code
    /// </summary>
    Task<ServiceCatalogItemDto?> GetServiceByCodeAsync(string code, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get full service details including all related data
    /// </summary>
    Task<ServiceCatalogFullDto?> GetServiceFullAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Create new service
    /// </summary>
    Task<ServiceCatalogItemDto> CreateServiceAsync(ServiceCatalogCreateDto request, string? userId = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// Update existing service
    /// </summary>
    Task<ServiceCatalogItemDto?> UpdateServiceAsync(int id, ServiceCatalogUpdateDto request, string? userId = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// Delete service (soft delete)
    /// </summary>
    Task<bool> DeleteServiceAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Check if service code exists
    /// </summary>
    Task<bool> ServiceCodeExistsAsync(string code, int? excludeId = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// Search services by text
    /// </summary>
    Task<PagedResponse<ServiceCatalogListItemDto>> SearchServicesAsync(string searchTerm, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default);
}
