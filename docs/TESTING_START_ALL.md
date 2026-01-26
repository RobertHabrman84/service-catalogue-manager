# Start-All.ps1 Improvements - Testing Guide

## ✅ Automated Health Check Feature

### Overview
The improved `start-all.ps1` script now includes a robust backend health check before starting the frontend, preventing startup issues.

---

## 🧪 Test Scenarios

### Test 1: Normal Startup (Backend Healthy)
**Expected behavior:**
1. Database starts (if not skipped)
2. Backend starts in background
3. Health check polls `/api/health` every 1-5s
4. Health check succeeds within 15-30s
5. Frontend starts
6. All services running

**Test command:**
```powershell
.\scripts\dev\start-all.ps1
```

**Success criteria:**
- ✅ "Backend is HEALTHY!" message appears
- ✅ Frontend starts after backend is ready
- ✅ Both services accessible

---

### Test 2: Slow Backend (Takes 40s to start)
**Expected behavior:**
1. Health check retries for up to 60s (default timeout)
2. Backend eventually responds
3. Frontend starts after health check passes

**Test command:**
```powershell
.\scripts\dev\start-all.ps1 -HealthCheckTimeout 120
```

**Success criteria:**
- ✅ Health check waits patiently
- ✅ No premature timeout
- ✅ Success after backend ready

---

### Test 3: Backend Fails to Start
**Expected behavior:**
1. Health check times out after 60s
2. Warning message displayed
3. Diagnostic commands suggested
4. Prompt: "Press Enter to continue or Ctrl+C to abort"
5. If Enter pressed: Frontend starts anyway (may not work)

**Test command:**
```powershell
# Manually break backend first
# Then:
.\scripts\dev\start-all.ps1
```

**Success criteria:**
- ✅ Timeout after 60s
- ✅ Clear error message
- ✅ User can decide to continue or abort

---

### Test 4: Skip Health Check (Legacy Behavior)
**Expected behavior:**
1. Backend starts
2. Waits 5s (no health check)
3. Frontend starts immediately

**Test command:**
```powershell
.\scripts\dev\start-all.ps1 -SkipHealthCheck
```

**Success criteria:**
- ✅ No HTTP health check performed
- ✅ Warning: "Skipping health check (not recommended)"

---

### Test 5: Custom Timeout
**Expected behavior:**
1. Health check uses custom timeout (e.g., 120s)
2. Retries for up to 120s before timing out

**Test command:**
```powershell
.\scripts\dev\start-all.ps1 -HealthCheckTimeout 120
```

**Success criteria:**
- ✅ Timeout message shows: "Timeout: 120 seconds"
- ✅ Actually waits up to 120s

---

### Test 6: Database Skip + Health Check
**Expected behavior:**
1. Database container not started
2. Backend starts (may fail if DB required)
3. Health check still runs

**Test command:**
```powershell
.\scripts\dev\start-all.ps1 -SkipDatabase
```

**Success criteria:**
- ✅ No docker-compose call
- ✅ Health check still functional

---

## 📊 Performance Benchmarks

| Scenario | Expected Time | Actual Time | Status |
|----------|--------------|-------------|--------|
| Normal startup | 15-30s | TBD | ⏳ |
| Slow backend (40s) | 40-45s | TBD | ⏳ |
| Backend timeout | 60s | TBD | ⏳ |
| Skip health check | 5s | TBD | ⏳ |

---

## 🐛 Troubleshooting

### Issue: "Backend health check TIMEOUT"
**Diagnosis:**
```powershell
# Check backend logs
Get-Job | Receive-Job

# Manual health check
Invoke-WebRequest http://localhost:7071/api/health
```

**Common causes:**
1. Backend compilation error (check logs)
2. Database connection issue (check connection string)
3. Port conflict (another process on 7071)
4. Firewall blocking localhost

**Solutions:**
```powershell
# Increase timeout
.\start-all.ps1 -HealthCheckTimeout 120

# Check port availability
netstat -ano | findstr :7071

# View backend errors
Get-Job -Id <backend-job-id> | Receive-Job -Keep
```

---

### Issue: Frontend starts but can't connect to backend
**Diagnosis:**
This should no longer happen with health check enabled!

**If it still happens:**
```powershell
# Check if health check was skipped
# Look for: "Skipping health check (not recommended)"

# Verify backend is actually healthy
Invoke-WebRequest http://localhost:7071/api/health
```

---

## 🔍 Health Check Endpoint Requirements

The script expects the backend `/api/health` endpoint to:

1. **Respond with HTTP 200** when healthy
2. **Optional:** Return JSON with `status` field:
   ```json
   {
     "status": "Healthy",
     "timestamp": "2026-01-26T19:00:00Z"
   }
   ```

**Example Health Function (Backend):**
```csharp
[Function("Health")]
public HttpResponseData Health(
    [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] 
    HttpRequestData req)
{
    var response = req.CreateResponse(HttpStatusCode.OK);
    response.WriteAsJsonAsync(new 
    { 
        status = "Healthy",
        timestamp = DateTime.UtcNow
    });
    return response;
}
```

---

## ✅ Validation Checklist

Before pushing to main branch:

- [ ] Normal startup works (backend healthy)
- [ ] Health check retries properly (slow backend)
- [ ] Timeout works (backend never starts)
- [ ] Skip health check works (legacy mode)
- [ ] Custom timeout parameter works
- [ ] Error messages are clear
- [ ] Diagnostic commands are helpful
- [ ] Frontend doesn't start prematurely

---

## 📝 User Feedback

After local testing, please provide:

1. **Startup time:** How long from script start to "All Services Started!"?
2. **Health check duration:** How long did health check take?
3. **Any errors:** Copy/paste full error messages
4. **Suggestion:** Any improvements to messages or behavior?

---

## 🚀 Next Steps

After validation:
1. Update main README.md with new parameters
2. Add health check info to DEVELOPMENT.md
3. Consider CI/CD health checks in Azure DevOps

---

## 📚 Related Files

- **Script:** `/scripts/dev/start-all.ps1`
- **Backend health endpoint:** `/src/backend/ServiceCatalogueManager.Api/Functions/Health/HealthFunctions.cs`
- **Frontend env:** `/src/frontend/.env.development`

---

**Last Updated:** 2026-01-26  
**Version:** 2.0 (with health check)
