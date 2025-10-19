# SCSS Styling Guidelines

## Intent

Write maintainable, themeable SCSS for Discourse themes using BEM naming, CSS custom properties, and responsive design patterns.

---

## 1. BEM Naming Convention

### Structure

```scss
.block {
  &__element {
    // Element styles
  }
  
  &--modifier {
    // Modifier styles
  }
  
  &__element--modifier {
    // Element with modifier
  }
}
```

### Example

```scss
.featured-topics {
  &__wrapper {
    padding: 1rem;
  }
  
  &__container {
    display: grid;
    gap: 1rem;
  }
  
  &__topic {
    background: var(--primary-very-low);
    
    &--pinned {
      border-left: 3px solid var(--tertiary);
    }
  }
  
  &__title {
    font-size: 1.2rem;
    color: var(--primary);
  }
}
```

---

## 2. Discourse Variables

### Color Variables

```scss
.my-component {
  // Primary colors
  color: var(--primary);
  background: var(--secondary);
  
  // Shades
  border-color: var(--primary-low);
  background: var(--primary-very-low);
  
  // Semantic colors
  color: var(--tertiary);      // Links, highlights
  color: var(--quaternary);    // Muted text
  color: var(--danger);        // Errors, warnings
  color: var(--success);       // Success states
  color: var(--love);          // Likes, favorites
}
```

### Common Variables

```scss
.my-component {
  // Typography
  font-family: var(--font-family);
  font-size: var(--font-0);  // Base size
  line-height: var(--line-height-medium);
  
  // Spacing
  padding: var(--space-2);
  margin: var(--space-4);
  
  // Borders
  border-radius: var(--border-radius);
  border: 1px solid var(--primary-low);
}
```

---

## 3. Responsive Design

### Breakpoints

```scss
.my-component {
  // Mobile-first approach
  display: block;
  
  // Tablet and up
  @media (min-width: 768px) {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
  }
  
  // Desktop and up
  @media (min-width: 1024px) {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### Mobile-Specific Styles

```scss
// mobile/mobile.scss
.featured-topics {
  &__container {
    grid-template-columns: 1fr;
  }
  
  &__topic {
    padding: 0.5rem;
  }
}
```

---

## 4. Theme Settings in SCSS

Settings from `settings.yml` are available in SCSS (kebab-case):

```yaml
# settings.yml
banner_padding:
  type: integer
  default: 20

enable_shadows:
  type: bool
  default: true
```

```scss
.banner {
  padding: #{$banner-padding}px;
  
  @if $enable-shadows {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
}
```

---

## 5. Layout Patterns

### Grid Layout

```scss
.featured-topics {
  &__container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: var(--space-4);
  }
}
```

### Flexbox Layout

```scss
.topic-meta {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  
  &__avatar {
    flex-shrink: 0;
  }
  
  &__details {
    flex: 1;
    min-width: 0; // Allow text truncation
  }
}
```

---

## 6. Common Patterns

### Card Component

```scss
.card {
  background: var(--secondary);
  border: 1px solid var(--primary-low);
  border-radius: var(--border-radius);
  padding: var(--space-4);
  transition: box-shadow 0.2s;
  
  &:hover {
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }
}
```

### Truncated Text

```scss
.topic-title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  
  // Multi-line truncation
  &--multiline {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    white-space: normal;
  }
}
```

### Loading State

```scss
.loading {
  position: relative;
  pointer-events: none;
  opacity: 0.6;
  
  &::after {
    content: "";
    position: absolute;
    top: 50%;
    left: 50%;
    width: 20px;
    height: 20px;
    margin: -10px 0 0 -10px;
    border: 2px solid var(--tertiary);
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
  }
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

---

## Best Practices

### ✅ Do

- Use BEM naming convention
- Use CSS custom properties (var(--name))
- Use Discourse color variables
- Write mobile-first responsive styles
- Use semantic spacing variables
- Leverage theme settings in SCSS
- Keep specificity low
- Use transitions for smooth interactions

### ❌ Don't

- Use hardcoded colors (use variables)
- Use `!important` (except rare cases)
- Use deep nesting (max 3 levels)
- Use pixel values for spacing (use variables)
- Override core Discourse styles unnecessarily
- Use vendor prefixes (autoprefixer handles this)

---

## Complete Example

```scss
// stylesheets/featured-topics.scss
.featured-topics {
  &__wrapper {
    padding: var(--space-4);
  }
  
  &__container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: var(--space-4);
    
    @media (max-width: 767px) {
      grid-template-columns: 1fr;
    }
  }
  
  &__topic {
    background: var(--secondary);
    border: 1px solid var(--primary-low);
    border-radius: var(--border-radius);
    padding: var(--space-3);
    transition: transform 0.2s, box-shadow 0.2s;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    &--featured {
      border-left: 3px solid var(--tertiary);
    }
  }
  
  &__thumbnail {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: var(--border-radius);
    margin-bottom: var(--space-2);
  }
  
  &__title {
    font-size: var(--font-up-1);
    color: var(--primary);
    margin-bottom: var(--space-1);
    
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  
  &__excerpt {
    color: var(--primary-medium);
    font-size: var(--font-down-1);
    line-height: var(--line-height-medium);
    
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  
  &__meta {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin-top: var(--space-2);
    padding-top: var(--space-2);
    border-top: 1px solid var(--primary-low);
  }
}
```

---

## References

- [Discourse SCSS Variables](https://github.com/discourse/discourse/blob/main/app/assets/stylesheets/common/foundation/variables.scss)
- [CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/--*)
- [BEM Methodology](http://getbem.com/)

