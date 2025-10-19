# Topic Card Highlight System

## Overview

The highlight system allows you to visually emphasize topic cards that have specific tags, making them stand out to increase visibility and click-through rates.

## Features

### Unified Tertiary Color Accent Style

The highlight system uses a **single, unified visual style** that combines the best aspects of multiple emphasis techniques:

- **Accent Border**: Colored border using your theme's tertiary color
- **Soft Glow**: Subtle outer ring effect for depth
- **Background Tint**: Gentle background color wash for harmony
- **Elevation Shadow**: Enhanced drop shadow with slight lift

This unified approach creates a cohesive, accessible highlight that works beautifully in both light and dark color schemes while maintaining visual harmony with your existing design.

### Three Intensity Levels

- **Subtle**: Minimal visual change, gentle emphasis
- **Medium**: Balanced prominence (recommended default)
- **Strong**: Maximum attention-grabbing effect

### Optional In-Card Accents

When enabled, highlighted cards receive additional subtle enhancements:

- **Tag Badge Accent**: Matching highlight tags display with tertiary color, background tint, and border
- **Title Color Shift**: Topic title subtly shifts toward tertiary color
- **Metadata Accents**: Icons and separators receive tertiary color hints

These accents work harmoniously with the card-level highlight to create a cohesive, polished appearance.

## Configuration

### Theme Settings

Navigate to **Admin → Customize → Themes → [Your Theme] → Settings**

#### `highlight_tags`
- **Type**: List (tag names)
- **Default**: `featured`
- **Description**: Tags that trigger highlighting
- **Format**: Pipe-separated (e.g., `featured|important|announcement`)
- **Example**: `featured` or `featured|breaking|urgent`

#### `highlight_style`
- **Type**: Dropdown
- **Default**: `tertiary_accent`
- **Options**:
  - `tertiary_accent` - Unified style combining border, background tint, and elevation
- **Description**: Single, cohesive highlight style that works across all themes and color schemes

#### `highlight_intensity`
- **Type**: Dropdown
- **Default**: `medium`
- **Options**:
  - `subtle` - Minimal effect
  - `medium` - Balanced (recommended)
  - `strong` - Maximum prominence
- **Recommendation**: Use `medium` for most cases, `strong` for campaigns

#### `show_highlight_incard_accents`
- **Type**: Boolean (checkbox)
- **Default**: `true` (enabled)
- **Description**: Show in-card accents for highlighted topics
- **What it does**:
  - Displays an accented badge for matching tag(s) within the card
  - Subtly adjusts topic title color toward tertiary
  - Adds tertiary color hints to metadata icons and separators
- **Recommendation**: Keep enabled for a polished, cohesive look

## Usage Examples

### Example 1: Highlight Featured Content (Recommended)
```
highlight_tags: featured
highlight_style: tertiary_accent
highlight_intensity: medium
show_highlight_incard_accents: true
```
Result: Topics tagged with "featured" will have a unified highlight with border, tint, shadow, plus accented tag badges and subtle title color shift.

### Example 2: Multiple Tags with Subtle Emphasis
```
highlight_tags: featured|important|announcement
highlight_style: tertiary_accent
highlight_intensity: subtle
show_highlight_incard_accents: true
```
Result: Topics with any of these tags will have a gentle, harmonious highlight with in-card accents.

### Example 3: Strong Emphasis for Urgent Topics
```
highlight_tags: urgent|breaking
highlight_style: tertiary_accent
highlight_intensity: strong
show_highlight_incard_accents: true
```
Result: Urgent topics will have a prominent, attention-grabbing highlight with enhanced in-card styling.

### Example 4: Card-Level Highlight Only (No In-Card Accents)
```
highlight_tags: featured
highlight_style: tertiary_accent
highlight_intensity: medium
show_highlight_incard_accents: false
```
Result: Topics receive only the card-level highlight (border, tint, shadow) without tag badges or title adjustments.

## Testing Checklist

### Visual Testing
- [ ] Test on desktop list layout
- [ ] Test on desktop grid layout
- [ ] Test on mobile list layout
- [ ] Test on mobile grid layout
- [ ] Test with light color scheme
- [ ] Test with dark color scheme
- [ ] Test cards with thumbnails
- [ ] Test cards without thumbnails (placeholder icon)
- [ ] Test with in-card accents enabled
- [ ] Test with in-card accents disabled
- [ ] Verify tag badges appear only for matching tags
- [ ] Check title color shift is subtle and readable

### Interaction Testing
- [ ] Verify hover states work correctly
- [ ] Check focus states for keyboard navigation
- [ ] Ensure click/tap targets remain functional
- [ ] Test with multiple highlighted cards on same page
- [ ] Test with no highlighted cards (graceful degradation)

### Accessibility Testing
- [ ] Verify color contrast meets WCAG standards
- [ ] Check that focus outlines are visible
- [ ] Ensure no motion for users with `prefers-reduced-motion`
- [ ] Test with screen reader (highlight should not interfere)

### Edge Cases
- [ ] Topics with multiple tags (some highlighted, some not)
- [ ] Very long topic titles
- [ ] Cards in different states (pinned, closed, archived)
- [ ] Mixed highlighted and non-highlighted cards
- [ ] Empty tag configuration (should show no highlights)

## Technical Details

### Implementation

The highlight system uses:
- **Value Transformer**: Adds `.topic-card--highlight` class at render time (no DOM queries)
- **MutationObserver**: Adds `.is-highlight-tag` class to matching tags when in-card accents enabled
- **CSS Variables**: Intensity mapped to CSS custom properties
- **BEM Naming**: `.topic-card--highlight` for card-level styles
- **Discourse Variables**: Uses `var(--tertiary)` for theme compatibility
- **SPA-Safe**: Observer disconnects on route change, reconnects afterRender

### CSS Classes Applied

**Card-level highlight** (always applied when topic has highlight tag):
```
.topic-card--highlight
```

**Tag-level accent** (applied when `show_highlight_incard_accents` is enabled):
```
.discourse-tag.is-highlight-tag
```

The card class applies the unified tertiary color accent style (border, tint, shadow). The tag class applies the accented badge styling and triggers title/metadata adjustments.

### Browser Compatibility

- Uses modern CSS (`color-mix`, CSS variables)
- Graceful degradation for older browsers
- No JavaScript required for visual effects
- Works with all Discourse-supported browsers

## Troubleshooting

### Highlights Not Showing

1. **Check tag spelling**: Ensure tag names match exactly (case-sensitive)
2. **Verify setting format**: Use pipe separator `|` for multiple tags
3. **Clear cache**: Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+R)
4. **Check theme is active**: Ensure theme component is enabled

### Highlights Too Subtle

1. Increase intensity: Change from `subtle` to `medium` or `strong`
2. Check color scheme: Verify tertiary color has good contrast in your theme
3. Verify tags are correctly configured and applied to topics

### Highlights Too Aggressive

1. Decrease intensity: Change from `strong` to `medium` or `subtle`
2. Consider using fewer highlight tags to reduce visual noise
3. Ensure your theme's tertiary color is not too bright or saturated
4. Disable in-card accents if the combined effect is too much

### Tag Badges Not Showing

1. **Check setting**: Ensure `show_highlight_incard_accents` is enabled (true)
2. **Verify tags exist**: Confirm topics have the configured highlight tags
3. **Check tag visibility**: Ensure tags are displayed in your card layout
4. **Clear cache**: Hard refresh browser to reload JavaScript

### Title Color Not Changing

1. **Check setting**: Ensure `show_highlight_incard_accents` is enabled
2. **Verify contrast**: Title shift is subtle by design (18-30% tertiary mix)
3. **Test hover state**: Color shift is more noticeable on hover/focus
4. **Check theme colors**: Ensure tertiary color differs from primary

## Best Practices

### Recommended Configurations

**For General Featured Content (Recommended)**
- Style: `tertiary_accent`
- Intensity: `medium`
- Tags: `featured`

**For Subtle Emphasis**
- Style: `tertiary_accent`
- Intensity: `subtle`
- Tags: `featured|recommended`

**For Urgent/Important Content**
- Style: `tertiary_accent`
- Intensity: `strong`
- Tags: `urgent|breaking`

### Design Guidelines

1. **Don't overuse**: Limit highlighted tags to 1-3 to maintain effectiveness
2. **Be consistent**: Use the same intensity across your site
3. **Test both themes**: Verify in light and dark color schemes
4. **Consider context**: Match intensity to content importance
5. **Monitor performance**: Too many highlights reduce individual impact
6. **Tertiary color matters**: Ensure your theme's tertiary color has good contrast and visibility
7. **In-card accents**: Keep enabled for polished look; disable if you prefer minimal styling
8. **Tag badge clarity**: Ensure highlight tags are meaningful and recognizable to users

## Accessibility Considerations

- ✅ No motion/animation by default (respects user preferences)
- ✅ Maintains proper color contrast ratios
- ✅ Preserves focus indicators for keyboard navigation
- ✅ Works with screen readers (semantic HTML unchanged)
- ✅ Touch targets remain accessible on mobile

## Future Enhancements

Potential additions (not currently implemented):
- Custom highlight colors per tag (override tertiary color)
- Animation option (with reduced-motion respect)
- Badge/ribbon overlay option
- Alternative unified styles (e.g., "primary accent", "success accent")
- Per-tag intensity overrides

## Support

For issues or questions:
- GitHub: [discourse-topic-cards repository](https://github.com/discourse/discourse-topic-cards)
- Meta Discourse: [Topic Cards discussion](https://meta.discourse.org/t/discourse-topic-cards/296048)

