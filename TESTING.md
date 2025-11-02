# Testing Guide - Topic Cards Refactor

## Automated Tests

### Running Tests

```bash
# Run all tests
pnpm test

# Run specific test file
pnpm test test/javascripts/topic-cards-test.gjs
```

### Test Coverage

The automated test suite covers:

1. **Component Rendering**
   - ✅ TopicExcerpt renders with BEM classes
   - ✅ TopicTagsInline renders category and tags
   - ✅ TopicByline renders author with BEM classes
   - ✅ TopicMetadata uses BEM-compliant classes (not `right-aligned`)

2. **Featured Link Behavior**
   - ✅ TopicActionButtons renders when featured link exists
   - ✅ TopicActionButtons does not render when no featured link
   - ✅ Featured link button has correct href, target, and rel attributes

3. **Accessibility**
   - ✅ TopicActionButtons has proper ARIA labels
   - ✅ Featured link button opens in new tab with security attributes

---

## Manual Testing Checklist

### Prerequisites

1. Start Discourse with theme CLI watch mode:
   ```bash
   discourse_theme watch .
   ```

2. Ensure theme is active in Admin → Customize → Themes

3. Configure at least one category to use cards:
   - Admin → Settings → Theme Settings
   - Set `list_view_categories` or `grid_view_categories`

---

### Test Scenarios

#### 1. Card Layouts - List Style

**Setup:**
- Navigate to a category configured for list-style cards
- Ensure some topics have featured links

**Verify:**
- [ ] Cards render in vertical list layout
- [ ] Each card has proper spacing and borders
- [ ] Thumbnails display correctly (or placeholder if no image)
- [ ] Title is limited to 2 lines with ellipsis
- [ ] Excerpt is limited to 3 lines with ellipsis
- [ ] Tags appear before excerpt (not after)
- [ ] Category badge and tags render inline
- [ ] Author avatar and username display
- [ ] Publish date shows (if enabled in settings)
- [ ] Metadata items (views, likes, replies) display correctly
- [ ] Featured link CTA button appears for topics with featured links
- [ ] Details button appears for topics with featured links
- [ ] No visible `&nbsp;` or extra spacing in title area
- [ ] Hover states work (card border, title underline)

**Known Issue:**
- `&nbsp;` text node may exist in DOM but should not be visible

---

#### 2. Card Layouts - Grid Style

**Setup:**
- Navigate to a category configured for grid-style cards
- Resize browser to desktop width (>1024px)

**Verify:**
- [ ] Cards render in grid layout (multiple columns)
- [ ] Grid adapts to viewport width
- [ ] All card content from list style test applies
- [ ] Cards have equal heights in each row
- [ ] Thumbnails maintain aspect ratio

---

#### 3. Classic Lists (Regression Test)

**Setup:**
- Navigate to a category NOT configured for cards
- Or disable cards globally in theme settings

**Verify:**
- [ ] Standard Discourse topic list renders
- [ ] No card-specific classes applied
- [ ] Inline featured link appears next to title (if topic has featured link)
- [ ] Proper spacing between title and featured link (CSS-based, not text node)
- [ ] No layout regressions
- [ ] No console errors

---

#### 4. Mobile Responsive

**Setup:**
- Resize browser to mobile width (<768px)
- Or use browser DevTools device emulation

**Verify:**
- [ ] Cards stack vertically (single column)
- [ ] Thumbnails scale appropriately
- [ ] Text remains readable
- [ ] Buttons are touch-friendly
- [ ] No horizontal scrolling
- [ ] Mobile-specific card style applies (if configured)

---

#### 5. Portfolio Route

**Setup:**
- Navigate to a user's portfolio page (e.g., `/u/username/portfolio`)
- Ensure `portfolio_topic_cards_style` is set to "list" or "grid"

**Verify:**
- [ ] Cards render on portfolio route
- [ ] Same card behavior as category lists
- [ ] No observers or DOM surgery (check console)
- [ ] Featured link suppression works

---

#### 6. Featured Link Behavior

**Setup:**
- Find or create a topic with a featured link
- View in both card and classic list modes

**Card Mode:**
- [ ] Inline featured link (next to title) is hidden
- [ ] Featured link CTA button appears in actions section
- [ ] CTA button has proper label and ARIA attributes
- [ ] Clicking CTA opens link in new tab
- [ ] Details button navigates to topic

**Classic Mode:**
- [ ] Inline featured link appears next to title
- [ ] Link has proper spacing (CSS margin, not text node)
- [ ] Clicking link opens in new tab

---

#### 7. Plugin Outlet Compatibility

**Setup:**
- If you have theme components that use `topic-list-after-title` outlet
- Or install a test component that renders in title area

**Verify:**
- [ ] Outlet content renders in card mode
- [ ] Outlet content renders in classic mode
- [ ] Outlet content is not hidden or obscured
- [ ] Outlet content maintains proper spacing

**If no outlets in use:**
- [ ] Visual inspection shows no regressions in title area

---

#### 8. Performance & Console

**Verify:**
- [ ] No console errors
- [ ] No console warnings
- [ ] No MutationObserver-related messages
- [ ] Page load is smooth
- [ ] Navigation between routes is smooth
- [ ] No memory leaks (check DevTools Performance tab)

---

#### 9. Accessibility

**Setup:**
- Use keyboard navigation (Tab, Enter, Space)
- Use screen reader (optional)

**Verify:**
- [ ] Cards are keyboard-navigable
- [ ] Focus states are visible
- [ ] Buttons have proper ARIA labels
- [ ] Featured link button announces destination
- [ ] Details button announces action
- [ ] No accessibility warnings in DevTools

---

#### 10. Cross-Browser Testing

**Test in:**
- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest, macOS/iOS)

**Verify:**
- [ ] Cards render consistently
- [ ] CSS grid/flexbox works
- [ ] Hover states work
- [ ] No browser-specific issues

---

## Debugging Tips

### Check for `&nbsp;` Text Node

1. Open DevTools → Elements
2. Find `.topic-card .link-top-line`
3. Expand the element tree
4. Look for text nodes before `a.topic-featured-link`
5. The anchor should have `display: none` in card mode

### Verify CSS Suppression

1. Open DevTools → Elements
2. Select `.topic-cards-list .link-top-line a.topic-featured-link`
3. Check Computed styles
4. Should show `display: none`

### Check for Observers

1. Open DevTools → Console
2. Type: `window.performance.getEntriesByType('measure')`
3. Should not see MutationObserver-related entries from this theme

### Verify BEM Classes

1. Inspect `.topic-card__metadata`
2. Should contain `.topic-card__metadata-items`
3. Should NOT contain `.right-aligned`

---

## Expected Results Summary

### ✅ Working Correctly

- Card layouts render in list and grid styles
- Components use BEM naming consistently
- Featured link CTA buttons work
- No MutationObservers running
- No post-render DOM surgery
- Accessibility features present
- Mobile responsive
- Portfolio route works

### ⚠️ Known Issues

- `&nbsp;` text node exists in DOM but is not visible (cosmetic only)
- See KNOWN_ISSUES.md for details

### ❌ Failures Requiring Attention

- Any console errors
- Missing components
- Broken layouts
- Non-functional buttons
- Accessibility violations

---

## Reporting Issues

When reporting issues, include:

1. **Environment:**
   - Discourse version
   - Browser and version
   - Device/viewport size

2. **Steps to reproduce:**
   - Exact navigation path
   - Theme settings configuration
   - Category configuration

3. **Expected vs Actual:**
   - What should happen
   - What actually happens
   - Screenshots/videos if applicable

4. **Console output:**
   - Any errors or warnings
   - Network tab issues

5. **DOM inspection:**
   - Relevant HTML structure
   - Applied CSS classes
   - Computed styles

