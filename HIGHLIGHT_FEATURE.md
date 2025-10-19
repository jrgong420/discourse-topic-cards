# Topic Card Highlight System

## Overview

The highlight system allows you to visually emphasize topic cards that have specific tags, making them stand out to increase visibility and click-through rates.

## Features

### Three Visual Styles

1. **Border** (Default)
   - Colored accent border using theme's tertiary color
   - Soft outer glow/ring effect
   - Best balance between prominence and harmony
   - Works well in both light and dark color schemes

2. **Background**
   - Subtle background tint
   - Light border accent
   - Most harmonious with existing design
   - Minimal visual disruption

3. **Elevation**
   - Deeper drop shadow
   - Slight visual lift effect
   - Non-color dependent prominence
   - Great for creating depth hierarchy

### Three Intensity Levels

- **Subtle**: Minimal visual change, gentle emphasis
- **Medium**: Balanced prominence (recommended default)
- **Strong**: Maximum attention-grabbing effect

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
- **Default**: `border`
- **Options**: 
  - `border` - Accent border with glow
  - `background` - Subtle background tint
  - `elevation` - Shadow depth emphasis
- **Recommendation**: Start with `border` for best visibility

#### `highlight_intensity`
- **Type**: Dropdown
- **Default**: `medium`
- **Options**:
  - `subtle` - Minimal effect
  - `medium` - Balanced (recommended)
  - `strong` - Maximum prominence
- **Recommendation**: Use `medium` for most cases, `strong` for campaigns

## Usage Examples

### Example 1: Highlight Featured Content
```
highlight_tags: featured
highlight_style: border
highlight_intensity: medium
```
Result: Topics tagged with "featured" will have a colored border with a soft glow.

### Example 2: Multiple Tags with Background Tint
```
highlight_tags: featured|important|announcement
highlight_style: background
highlight_intensity: subtle
```
Result: Topics with any of these tags will have a subtle background tint.

### Example 3: Strong Emphasis for Urgent Topics
```
highlight_tags: urgent|breaking
highlight_style: elevation
highlight_intensity: strong
```
Result: Urgent topics will have a prominent shadow effect.

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
- **Value Transformer**: Adds classes at render time (no DOM queries)
- **CSS Variables**: Intensity mapped to CSS custom properties
- **BEM Naming**: `.topic-card--highlight` with style modifiers
- **Discourse Variables**: Uses `var(--tertiary)` for theme compatibility

### CSS Classes Applied

When a topic has a highlight tag:
```
.topic-card--highlight
.topic-card--highlight--{style}
```

Examples:
- `.topic-card--highlight.topic-card--highlight--border`
- `.topic-card--highlight.topic-card--highlight--background`
- `.topic-card--highlight.topic-card--highlight--elevation`

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
2. Try different style: `border` is more prominent than `background`
3. Check color scheme: Some styles work better in light vs dark mode

### Highlights Too Aggressive

1. Decrease intensity: Change from `strong` to `medium` or `subtle`
2. Try different style: `background` is more subtle than `border`
3. Consider using fewer highlight tags

## Best Practices

### Recommended Configurations

**For General Featured Content**
- Style: `border`
- Intensity: `medium`
- Tags: `featured`

**For Subtle Emphasis**
- Style: `background`
- Intensity: `subtle`
- Tags: `featured|recommended`

**For Urgent/Important Content**
- Style: `elevation`
- Intensity: `strong`
- Tags: `urgent|breaking`

### Design Guidelines

1. **Don't overuse**: Limit highlighted tags to 1-3 to maintain effectiveness
2. **Be consistent**: Use the same style/intensity across your site
3. **Test both themes**: Verify in light and dark color schemes
4. **Consider context**: Match intensity to content importance
5. **Monitor performance**: Too many highlights reduce individual impact

## Accessibility Considerations

- ✅ No motion/animation by default (respects user preferences)
- ✅ Maintains proper color contrast ratios
- ✅ Preserves focus indicators for keyboard navigation
- ✅ Works with screen readers (semantic HTML unchanged)
- ✅ Touch targets remain accessible on mobile

## Future Enhancements

Potential additions (not currently implemented):
- Custom highlight colors per tag
- Animation option (with reduced-motion respect)
- Badge/ribbon overlay option
- Gradient background option
- Multiple style combinations

## Support

For issues or questions:
- GitHub: [discourse-topic-cards repository](https://github.com/discourse/discourse-topic-cards)
- Meta Discourse: [Topic Cards discussion](https://meta.discourse.org/t/discourse-topic-cards/296048)

