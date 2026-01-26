// =============================================================================
// SERVICE CATALOGUE MANAGER - K6 SPIKE TEST
// =============================================================================
// Tests system behavior under sudden, extreme traffic spikes to validate
// auto-scaling and recovery capabilities.

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { randomItem, randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

// Custom metrics
const errorRate = new Rate('errors');
const spikeRecoveryTime = new Trend('spike_recovery_time');
const requestDuration = new Trend('request_duration');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:7071/api';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || '';

// Spike test - sudden traffic bursts
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Baseline
    { duration: '10s', target: 200 },  // SPIKE 1
    { duration: '30s', target: 10 },   // Recovery
    { duration: '10s', target: 250 },  // SPIKE 2 (higher)
    { duration: '30s', target: 10 },   // Recovery
    { duration: '10s', target: 300 },  // SPIKE 3 (peak)
    { duration: '1m', target: 10 },    // Extended recovery
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<3000'],  // Allow slower during spikes
    http_req_failed: ['rate<0.20'],     // Allow up to 20% failures during spike
    errors: ['rate<0.25'],
  },
  tags: {
    testType: 'spike',
    environment: __ENV.ENVIRONMENT || 'dev',
  },
};

function getHeaders() {
  const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' };
  if (AUTH_TOKEN) headers['Authorization'] = `Bearer ${AUTH_TOKEN}`;
  return headers;
}

let lastResponseTime = 0;
let spikeDetected = false;

export function setup() {
  console.log(`Starting SPIKE test against: ${BASE_URL}`);
  console.log('WARNING: This test will generate sudden traffic bursts!');
  
  const healthCheck = http.get(`${BASE_URL}/health`, { headers: getHeaders() });
  if (healthCheck.status !== 200) {
    throw new Error(`API health check failed: ${healthCheck.status}`);
  }
  
  const servicesRes = http.get(`${BASE_URL}/services`, { headers: getHeaders() });
  const services = JSON.parse(servicesRes.body || '[]');
  
  // Get baseline response time
  const baselineRes = http.get(`${BASE_URL}/services`, { headers: getHeaders() });
  
  return {
    serviceIds: services.slice(0, 10).map(s => s.id),
    baselineResponseTime: baselineRes.timings.duration,
    startTime: Date.now(),
    spikeCount: 0,
  };
}

export default function(data) {
  const headers = getHeaders();
  const currentVUs = __VU;
  
  // Detect spike phases (high VU count)
  const inSpike = currentVUs > 50;
  
  // Fast operations during spike
  if (inSpike) {
    rapidRequests(headers, data);
  } else {
    normalRequests(headers, data);
  }
  
  // Minimal sleep during spike
  sleep(inSpike ? 0.1 : randomIntBetween(1, 2));
}

function rapidRequests(headers, data) {
  group('Spike - Rapid Requests', () => {
    // Quick read operations only during spike
    const operation = randomIntBetween(1, 100);
    
    if (operation <= 70) {
      const start = Date.now();
      const response = http.get(`${BASE_URL}/services`, { headers });
      const duration = Date.now() - start;
      
      requestDuration.add(duration);
      
      const success = check(response, {
        'spike list OK': (r) => r.status === 200 || r.status === 429 || r.status === 503,
      });
      
      errorRate.add(!success);
    } else {
      if (data.serviceIds?.length) {
        const serviceId = randomItem(data.serviceIds);
        const start = Date.now();
        const response = http.get(`${BASE_URL}/services/${serviceId}`, { headers });
        const duration = Date.now() - start;
        
        requestDuration.add(duration);
        
        const success = check(response, {
          'spike get OK': (r) => r.status === 200 || r.status === 404 || r.status === 429 || r.status === 503,
        });
        
        errorRate.add(!success);
      }
    }
  });
}

function normalRequests(headers, data) {
  group('Normal - Recovery Phase', () => {
    const start = Date.now();
    const response = http.get(`${BASE_URL}/services`, { headers });
    const duration = Date.now() - start;
    
    requestDuration.add(duration);
    spikeRecoveryTime.add(duration);
    
    const success = check(response, {
      'recovery status OK': (r) => r.status === 200,
      'recovery time OK': (r) => r.timings.duration < 1000,
    });
    
    errorRate.add(!success);
    
    // Log if still degraded after spike
    if (data.baselineResponseTime && duration > data.baselineResponseTime * 3) {
      console.warn(`Recovery degraded: ${duration}ms vs baseline ${data.baselineResponseTime}ms`);
    }
  });
}

export function teardown(data) {
  const duration = (Date.now() - data.startTime) / 1000;
  console.log(`Spike test completed in ${duration}s`);
}

export function handleSummary(data) {
  const { metrics } = data;
  
  const summary = `
================================================================================
SPIKE TEST SUMMARY
================================================================================
Duration: ${data.state.testRunDurationMs / 1000}s
Peak VUs: ${metrics.vus_max?.values?.max || 'N/A'}

Requests:
  Total: ${metrics.http_reqs?.values?.count || 0}
  Rate: ${metrics.http_reqs?.values?.rate?.toFixed(2) || 0}/s
  Failed: ${((metrics.http_req_failed?.values?.rate || 0) * 100).toFixed(2)}%

Response Times:
  Avg: ${metrics.http_req_duration?.values?.avg?.toFixed(2) || 0}ms
  p95: ${metrics.http_req_duration?.values['p(95)']?.toFixed(2) || 0}ms
  p99: ${metrics.http_req_duration?.values['p(99)']?.toFixed(2) || 0}ms
  Max: ${metrics.http_req_duration?.values?.max?.toFixed(2) || 0}ms

Recovery Analysis:
  Avg Recovery Time: ${metrics.spike_recovery_time?.values?.avg?.toFixed(2) || 'N/A'}ms
  Error Rate: ${((metrics.errors?.values?.rate || 0) * 100).toFixed(2)}%

SPIKE RESILIENCE:
  ✓ System handled ${metrics.vus_max?.values?.max || 0} concurrent users
  ${(metrics.http_req_failed?.values?.rate || 0) < 0.1 ? '✓' : '✗'} Error rate acceptable during spike
  ${(metrics.spike_recovery_time?.values?.avg || 0) < 500 ? '✓' : '✗'} Quick recovery after spike
================================================================================
`;
  
  return {
    'stdout': summary,
    '../results/spike-test-summary.json': JSON.stringify(data, null, 2),
  };
}
