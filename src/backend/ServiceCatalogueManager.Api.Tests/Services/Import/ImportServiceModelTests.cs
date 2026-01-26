using System.ComponentModel.DataAnnotations;
using Xunit;
using ServiceCatalogueManager.Api.Models.Import;

namespace ServiceCatalogueManager.Api.Tests.Services.Import;

public class ImportServiceModelTests : ImportTestBase
{
    [Fact]
    public void ValidModel_PassesValidation()
    {
        // Arrange
        var model = CreateMinimalValidModel();
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.True(isValid);
        Assert.Empty(results);
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public void ServiceCode_WhenNullOrEmpty_FailsValidation(string? serviceCode)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.ServiceCode = serviceCode!;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.ServiceCode)));
    }

    [Theory]
    [InlineData("ID123")]  // Valid
    [InlineData("ID001")]  // Valid
    [InlineData("ID999")]  // Valid
    public void ServiceCode_WithValidPattern_PassesValidation(string serviceCode)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.ServiceCode = serviceCode;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.True(isValid);
    }

    [Theory]
    [InlineData("INVALID")]
    [InlineData("ID12")]      // Too short
    [InlineData("ID1234")]    // Too long
    [InlineData("id001")]     // Lowercase
    [InlineData("ID00A")]     // Letter instead of number
    public void ServiceCode_WithInvalidPattern_FailsValidation(string serviceCode)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.ServiceCode = serviceCode;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.ServiceCode)));
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public void ServiceName_WhenNullOrEmpty_FailsValidation(string? serviceName)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.ServiceName = serviceName!;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.ServiceName)));
    }

    [Fact]
    public void ServiceName_WhenTooLong_FailsValidation()
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.ServiceName = new string('A', 201); // Exceeds max length of 200
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.ServiceName)));
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public void Category_WhenNullOrEmpty_FailsValidation(string? category)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.Category = category!;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.Category)));
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public void Description_WhenNullOrEmpty_FailsValidation(string? description)
    {
        // Arrange
        var model = CreateMinimalValidModel();
        model.Description = description!;
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.False(isValid);
        Assert.Contains(results, r => r.MemberNames.Contains(nameof(ImportServiceModel.Description)));
    }

    [Fact]
    public void Version_DefaultsToV1_0()
    {
        // Arrange & Act
        var model = new ImportServiceModel();

        // Assert
        Assert.Equal("v1.0", model.Version);
    }

    [Fact]
    public void CompleteModel_PassesValidation()
    {
        // Arrange
        var model = CreateCompleteModel();
        var context = new ValidationContext(model);
        var results = new List<ValidationResult>();

        // Act
        var isValid = Validator.TryValidateObject(model, context, results, true);

        // Assert
        Assert.True(isValid);
        Assert.NotNull(model.UsageScenarios);
        Assert.NotNull(model.Dependencies);
        Assert.NotNull(model.SizeOptions);
    }
}
