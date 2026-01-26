// =============================================================================
// SERVICE CATALOGUE MANAGER - UPDATE SERVICE VALIDATOR TESTS
// =============================================================================

using FluentValidation.TestHelper;

namespace ServiceCatalogueManager.Api.Tests.Unit.Validators;

public class UpdateServiceValidatorTests
{
    private readonly UpdateServiceValidator _validator;
    private readonly IFixture _fixture;

    public UpdateServiceValidatorTests()
    {
        _validator = new UpdateServiceValidator();
        _fixture = new Fixture();
    }

    #region ServiceName Validation

    [Fact]
    public void ServiceName_WhenEmpty_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, string.Empty)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceName);
    }

    [Fact]
    public void ServiceName_WhenTooLong_ShouldHaveValidationError()
    {
        // Arrange
        var longName = new string('A', 201);
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, longName)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceName);
    }

    [Fact]
    public void ServiceName_WhenValid_ShouldNotHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Service Name")
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ServiceName);
    }

    #endregion

    #region Version Validation

    [Theory]
    [InlineData("1.0.0")]
    [InlineData("2.1.0")]
    [InlineData("10.20.30")]
    public void Version_WhenValidSemver_ShouldNotHaveValidationError(string version)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.Version, version)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.Version);
    }

    [Theory]
    [InlineData("invalid")]
    [InlineData("1.0")]
    [InlineData("v1.0.0")]
    [InlineData("")]
    public void Version_WhenInvalidFormat_ShouldHaveValidationError(string version)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.Version, version)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.Version);
    }

    #endregion

    #region Status Validation

    [Fact]
    public void StatusId_WhenZero_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.StatusId, 0)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.StatusId);
    }

    [Fact]
    public void StatusId_WhenNegative_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.StatusId, -1)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.StatusId);
    }

    [Fact]
    public void StatusId_WhenValid_ShouldNotHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.StatusId, 1)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.StatusId);
    }

    #endregion

    #region Category Validation

    [Fact]
    public void CategoryId_WhenZero_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.CategoryId, 0)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.CategoryId);
    }

    [Fact]
    public void CategoryId_WhenValid_ShouldNotHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.CategoryId, 1)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.CategoryId);
    }

    #endregion

    #region Email Validation

    [Theory]
    [InlineData("invalid-email")]
    [InlineData("@invalid.com")]
    public void ServiceOwnerEmail_WithInvalidFormat_ShouldHaveValidationError(string email)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceOwnerEmail, email)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceOwnerEmail);
    }

    [Theory]
    [InlineData("valid@email.com")]
    [InlineData("")]
    [InlineData(null)]
    public void ServiceOwnerEmail_WhenValidOrEmpty_ShouldNotHaveValidationError(string? email)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.ServiceOwnerEmail, email)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ServiceOwnerEmail);
    }

    #endregion

    #region URL Validation

    [Theory]
    [InlineData("https://docs.example.com")]
    [InlineData("http://localhost:3000")]
    [InlineData("")]
    [InlineData(null)]
    public void DocumentationUrl_WhenValidOrEmpty_ShouldNotHaveValidationError(string? url)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.DocumentationUrl, url)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.DocumentationUrl);
    }

    [Theory]
    [InlineData("not-a-url")]
    [InlineData("ftp://invalid")]
    public void DocumentationUrl_WhenInvalid_ShouldHaveValidationError(string url)
    {
        // Arrange
        var request = _fixture.Build<UpdateServiceRequest>()
            .With(x => x.DocumentationUrl, url)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.DocumentationUrl);
    }

    #endregion

    #region Complete Request Validation

    [Fact]
    public void ValidRequest_ShouldPassValidation()
    {
        // Arrange
        var request = new UpdateServiceRequest
        {
            ServiceName = "Updated Service Name",
            ShortDescription = "Updated description",
            Version = "2.0.0",
            StatusId = 2,
            CategoryId = 1,
            ServiceOwnerEmail = "owner@example.com",
            DocumentationUrl = "https://docs.example.com"
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveAnyValidationErrors();
    }

    #endregion
}
