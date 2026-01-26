// =============================================================================
// SERVICE CATALOGUE MANAGER - GLOBAL USINGS FOR TESTS
// =============================================================================

global using Xunit;
global using Moq;
global using FluentAssertions;
global using AutoFixture;
global using AutoFixture.Xunit2;
global using AutoFixture.AutoMoq;

global using Microsoft.EntityFrameworkCore;
global using Microsoft.Extensions.Logging;
global using Microsoft.Extensions.Options;

global using ServiceCatalogueManager.Api.Data.DbContext;
global using ServiceCatalogueManager.Api.Data.Entities;
global using ServiceCatalogueManager.Api.Data.Repositories;
global using ServiceCatalogueManager.Api.Services.Interfaces;
global using ServiceCatalogueManager.Api.Services.Implementations;
global using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
global using ServiceCatalogueManager.Api.Models.DTOs.Lookup;
global using ServiceCatalogueManager.Api.Models.DTOs.Export;
global using ServiceCatalogueManager.Api.Models.Requests;
global using ServiceCatalogueManager.Api.Models.Responses;
global using ServiceCatalogueManager.Api.Validators;
global using ServiceCatalogueManager.Api.Mappers;
global using ServiceCatalogueManager.Api.Exceptions;
global using ServiceCatalogueManager.Api.Configuration;

global using ServiceCatalogueManager.Api.Tests.Fixtures;
global using ServiceCatalogueManager.Api.Tests.Mocks;
