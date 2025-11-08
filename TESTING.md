# Testing Guide

This theme component includes two types of automated tests:

1. **QUnit Tests** (JavaScript/client-side) - Fast feedback for component logic
2. **Rails System Tests** (RSpec/Capybara) - End-to-end testing with full Discourse environment

---

## QUnit Tests (Client-Side)

### Location
- `test/javascripts/carousel-test.gjs`
- `test/javascripts/topic-cards-test.gjs`

### What They Test
- Component rendering states (loading, error, empty, success)
- ARIA attributes and accessibility
- Keyboard navigation
- Navigation controls (arrows, dots)
- Settings-driven behavior
- Featured link behavior
- BEM class structure

### How to Run

#### Option 1: Local Discourse Development Instance

1. Install the theme in your local Discourse instance:
   ```bash
   discourse_theme watch .
   ```

2. Navigate to the theme QUnit test route:
   ```
   http://localhost:3000/theme-qunit
   ```

3. The test runner will execute all theme tests and display results.

#### Option 2: Production/Staging Instance

1. Install the theme on your Discourse instance (Admin → Customize → Themes)

2. Navigate to:
   ```
   https://your-discourse-site.com/theme-qunit
   ```

### Test Structure

Tests use:
- **QUnit** - Test framework
- **@ember/test-helpers** - Rendering and DOM utilities
- **Pretender** - API mocking
- **data-test attributes** - Stable selectors (e.g., `[data-test-prev]`, `[data-test-next]`)

Example:
```javascript
test("displays navigation arrows", async function (assert) {
  await render(hbs`<TopicCardsCarousel />`);
  await waitFor("[data-test-prev]", { timeout: 2000 });

  assert.dom("[data-test-prev]").exists();
  assert.dom("[data-test-next]").exists();
});
```

---

## Rails System Tests (End-to-End)

### Location
- `spec/system/carousel_spec.rb`

### What They Test
- Full page rendering with theme installed
- Route gating (home, latest, top, categories)
- Theme settings integration
- User interactions (clicks, keyboard navigation)
- Accessibility in real browser environment

### Prerequisites

1. **Install Discourse Theme CLI**:
   ```bash
   gem install discourse_theme
   ```

2. **Ensure Ruby ≥ 2.7** (recommended: 3.3.9):
   ```bash
   ruby --version
   ```

### How to Run

#### Run All System Tests

```bash
discourse_theme rspec .
```

On first run, you'll be prompted:
```
Do you have a local Discourse development environment? (Y/n)
```

- **Recommended for most users**: Press `n` to use Docker
  - Automatically sets up a Discourse environment
  - No manual configuration needed
  - Slower initial setup, but reliable

- **For experienced developers**: Press `Y` if you have a local Discourse dev setup
  - Faster test runs
  - Requires existing Discourse development environment

#### Run Specific Test File

```bash
discourse_theme rspec spec/system/carousel_spec.rb
```

#### Run Specific Test (by line number)

```bash
discourse_theme rspec spec/system/carousel_spec.rb:18
```

#### Headful Mode (Visual Debugging)

Watch tests run in a real browser:

```bash
discourse_theme rspec . --headful
```

Useful for:
- Debugging test failures
- Seeing actual UI behavior
- Inspecting element states

#### Pause Test Execution

Add `pause_test` in your test to inspect the page:

```ruby
it "displays the carousel" do
  visit "/"
  pause_test  # Browser will pause here
  expect(page).to have_css(".topic-cards-carousel")
end
```

### Test Structure

Tests use:
- **RSpec** - Test framework
- **Capybara** - Browser automation
- **Fabrication** - Test data creation
- **upload_theme_component** - Theme installation helper

Example:
```ruby
RSpec.describe "Carousel", system: true do
  let!(:theme) { upload_theme_component }

  before do
    theme.update_setting(:carousel_display_location, "home")
    theme.save!
  end

  it "renders on home page" do
    visit "/"
    expect(page).to have_css(".topic-cards-carousel", wait: 5)
  end
end
```

### Available Helpers

- `upload_theme_component` - Install theme component
- `Fabricate(:topic)` - Create test topics
- `Fabricate(:user)` - Create test users
- `sign_in(user)` - Authenticate as user
- `theme.update_setting(:key, value)` - Change theme settings
- `visit("/path")` - Navigate to page
- `expect(page).to have_css(selector)` - Assert element exists

---

## Continuous Integration (CI)

### GitHub Actions Example

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  system-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3.9
          bundler-cache: true

      - name: Install Discourse Theme CLI
        run: gem install discourse_theme

      - name: Run System Tests
        run: discourse_theme rspec .
```

**Note**: System tests require a Discourse instance, so CI runs use Docker (slower but reliable).

---

## Writing New Tests

### QUnit Test Template

```javascript
import { module, test } from "qunit";
import { render, waitFor } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";

module("Component | topic-cards-carousel", function (hooks) {
  setupRenderingTest(hooks);

  test("your test name", async function (assert) {
    await render(hbs`<TopicCardsCarousel />`);
    await waitFor("[data-test-prev]", { timeout: 2000 });

    assert.dom(".topic-cards-carousel").exists();
  });
});
```

### System Test Template

```ruby
RSpec.describe "Feature Name", system: true do
  let!(:theme) { upload_theme_component }

  before do
    theme.update_setting(:some_setting, "value")
    theme.save!
  end

  it "does something" do
    visit "/"
    expect(page).to have_css(".some-element", wait: 5)
  end
end
```

---

## Troubleshooting

### QUnit Tests

**Tests not appearing**:
- Ensure theme is installed and active
- Check browser console for errors
- Verify test file is in `test/javascripts/`

**Tests failing**:
- Check data-test attributes match component markup
- Verify API mocks return expected data
- Use browser DevTools to inspect DOM

### System Tests

**Docker setup fails**:
- Ensure Docker is installed and running
- Check disk space (Docker images are large)
- Try `docker system prune` to free space

**Tests timeout**:
- Increase wait time: `expect(page).to have_css(".selector", wait: 10)`
- Use `pause_test` to inspect state
- Run with `--headful` to see what's happening

**Theme not loading**:
- Verify `upload_theme_component` is called
- Check theme settings are saved: `theme.save!`
- Ensure Discourse version compatibility

---

## Best Practices

### QUnit
- Use `data-test` attributes for stable selectors
- Mock external dependencies (API calls, libraries)
- Test one behavior per test
- Use descriptive test names

### System Tests
- Use `wait: 5` for dynamic content
- Fabricate minimal test data
- Clean up state between tests
- Test user-facing behavior, not implementation

### Both
- Keep tests fast and focused
- Test edge cases (empty states, errors)
- Maintain accessibility tests
- Update tests when markup changes

---

## Resources

- [Discourse Theme Testing Guide](https://meta.discourse.org/t/end-to-end-system-testing-for-themes-and-theme-components/281579)
- [QUnit Documentation](https://qunitjs.com/)
- [RSpec Documentation](https://rspec.info/)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [Discourse Theme CLI](https://github.com/discourse/discourse_theme)

---

## Manual Testing Checklist

### Prerequisites

1. Start Discourse with theme CLI watch mode:
   ```bash
   discourse_theme watch .
   ```

2. Ensure theme is active in Admin → Customize → Themes

3. Configure carousel and card settings in theme settings

---

### Carousel Testing

#### Display & Route Gating

**Setup:**
- Set `carousel_display_location` to "home"
- Configure `carousel_max_items` to 5

**Verify:**
- [ ] Carousel appears on `/latest`
- [ ] Carousel appears on `/top`
- [ ] Carousel appears on `/categories`
- [ ] Carousel does not appear when `carousel_display_location` is "disabled"
- [ ] Carousel respects `carousel_plugin_outlet` setting

#### Navigation Controls

**Verify:**
- [ ] Previous/Next arrows appear
- [ ] Arrows have proper ARIA labels
- [ ] Arrows are keyboard accessible (Tab, Enter, Space)
- [ ] Pagination dots appear when enabled
- [ ] Clicking dots navigates to correct slide
- [ ] Arrow buttons disable/enable based on `carousel_loop` setting

#### Embla Options

**Test each setting:**
- [ ] `carousel_loop`: true enables infinite looping
- [ ] `carousel_loop`: false stops at first/last slide
- [ ] `carousel_align`: "start" aligns slides to left
- [ ] `carousel_align`: "center" centers active slide
- [ ] `carousel_drag_free`: true enables free-scroll dragging
- [ ] `carousel_drag_free`: false snaps slides to positions
- [ ] `carousel_speed`: "slow" has leisurely transitions
- [ ] `carousel_speed`: "normal" has balanced transitions
- [ ] `carousel_speed`: "fast" has snappy transitions
- [ ] `carousel_scroll_by`: "1" scrolls one slide at a time
- [ ] `carousel_scroll_by`: "page" scrolls full viewport

#### Responsive Behavior

**Verify:**
- [ ] Desktop: Grid layout with multiple slides per view
- [ ] Tablet: Fewer slides per view
- [ ] Mobile: List layout (one slide per view)
- [ ] Peek gradients appear when slides overflow
- [ ] Slides resize smoothly on viewport change

---

### Card Layouts - List Style

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
- [ ] Hover states work (card border, title underline)

---

### Card Layouts - Grid Style

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

