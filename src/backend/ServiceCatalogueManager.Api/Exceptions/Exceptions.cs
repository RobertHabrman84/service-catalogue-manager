namespace ServiceCatalogueManager.Api.Exceptions;

/// <summary>
/// Base exception for application errors
/// </summary>
public abstract class ApplicationException : Exception
{
    protected ApplicationException(string message) : base(message) { }
    protected ApplicationException(string message, Exception innerException) : base(message, innerException) { }
}

/// <summary>
/// Exception thrown when a requested resource is not found
/// </summary>
public class NotFoundException : ApplicationException
{
    public NotFoundException(string message) : base(message) { }
    public NotFoundException(string entityName, object key) 
        : base($"{entityName} with key '{key}' was not found.") { }
}

/// <summary>
/// Exception thrown when validation fails
/// </summary>
public class ValidationException : ApplicationException
{
    public Dictionary<string, string[]> Errors { get; }

    public ValidationException(string message) : base(message)
    {
        Errors = new Dictionary<string, string[]>();
    }

    public ValidationException(Dictionary<string, string[]> errors) 
        : base("One or more validation errors occurred.")
    {
        Errors = errors;
    }

    public ValidationException(string propertyName, string errorMessage)
        : base("Validation error occurred.")
    {
        Errors = new Dictionary<string, string[]>
        {
            { propertyName, new[] { errorMessage } }
        };
    }
}

/// <summary>
/// Exception thrown when user is not authenticated
/// </summary>
public class UnauthorizedException : ApplicationException
{
    public UnauthorizedException() : base("Authentication is required to access this resource.") { }
    public UnauthorizedException(string message) : base(message) { }
}

/// <summary>
/// Exception thrown when user is authenticated but not authorized
/// </summary>
public class ForbiddenException : ApplicationException
{
    public ForbiddenException() : base("You do not have permission to access this resource.") { }
    public ForbiddenException(string message) : base(message) { }
}

/// <summary>
/// Exception thrown when there is a conflict with the current state
/// </summary>
public class ConflictException : ApplicationException
{
    public ConflictException(string message) : base(message) { }
    public ConflictException(string entityName, string conflictReason)
        : base($"Conflict with {entityName}: {conflictReason}") { }
}

/// <summary>
/// Exception thrown when a duplicate resource is detected
/// </summary>
public class DuplicateException : ConflictException
{
    public DuplicateException(string entityName, string identifier)
        : base($"{entityName} with identifier '{identifier}' already exists.") { }
}

/// <summary>
/// Exception thrown when an external service fails
/// </summary>
public class ExternalServiceException : ApplicationException
{
    public string ServiceName { get; }
    public int? StatusCode { get; }

    public ExternalServiceException(string serviceName, string message)
        : base($"External service '{serviceName}' failed: {message}")
    {
        ServiceName = serviceName;
    }

    public ExternalServiceException(string serviceName, string message, int statusCode)
        : base($"External service '{serviceName}' returned status {statusCode}: {message}")
    {
        ServiceName = serviceName;
        StatusCode = statusCode;
    }

    public ExternalServiceException(string serviceName, string message, Exception innerException)
        : base($"External service '{serviceName}' failed: {message}", innerException)
    {
        ServiceName = serviceName;
    }
}

/// <summary>
/// Exception thrown when business rule is violated
/// </summary>
public class BusinessRuleException : ApplicationException
{
    public string RuleName { get; }

    public BusinessRuleException(string ruleName, string message)
        : base(message)
    {
        RuleName = ruleName;
    }
}

/// <summary>
/// Exception thrown when an operation times out
/// </summary>
public class TimeoutException : ApplicationException
{
    public TimeSpan Timeout { get; }

    public TimeoutException(string operation, TimeSpan timeout)
        : base($"Operation '{operation}' timed out after {timeout.TotalSeconds} seconds.")
    {
        Timeout = timeout;
    }
}
