// =============================================================================
// SERVICE CATALOGUE MANAGER - CREATE SERVICE VALIDATOR TESTS
// =============================================================================

using FluentValidation.TestHelper;

namespace ServiceCatalogueManager.Api.Tests.Unit.Validators;

public class CreateServiceValidatorTests
{
    private readonly CreateServiceValidator _validator;
    private readonly IFixture _fixture;

    public CreateServiceValidatorTests()
    {
        _validator = new CreateServiceValidator();
        _fixture = new Fixture();
    }

    #region ServiceCode Validation

    [Fact]
    public void ServiceCode_WhenEmpty_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, string.Empty)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceCode);
    }

    [Fact]
    public void ServiceCode_WhenNull_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, (string?)null)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceCode);
    }

    [Theory]
    [InlineData("A")]
    [InlineData("AB")]
    public void ServiceCode_WhenTooShort_ShouldHaveValidationError(string code)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, code)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceCode)
            .WithErrorMessage("*at least 3*");
    }

    [Fact]
    public void ServiceCode_WhenTooLong_ShouldHaveValidationError()
    {
        // Arrange
        var longCode = new string('A', 51);
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, longCode)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceCode);
    }

    [Theory]
    [InlineData("TST-001")]
    [InlineData("SVC-ABC-123")]
    [InlineData("SERVICE_CODE")]
    public void ServiceCode_WhenValid_ShouldNotHaveValidationError(string code)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, code)
            .With(x => x.ServiceName, "Valid Name")
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ServiceCode);
    }

    [Theory]
    [InlineData("test code")]
    [InlineData("test@code")]
    [InlineData("test#code")]
    public void ServiceCode_WithInvalidCharacters_ShouldHaveValidationError(string code)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, code)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceCode);
    }

    #endregion

    #region ServiceName Validation

    [Fact]
    public void ServiceName_WhenEmpty_ShouldHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
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
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceName, longName)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceName);
    }

    [Theory]
    [InlineData("Valid Service Name")]
    [InlineData("Service 123")]
    [InlineData("My-Service_Name")]
    public void ServiceName_WhenValid_ShouldNotHaveValidationError(string name)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, "TST-001")
            .With(x => x.ServiceName, name)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ServiceName);
    }

    #endregion

    #region Description Validation

    [Fact]
    public void ShortDescription_WhenTooLong_ShouldHaveValidationError()
    {
        // Arrange
        var longDescription = new string('A', 501);
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ShortDescription, longDescription)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ShortDescription);
    }

    [Fact]
    public void ShortDescription_WhenOptionalAndEmpty_ShouldNotHaveValidationError()
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, "TST-001")
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.ShortDescription, string.Empty)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ShortDescription);
    }

    #endregion

    #region Email Validation

    [Theory]
    [InlineData("invalid-email")]
    [InlineData("@invalid.com")]
    [InlineData("invalid@")]
    public void ServiceOwnerEmail_WithInvalidFormat_ShouldHaveValidationError(string email)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceOwnerEmail, email)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.ServiceOwnerEmail);
    }

    [Theory]
    [InlineData("valid@email.com")]
    [InlineData("user.name@domain.org")]
    [InlineData("test+tag@example.co.uk")]
    public void ServiceOwnerEmail_WithValidFormat_ShouldNotHaveValidationError(string email)
    {
        // Arrange
        var request = _fixture.Build<CreateServiceRequest>()
            .With(x => x.ServiceCode, "TST-001")
            .With(x => x.ServiceName, "Valid Name")
            .With(x => x.ServiceOwnerEmail, email)
            .Create();

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveValidationErrorFor(x => x.ServiceOwnerEmail);
    }

    #endregion

    #region Complete Request Validation

    [Fact]
    public void ValidRequest_ShouldPassValidation()
    {
        // Arrange
        var request = new CreateServiceRequest
        {
            ServiceCode = "TST-001",
            ServiceName = "Valid Test Service",
            ShortDescription = "A valid description",
            ServiceOwnerEmail = "owner@example.com",
            CategoryId = 1,
            StatusId = 1
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldNotHaveAnyValidationErrors();
    }

    #endregion
}
