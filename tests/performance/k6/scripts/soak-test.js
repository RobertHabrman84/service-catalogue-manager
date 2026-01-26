// =============================================================================
// SERVICE CATALOGUE MANAGER - K6 SOAK TEST
// =============================================================================
// Extended duration test to identify memory leaks, resource exhaustion,
// and degradation over time.

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { randomItem, randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom metrics
const errorRate = new Rate('errors');
const requestDuration = new Trend('request_duration');
const memoryIndicator = new Trend('memory_indicator');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:7071/api';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || '';

// Soak test - constant moderate load over extended period
export const options = {
  stages: [
    { duration: '5m', target: 50 },    // Ramp up
    { duration: '60m', target: 50 },   // Hold for 1 hour
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000', 'p(99)<2000'],
    http_req_failed: ['rate<0.02'],
    errors: ['rate<0.05'],
  },
  tags: {
    testType: 'soak',
    environment: __ENV.ENVIRONMENT || 'dev',
  },
};

function getHeaders() {
  const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' };
  if (AUTH_TOKEN) headers['Authorization'] = `Bearer ${AUTH_TOKEN}`;
  return headers;
}

export function setup() {
  console.log(`Starting SOAK test against: ${BASE_URL}`);
  console.log('This test will run for approximately 70 minutes');
  
  const healthCheck = http.get(`${BASE_URL}/health`, { headers: getHeaders() });
  if (healthCheck.status !== 200) {
    throw new Error(`API health check failed: ${healthCheck.status}`);
  }
  
  const servicesRes = http.get(`${BASE_URL}/services`, { headers: getHeaders() });
  const services = JSON.parse(servicesRes.body || '[]');
  
  return {
    serviceIds: services.slice(0, 15).map(s => s.id),
    startTime: Date.now(),
    checkpoints: [],
  };
}

export default function(data) {
  const headers = getHeaders();
  const iteration = __ITER;
  
  // Periodic health/memory checks every 100 iterations
  if (iteration % 100 === 0) {
    checkSystemHealth(headers, data);
  }
  
  // Standard operations mix
  const operation = randomIntBetween(1, 100);
  
  if (operation <= 45) {
    testListServices(headers);
  } else if (operation <= 75) {
    testGetServiceById(headers, data);
  } else if (operation <= 90) {
    testGetLookups(headers);
  } else {
    testSearchServices(headers);
  }
  
  // Realistic think time
  sleep(randomIntBetween(2, 5));
}

function checkSystemHealth(headers, data) {
  group('Health Check', () => {
    const response = http.get(`${BASE_URL}/health`, { headers });
    
    const success = check(response, {
      'health check OK': (r) => r.status === 200,
    });
    
    // Track response time as memory/degradation indicator
    memoryIndicator.add(response.timings.duration);
    
    if (!success) {
      console.warn(`Health check failed at iteration ${__ITER}`);
    }
  });
}

function testListServices(headers) {
  group('Soak - List Services', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'list status 200': (r) => r.status === 200,
      'list response time OK': (r) => r.timings.duration < 1000,
    });
    
    errorRate.add(!success);
  });
}

function testGetServiceById(headers, data) {
  group('Soak - Get Service', () => {
    if (!data.serviceIds?.length) return;
    
    const serviceId = randomItem(data.serviceIds);
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services/${serviceId}`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'get status OK': (r) => r.status === 200 || r.status === 404,
      'get response time OK': (r) => r.timings.duration < 500,
    });
    
    errorRate.add(!success);
  });
}

function testGetLookups(headers) {
  group('Soak - Get Lookups', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/lookups`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'lookups status 200': (r) => r.status === 200,
    });
    
    errorRate.add(!success);
  });
}

function testSearchServices(headers) {
  group('Soak - Search', () => {
    const terms = ['service', 'api', 'data', 'test'];
    const term = randomItem(terms);
    
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services?search=${term}`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'search status 200': (r) => r.status === 200,
    });
    
    errorRate.add(!success);
  });
}

export function teardown(data) {
  const duration = (Date.now() - data.startTime) / 1000 / 60;
  console.log(`Soak test completed after ${duration.toFixed(1)} minutes`);
}

export function handleSummary(data) {
  const { metrics } = data;
  const durationMins = data.state.testRunDurationMs / 1000 / 60;
  
  const summary = `
================================================================================
SOAK TEST SUMMARY
================================================================================
Duration: ${durationMins.toFixed(1)} minutes
VUs: ${metrics.vus_max?.values?.max || 'N/A'}

Requests:
  Total: ${metrics.http_reqs?.values?.count || 0}
  Rate: ${metrics.http_reqs?.values?.rate?.toFixed(2) || 0}/s
  Failed: ${((metrics.http_req_failed?.values?.rate || 0) * 100).toFixed(2)}%

Response Times:
  Avg: ${metrics.http_req_duration?.values?.avg?.toFixed(2) || 0}ms
  p95: ${metrics.http_req_duration?.values['p(95)']?.toFixed(2) || 0}ms
  p99: ${metrics.http_req_duration?.values['p(99)']?.toFixed(2) || 0}ms

Stability Indicators:
  Error Rate: ${((metrics.errors?.values?.rate || 0) * 100).toFixed(2)}%
  Health Check Avg: ${metrics.memory_indicator?.values?.avg?.toFixed(2) || 'N/A'}ms

DEGRADATION CHECK:
  If p99 significantly > p95, possible memory leak
  If error rate increases over time, resource exhaustion likely
================================================================================
`;
  
  return {
    'stdout': summary,
    '../results/soak-test-summary.json': JSON.stringify(data, null, 2),
  };
}
