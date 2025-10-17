# Topic Cards - Core Style Alignment

## Summary

This document outlines the changes made to align the `discourse-topic-cards` theme component with Discourse's core design tokens, CSS variables, and theming best practices.

## Branch

`feat/core-style`

## Changes Made

### 1. Scoped CSS Variable Overrides

**Before:**
```scss
:root {
  --d-border-radius-large: 20px;
}
```

**After:**
```scss
.topic-cards-list {
  // Scope border-radius override to this component only
  --d-border-radius-large: 20px;
}
```

**Rationale:** Following Discourse best practices, CSS variable overrides should be scoped to the component wrapper rather than globally at `:root` to avoid affecting the entire site.

### 2. Spacing Tokens

Replaced all hardcoded spacing values with Discourse spacing tokens:

| Before | After | Usage |
|--------|-------|-------|
| `1.5rem` | `var(--space-6)` | List margin-top |
| `1em` | `var(--space-4)` | List body gap |
| `1.5rem` | `var(--space-6)` | Card gap |
| `1rem 1.5rem 1rem 0` | `var(--space-4) var(--space-6) var(--space-4) 0` | Main link padding |
| `0.75rem` | `var(--space-3)` | Link bottom margin |
| `20px` | `var(--space-4)` | Item margin-left |
| `0.5rem 1rem` | `var(--space-2) var(--space-4)` | Excerpt margin-block |
| `0.75rem` | `var(--space-3)` | Mobile padding |
| `1rem` | `var(--space-4)` | Mobile thumbnail margin |

### 3. Typography Tokens

Replaced custom font size variables with core typography tokens:

| Before | After | Element |
|--------|-------|---------|
| `--font-down-1-rem` | `var(--font-down-1)` | OP, metadata, publish date |
| `bold` | `var(--topic-title-font-weight)` | Title font-weight |
| N/A | `var(--topic-title-font-weight--visited)` | Visited title font-weight |

### 4. Color Tokens

Applied Discourse core color tokens for semantic consistency:

| Token | Usage |
|-------|-------|
| `var(--title-color)` | Topic title default color |
| `var(--title-color--read)` | Visited topic title color |
| `var(--excerpt-color)` | Excerpt text color |
| `var(--metadata-color)` | Metadata (author, date, counts) color |
| `var(--secondary)` | Card background (already used) |
| `var(--primary-low)` | Card hover border (already used) |
| `var(--quaternary)` | Selected title (already used) |
| `var(--primary-medium)` | Icon colors (already used) |
| `var(--love)`, `var(--love-low)` | Like button (already used) |

### 5. Line Height Tokens

Replaced hardcoded line heights with core tokens:

| Before | After | Element |
|--------|-------|---------|
| `1.4em` | `var(--line-height-large)` | Title line-height |
| `1.1em` | `var(--line-height-large)` | Excerpt line-height |
| N/A | `var(--line-height-large)` | Link bottom line, metadata |

### 6. Visited State Styling

Added proper visited state handling matching core behavior:

```scss
.title.visited:not(.badge-notification) {
  color: var(--title-color--read);
  font-weight: var(--topic-title-font-weight--visited);
}
```

### 7. Tag Spacing Alignment

Aligned tag spacing with core `.link-bottom-line` patterns:

```scss
.link-bottom-line {
  gap: 0 var(--space-2);
  line-height: var(--line-height-large);
  
  .discourse-tag.box {
    margin-right: var(--space-1);
  }
}
```

### 8. Metadata Consistency

Added consistent spacing and color to metadata elements:

```scss
&__metadata {
  gap: 0 var(--space-2);
  line-height: var(--line-height-large);
  
  .number,
  .d-icon,
  .activity a {
    font-size: var(--font-down-1);
    color: var(--metadata-color);
  }
}
```

## Benefits

1. **Automatic Dark Mode Support**: By using CSS custom properties instead of SCSS variables, the component now automatically adapts to dark mode color scheme switching.

2. **Consistent Typography**: Font sizes, weights, and line heights now match the default Discourse theme, ensuring visual consistency.

3. **Responsive Spacing**: Spacing tokens ensure consistent spacing across the component and with other Discourse UI elements.

4. **Theme Compatibility**: The component will now respect custom color schemes and theme modifications applied at the site level.

5. **Maintainability**: Using core tokens means the component will automatically benefit from future Discourse design system improvements.

6. **Accessibility**: Core tokens include accessibility considerations built into Discourse's design system.

## Testing Checklist

- [ ] Visual verification in light mode
- [ ] Visual verification in dark mode
- [ ] Visual verification with custom color schemes
- [ ] Desktop responsive layout
- [ ] Mobile responsive layout
- [ ] Tablet responsive layout
- [ ] Topic title visited state
- [ ] Tag spacing and alignment
- [ ] Metadata spacing and colors
- [ ] Excerpt text rendering
- [ ] Integration with /styleguide
- [ ] No global CSS leakage (scoped overrides)

## Files Modified

- `common/common.scss` - Main component styles
- `mobile/mobile.scss` - Mobile-specific overrides

## Commit

```
feat: align topic-cards styles with Discourse core design tokens

- Scope --d-border-radius-large override to .topic-cards-list wrapper instead of global :root
- Replace hardcoded spacing values with Discourse spacing tokens (--space-*)
- Replace hardcoded font sizes with core typography tokens (--font-down-1, --font-0)
- Use core color tokens for titles (--title-color, --title-color--read)
- Use core color tokens for excerpts (--excerpt-color) and metadata (--metadata-color)
- Apply core font-weight tokens (--topic-title-font-weight, --topic-title-font-weight--visited)
- Use core line-height tokens (--line-height-large, --line-height-medium)
- Add visited state styling for topic titles matching core behavior
- Align tag spacing with core .link-bottom-line patterns
- Update mobile styles to use spacing tokens consistently

This ensures the component integrates seamlessly with Discourse's default theme,
supports automatic dark mode switching, and follows Discourse theming best practices.
```

## References

- [Developing Discourse Themes & Theme Components](https://meta.discourse.org/t/developing-discourse-themes-theme-components/93648)
- [Update themes and plugins to support automatic dark mode](https://meta.discourse.org/t/update-themes-and-plugins-to-support-automatic-dark-mode/161595)
- [Structure of themes and theme components](https://meta.discourse.org/t/structure-of-themes-and-theme-components/60848)
- [Styleguide Plugin Now in Discourse Core](https://meta.discourse.org/t/styleguide-plugin-now-in-discourse-core/167293)
- [Override border-radius variables with theme](https://meta.discourse.org/t/override-border-radius-variables-with-theme/246574)

## Next Steps

1. Deploy to a test Discourse instance
2. Enable the styleguide (`/admin/site_settings/category/all_results?filter=styleguide`)
3. Visit `/styleguide` to compare component styling with core elements
4. Test with multiple color schemes (light, dark, custom)
5. Test responsive behavior on mobile, tablet, and desktop
6. Gather user feedback
7. Iterate on spacing/sizing if needed (minimal adjustments only)

