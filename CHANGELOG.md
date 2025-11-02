# Changelog

All notable changes to the Topic Cards theme component will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-XX

### Major Refactor - Data-Driven Rendering

This release represents a complete architectural refactor to align with modern Discourse theme development best practices and improve maintainability, performance, and SPA compatibility.

### Changed

#### Architecture
- **Removed all MutationObserver-based DOM surgery** - Eliminated brittle post-render DOM manipulation in favor of CSS-based solutions and data-driven rendering
- **Removed `schedule("afterRender")` patterns** - No longer rely on timing-dependent DOM manipulation
- **CSS-based featured link suppression** - Inline featured links in card mode are now hidden via CSS instead of removed via JavaScript
- **Idempotent rendering** - All components now render consistently regardless of SPA navigation patterns

#### Component Structure
- **BEM naming normalization** - Replaced ad-hoc class names (e.g., `right-aligned`) with proper BEM variants (e.g., `topic-card__metadata-items`)
- **Component documentation** - Added comprehensive JSDoc comments to all components explaining structure, BEM hierarchy, and accessibility features
- **Initializer documentation** - Added detailed header comments explaining component rendering order, CSS classes, and key features

#### Code Quality
- **Reduced code size** - Removed 149 lines of DOM surgery code across both initializers
- **Improved maintainability** - Single source of truth for styling (CSS), not duplicated logic
- **Better SPA compatibility** - No observers to disconnect, no timing issues, no re-render bugs

### Added

#### Documentation
- **KNOWN_ISSUES.md** - Documents the `&nbsp;` text node cosmetic issue and planned fixes
- **TESTING.md** - Comprehensive manual and automated testing guide with checklists
- **CHANGELOG.md** - This file, documenting all changes

#### Tests
- **Component rendering tests** - Verify BEM classes and proper rendering
- **Featured link behavior tests** - Ensure CTA buttons work correctly
- **Accessibility tests** - Verify ARIA labels and keyboard navigation
- **Regression tests** - Ensure classic lists remain unaffected

#### Features
- **Improved accessibility** - All action buttons now have proper ARIA labels
- **Better plugin outlet compatibility** - Explicitly preserves `topic-list-after-title` and other title-row outlets
- **Portfolio route parity** - Portfolio cards now use the same clean architecture as category cards

### Fixed

- **SPA navigation bugs** - Eliminated observer-related issues during route changes
- **Memory leaks** - No more orphaned observers or event listeners
- **Timing issues** - No more race conditions with `afterRender` scheduling
- **Duplicate processing** - Eliminated redundant DOM surgery on re-renders

### Technical Details

#### Files Modified

**Removed Code:**
- `javascripts/discourse/api-initializers/discourse-topic-list-cards.gjs` (-74 lines)
- `javascripts/discourse/api-initializers/portfolio-topic-cards.gjs` (-75 lines)

**Added Code:**
- `common/common.scss` (+28 lines for CSS-based suppression)
- Component documentation (+60 lines across all components)
- Test suite (+150 lines)

**Net Change:** -121 lines of production code

#### Migration Notes

**For Theme Developers:**
- If you were relying on the `processLinkTopLines()` function, it has been removed
- Featured link suppression is now handled via CSS (`.topic-cards-list .link-top-line a.topic-featured-link { display: none; }`)
- All components now use proper BEM naming - update any custom CSS that relied on old class names

**For Site Admins:**
- No configuration changes required
- All existing theme settings continue to work
- No breaking changes to user-facing features

### Known Issues

- **`&nbsp;` text node** - A non-breaking space text node still exists in the DOM before the featured link area in card mode, despite CSS suppression. This is cosmetic only and does not affect functionality. See KNOWN_ISSUES.md for details.

### Upgrade Path

1. Update theme to v2.0.0
2. Clear browser cache
3. Run automated tests: `pnpm test`
4. Follow manual testing checklist in TESTING.md
5. Verify no console errors
6. Check that cards render correctly in all configured categories

### Performance Improvements

- **Eliminated MutationObserver overhead** - No more continuous DOM monitoring
- **Reduced JavaScript execution** - 149 fewer lines of code to execute
- **Faster page loads** - No post-render DOM manipulation delays
- **Better SPA performance** - No observer disconnect/reconnect on route changes

### Accessibility Improvements

- All action buttons have descriptive ARIA labels
- Featured link button announces destination domain
- Details button announces action
- Keyboard navigation fully supported
- Focus states clearly visible

### Browser Compatibility

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest, macOS/iOS)
- Mobile browsers (iOS Safari, Chrome Mobile)

### Minimum Requirements

- Discourse 3.2.0 or higher
- Glimmer topic list mode enabled (default in Discourse 3.2+)

---

## [1.x.x] - Previous Versions

See Git history for changes prior to the v2.0.0 refactor.

---

## Versioning Strategy

- **Major version (2.x.x)** - Breaking changes, architectural refactors
- **Minor version (x.1.x)** - New features, non-breaking changes
- **Patch version (x.x.1)** - Bug fixes, documentation updates

