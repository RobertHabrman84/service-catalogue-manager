# Testing Guide

## Testing Strategy

| Level | Framework | Coverage Target |
|-------|-----------|-----------------|
| Unit | xUnit / Vitest | 80% |
| Integration | xUnit | Key paths |
| E2E | Playwright | Critical flows |
| Performance | k6 | Baselines |

## Backend Testing

### Unit Tests

```csharp
public class ServiceCatalogServiceTests
{
    private readonly Mock<IRepository> _mockRepo;
    private readonly ServiceCatalogService _service;

    public ServiceCatalogServiceTests()
    {
        _mockRepo = new Mock<IRepository>();
        _service = new ServiceCatalogService(_mockRepo.Object);
    }

    [Fact]
    public async Task GetByIdAsync_ValidId_ReturnsService()
    {
        // Arrange
        var expected = new ServiceCatalogItem { Id = 1 };
        _mockRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(expected);

        // Act
        var result = await _service.GetByIdAsync(1);

        // Assert
        result.Should().BeEquivalentTo(expected);
    }
}
```

### Running Backend Tests

```bash
cd src/backend/ServiceCatalogueManager.Api.Tests

# All tests
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"

# Specific category
dotnet test --filter "Category=Unit"
```

## Frontend Testing

### Component Tests

```tsx
import { render, screen } from '@testing-library/react';
import { ServiceCard } from './ServiceCard';

describe('ServiceCard', () => {
  it('renders service name', () => {
    const service = { id: 1, name: 'Test Service' };
    
    render(<ServiceCard service={service} />);
    
    expect(screen.getByText('Test Service')).toBeInTheDocument();
  });
});
```

### Running Frontend Tests

```bash
cd src/frontend

# All tests
npm test

# Watch mode
npm run test:watch

# With coverage
npm run test:coverage
```

## E2E Testing

### Writing E2E Tests

```typescript
import { test, expect } from '@playwright/test';

test('create new service', async ({ page }) => {
  await page.goto('/services/create');
  await page.fill('[data-testid="service-code"]', 'TST-001');
  await page.fill('[data-testid="service-name"]', 'Test');
  await page.click('[data-testid="save-button"]');
  
  await expect(page).toHaveURL(/services\/\d+/);
});
```

### Running E2E Tests

```bash
cd tests/e2e

# All browsers
npx playwright test

# Specific browser
npx playwright test --project=chromium

# UI mode
npx playwright test --ui
```

## Performance Testing

```bash
cd tests/performance/k6

# Load test
k6 run scripts/load-test.js

# With environment
k6 run -e BASE_URL=https://api.staging.example.com scripts/load-test.js
```

## Test Data

### Fixtures

Use `TestDataBuilder` for consistent test data:

```csharp
var service = TestDataBuilder.CreateTestService();
```

### Database

- Integration tests use in-memory SQLite
- E2E tests use dedicated test database
- Test data is reset between runs

## CI Integration

Tests run automatically on:
- Pull requests
- Merges to develop/main
- Nightly builds

## Coverage Reports

Coverage reports are generated in:
- Backend: `TestResults/coverage.cobertura.xml`
- Frontend: `coverage/lcov.info`

Reports are published to SonarCloud.
