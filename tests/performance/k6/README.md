# Performance Tests - Service Catalogue Manager

Performance testing suite using [k6](https://k6.io/) for load, stress, soak, and spike testing.

## Prerequisites

- [k6](https://k6.io/docs/getting-started/installation/) installed
- Node.js 18+ (optional, for report generation)
- Access to target API environment

## Installation

```bash
# Install k6 (macOS)
brew install k6

# Install k6 (Windows)
choco install k6

# Install k6 (Linux)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

## Test Types

| Test | Description | Duration | VUs |
|------|-------------|----------|-----|
| **Load** | Normal traffic simulation | 10 min | 50-100 |
| **Stress** | Find breaking point | 15 min | 100-500 |
| **Soak** | Extended duration test | 1 hour | 50 |
| **Spike** | Sudden traffic bursts | 5 min | 10-200 |

## Running Tests

### Basic Usage

```bash
# Load test
k6 run scripts/load-test.js

# Stress test
k6 run scripts/stress-test.js

# Soak test
k6 run scripts/soak-test.js

# Spike test
k6 run scripts/spike-test.js
```

### With Environment Variables

```bash
# Custom base URL
k6 run -e BASE_URL=https://api.staging.example.com scripts/load-test.js

# Custom VUs and duration
k6 run --vus 100 --duration 5m scripts/load-test.js

# With output to JSON
k6 run --out json=results/load-test-results.json scripts/load-test.js
```

### Cloud Execution (k6 Cloud)

```bash
# Login to k6 cloud
k6 login cloud --token <your-token>

# Run in cloud
k6 cloud scripts/load-test.js
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `http://localhost:7071/api` | API base URL |
| `AUTH_TOKEN` | - | Bearer token for auth |
| `VUS` | Varies by test | Virtual users |
| `DURATION` | Varies by test | Test duration |

### Thresholds

Defined in `config/thresholds.json`:

- **http_req_duration**: p(95) < 500ms
- **http_req_failed**: < 1%
- **http_reqs**: > 100/s

## Results

Results are stored in `../results/` directory:

- `load-test-YYYY-MM-DD.json` - Raw results
- `summary-YYYY-MM-DD.html` - HTML report

### Viewing Results

```bash
# Generate HTML report
k6 run --out json=results/output.json scripts/load-test.js

# Use k6 reporter
npx k6-reporter results/output.json
```

## CI/CD Integration

### Azure DevOps

```yaml
- task: k6-load-test@0
  inputs:
    filename: 'tests/performance/k6/scripts/load-test.js'
    cloud: false
```

### GitHub Actions

```yaml
- name: Run k6 load test
  uses: grafana/k6-action@v0.3.1
  with:
    filename: tests/performance/k6/scripts/load-test.js
```

## Performance Baselines

| Endpoint | p50 | p95 | p99 |
|----------|-----|-----|-----|
| GET /services | 50ms | 150ms | 300ms |
| GET /services/{id} | 30ms | 100ms | 200ms |
| POST /services | 100ms | 300ms | 500ms |
| GET /lookups | 20ms | 50ms | 100ms |

## Troubleshooting

### Common Issues

1. **Connection refused**: Ensure API is running
2. **401 Unauthorized**: Check AUTH_TOKEN
3. **High error rate**: Check API logs for errors

### Debug Mode

```bash
k6 run --http-debug scripts/load-test.js
```
