# Card Styles Implementation Summary

## Overview
Implemented configurable card layout system allowing independent selection of "landscape" and "portrait" card styles for desktop and mobile viewports.

## Branch
`feat/card-styles-config` (based on `feat/core-style`)

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
**Card Style Settings:**
- `card_style_desktop`: landscape (default) | portrait
- `card_style_mobile`: portrait (default) | landscape

**Max-Dimension Settings (Orientation-Specific):**
- `set_card_max_height`: boolean (default: true) - Applies to **landscape cards only**
- `card_max_height`: integer (default: 275) - Max height in pixels for landscape cards
- `set_card_max_width`: boolean (default: false) - Applies to **portrait cards only**
- `card_max_width`: integer (default: 360) - Max width in pixels for portrait cards

Defaults preserve current behavior:
- Desktop: landscape (image left, content right)
- Mobile: portrait (image top, content below)
- Max-height enabled by default for landscape cards
- Max-width disabled by default for portrait cards

### 2. Runtime Wiring (discourse-topic-list-cards.gjs)
Modified two value transformers to apply BEM modifier classes:

**topic-list-class transformer:**
- Adds `topic-cards-list--landscape` or `topic-cards-list--portrait`
- Based on viewport (site.mobileView) and corresponding setting

**topic-list-item-class transformer:**
- Adds `topic-card--landscape` or `topic-card--portrait`
- Conditionally adds `has-max-height` when card style is landscape AND `set_card_max_height` is true
- Conditionally adds `has-max-width` when card style is portrait AND `set_card_max_width` is true
- Ensures max-dimension classes are orientation-specific and mutually exclusive

### 3. Desktop Styles (desktop/desktop.scss)
**Portrait style (.topic-card--portrait):**
- Responsive grid container: `repeat(auto-fit, minmax(clamp(260px, 28vw, 360px), 1fr))`
- Automatically flows between 2-4 columns based on viewport width
- Stacked layout: thumbnail above content
- Reuses mobile layout pattern with desktop-appropriate spacing
- Max-height: 250px for thumbnails
- Full-width cards with border-radius on all corners

**Landscape style:**
- No changes needed; common.scss handles default landscape layout

**Max-Height (Landscape Only):**
- `.topic-card--landscape.has-max-height`: Applies max-height constraint
- Uses `$card-max-height` SCSS variable from settings
- Includes overflow handling for grid layout and excerpt text
- Thumbnail aspect-ratio normalization (16:9) in max-height mode

**Max-Width (Portrait Only):**
- `.topic-card--portrait.has-max-width`: Applies max-width constraint
- Uses `$card-max-width` SCSS variable from settings
- Centers cards within grid cells using `margin: auto`
- Ensures content doesn't overflow max-width

### 4. Mobile Styles (mobile/mobile.scss)
**Portrait style (.topic-card--portrait):**
- Existing mobile styles preserved
- Stacked layout with full-width thumbnail

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
- `set_card_max_width` applies **only to portrait cards** (vertical layout in grid)
- Each orientation gets the constraint that makes sense for its layout
- Settings work independently and can be mixed (e.g., desktop landscape with max-height + mobile portrait with max-width)

**Benefits:**
- More intuitive settings that match the visual layout
- Better control over card dimensions in different orientations
- Prevents awkward constraints (e.g., max-height on stacked portrait cards)
- Maintains backward compatibility with existing max-height behavior for landscape cards

