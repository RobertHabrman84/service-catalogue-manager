// =============================================================================
// SERVICE CATALOGUE MANAGER - MOCK HTTP MESSAGE HANDLER
// =============================================================================

using System.Net;
using System.Text.Json;

namespace ServiceCatalogueManager.Api.Tests.Mocks;

public class MockHttpMessageHandler : HttpMessageHandler
{
    private readonly Dictionary<string, MockResponse> _responses = new();
    private readonly List<HttpRequestMessage> _requests = new();

    public IReadOnlyList<HttpRequestMessage> Requests => _requests.AsReadOnly();

    public void SetupResponse(string url, HttpStatusCode statusCode, object? content = null)
    {
        _responses[url] = new MockResponse
        {
            StatusCode = statusCode,
            Content = content != null ? JsonSerializer.Serialize(content) : null
        };
    }

    public void SetupResponse(string url, HttpStatusCode statusCode, string content)
    {
        _responses[url] = new MockResponse
        {
            StatusCode = statusCode,
            Content = content
        };
    }

    public void SetupResponsePattern(string urlPattern, HttpStatusCode statusCode, object? content = null)
    {
        _responses[$"pattern:{urlPattern}"] = new MockResponse
        {
            StatusCode = statusCode,
            Content = content != null ? JsonSerializer.Serialize(content) : null,
            IsPattern = true
        };
    }

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        _requests.Add(request);

        var url = request.RequestUri?.ToString() ?? string.Empty;

        // Check exact match
        if (_responses.TryGetValue(url, out var response))
        {
            return Task.FromResult(CreateResponse(response));
        }

        // Check pattern matches
        foreach (var kvp in _responses.Where(r => r.Value.IsPattern))
        {
            var pattern = kvp.Key.Replace("pattern:", "");
            if (url.Contains(pattern))
            {
                return Task.FromResult(CreateResponse(kvp.Value));
            }
        }

        // Default response
        return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent("{\"success\":true}")
        });
    }

    private static HttpResponseMessage CreateResponse(MockResponse mockResponse)
    {
        var response = new HttpResponseMessage(mockResponse.StatusCode);
        if (mockResponse.Content != null)
        {
            response.Content = new StringContent(mockResponse.Content, System.Text.Encoding.UTF8, "application/json");
        }
        return response;
    }

    public void Reset()
    {
        _responses.Clear();
        _requests.Clear();
    }

    public void VerifyRequest(string url, HttpMethod method, int times = 1)
    {
        var matchingRequests = _requests.Count(r =>
            r.RequestUri?.ToString().Contains(url) == true && r.Method == method);

        if (matchingRequests != times)
        {
            throw new InvalidOperationException(
                $"Expected {times} request(s) to {url} with method {method}, but found {matchingRequests}");
        }
    }

    public void VerifyNoRequests()
    {
        if (_requests.Count > 0)
        {
            throw new InvalidOperationException($"Expected no requests, but found {_requests.Count}");
        }
    }

    private class MockResponse
    {
        public HttpStatusCode StatusCode { get; set; }
        public string? Content { get; set; }
        public bool IsPattern { get; set; }
    }
}
