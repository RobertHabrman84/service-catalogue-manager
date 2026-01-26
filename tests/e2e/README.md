# E2E Tests - Service Catalogue Manager

End-to-end tests using [Playwright](https://playwright.dev/).

## Setup

```bash
npm install
npx playwright install
```

## Running Tests

```bash
# All tests
npm test

# Headed mode
npm run test:headed

# UI mode
npm run test:ui

# Debug mode
npm run test:debug

# Specific browser
npm run test:chromium
npm run test:firefox
npm run test:webkit
```

## Structure

```
e2e/
├── specs/          # Test specifications
├── pages/          # Page Object Models
├── fixtures/       # Test fixtures & data
├── utils/          # Helper functions
└── playwright.config.ts
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `http://localhost:5173` | Frontend URL |
| `API_URL` | `http://localhost:7071/api` | API URL |
| `TEST_USER` | - | Test user email |
| `TEST_PASSWORD` | - | Test user password |

## CI Integration

```yaml
- name: Run E2E tests
  run: npx playwright test --reporter=junit
```
