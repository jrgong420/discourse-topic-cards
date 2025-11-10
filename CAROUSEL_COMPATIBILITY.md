# Carousel Compatibility Verification

## Overview

This document verifies that the Topic Cards Carousel component is compatible with existing theme components and does not introduce conflicts.

## Component Architecture

### Namespace Separation

**Carousel Namespace:**
- CSS: `.topic-cards-carousel`
- Card CSS: `.carousel-topic-card`
- Plugin Outlet: `above-main-container`
- Route: `discovery.latest` (home page only)

**Existing Topic Cards Namespace:**
- CSS: `.topic-cards-list`
- Card CSS: `.topic-card`
- Plugin Outlet: `topic-list-main-link-bottom`
- Routes: All category/tag routes

**Result:** ✅ No namespace conflicts - completely separate BEM hierarchies

---

## Plugin Outlet Compatibility

### Carousel Outlets Used
- `above-main-container` - Renders carousel at top of page

### Existing Component Outlets
- `topic-list-main-link-bottom` - Used by discourse-topic-list-cards
- No other outlets used by carousel

**Result:** ✅ No outlet conflicts - carousel uses different outlet

---

## API Transformer Compatibility

### Carousel Transformers
- **None** - Carousel does not register any value or behavior transformers

### Existing Transformers
- `topic-list-class` - Used by discourse-topic-list-cards and portfolio-topic-cards
- `topic-list-item-class` - Used by discourse-topic-list-cards and portfolio-topic-cards
- `topic-list-item-click` - Used by discourse-topic-list-cards

**Result:** ✅ No transformer conflicts - carousel doesn't register transformers

---

## Component Reuse

### Shared Components
The carousel reuses existing topic card components:

1. **TopicTagsInline** - Renders category and tags
2. **TopicExcerpt** - Renders topic excerpt
3. **TopicByline** - Renders author and publish date
4. **TopicMetadata** - Renders views, likes, replies, activity
5. **TopicActionButtons** - Renders details and featured link buttons

**Result:** ✅ Proper reuse - carousel uses existing components correctly

---

## CSS Specificity

### Carousel Styles
- All carousel styles scoped under `.topic-cards-carousel`
- Carousel cards use `.carousel-topic-card` class
- No global styles or overrides

### Existing Styles
- Topic list cards scoped under `.topic-cards-list`
- Individual cards use `.topic-card` class
- No overlap with carousel classes

**Result:** ✅ No CSS conflicts - separate BEM namespaces

---

## Route Gating

### Carousel Routes
- Only renders on `discovery.latest` (home page)
- Controlled by `carousel_display_location` setting

### Existing Component Routes
- discourse-topic-list-cards: All category/tag routes
- portfolio-topic-cards: `user.portfolio` route only

**Result:** ✅ No route conflicts - different routes

---

## Settings Compatibility

### Carousel Settings

The carousel uses a minimal, Embla-aligned settings structure organized into logical groups:

**Display & Layout:**
- `carousel_display_location` - Where to show carousel (home/disabled)
- `carousel_desktop_layout` - Desktop layout mode (list/grid)
- `carousel_mobile_layout` - Mobile layout mode (list/grid)
- `carousel_plugin_outlet` - Plugin outlet location (advanced)

**Topic Source & Filtering:**
- `carousel_filter_tags` - Tag filtering (pipe-separated)
- `carousel_max_items` - Maximum topics to display (1-20)
- `carousel_order` - Topic ordering (latest/random/popular)

**Grid Layout & Sizing:**
- `carousel_slides_per_view` - Max cards per slide in grid mode (1-6)
- `carousel_min_card_width_px` - Min card width for responsive grid (240-480px)

**Embla Carousel Behavior:**
- `carousel_loop` - Enable infinite looping (bool)
- `carousel_align` - Slide alignment (start/center)
- `carousel_drag_free` - Enable free-scroll dragging (bool)
- `carousel_speed` - Animation speed (slow/normal/fast)

### Existing Settings
- `show_likes`, `show_views`, `show_reply_count`, etc. - Shared with carousel cards
- `list_view_categories`, `grid_view_categories` - Topic list cards only
- `thumbnail_placeholder_icon` - Shared with carousel cards

**Result:** ✅ Compatible - carousel respects shared settings

---

## Embla Configuration Mapping

The carousel settings map to Embla Carousel options as follows:

### User-Configurable (via settings.yml)

| Setting | Embla Option | Values | Default | Description |
|---------|--------------|--------|---------|-------------|
| `carousel_loop` | `loop` | true/false | true | Infinite looping |
| `carousel_align` | `align` | start/center | start | Slide alignment |
| `carousel_drag_free` | `dragFree` | true/false | false | Free-scroll dragging |
| `carousel_speed` | `duration` | slow(35)/normal(25)/fast(15) | normal | Animation speed |

### Hardcoded Defaults (sensible defaults)

| Embla Option | Value | Rationale |
|--------------|-------|-----------|
| `containScroll` | "trimSnaps" | Best for grouped slides |
| `skipSnaps` | false | Predictable snapping behavior |
| `draggable` | true | Always allow dragging |
| `axis` | "x" | Horizontal carousel |
| `startIndex` | 0 | Start at first slide |

### Layout-Specific (computed from settings)

- `carousel_slides_per_view` - Controls chunking logic (cards per slide)
- `carousel_min_card_width_px` - Used in responsive grid calculations

**Note:** These are not direct Embla options but control how topics are chunked into slides and how the grid layout responds to viewport changes.

---

## Migration Guide

### Upgrading from Previous Versions

If you're upgrading from a version with the old carousel settings, here's what changed:

**Renamed Settings:**
- `carousel_max_cards_visible` → `carousel_slides_per_view`
- `carousel_grid_min_card_width` → `carousel_min_card_width_px`

**New Settings:**
- `carousel_loop` - Controls infinite looping (default: true)
- `carousel_align` - Controls slide alignment (default: start)
- `carousel_drag_free` - Controls free-scroll dragging (default: false)
- `carousel_speed` - Controls animation speed (default: normal)

**Changed Defaults:**
- `carousel_desktop_layout` - Changed from "list" to "grid" for better showcase

**No Action Required:**
- The component will use sensible defaults if settings are not configured
- Existing settings will continue to work
- New settings provide additional control over carousel behavior

---

## Data Fetching

### Carousel Data
- Fetches topics via Discourse API (`/latest.json`, `/top.json`, `/tag/{tag}.json`)
- Creates Topic model instances via store service
- Independent from topic list data

### Existing Components
- Use Discourse's built-in topic list data
- No custom data fetching

**Result:** ✅ No conflicts - carousel fetches its own data

---

## Performance Impact

### Carousel Performance Features
- Lazy loading with IntersectionObserver
- Only fetches when visible in viewport
- Caches topics after first load
- Smooth animations with CSS transitions

### Impact on Existing Components
- No impact - carousel is independent
- Only loads on home page
- Can be disabled via settings

**Result:** ✅ Minimal impact - lazy loading prevents performance issues

---

## Accessibility

### Carousel Accessibility
- ARIA roles and labels
- Keyboard navigation (Left/Right arrows)
- Focus management
- Screen reader support

### Existing Components
- Topic cards have proper semantic HTML
- Links and buttons are accessible

**Result:** ✅ Enhanced accessibility - carousel adds keyboard navigation

---

## Browser Compatibility

### Carousel Requirements
- IntersectionObserver API (supported in all modern browsers)
- Embla Carousel library (loaded from CDN or theme uploads)
- CSS Grid and Flexbox

### Existing Components
- Standard Discourse browser requirements

**Result:** ✅ Compatible - same browser requirements as Discourse

---

## Testing Checklist

### Basic Functionality
- [ ] Carousel renders on home page when enabled
- [ ] Carousel does not render when disabled
- [ ] Carousel does not appear on category/tag pages
- [ ] Topic list cards still work on category pages
- [ ] Portfolio cards still work on user portfolio page

### Component Interaction
- [ ] Carousel cards use same thumbnail component
- [ ] Carousel cards respect `show_likes`, `show_views` settings
- [ ] Carousel cards use same placeholder icon setting
- [ ] Carousel cards render excerpts correctly
- [ ] Carousel cards show byline and metadata

### CSS Isolation
- [ ] Carousel styles don't affect topic list cards
- [ ] Topic list card styles don't affect carousel
- [ ] Both can appear on same page without conflicts
- [ ] Responsive behavior works for both

### Performance
- [ ] Carousel lazy loads when scrolling to it
- [ ] No duplicate API calls
- [ ] Page load time not significantly impacted
- [ ] Smooth animations and transitions

### Accessibility
- [ ] Keyboard navigation works in carousel
- [ ] Screen readers announce carousel properly
- [ ] Focus management works correctly
- [ ] ARIA labels are present and correct

### Settings
- [ ] Carousel respects display location setting
- [ ] Layout settings work correctly (list/grid)
- [ ] Tag filtering works
- [ ] Max items setting is respected
- [ ] Order setting works (latest/random/popular)
- [ ] Slides per view setting controls grid columns
- [ ] Min card width setting affects responsive layout
- [ ] Loop setting enables/disables infinite looping
- [ ] Align setting changes slide alignment
- [ ] Drag free setting affects dragging behavior
- [ ] Speed setting changes animation speed

---

## Known Limitations

1. **Single Plugin Outlet**: Carousel currently only supports `above-main-container` outlet
2. **Home Page Only**: Carousel only renders on `discovery.latest` route
3. **No Category Filtering**: Carousel doesn't support per-category configuration like topic list cards

---

## Future Enhancements

1. **Multiple Outlets**: Support for additional plugin outlets
2. **Category Filtering**: Per-category carousel configuration
3. **Custom Ordering**: More ordering options (trending, bookmarked, etc.)
4. **Autoplay**: Optional autoplay with configurable interval

---

## Conclusion

✅ **The carousel component is fully compatible with existing theme components.**

- No namespace conflicts
- No plugin outlet conflicts
- No API transformer conflicts
- Proper component reuse
- Independent data fetching
- Minimal performance impact
- Enhanced accessibility
- Can coexist with topic list cards and portfolio cards

The carousel uses a completely separate namespace and plugin outlet, ensuring it does not interfere with existing functionality while properly reusing shared components and respecting shared settings.

