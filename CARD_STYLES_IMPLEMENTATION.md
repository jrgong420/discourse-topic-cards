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

## Changes Made

### 1. Theme Settings (settings.yml)
Added two new enum settings:
- `card_style_desktop`: landscape (default) | portrait
- `card_style_mobile`: portrait (default) | landscape

Defaults preserve current behavior:
- Desktop: landscape (image left, content right)
- Mobile: portrait (image top, content below)

### 2. Runtime Wiring (discourse-topic-list-cards.gjs)
Modified two value transformers to apply BEM modifier classes:

**topic-list-class transformer:**
- Adds `topic-cards-list--landscape` or `topic-cards-list--portrait`
- Based on viewport (site.mobileView) and corresponding setting

**topic-list-item-class transformer:**
- Adds `topic-card--landscape` or `topic-card--portrait`
- Preserves existing classes (topic-card, has-max-height)

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

## Testing Recommendations

### Manual QA Checklist
- [ ] Desktop portrait: Verify 2/3/4 column grid at different widths
- [ ] Desktop landscape: Confirm existing behavior unchanged
- [ ] Mobile portrait: Confirm existing behavior unchanged
- [ ] Mobile landscape: Check row layout, spacing, typography
- [ ] All combinations: Verify click navigation works
- [ ] All combinations: Check thumbnail rendering and aspect ratios
- [ ] All combinations: Validate metadata/tags/excerpt display
- [ ] Theme settings UI: Confirm dropdowns appear and work

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

