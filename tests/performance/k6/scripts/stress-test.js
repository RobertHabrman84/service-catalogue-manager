// =============================================================================
// SERVICE CATALOGUE MANAGER - K6 STRESS TEST
// =============================================================================
// Tests system behavior under extreme load to find breaking points and
// validate recovery capabilities.

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { randomItem, randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom metrics
const errorRate = new Rate('errors');
const requestDuration = new Trend('request_duration');
const successfulRequests = new Counter('successful_requests');
const failedRequests = new Counter('failed_requests');

// Configuration
const BASE_URL = __ENV.BASE_URL || 'http://localhost:7071/api';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || '';

// Stress test configuration - aggressive ramp up
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp to 100 VUs
    { duration: '3m', target: 200 },   // Ramp to 200 VUs
    { duration: '3m', target: 300 },   // Ramp to 300 VUs
    { duration: '3m', target: 400 },   // Ramp to 400 VUs
    { duration: '3m', target: 500 },   // Peak at 500 VUs
    { duration: '2m', target: 500 },   // Hold at 500 VUs
    { duration: '3m', target: 200 },   // Ramp down
    { duration: '2m', target: 0 },     // Ramp to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],  // More relaxed under stress
    http_req_failed: ['rate<0.10'],     // Allow up to 10% failures
    errors: ['rate<0.15'],
  },
  tags: {
    testType: 'stress',
    environment: __ENV.ENVIRONMENT || 'dev',
  },
};

function getHeaders() {
  const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' };
  if (AUTH_TOKEN) headers['Authorization'] = `Bearer ${AUTH_TOKEN}`;
  return headers;
}

export function setup() {
  console.log(`Starting STRESS test against: ${BASE_URL}`);
  console.log('WARNING: This test will push the system to its limits!');
  
  const healthCheck = http.get(`${BASE_URL}/health`, { headers: getHeaders() });
  if (healthCheck.status !== 200) {
    throw new Error(`API health check failed: ${healthCheck.status}`);
  }
  
  const servicesRes = http.get(`${BASE_URL}/services`, { headers: getHeaders() });
  const services = JSON.parse(servicesRes.body || '[]');
  
  return {
    serviceIds: services.slice(0, 20).map(s => s.id),
    startTime: Date.now(),
  };
}

export default function(data) {
  const headers = getHeaders();
  
  // Mix of operations with higher read ratio
  const operation = randomIntBetween(1, 100);
  
  if (operation <= 50) {
    testListServices(headers);
  } else if (operation <= 80) {
    testGetServiceById(headers, data);
  } else if (operation <= 90) {
    testGetLookups(headers);
  } else {
    testCreateService(headers);
  }
  
  // Minimal think time during stress
  sleep(randomIntBetween(0.5, 1.5));
}

function testListServices(headers) {
  group('Stress - List Services', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'list status OK': (r) => r.status === 200 || r.status === 503,
      'list not server error': (r) => r.status < 500 || r.status === 503,
    });
    
    errorRate.add(!success);
    success ? successfulRequests.add(1) : failedRequests.add(1);
  });
}

function testGetServiceById(headers, data) {
  group('Stress - Get Service', () => {
    if (!data.serviceIds?.length) return;
    
    const serviceId = randomItem(data.serviceIds);
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services/${serviceId}`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'get status OK': (r) => r.status === 200 || r.status === 404 || r.status === 503,
      'get not server error': (r) => r.status < 500 || r.status === 503,
    });
    
    errorRate.add(!success);
    success ? successfulRequests.add(1) : failedRequests.add(1);
  });
}

function testGetLookups(headers) {
  group('Stress - Get Lookups', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/lookups`, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'lookups status OK': (r) => r.status === 200 || r.status === 503,
    });
    
    errorRate.add(!success);
    success ? successfulRequests.add(1) : failedRequests.add(1);
  });
}

function testCreateService(headers) {
  group('Stress - Create Service', () => {
    const uniqueId = `${Date.now()}-${randomIntBetween(1000, 9999)}`;
    const payload = JSON.stringify({
      serviceCode: `STR-${uniqueId}`.substring(0, 15),
      serviceName: `Stress Test ${uniqueId}`,
      shortDescription: 'Created during stress testing',
      categoryId: randomIntBetween(1, 5),
      statusId: 1,
    });
    
    const start = Date.now();
    const response = http.post(`${BASE_URL}/services`, payload, { headers });
    requestDuration.add(Date.now() - start);
    
    const success = check(response, {
      'create status OK': (r) => [200, 201, 429, 503].includes(r.status),
    });
    
    errorRate.add(!success);
    success ? successfulRequests.add(1) : failedRequests.add(1);
  });
}

export function teardown(data) {
  const duration = (Date.now() - data.startTime) / 1000;
  console.log(`Stress test completed in ${duration}s`);
}

export function handleSummary(data) {
  const { metrics } = data;
  const summary = `
================================================================================
STRESS TEST SUMMARY
================================================================================
Peak VUs: ${metrics.vus_max?.values?.max || 'N/A'}
Duration: ${data.state.testRunDurationMs / 1000}s

Requests:
  Total: ${metrics.http_reqs?.values?.count || 0}
  Rate: ${metrics.http_reqs?.values?.rate?.toFixed(2) || 0}/s
  Failed: ${((metrics.http_req_failed?.values?.rate || 0) * 100).toFixed(2)}%

Response Times:
  Avg: ${metrics.http_req_duration?.values?.avg?.toFixed(2) || 0}ms
  p95: ${metrics.http_req_duration?.values['p(95)']?.toFixed(2) || 0}ms
  p99: ${metrics.http_req_duration?.values['p(99)']?.toFixed(2) || 0}ms
  Max: ${metrics.http_req_duration?.values?.max?.toFixed(2) || 0}ms

Breaking Point Analysis:
  Error Rate: ${((metrics.errors?.values?.rate || 0) * 100).toFixed(2)}%
  Successful: ${metrics.successful_requests?.values?.count || 0}
  Failed: ${metrics.failed_requests?.values?.count || 0}
================================================================================
`;
  
  return {
    'stdout': summary,
    '../results/stress-test-summary.json': JSON.stringify(data, null, 2),
  };
}
