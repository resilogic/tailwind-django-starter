# Integrate Aceternity UI Component into Section View

**Description**: Automatically integrate a standalone Aceternity UI component into an existing refactored section View component.

**Usage**: `/refactor-aceternity-component <ui-component-path> <target-section> [position]`

**Examples**:
```bash
# Integrate hero-highlight at the beginning of HeroView
/refactor-aceternity-component components/ui/hero-highlight.tsx hero beginning

# Integrate animated-tooltip into FeaturesView
/refactor-aceternity-component components/ui/animated-tooltip.tsx features

# Integrate focus-cards at end of OutcomesView
/refactor-aceternity-component components/ui/focus-cards.tsx outcomes end
```

---

## Instructions for Claude Agent

You are a specialized UI component integration agent. Your task is to integrate standalone Aceternity UI components into existing refactored section View components following the Container/Hook/View architecture.

### Context

This command is for **UI component integration** only, not full section refactoring. The target section should already be refactored following the Container/Hook/View pattern (see `/services/ace/README.md`).

**Difference from `/refactor-aceternity`:**
- `/refactor-aceternity`: Refactors entire sections (creates 13+ files)
- `/refactor-aceternity-component`: Integrates UI components (modifies 1-2 files)

### Required Arguments

1. **ui-component-path**: Path to the UI component file (e.g., `components/ui/hero-highlight.tsx`)
2. **target-section**: Section name (e.g., "hero", "features", "pricing")
3. **position** (optional): Where to place component - "beginning", "end", or "auto" (default: "auto")

### Step-by-Step Integration Process

#### Phase 1: Analysis & Validation

1. **Read UI component**
   - Component file: `services/ace/<ui-component-path>`
   - Identify component exports (named exports, default export)
   - Parse component props interface
   - Note required vs optional props
   - Identify dependencies (Motion, icons, other UI components)
   - Extract usage examples from component comments/JSDoc

2. **Read target section View**
   - View file: `services/ace/components/<target-section>/ui/<Section>View.tsx`
   - Verify file exists (if not, error: "Target section not found or not refactored yet")
   - Parse current imports
   - Identify component structure
   - Find integration points (beginning, end, or logical locations)

3. **Check for conflicts**
   - Check if component already imported
   - Check for naming conflicts
   - Verify TypeScript types compatibility

4. **Determine integration strategy**
   - Position: beginning, end, or auto (based on component type)
   - Props: Required props from section data, defaults for optional props
   - Wrapping: Does it need a container div? Grid? Section?

#### Phase 2: Generate Integration Plan

**Before making changes, present plan to user:**

```markdown
## Integration Plan: <ComponentName> → <Section>View

### Component Analysis
- **Component**: <ComponentName>
- **Export**: Named / Default
- **Required Props**: [list]
- **Optional Props**: [list]
- **Dependencies**: [list]

### Target View Analysis
- **View**: components/<section>/ui/<Section>View.tsx
- **Current Imports**: [count] imports
- **Integration Point**: <position> (line ~X)

### Changes Required

1. **Add Import**:
   ```typescript
   import { <ComponentName> } from '@/components/ui/<component-file>';
   ```

2. **Add Component Usage** (at <position>):
   ```typescript
   <<ComponentName>
     requiredProp={existingData.field}
     optionalProp="default value"
   />
   ```

3. **Props Mapping**:
   - `requiredProp`: Will use `<source>`
   - `optionalProp`: Will use default value

### TypeScript Changes
- [ ] Add new prop types to <Section>ViewProps (if needed)
- [ ] Update parent component to pass new data (if needed)

### Proceed with integration? (y/n)
```

Wait for user confirmation before proceeding.

#### Phase 3: Implementation

**ONLY after user confirms, proceed with changes.**

1. **Update imports in View component**

   Add import statement after existing imports:
   ```typescript
   import { <ComponentName> } from '@/components/ui/<component-file>';
   ```

   Maintain alphabetical order or group with other UI components.

2. **Integrate component into JSX**

   **Position: Beginning**
   ```typescript
   export function <Section>View(props: <Section>ViewProps) {
     return (
       <section id="<section>">
         {/* NEW: Aceternity UI Component */}
         <<ComponentName> {...requiredProps} />

         {/* Existing content */}
         <Container>
           ...
         </Container>
       </section>
     );
   }
   ```

   **Position: End**
   ```typescript
   export function <Section>View(props: <Section>ViewProps) {
     return (
       <section id="<section>">
         {/* Existing content */}
         <Container>
           ...
         </Container>

         {/* NEW: Aceternity UI Component */}
         <<ComponentName> {...requiredProps} />
       </section>
     );
   }
   ```

   **Position: Auto (Smart placement)**
   - Hero effects (spotlight, gradient) → Beginning (background layer)
   - Interactive components (tooltips, cards) → Middle (content layer)
   - Decorative effects (meteors, particles) → End (foreground layer)

3. **Handle props mapping**

   **Option A: Use existing View props**
   ```typescript
   <<ComponentName>
     title={title}           // From existing props
     description={description}
   />
   ```

   **Option B: Use defaults**
   ```typescript
   <<ComponentName>
     variant="default"
     className="mt-8"
   />
   ```

   **Option C: Hybrid**
   ```typescript
   <<ComponentName>
     title={title}           // From props
     variant="default"       // Default value
     className="mt-8"        // Styling
   />
   ```

4. **Update TypeScript types (if needed)**

   If component requires new data not in View props:

   **A. Update types file:**
   ```typescript
   // components/<section>/<section>.types.ts
   export interface <Section>Data {
     // Existing fields
     title: string;
     description: string;
     // NEW fields for component
     highlightWords?: string[];  // Optional to avoid breaking changes
   }
   ```

   **B. Update mapper:**
   ```typescript
   // components/<section>/<section>.mapper.ts
   export function mapTo<Section>Data(response: <Section>Response): <Section>Data {
     return {
       // Existing mappings
       title: response.<section>.title,
       // NEW mapping
       highlightWords: response.<section>.highlightWords || [],
     };
   }
   ```

   **C. Update GraphQL query:**
   ```typescript
   // lib/graphql/queries.ts
   export const <SECTION>_QUERY = `
     query <Section>Section {
       <section> {
         title
         description
         highlightWords  # NEW field
       }
     }
   `;
   ```

   **D. Update GraphQL types:**
   ```typescript
   // lib/graphql/types.ts
   export interface <Section>Response {
     <section>: {
       title: string;
       description: string;
       highlightWords?: string[];  // NEW field
     };
   }
   ```

#### Phase 4: Validation

1. **TypeScript compilation**
   ```bash
   cd services/ace
   pnpm build
   ```

   If errors:
   - Fix import paths
   - Fix prop types
   - Fix type mismatches

2. **Visual inspection**
   - Read updated View component
   - Verify import added
   - Verify component usage looks correct
   - Check indentation and formatting

3. **Check for side effects**
   - No duplicate imports
   - No unused imports
   - No breaking changes to existing code

#### Phase 5: Browser Verification

**CRITICAL**: Test the integration in browser.

1. **Check running servers**
   - ACE Frontend: http://localhost:3000
   - GraphQL Mock Server: http://localhost:8000/api/graphql/ (if needed)
   - Use BashOutput tool to check background processes

2. **Update GraphQL mock data (if new fields added)**
   ```json
   // services/graphql-mock/src/data/<section>.json
   {
     "<section>": {
       "title": "...",
       "highlightWords": ["word1", "word2"]  // NEW field
     }
   }
   ```

3. **Test in browser**
   - Navigate to http://localhost:3000
   - Scroll to the target section
   - Verify UI component renders correctly
   - Check component animations/interactions work
   - Test dark mode (if applicable)
   - Test responsive design (mobile, tablet, desktop)
   - Open browser console, check for errors

4. **Common issues and fixes**
   - **Component not visible**: Check z-index, positioning, or visibility styles
   - **Props error**: Check required props are passed
   - **Import error**: Check component export matches import
   - **Styling issues**: Check Tailwind classes, dark mode variants
   - **Animation issues**: Check Motion component setup

#### Phase 6: Report

Create a comprehensive integration report:

```markdown
## Integration Complete: <ComponentName> → <Section>View

### ✅ Changes Made

**Files Modified**:
1. `components/<section>/ui/<Section>View.tsx` - Added component integration
2. `components/<section>/<section>.types.ts` - [Updated / Not modified]
3. `components/<section>/<section>.mapper.ts` - [Updated / Not modified]
4. `lib/graphql/queries.ts` - [Updated / Not modified]
5. `lib/graphql/types.ts` - [Updated / Not modified]

### 📊 Integration Details

**Component Integrated**: `<ComponentName>`
**Target Section**: `<Section>View`
**Position**: <beginning/end/line X>
**Props Passed**:
- `prop1`: From `<source>`
- `prop2`: Default value

**Import Added**:
```typescript
import { <ComponentName> } from '@/components/ui/<component-file>';
```

**Usage Added**:
```typescript
<<ComponentName>
  prop1={value1}
  prop2="value2"
/>
```

### 🔍 Type Safety

- [ ] TypeScript compiles without errors
- [ ] New types added to <Section>Data interface
- [ ] GraphQL query updated
- [ ] Mapper function updated

### 🌐 Browser Verification

**Component Status in Browser:**
- [ ] Component renders at http://localhost:3000
- [ ] No console errors
- [ ] Animations/interactions work correctly
- [ ] Dark mode supported
- [ ] Responsive on mobile/tablet/desktop

### 📝 Manual Steps Required (if any)

[List any manual steps the user needs to complete]

### ⚠️ Notes

[Any special considerations or warnings]

### 🎯 Next Steps

1. ✅ Component integrated into View
2. ✅ TypeScript validated
3. ✅ Browser tested
4. 🔜 Update Storybook story (optional)
5. 🔜 Update View component tests (optional)
```

---

## Common Use Cases

### Use Case 1: Background Effects (No Props Needed)

**Component**: `spotlight.tsx`, `dotted-glow-background.tsx`, `meteors.tsx`

**Integration**:
```typescript
// Usually at beginning or end, no props required
<Spotlight className="absolute top-0 left-0" />
```

**Position**: Auto → Background layer (beginning)

### Use Case 2: Text Effects (Use Existing Content)

**Component**: `text-generate-effect.tsx`, `flip-words.tsx`, `typewriter-effect.tsx`

**Integration**:
```typescript
// Replace existing text with effect
<TextGenerateEffect words={title} />
```

**Props**: Use existing View props (title, description, etc.)
**Position**: Auto → Where text currently is

### Use Case 3: Interactive Components (New Props Needed)

**Component**: `animated-tooltip.tsx`, `focus-cards.tsx`, `card-stack.tsx`

**Integration**:
```typescript
<AnimatedTooltip items={tooltipItems} />
```

**Props**: Requires new data structure
**Type Updates**: Required
**Position**: Auto → Content area

### Use Case 4: Layout Components (Wrapper Changes)

**Component**: `background-gradient.tsx`, `lamp.tsx`, `moving-border.tsx`

**Integration**:
```typescript
// Wrap existing content
<BackgroundGradient>
  <div>{/* Existing content */}</div>
</BackgroundGradient>
```

**Props**: May need className for styling
**Position**: Wraps existing elements

---

## Error Handling

### Error: Target Section Not Found

**Cause**: Section doesn't exist or not refactored yet

**Solution**:
1. Check spelling of section name
2. Verify section is refactored (has `ui/` folder structure)
3. Run `/refactor-aceternity` first if not refactored

### Error: Component Import Not Found

**Cause**: UI component path incorrect

**Solution**:
1. Verify component file exists
2. Check spelling and path
3. Verify component is in `components/ui/` folder

### Error: TypeScript Compilation Failed

**Cause**: Props type mismatch

**Solution**:
1. Check component prop types
2. Update View props interface
3. Pass correct prop types

### Error: Component Not Rendering in Browser

**Cause**: Props missing, z-index issue, or visibility issue

**Solution**:
1. Check browser console for errors
2. Verify required props are passed
3. Check CSS positioning/visibility
4. Verify GraphQL data includes new fields (if needed)

---

## Special Considerations

### Aceternity UI Component Types

**1. Background Effects**
- Examples: Spotlight, DottedGlowBackground, Meteors
- Position: Background layer (beginning of section)
- Props: Usually just className
- No data required

**2. Text Effects**
- Examples: TextGenerateEffect, FlipWords, TypewriterEffect
- Position: Replace existing text elements
- Props: Use existing View props (title, description)
- No new data required

**3. Card Components**
- Examples: FocusCards, CardStack, BackgroundGradient
- Position: Content area
- Props: May require new data structure
- Type updates may be needed

**4. Interactive Components**
- Examples: AnimatedTooltip, HoverEffect, InfiniteMovingCards
- Position: Content area
- Props: Usually require arrays of items
- Type updates required

**5. Layout Wrappers**
- Examples: MovingBorder, Lamp, Container effects
- Position: Wrap existing content
- Props: Minimal (usually className)
- May require restructuring JSX

### Prop Inference Strategy

1. **Check component file** for prop interface
2. **Use existing View props** when possible (title, description, items)
3. **Use sensible defaults** for optional props (variant, className)
4. **Add new types** only when absolutely necessary
5. **Prefer optional props** to avoid breaking changes

### Animation Preservation

- Preserve existing Motion animations
- Don't conflict with existing animations
- Consider z-index layering
- Test animation performance

### Dark Mode

- Ensure component supports dark mode
- Use `dark:` prefix for Tailwind classes
- Test toggle in browser

---

## Quality Checklist

Before completing, verify:

**Code Integration:**
- [ ] Import statement added correctly
- [ ] Component usage added at correct position
- [ ] Props passed correctly (types match)
- [ ] No duplicate imports
- [ ] No unused imports
- [ ] Indentation and formatting consistent

**Type Safety:**
- [ ] TypeScript compiles without errors
- [ ] New types added to interface (if needed)
- [ ] GraphQL query updated (if needed)
- [ ] Mapper function updated (if needed)
- [ ] Props interface matches usage

**UI/UX:**
- [ ] Component renders correctly
- [ ] Animations work as expected
- [ ] Dark mode supported
- [ ] Responsive on all devices
- [ ] No styling conflicts with existing content

**Browser Verification:**
- [ ] Component visible at http://localhost:3000
- [ ] No console errors
- [ ] GraphQL data loads (if new fields added)
- [ ] Interactions work correctly
- [ ] Performance acceptable

**Documentation:**
- [ ] Changes clearly documented
- [ ] Manual steps listed (if any)
- [ ] Next steps provided

---

## Begin Integration

Now analyze the UI component and target section, generate an integration plan, and execute all phases autonomously after user confirmation. Report progress and final results.
