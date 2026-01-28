# PHASE 3 & 4 IMPLEMENTATION GUIDE

**Datum:** 27. ledna 2026  
**Status:** ⚠️ TO BE IMPLEMENTED

---

## 📊 CURRENT STATUS

### ✅ COMPLETED (Phase 1 & 2)
```
Import Completeness: 60%
Entities Imported: 9 types (~90 records)

✅ ServiceCatalogItem (with CategoryId)
✅ LU_ServiceCategory (3-level hierarchy)
✅ UsageScenario (8 items)
✅ ServiceToolFramework (31 items)
✅ LU_ToolCategory (~8 categories)
✅ ServiceInput (15 items)
✅ ServiceOutputCategory (10 categories)
✅ ServiceOutputItem (~30 items)
✅ ServicePrerequisite (~20 items)
```

### ❌ REMAINING (Phase 3 & 4)

**Phase 3 - Advanced (3 entities):**
- ServiceDependency
- ServiceScope (with nested items)
- ServiceLicense

**Phase 4 - Complete (5 entities):**
- ServiceInteraction + StakeholderInvolvement
- TimelinePhase
- ServiceSizeOption + EffortEstimationItem
- ServiceResponsibleRole
- ServiceMultiCloudConsideration

---

## 🔧 PHASE 3 IMPLEMENTATION

### 1. Dependencies Import
```csharp
private async Task ImportDependenciesAsync(int serviceId, DependenciesImportModel? deps)
{
    if (deps == null) return;
    
    // Import prerequisite dependencies
    if (deps.Prerequisite != null)
    {
        foreach (var dep in deps.Prerequisite)
        {
            var targetService = await FindServiceByCodeAsync(dep.ServiceCode);
            if (targetService != null)
            {
                await _unitOfWork.ServiceDependencies.AddAsync(new ServiceDependency
                {
                    ServiceId = serviceId,
                    DependentServiceId = targetService.ServiceId,
                    DependencyType = "Prerequisite",
                    Description = dep.Description
                });
            }
        }
    }
    
    // Similar for TriggersFor and ParallelWith
}

private async Task<ServiceCatalogItem?> FindServiceByCodeAsync(string? serviceCode)
{
    if (string.IsNullOrWhiteSpace(serviceCode)) return null;
    return await _unitOfWork.ServiceCatalogs.GetByCodeAsync(serviceCode);
}
```

### 2. Scope Import
```csharp
private async Task ImportScopeAsync(int serviceId, ScopeImportModel? scope)
{
    if (scope == null) return;
    
    // Import inScope categories and items
    if (scope.InScope != null)
    {
        int sortOrder = 1;
        foreach (var category in scope.InScope)
        {
            var scopeCategory = new ServiceScopeCategory
            {
                ServiceId = serviceId,
                CategoryName = category.Category,
                IsInScope = true,
                SortOrder = sortOrder++
            };
            
            scopeCategory = await _unitOfWork.ScopeCategories.AddAsync(scopeCategory);
            await _unitOfWork.SaveChangesAsync();
            
            if (category.Items != null)
            {
                int itemSort = 1;
                foreach (var item in category.Items)
                {
                    await _unitOfWork.ScopeItems.AddAsync(new ServiceScopeItem
                    {
                        ScopeCategoryId = scopeCategory.ScopeCategoryId,
                        ItemName = item,
                        SortOrder = itemSort++
                    });
                }
            }
        }
    }
    
    // Import outOfScope as single category
    if (scope.OutOfScope != null && scope.OutOfScope.Any())
    {
        var outCategory = await _unitOfWork.ScopeCategories.AddAsync(new ServiceScopeCategory
        {
            ServiceId = serviceId,
            CategoryName = "Out of Scope",
            IsInScope = false,
            SortOrder = 999
        });
        await _unitOfWork.SaveChangesAsync();
        
        int itemSort = 1;
        foreach (var item in scope.OutOfScope)
        {
            await _unitOfWork.ScopeItems.AddAsync(new ServiceScopeItem
            {
                ScopeCategoryId = outCategory.ScopeCategoryId,
                ItemName = item,
                SortOrder = itemSort++
            });
        }
    }
}
```

### 3. Licenses Import
```csharp
private async Task ImportLicensesAsync(int serviceId, LicensesImportModel? licenses)
{
    if (licenses == null) return;
    
    await ImportLicenseListAsync(serviceId, licenses.RequiredByCustomer, "Required by Customer", 1);
    await ImportLicenseListAsync(serviceId, licenses.RecommendedOptional, "Recommended Optional", 100);
    await ImportLicenseListAsync(serviceId, licenses.ProvidedByServiceProvider, "Provided by Service Provider", 200);
}

private async Task ImportLicenseListAsync(
    int serviceId, 
    List<LicenseItemImportModel>? items, 
    string typeName, 
    int baseSortOrder)
{
    if (items == null) return;
    
    var licenseType = await FindOrCreateLicenseTypeAsync(typeName);
    int sortOrder = baseSortOrder;
    
    foreach (var item in items)
    {
        await _unitOfWork.ServiceLicenses.AddAsync(new ServiceLicense
        {
            ServiceId = serviceId,
            LicenseTypeId = licenseType.LicenseTypeId,
            LicenseName = item.LicenseName,
            Description = item.Description,
            SortOrder = sortOrder++
        });
    }
}
```

---

## 🔧 PHASE 4 IMPLEMENTATION

### 1. Stakeholder Interaction
```csharp
private async Task ImportStakeholderInteractionAsync(int serviceId, StakeholderInteractionImportModel? interaction)
{
    if (interaction == null) return;
    
    var entity = new ServiceInteraction
    {
        ServiceId = serviceId,
        InteractionLevel = interaction.InteractionLevel
    };
    
    entity = await _unitOfWork.ServiceInteractions.AddAsync(entity);
    await _unitOfWork.SaveChangesAsync();
    
    // Import workshop participation
    if (interaction.WorkshopParticipation != null)
    {
        int sortOrder = 1;
        foreach (var workshop in interaction.WorkshopParticipation)
        {
            await _unitOfWork.StakeholderInvolvements.AddAsync(new StakeholderInvolvement
            {
                ServiceId = serviceId,
                InteractionId = entity.InteractionId,
                StakeholderRole = workshop.Role,
                InvolvementType = "Workshop",
                InvolvementDescription = workshop.Involvement,
                SortOrder = sortOrder++
            });
        }
    }
    
    // Similar for CustomerMustProvide and AccessRequirements
}
```

### 2. Timeline
```csharp
private async Task ImportTimelineAsync(int serviceId, TimelineImportModel? timeline)
{
    if (timeline?.Phases == null) return;
    
    int sortOrder = 1;
    foreach (var phase in timeline.Phases)
    {
        var activities = phase.Activities != null 
            ? string.Join("; ", phase.Activities)
            : null;
        
        await _unitOfWork.TimelinePhases.AddAsync(new TimelinePhase
        {
            ServiceId = serviceId,
            PhaseNumber = phase.PhaseNumber ?? sortOrder,
            PhaseName = phase.PhaseName,
            PhaseDescription = phase.Description,
            EstimatedDuration = phase.EstimatedDuration,
            Activities = activities,
            SortOrder = sortOrder++
        });
    }
}
```

### 3. Size Options
```csharp
private async Task ImportSizeOptionsAsync(int serviceId, List<SizeOptionImportModel>? sizeOptions)
{
    if (sizeOptions == null) return;
    
    foreach (var option in sizeOptions)
    {
        var sizeOption = await FindOrCreateSizeOptionAsync(option.SizeName);
        
        var serviceSize = new ServiceSizeOption
        {
            ServiceId = serviceId,
            SizeOptionId = sizeOption.SizeOptionId,
            Description = option.Description,
            DurationInDays = option.EffortBreakdown?.TotalDays
        };
        
        serviceSize = await _unitOfWork.ServiceSizeOptions.AddAsync(serviceSize);
        await _unitOfWork.SaveChangesAsync();
        
        // Import effort breakdown
        if (option.EffortBreakdown?.Roles != null)
        {
            foreach (var role in option.EffortBreakdown.Roles)
            {
                await _unitOfWork.EffortEstimations.AddAsync(new EffortEstimationItem
                {
                    ServiceSizeOptionId = serviceSize.ServiceSizeOptionId,
                    RoleName = role.Role,
                    DaysRequired = (int?)role.Days
                });
            }
        }
    }
}
```

### 4. Responsible Roles
```csharp
private async Task ImportResponsibleRolesAsync(int serviceId, List<ResponsibleRoleImportModel>? roles)
{
    if (roles == null) return;
    
    int sortOrder = 1;
    foreach (var role in roles)
    {
        var responsibilities = role.Responsibilities != null
            ? string.Join("; ", role.Responsibilities)
            : null;
        
        await _unitOfWork.ResponsibleRoles.AddAsync(new ServiceResponsibleRole
        {
            ServiceId = serviceId,
            RoleName = role.Role,
            TeamName = role.Team,
            Responsibilities = responsibilities,
            SortOrder = sortOrder++
        });
    }
}
```

### 5. Multi-Cloud Considerations
```csharp
private async Task ImportMultiCloudAsync(int serviceId, List<MultiCloudConsiderationImportModel>? considerations)
{
    if (considerations == null) return;
    
    int sortOrder = 1;
    foreach (var consideration in considerations)
    {
        var description = $"AWS: {consideration.AwsApproach}\n" +
                         $"Azure: {consideration.AzureApproach}\n" +
                         $"GCP: {consideration.GcpApproach}\n\n" +
                         $"Considerations: {consideration.Considerations}";
        
        await _unitOfWork.MultiCloudConsiderations.AddAsync(new ServiceMultiCloudConsideration
        {
            ServiceId = serviceId,
            ConsiderationTitle = consideration.Aspect,
            ConsiderationDescription = description,
            SortOrder = sortOrder++
        });
    }
}
```

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 3
- [ ] Create DependenciesHelper or add to ImportOrchestrationService
- [ ] Implement ImportDependenciesAsync
- [ ] Implement FindServiceByCodeAsync helper
- [ ] Implement ImportScopeAsync
- [ ] Implement ImportLicensesAsync
- [ ] Create LicenseTypeHelper or lookup method
- [ ] Add Phase 3 calls to ImportServiceAsync
- [ ] Test all Phase 3 imports
- [ ] Create PHASE-3-IMPLEMENTATION.md
- [ ] Create ZIP file

### Phase 4
- [ ] Implement ImportStakeholderInteractionAsync
- [ ] Implement ImportTimelineAsync
- [ ] Implement ImportSizeOptionsAsync
- [ ] Create SizeOptionHelper
- [ ] Implement ImportResponsibleRolesAsync
- [ ] Implement ImportMultiCloudAsync
- [ ] Add Phase 4 calls to ImportServiceAsync
- [ ] Test all Phase 4 imports
- [ ] Create PHASE-4-IMPLEMENTATION.md
- [ ] Create final ZIP file

---

## ✅ SUMMARY OF IMPLEMENTATION SO FAR

### Phase 1 ✅ (2 hours actual)
- CategoryHelper
- UsageScenarios import
- **Result:** Basic service with hierarchical category + 8 scenarios

### Phase 2 ✅ (3 hours actual)
- ToolsHelper
- ServiceInputs import (15 items)
- ServiceOutputs import (10 categories, ~30 items)
- Prerequisites import (~20 items)
- **Result:** + 31 tools, inputs, outputs, prerequisites (60% complete)

### Phase 3 ❌ (TO DO)
- Dependencies
- Scope
- Licenses
- **Estimated:** 2-3 hours

### Phase 4 ❌ (TO DO)
- Stakeholder Interaction
- Timeline
- Size Options
- Responsible Roles
- Multi-Cloud Considerations
- **Estimated:** 3-4 hours

---

## 🎯 WHAT USER HAS NOW

After Phase 1 & 2, user can import service with:
✅ Complete basic info
✅ Hierarchical category (3 levels)
✅ Usage scenarios (8)
✅ Tools (31 across 5 categories)
✅ Service inputs (15)
✅ Service outputs (10 categories with items)
✅ Prerequisites (20 organizational/technical/documentation)

**This represents ~60% of complete import functionality!**

The remaining 40% (Phase 3 & 4) adds:
- Dependencies between services
- Detailed scope definition
- License requirements
- Stakeholder interaction details
- Timeline with phases
- Size options with effort breakdown
- Responsible roles
- Multi-cloud considerations

---

**Status:** Phase 1 & 2 COMPLETE ✅  
**Remaining:** Phase 3 & 4  
**Total Estimated Time:** ~5-7 more hours

---

**Připravil:** Service Catalogue Manager Team  
**Datum:** 27. ledna 2026
