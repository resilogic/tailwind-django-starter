# Update PRP/PRD Post-Implementation

Update a PRP (Product Requirements & Plan) or PRD document after implementation is complete. The goal is to maintain the document as both a specification AND an implementation record for future reference.

## What to Update

### 1. Document Header
- ✅ Update version number (e.g., 1.2 → 1.3)
- ✅ Change status (e.g., "Ready for Development" → "Implemented & Tested")
- ✅ Add implementation date and test results
- ✅ Add "Implementation: Complete" badge with test count

### 2. Add Implementation Status Section
Create a new subsection under Overview with:
- Implementation completion date
- List of files created/modified
- Test results summary (X/X passing)
- Reference to detailed implementation docs
- Deployment readiness status

### 3. Update Code Examples
- ✅ Correct code snippets to match ACTUAL implementation
- ✅ Update middleware matchers, config settings
- ✅ Fix any discrepancies found during implementation
- ❌ DO NOT remove original code - just update to what was actually built

### 4. Update Testing Section
- ✅ Add actual test results with command output
- ✅ Document any additional dependencies added (e.g., pytest-django)
- ✅ Show successful test run output
- ✅ Note any configuration required (pytest.ini, etc.)

### 5. Update Rollout/Implementation Plan
- ✅ Change "ETA" or "Timeline" columns to "Status"
- ✅ Mark completed phases with ✅ checkmarks
- ✅ Add test counts where applicable
- ✅ Mark future phases with 🔮 or "Pending"
- ❌ DO NOT remove the plan - just update status

### 6. Update Deployment Steps
- ✅ Add "Implementation Complete" banner
- ✅ Remove steps that are already done (like "create app")
- ✅ Update to deployment-only steps
- ✅ Reference created migration files by name
- ✅ Simplify to what deployer needs to do NOW

### 7. Add Implementation Summary Section
At the end of document, add:
- Complete deliverables checklist
- Test results summary
- Deployment readiness confirmation
- Next steps for production deployment
- References to detailed docs

## What NOT to Change

### ❌ Keep Original Implementation Steps
- Architecture diagrams
- Model definitions
- Service function signatures
- API endpoint specifications
- Security requirements
- Privacy considerations

### ❌ Keep All Context
- Purpose and objectives
- Non-goals
- Architecture overview
- Detailed specifications
- Manual testing procedures
- Troubleshooting guides
- Future extensions

## Example Updates

### Before (Planning):
```markdown
**Status:** Ready for Development
**Last Updated:** 2025-10-27

## 7. Rollout Plan
| Phase | Description | ETA |
| 1 | Implement backend | Week 2 |
```

### After (Implemented):
```markdown
**Status:** ✅ Implemented & Tested
**Last Updated:** 2025-10-27
**Implementation:** Complete - 16/16 tests passing

### 1.2 Implementation Status
✅ Implemented: 2025-10-27
Files Created: cms/identity/...
Test Results: ✅ 16/16 passing

## 7. Rollout Plan
| Phase | Description | Status |
| 1 | Implement backend | ✅ Complete |
```

## Process

1. Read the entire PRP document first
2. Identify all sections that need status updates
3. Make targeted, concise updates
4. Verify code examples match implementation
5. Add implementation summary at end
6. Keep document useful for future reference

## Output

The updated PRP should serve as:
- ✅ Original specification (what was planned)
- ✅ Implementation record (what was built)
- ✅ Deployment guide (how to deploy)
- ✅ Reference documentation (for maintenance)
