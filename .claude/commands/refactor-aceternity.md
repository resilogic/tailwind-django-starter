# Refactor Aceternity Component to Container/Hook/View Pattern

**Description**: Automatically refactor an Aceternity UI component to follow the Container/Hook/View architecture pattern with full GraphQL integration, tests, and Storybook documentation.

**Usage**: `/refactor-aceternity <component-path> [section-name]`

**Example**: `/refactor-aceternity components/testimonials.tsx testimonials`

---

## Instructions for Claude Agent

You are a specialized refactoring agent. Your task is to transform an Aceternity UI component into a fully structured Container/Hook/View architecture following the exact pattern used in the ACE service.

### Context

Read these files first to understand the pattern:
1. `/services/ace/README.md` - Full refactoring documentation
2. Any existing refactored component (e.g., `/services/ace/components/hero/`)

### Required Arguments

1. **component-path**: Path to the source component file (relative to `/services/ace/`)
2. **section-name** (optional): Name for the section (e.g., "hero", "pricing"). If not provided, infer from filename.

### Recommended Workflow (Important!)

**BEST PRACTICE**: The component should be added to `app/page.tsx` BEFORE refactoring:

1. ✅ **User adds raw Aceternity block** → `components/new-block.tsx`
2. ✅ **User adds to page** → Import and use in `app/page.tsx`
3. ✅ **User verifies in browser** → http://localhost:3000 (check animations, styling)
4. ✅ **User runs refactoring** → `/refactor-aceternity components/new-block.tsx`
5. ✅ **Agent refactors** → Container/Hook/View pattern
6. ✅ **Agent verifies** → Component still renders with GraphQL data

**If component is NOT yet on page:**
- Agent should ask: "Should I add this component to app/page.tsx?"
- If yes, add both import and usage
- If no, complete refactoring but note in report that component is not visible

### Step-by-Step Refactoring Process

#### Phase 1: Analysis & Planning

1. **Read source component**
   - Parse the component structure
   - Identify all props, state, and hardcoded content
   - Note any special features (animations, skeletons, sub-components)
   - Extract the component's purpose and main data fields

2. **Check page integration**
   - Read `services/ace/app/page.tsx`
   - Check if component is already imported and used
   - If found: Note the import path and usage location
   - If not found: Ask user if component should be added to page
   - **IMPORTANT**: Recommend adding raw component to page BEFORE refactoring for end-to-end verification

3. **Determine section name**
   - If provided as argument, use it
   - Otherwise, infer from filename (e.g., `Testimonials.tsx` → `testimonials`)
   - Convert to camelCase for code, kebab-case for files

4. **Plan file structure**
   ```
   components/[section]/
   ├── ui/
   │   ├── [Section]View.tsx           # Presentational component
   │   ├── [Section]View.test.tsx      # View tests
   │   └── [Section]View.stories.tsx   # Storybook story
   ├── [Section].tsx                   # Container component
   ├── [section].types.ts              # TypeScript interfaces
   ├── [section].mapper.ts             # GraphQL mapper
   └── index.tsx                       # Barrel export

   hooks/
   ├── use[Section]Data.ts             # Custom hook
   └── use[Section]Data.test.ts        # Hook tests
   ```

#### Phase 2: Create Type Definitions

Create `components/[section]/[section].types.ts`:

```typescript
// Extract all data fields from the source component
export interface [Section]Data {
  // Add all fields that should come from GraphQL
  // Include proper TypeScript types
}

export interface [Section]ViewProps extends [Section]Data {
  // Add any additional view-specific props
}
```

**Guidelines:**
- Convert hardcoded strings to data fields
- Use descriptive names (title, subtitle, description, items, etc.)
- Include proper types (string, number, array, etc.)
- Consider nested objects for complex data

#### Phase 3: Create View Component

Create `components/[section]/ui/[Section]View.tsx`:

```typescript
import type { [Section]ViewProps } from '../[section].types';

export function [Section]View(props: [Section]ViewProps) {
  // Pure presentational component
  // Use props instead of hardcoded values
  // Preserve all Aceternity UI components
  // Keep animations and styling
}
```

**Guidelines:**
- Remove all data fetching logic
- Replace hardcoded content with props
- Preserve Motion animations
- Keep all Aceternity UI components
- Maintain responsive design
- Support dark mode

**Special Cases:**
- If component has skeleton components, keep them in `components/[section]/skeletons/`
- If component has sub-components (cards, etc.), create separate files in `ui/`

#### Phase 4: Create Custom Hook

Create `hooks/use[Section]Data.ts`:

```typescript
"use client";

import { useQuery } from 'urql';
import { [SECTION]_QUERY } from '@/lib/graphql/queries';
import { mapTo[Section]Data } from '@/components/[section]/[section].mapper';
import type { [Section]Response } from '@/lib/graphql/types';

export function use[Section]Data() {
  const [result] = useQuery<[Section]Response>({
    query: [SECTION]_QUERY,
  });

  return {
    data: result.data ? mapTo[Section]Data(result.data) : null,
    loading: result.fetching,
    error: result.error || null,
  };
}
```

**Guidelines:**
- Always use "use client" directive
- Import urql's useQuery
- Use proper TypeScript generics
- Return { data, loading, error }

#### Phase 5: Create Mapper Function

Create `components/[section]/[section].mapper.ts`:

```typescript
import type { [Section]Data } from './[section].types';
import type { [Section]Response } from '@/lib/graphql/types';

export function mapTo[Section]Data(response: [Section]Response): [Section]Data {
  return {
    // Map GraphQL response fields to component data
    // Handle any data transformations
  };
}
```

**Guidelines:**
- Map GraphQL response to component props
- Handle null/undefined values
- Transform data if needed (e.g., parse dates, format strings)

#### Phase 6: Create Container Component

Create `components/[section]/[Section].tsx`:

```typescript
"use client";

import { use[Section]Data } from '@/hooks/use[Section]Data';
import { [Section]View } from './ui/[Section]View';

export function [Section]() {
  const { data, loading, error } = use[Section]Data();

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error loading [section]</div>;
  if (!data) return null;

  return <[Section]View {...data} />;
}
```

**Guidelines:**
- Always use "use client" directive
- Handle all three states: loading, error, null
- Spread data to view component

#### Phase 7: Create Barrel Export

Create `components/[section]/index.tsx`:

```typescript
export { [Section] } from './[Section]';
export { [Section]View } from './ui/[Section]View';
export type { [Section]Data, [Section]ViewProps } from './[section].types';
```

#### Phase 8: Update GraphQL Files

**A. Add query to `lib/graphql/queries.ts`:**

```typescript
export const [SECTION]_QUERY = `
  query [Section]Section {
    [section] {
      # Add all fields from [Section]Data interface
    }
  }
`;
```

**B. Add response type to `lib/graphql/types.ts`:**

```typescript
export interface [Section]Response {
  [section]: {
    // Match query fields
  };
}
```

#### Phase 9: Create Tests

**A. Hook test (`hooks/use[Section]Data.test.ts`):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook } from '@testing-library/react';
import { useQuery } from 'urql';
import { use[Section]Data } from './use[Section]Data';

vi.mock('urql', () => ({
  useQuery: vi.fn(),
}));

const mockedUseQuery = vi.mocked(useQuery);

describe('use[Section]Data', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns loading state when fetching', () => {
    mockedUseQuery.mockReturnValue([
      { data: undefined, error: undefined, fetching: true } as any,
      vi.fn(),
    ]);

    const { result } = renderHook(() => use[Section]Data());
    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBeNull();
  });

  it('returns data on successful fetch', () => {
    const mockData = { /* mock response */ };
    mockedUseQuery.mockReturnValue([
      { data: mockData, error: undefined, fetching: false } as any,
      vi.fn(),
    ]);

    const { result } = renderHook(() => use[Section]Data());
    expect(result.current.loading).toBe(false);
    expect(result.current.data).toBeTruthy();
  });

  it('returns error on failed fetch', () => {
    const mockError = new Error('GraphQL error');
    mockedUseQuery.mockReturnValue([
      { data: undefined, error: mockError, fetching: false } as any,
      vi.fn(),
    ]);

    const { result } = renderHook(() => use[Section]Data());
    expect(result.current.error).toBe(mockError);
  });
});
```

**B. View test (`components/[section]/ui/[Section]View.test.tsx`):**

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { [Section]View } from './[Section]View';

describe('[Section]View', () => {
  const mockProps = {
    // Add mock props
  };

  it('renders without crashing', () => {
    render(<[Section]View {...mockProps} />);
  });

  it('displays main content', () => {
    render(<[Section]View {...mockProps} />);
    // Add assertions for key content
  });
});
```

#### Phase 10: Create Storybook Story

Create `components/[section]/ui/[Section]View.stories.tsx`:

```typescript
import type { Meta, StoryObj } from '@storybook/nextjs-vite';
import { [Section]View } from './[Section]View';

const meta = {
  title: 'Sections/[Section]View',
  component: [Section]View,
  parameters: {
    layout: 'fullscreen',
  },
  tags: ['autodocs'],
  argTypes: {
    // Add argTypes for each prop with controls and descriptions
  },
} satisfies Meta<typeof [Section]View>;

export default meta;
type Story = StoryObj<typeof meta>;

/**
 * Default view of the [section] section
 */
export const Default: Story = {
  args: {
    // Add default mock data
  },
};

/**
 * [Add variant description]
 */
export const [Variant]: Story = {
  args: {
    // Add variant mock data
  },
};
```

**Guidelines:**
- Create at least 2-3 story variants
- Document each story with JSDoc comments
- Use realistic mock data
- Add proper argTypes with descriptions

#### Phase 11: Update Homepage Integration

**CRITICAL**: This step ensures end-to-end verification in the browser.

1. **Check if component is used in page:**
   - Read `services/ace/app/page.tsx`
   - Look for existing import of the raw component

2. **Update import path (if needed):**

   **Before refactoring** (raw component):
   ```typescript
   import { NewBlock } from '@/components/new-block';
   ```

   **After refactoring** (Container via barrel export):
   ```typescript
   import { NewBlock } from '@/components/new-block';  // ← Same path, but now imports from index.tsx
   ```

   The import path stays the same because `index.tsx` exports the Container component with the same name.

3. **If component not yet in page:**
   - Ask user: "Should I add this component to app/page.tsx for browser verification?"
   - If yes, add import and usage in appropriate location
   - Suggest position based on section type (hero at top, pricing/faqs at bottom, features in middle)

4. **Verify the integration:**
   ```typescript
   // Example: app/page.tsx after refactoring
   import { Hero } from '@/components/hero';
   import { NewBlock } from '@/components/new-block';  // ← Refactored Container
   import { Features } from '@/components/features';

   export default function Home() {
     return (
       <>
         <Hero />
         <NewBlock />  {/* ← Now using Container/Hook/View pattern */}
         <Features />
       </>
     );
   }
   ```

**Key Points:**
- ✅ Import path remains the same (barrel export handles routing)
- ✅ Component name remains the same
- ✅ User can see component in browser at http://localhost:3000
- ✅ Automatic GraphQL data fetching via Container → Hook → View
- ❌ Don't change the import path structure
- ❌ Don't break existing page layout

#### Phase 12: Final Validation

1. **Check all files created:**
   - Container, View, types, mapper, hook, index
   - Hook test, View test, Storybook story
   - GraphQL query and type added

2. **Verify naming consistency:**
   - PascalCase for components
   - camelCase for hooks
   - kebab-case for files
   - SCREAMING_SNAKE_CASE for query constants

3. **Run validation commands:**
   ```bash
   cd services/ace
   pnpm build          # Check for TypeScript errors
   pnpm test           # Run tests
   ```

#### Phase 13: Browser Verification (Critical)

**IMPORTANT**: Verify the refactored component renders correctly in the browser.

1. **Check running servers:**
   - GraphQL Mock Server should be running: http://localhost:8000/api/graphql/
   - ACE Frontend should be running: http://localhost:3000
   - Use BashOutput tool to check background bash processes if needed

2. **Create mock data file:**
   - Create `services/graphql-mock/src/data/[section].json` with sample data
   - Structure should match the GraphQL query fields
   - Example structure:
   ```json
   {
     "[section]": {
       "field1": "value1",
       "field2": "value2"
     }
   }
   ```

3. **Update GraphQL Mock Server resolver:**
   - Read `services/graphql-mock/src/index.ts` or similar
   - Add resolver for the new section query
   - Import and use the JSON data file

4. **Test in browser:**
   - Navigate to http://localhost:3000
   - Scroll to the new component
   - Verify it renders with GraphQL data (not loading state)
   - Check console for errors
   - Verify animations work
   - Test dark mode toggle
   - Check responsive design (mobile, tablet, desktop)

5. **Troubleshoot if needed:**
   - **Loading state forever**: Check GraphQL mock resolver
   - **Error state**: Check browser console for GraphQL errors
   - **Null state**: Check if GraphQL response matches expected structure
   - **TypeScript errors**: Check mapper function types
   - **Styling broken**: Verify all Aceternity components preserved

#### Phase 14: Report

Create a comprehensive report with:

```markdown
## Refactoring Complete: [Section] Component

### ✅ Files Created

**Component Structure:**
- components/[section]/[Section].tsx
- components/[section]/[section].types.ts
- components/[section]/[section].mapper.ts
- components/[section]/ui/[Section]View.tsx
- components/[section]/index.tsx

**Hooks:**
- hooks/use[Section]Data.ts

**Tests:**
- hooks/use[Section]Data.test.ts
- components/[section]/ui/[Section]View.test.tsx

**Documentation:**
- components/[section]/ui/[Section]View.stories.tsx

**GraphQL:**
- Updated lib/graphql/queries.ts (added [SECTION]_QUERY)
- Updated lib/graphql/types.ts (added [Section]Response)

### 📊 Component Analysis

**Data Fields:** [List all fields in [Section]Data interface]
**Special Features:** [List any skeletons, animations, sub-components]
**GraphQL Query:** [Show the query structure]

### 🧪 Testing Status

- Hook tests: [X] passing
- View tests: [X] passing

### 📚 Storybook

Stories available:
- Default
- [List other variants]

View at: http://localhost:6006/?path=/story/sections-[section]view--default

### ⚠️ Notes

[Any special considerations or manual steps needed]

### 🌐 Browser Verification

**Component Status in Browser:**
- [ ] Component renders at http://localhost:3000
- [ ] GraphQL data loads correctly (not stuck in loading state)
- [ ] No console errors
- [ ] Animations work correctly
- [ ] Dark mode supported
- [ ] Responsive on mobile/tablet/desktop

**Mock Data:**
- GraphQL Mock data file: `services/graphql-mock/src/data/[section].json`
- Mock resolver: [Updated/Not Updated]

**If verification failed:**
- [List any issues found during browser testing]

### 🎯 Next Steps

1. ✅ Component added to page at app/page.tsx (if applicable)
2. ✅ GraphQL Mock Server data file created: `services/graphql-mock/src/data/[section].json`
3. ✅ Browser verification complete: http://localhost:3000
4. 🔜 Implement production backend GraphQL resolver when ready
5. 🔜 Update GraphQL backend schema to include new section query
```

---

## Error Handling

If you encounter any issues:

1. **Missing imports**: Check existing components for correct import paths
2. **Type errors**: Ensure GraphQL types match mapper inputs/outputs
3. **Component structure unclear**: Ask for clarification about the component's purpose
4. **Special features**: Preserve skeleton components, animations, and Aceternity UI features

---

## Special Considerations

### Skeleton Components

If the source component has animated skeleton backgrounds:
- Keep them in `components/[section]/skeletons/`
- Import and use in the View component
- Map skeleton data appropriately

### Sub-Components

If the component has reusable sub-components (e.g., cards):
- Create them in `components/[section]/ui/`
- Name descriptively (e.g., `pricing-card.tsx`, `card-components.tsx`)
- Import in the View component

### Animations

- Preserve all Motion (Framer Motion) animations
- Keep animation props and variants
- Ensure animations work with dynamic data

### Icons

- Use existing Tabler icons from `@tabler/icons-react`
- If custom icons needed, place in `icons/` directory
- Handle icon mappings in mapper function if needed

---

## Quality Checklist

Before completing, verify:

**Code Structure:**
- [ ] All files follow naming conventions
- [ ] TypeScript types are properly defined
- [ ] GraphQL query matches response type
- [ ] Mapper correctly transforms data
- [ ] View component is purely presentational
- [ ] Container handles all states (loading, error, null)
- [ ] Hook uses urql correctly
- [ ] Tests cover main scenarios
- [ ] Storybook story has multiple variants
- [ ] No hardcoded content in View component

**UI/UX:**
- [ ] Animations and styling preserved
- [ ] Dark mode supported
- [ ] Responsive design maintained

**Integration:**
- [ ] Component added to app/page.tsx (or user notified)
- [ ] Import path uses barrel export correctly
- [ ] GraphQL mock data file created
- [ ] GraphQL mock resolver updated

**Browser Verification (Critical):**
- [ ] Component renders at http://localhost:3000
- [ ] No console errors
- [ ] GraphQL data loads (not stuck in loading state)
- [ ] Animations work correctly
- [ ] Dark mode toggle works
- [ ] Mobile/tablet/desktop responsive

---

## Begin Refactoring

Now analyze the source component and execute all phases autonomously. Report progress and final results.
