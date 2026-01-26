// =============================================================================
// SERVICE CATALOGUE MANAGER - K6 LOAD TEST
// =============================================================================
// Simulates normal expected traffic patterns to validate system performance
// under typical production conditions.

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { randomItem, randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom metrics
const errorRate = new Rate('errors');
const serviceListDuration = new Trend('service_list_duration');
const serviceDetailDuration = new Trend('service_detail_duration');
const lookupDuration = new Trend('lookup_duration');
const createServiceDuration = new Trend('create_service_duration');
const successfulRequests = new Counter('successful_requests');

// Configuration from environment or defaults
const BASE_URL = __ENV.BASE_URL || 'http://localhost:7071/api';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || '';

// Load test configuration
export const options = {
  stages: [
    { duration: '2m', target: 20 },   // Ramp up to 20 VUs
    { duration: '5m', target: 50 },   // Ramp up to 50 VUs
    { duration: '3m', target: 100 },  // Ramp up to 100 VUs
    { duration: '5m', target: 100 },  // Stay at 100 VUs
    { duration: '3m', target: 50 },   // Ramp down to 50 VUs
    { duration: '2m', target: 0 },    // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
    errors: ['rate<0.05'],
    service_list_duration: ['p(95)<300'],
    service_detail_duration: ['p(95)<200'],
    lookup_duration: ['p(95)<100'],
  },
  tags: {
    testType: 'load',
    environment: __ENV.ENVIRONMENT || 'dev',
  },
};

// Request headers
function getHeaders() {
  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  if (AUTH_TOKEN) {
    headers['Authorization'] = `Bearer ${AUTH_TOKEN}`;
  }
  return headers;
}

// Test data
const serviceCategories = ['APP', 'INFRA', 'DATA', 'SECURITY', 'INTEGRATION'];
const searchTerms = ['service', 'api', 'data', 'cloud', 'integration'];

// Setup function - runs once before test
export function setup() {
  console.log(`Starting load test against: ${BASE_URL}`);
  
  // Verify API is accessible
  const healthCheck = http.get(`${BASE_URL}/health`, { headers: getHeaders() });
  if (healthCheck.status !== 200) {
    throw new Error(`API health check failed: ${healthCheck.status}`);
  }
  
  // Get existing services for testing
  const servicesRes = http.get(`${BASE_URL}/services`, { headers: getHeaders() });
  const services = JSON.parse(servicesRes.body || '[]');
  
  return {
    serviceIds: services.slice(0, 10).map(s => s.id),
    serviceCodes: services.slice(0, 10).map(s => s.serviceCode),
  };
}

// Main test function
export default function(data) {
  const headers = getHeaders();
  
  // Simulate realistic user behavior with weighted scenarios
  const scenario = randomIntBetween(1, 100);
  
  if (scenario <= 40) {
    // 40% - Browse service catalog
    browseServices(headers, data);
  } else if (scenario <= 70) {
    // 30% - View service details
    viewServiceDetails(headers, data);
  } else if (scenario <= 85) {
    // 15% - Search services
    searchServices(headers);
  } else if (scenario <= 95) {
    // 10% - Load lookups
    loadLookups(headers);
  } else {
    // 5% - Create service (write operation)
    createService(headers);
  }
  
  // Think time between requests
  sleep(randomIntBetween(1, 3));
}

function browseServices(headers, data) {
  group('Browse Services', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services`, { headers });
    serviceListDuration.add(Date.now() - start);
    
    const success = check(response, {
      'services list status 200': (r) => r.status === 200,
      'services list has data': (r) => JSON.parse(r.body || '[]').length >= 0,
      'services list response time OK': (r) => r.timings.duration < 500,
    });
    
    errorRate.add(!success);
    if (success) successfulRequests.add(1);
  });
}

function viewServiceDetails(headers, data) {
  group('View Service Details', () => {
    if (!data.serviceIds || data.serviceIds.length === 0) {
      return;
    }
    
    const serviceId = randomItem(data.serviceIds);
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services/${serviceId}`, { headers });
    serviceDetailDuration.add(Date.now() - start);
    
    const success = check(response, {
      'service detail status 200': (r) => r.status === 200,
      'service detail has id': (r) => JSON.parse(r.body || '{}').id !== undefined,
      'service detail response time OK': (r) => r.timings.duration < 300,
    });
    
    errorRate.add(!success);
    if (success) successfulRequests.add(1);
  });
}

function searchServices(headers) {
  group('Search Services', () => {
    const searchTerm = randomItem(searchTerms);
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services?search=${searchTerm}`, { headers });
    serviceListDuration.add(Date.now() - start);
    
    const success = check(response, {
      'search status 200': (r) => r.status === 200,
      'search response time OK': (r) => r.timings.duration < 500,
    });
    
    errorRate.add(!success);
    if (success) successfulRequests.add(1);
  });
}

function loadLookups(headers) {
  group('Load Lookups', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/lookups`, { headers });
    lookupDuration.add(Date.now() - start);
    
    const success = check(response, {
      'lookups status 200': (r) => r.status === 200,
      'lookups has data': (r) => {
        const body = JSON.parse(r.body || '{}');
        return body.statuses || body.categories;
      },
      'lookups response time OK': (r) => r.timings.duration < 200,
    });
    
    errorRate.add(!success);
    if (success) successfulRequests.add(1);
  });
}

function createService(headers) {
  group('Create Service', () => {
    const uniqueId = `${Date.now()}-${randomIntBetween(1000, 9999)}`;
    const payload = JSON.stringify({
      serviceCode: `LOAD-${uniqueId}`.substring(0, 15),
      serviceName: `Load Test Service ${uniqueId}`,
      shortDescription: 'Service created during load testing',
      categoryId: randomIntBetween(1, 5),
      statusId: 1,
    });
    
    const start = Date.now();
    const response = http.post(`${BASE_URL}/services`, payload, { headers });
    createServiceDuration.add(Date.now() - start);
    
    const success = check(response, {
      'create status 201 or 200': (r) => r.status === 201 || r.status === 200,
      'create response time OK': (r) => r.timings.duration < 1000,
    });
    
    errorRate.add(!success);
    if (success) successfulRequests.add(1);
  });
}

// Teardown function - runs once after test
export function teardown(data) {
  console.log('Load test completed');
  console.log(`Tested with ${data.serviceIds?.length || 0} existing services`);
}

// Handle test summary
export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    '../results/load-test-summary.json': JSON.stringify(data, null, 2),
  };
}

function textSummary(data, options) {
  const { metrics } = data;
  return `
================================================================================
LOAD TEST SUMMARY
================================================================================
Duration: ${data.state.testRunDurationMs / 1000}s
VUs Max: ${data.metrics.vus_max?.values?.max || 'N/A'}

HTTP Requests:
  Total: ${metrics.http_reqs?.values?.count || 0}
  Rate: ${metrics.http_reqs?.values?.rate?.toFixed(2) || 0}/s
  Failed: ${((metrics.http_req_failed?.values?.rate || 0) * 100).toFixed(2)}%

Response Times:
  Avg: ${metrics.http_req_duration?.values?.avg?.toFixed(2) || 0}ms
  p95: ${metrics.http_req_duration?.values['p(95)']?.toFixed(2) || 0}ms
  p99: ${metrics.http_req_duration?.values['p(99)']?.toFixed(2) || 0}ms

Custom Metrics:
  Error Rate: ${((metrics.errors?.values?.rate || 0) * 100).toFixed(2)}%
  Successful Requests: ${metrics.successful_requests?.values?.count || 0}
================================================================================
`;
}
