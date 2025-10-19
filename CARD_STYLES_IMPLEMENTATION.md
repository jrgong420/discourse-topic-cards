# Card Styles Implementation Summary

## Overview
Implemented configurable card layout system allowing independent selection of "list" and "grid" card layouts for desktop and mobile viewports, with comprehensive border radius theming and uniform grid height support.

## Branch
`feat/css-refactor` (refactored from `feat/card-styles-config`)

## Commits
1. `a656be3` - Add card_style_desktop and card_style_mobile theme settings
2. `0c6fa3b` - Wire card style modifier classes in initializer
3. `b403a49` - Implement portrait desktop and landscape mobile card styles
4. `445e2bb` - Add system specs for card style configurations
5. `0d6e8e4` - Add implementation documentation for card styles feature
6. `ad4d010` - Add portrait max-width settings and clarify landscape max-height
7. `53d669d` - Refactor initializer for orientation-specific max-dimension classes
8. `6750cb0` - Update SCSS for orientation-specific max dimensions
9. `09dc3b0` - Add specs for orientation-specific max-dimension features

## Changes Made

### 1. Theme Settings (settings.yml)
**Card Layout Settings:**
- `card_style_desktop`: list (default) | grid
- `card_style_mobile`: grid (default) | list

**Max-Dimension Settings (Layout-Specific):**
- `set_card_max_height`: boolean (default: true) - Applies to **list cards only**
- `card_max_height`: integer (default: 275) - Max height in pixels for list cards
- `set_grid_card_max_width`: boolean (default: false) - Applies to **grid cards on desktop/tablet only** (no effect on smartphones)
- `grid_card_max_width`: integer (default: 360) - Max width in pixels for grid cards on desktop/tablet. Set to 0 to disable max-width constraint (no effect on smartphones)
- `grid_card_min_width`: integer (default: 260) - Minimum column width in pixels for desktop/tablet grid. Grid auto-fits as many cards as fit per row (no effect on smartphones)
- `set_card_grid_height`: boolean (default: true) - Applies to **grid cards on desktop only**
- `card_grid_height`: integer (default: 420) - Uniform height in pixels for grid cards on desktop
- `grid_thumbnail_max_height`: integer (default: 150) - Maximum thumbnail height in pixels for smartphone grid only (no effect on desktop/tablet)


**Border Radius Setting:**
- `card_border_radius`: none | small | medium | large (default) | extra_large
  - Maps to Discourse core CSS variables for consistency

Defaults:
- Desktop: list (image left, content right)
- Mobile: grid (image top, content below)
- Max-height enabled by default for list cards
- Max-width disabled by default for grid cards
- Grid height enabled by default for desktop grid cards

### 2. Runtime Wiring (discourse-topic-list-cards.gjs)
Modified two value transformers to apply BEM modifier classes:

**Backward Compatibility:**
- `normalizeCardStyle()` function maps legacy values (portrait→grid, landscape→list)
- Ensures existing sites continue to work during migration

**topic-list-class transformer:**
- Adds `topic-cards-list--list` or `topic-cards-list--grid`
- Based on viewport (site.mobileView) and corresponding setting

**topic-list-item-class transformer:**
- Adds `topic-card--list` or `topic-card--grid`
- Conditionally adds `has-max-height` when card layout is list AND `set_card_max_height` is true
- Conditionally adds `has-max-width` when card layout is grid AND `set_grid_card_max_width` is true AND `grid_card_max_width` > 0
- Conditionally adds `has-grid-height` when card layout is grid AND `set_card_grid_height` is true AND desktop viewport
- Ensures max-dimension classes are layout-specific and mutually exclusive

### 3. CSS Architecture (common/common.scss)
**Border Radius Mapping:**
- Component-scoped CSS variable `--topic-cards-border-radius` set on `.topic-cards-list`
- Maps `$card_border_radius` setting to Discourse core variables:
  - none → 0
  - small → var(--d-border-radius)
  - medium → calc(var(--d-border-radius) * 1.5)
  - large → var(--d-border-radius-large)
  - extra_large → calc(var(--d-border-radius-large) * 1.5)

**Shared Card Styles:**
- Base card container styles (flex, background, shadow, border)
- Uses `--topic-cards-border-radius` for consistent corner rounding
- Shared thumbnail base styles

### 4. Desktop Styles (desktop/desktop.scss)
**Grid layout (.topic-card--grid):**
- Responsive grid container: `repeat(auto-fill, minmax(#{$grid-card-min-width}px, 1fr))`
- Automatically fits as many columns as possible based on `grid_card_min_width` setting and available container width
- Stacked layout: thumbnail above content
- Max-height: 250px for thumbnails
- Thumbnail corners: top-left and top-right rounded with `--topic-cards-border-radius`

**List layout (.topic-card--list):**
- Row layout with thumbnail on left (30% flex-basis, max 450px)
- Thumbnail corners: left side rounded with `--topic-cards-border-radius`
- Horizontal gap between thumbnail and content

**Max-Height (List Only):**
- `.topic-card--list.has-max-height`: Applies max-height constraint
- Uses `$card-max-height` SCSS variable from settings
- Thumbnail aspect-ratio normalization (16:9) in max-height mode
- Overflow handling for content regions

**Max-Width (Grid, Desktop/Tablet Only):**
- `.topic-card--grid.has-max-width

**Uniform Grid Height (Grid Desktop Only):**
- `.topic-card--grid.has-grid-height`: Enforces uniform card height
- Uses `$card-grid-height` SCSS variable from settings (default 420px)
- Fixed thumbnail height (250px) with overflow handling
- Content region uses flex with min-height: 0 for proper overflow
- Excerpt clamped to 4 lines with -webkit-line-clamp

### 5. Mobile Styles (mobile/mobile.scss)
**Grid layout (.topic-card--grid):**
- Stacked layout with full-width thumbnail
- Thumbnail corners: top-left and top-right rounded with `--topic-cards-border-radius`

**Landscape style (.topic-card--landscape):**
- Row layout adapted for mobile
- Thumbnail: 35% width, max 150px, max-height 120px
- Compact typography:
  - Title: `var(--font-down-1)`
  - Excerpt: `var(--font-down-1)`
  - Metadata/OP: `var(--font-down-2)`
- Tighter spacing: `var(--space-2)`, `var(--space-3)`
- Maintains touch targets and readability

### 5. Testing (spec/system/card_styles_spec.rb)
System specs covering:
- All 4 combinations of desktop/mobile card styles
- Viewport-specific class application
- Desktop viewport: 1280x800
- Mobile viewport: 375x667
- Card content rendering validation
- **Max-height for landscape cards:**
  - Verifies `has-max-height` class only applied to landscape cards
  - Confirms portrait cards never receive `has-max-height`
- **Max-width for portrait cards:**
  - Verifies `has-max-width` class only applied to portrait cards
  - Confirms landscape cards never receive `has-max-width`
- **Independent max-dimension settings:**
  - Tests both settings work independently across viewport combinations
  - Validates classes are mutually exclusive

## Supported Combinations

| Desktop Style | Mobile Style | Use Case |
|--------------|--------------|----------|
| Landscape (default) | Portrait (default) | Current behavior |
| Landscape | Landscape | Consistent row layout across devices |
| Portrait | Landscape | Grid on desktop, row on mobile |
| Portrait | Portrait | Consistent stacked layout across devices |

## Design Decisions

### Grid Implementation
- Used `auto-fit` with `minmax()` for intrinsic responsiveness
- Avoids hard-coded breakpoints
- Natural flow between 2-4 columns based on available space
- Min card width: 260px, Max: 360px (28vw clamped)

### BEM Naming
- Modifier classes: `--landscape`, `--portrait`
- Applied to both list and item levels
- Clear separation of concerns

### CSS Custom Properties
- Leveraged existing Discourse tokens:
  - Spacing: `--space-1` through `--space-6`
  - Typography: `--font-down-1`, `--font-down-2`
  - Border radius: `--d-border-radius`, `--d-border-radius-large`
  - Colors: `--primary-low`

### Mobile Landscape Constraints
- Thumbnail max-width: 150px (prevents excessive image size)
- Thumbnail max-height: 120px (maintains aspect ratio)
- Compact font sizes for readability on small screens
- Preserved touch target sizes

### Orientation-Specific Max Dimensions
**Why separate max-height and max-width?**
- Landscape cards (horizontal layout) benefit from height constraints to maintain consistent row heights
- Portrait cards (vertical layout) benefit from width constraints to prevent overly wide cards in grid
- Each orientation has different overflow concerns and visual requirements

**Implementation approach:**
- Max-dimension classes (`has-max-height`, `has-max-width`) are applied conditionally in the initializer
- SCSS rules target specific orientation + class combinations (e.g., `.topic-card--landscape.has-max-height`)
- Settings are independent and can be enabled/disabled separately
- Default behavior preserved: max-height enabled for landscape, max-width disabled for portrait

## Testing Recommendations

### Manual QA Checklist
**Card Styles:**
- [ ] Desktop portrait: Verify 2/3/4 column grid at different widths
- [ ] Desktop landscape: Confirm existing behavior unchanged
- [ ] Mobile portrait: Confirm existing behavior unchanged
- [ ] Mobile landscape: Check row layout, spacing, typography
- [ ] All combinations: Verify click navigation works
- [ ] All combinations: Check thumbnail rendering and aspect ratios
- [ ] All combinations: Validate metadata/tags/excerpt display

**Max Dimensions:**
- [ ] Landscape cards: Enable max-height, verify cards constrained to set height
- [ ] Landscape cards: Disable max-height, verify cards grow with content
- [ ] Portrait cards: Enable max-width, verify cards constrained and centered in grid
- [ ] Portrait cards: Disable max-width, verify cards use full grid cell width
- [ ] Mixed settings: Enable both, verify landscape gets height constraint and portrait gets width constraint
- [ ] Aspect ratio: Verify landscape thumbnails normalize to 16:9 when max-height enabled

**Settings UI:**
- [ ] Theme settings UI: Confirm all dropdowns and toggles appear and work
- [ ] Verify setting descriptions clearly indicate orientation-specific behavior

### Automated Tests
Run system specs:
```bash
bundle exec rspec spec/system/card_styles_spec.rb
```

## Next Steps
1. Manual QA across all four combinations
2. Run automated specs to verify class application
3. Test on actual Discourse instance with theme installed
4. Gather user feedback on grid column counts and spacing
5. Consider adding setting for custom grid column counts (future enhancement)

## Potential Future Enhancements
- Custom grid column count setting (2/3/4/auto)
- Tablet-specific breakpoint and style
- Animation transitions when switching styles
- Per-category card style overrides
- Custom thumbnail aspect ratios per style
- Configurable max-height for portrait cards (currently only thumbnails have max-height)
- Configurable max-width for landscape cards (if needed for ultra-wide displays)

## Key Features Summary

### Orientation-Specific Max Dimensions
This implementation introduces a key architectural improvement: **max-dimension constraints are now orientation-aware**.

**Before:**
- `set_card_max_height` applied to all cards regardless of orientation
- No max-width option available
- Portrait cards in grid could become excessively wide

**After:**
- `set_card_max_height` applies **only to landscape cards** (horizontal layout)
- `set_grid_card_max_width` applies **only to portrait cards** (vertical layout in grid)
- Each orientation gets the constraint that makes sense for its layout
- Settings work independently and can be mixed (e.g., desktop landscape with max-height + mobile portrait with max-width)

**Benefits:**
- More intuitive settings that match the visual layout
- Better control over card dimensions in different orientations
- Prevents awkward constraints (e.g., max-height on stacked portrait cards)
- Maintains backward compatibility with existing max-height behavior for landscape cards

---

## Recent Improvements (2025)

### Placeholder Thumbnails
**Implementation:** Always render `.topic-card__thumbnail` cell, even when no image exists.

**Behavior:**
- Topics without thumbnails display a placeholder element (`.thumbnail-placeholder`)
- Placeholder maintains consistent aspect ratio (16:9) across layouts
- Matches border radius of actual thumbnails (top corners for grid, left corners for list)
- Background: `var(--primary-low)` for visual consistency
- Marked as decorative (`aria-hidden="true"`)

**Benefits:**
- Uniform card layout regardless of thumbnail presence
- No layout shift when images load
- Grid/list alignment remains consistent across mixed content

### Title and Status Ordering
**Implementation:** CSS-only ordering within `.link-top-line` using flexbox `order` property.

**Behavior:**
- Topic title always appears first (order: 1)
- Topic statuses appear after the title (order: 2)
- No DOM manipulation required

**Benefits:**
- Predictable, accessible reading order
- Clean visual hierarchy
- Maintains click target behavior

### Calendar Event Date Positioning
**Implementation:** CSS Grid layout for `.link-top-line` with dedicated row for event dates.

**Behavior:**
- Title and statuses on first row (grid areas: "title" and "statuses")
- Calendar event date (`.header-topic-title-suffix-outlet`) on second row (grid area: "event")
- Spans full width below title
- Small top margin for visual separation

**Benefits:**
- Event dates never inline with title (prevents wrapping issues)
- Clean, predictable layout
- No collision with tags or excerpt areas

### Separator Stability
**Implementation:** Explicit CSS rules ensure separators remain visible across routes.

**Behavior:**
- Grid layout: separators span full width (`grid-column: 1 / -1`)
- List layout: separators display as block elements
- Visibility maintained across navigation and route changes

**Testing:**
- System specs verify separator presence after navigation
- Covers both grid and list layouts

**Benefits:**
- Reliable visual separation between topic groups
- No accidental hiding via cascade
- Consistent behavior across SPA navigation

