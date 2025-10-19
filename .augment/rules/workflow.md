# Development Workflow and Compatibility

## Intent

Set up efficient local development with Discourse Theme CLI and stay compatible with current/future Discourse versions.

---

## 1. Development Setup

### Prerequisites

- **Ruby** ≥ 2.7 (recommended: 3.3.9 via rbenv)
- **Node.js** ≥ 22 (recommended: 22.x via fnm/nvm)
- **pnpm** (via Corepack: `corepack enable`)
- **Discourse Theme CLI**: `gem install discourse_theme`
- **Discourse instance** (local dev or staging with admin access)

### Initial Setup

```bash
# Install Theme CLI
gem install discourse_theme

# Clone/create theme
git clone <repo-url>
cd my-theme

# Install dependencies
pnpm install

# Configure Theme CLI
discourse_theme watch .
```

Theme CLI prompts:
1. Discourse URL (e.g., `http://localhost:3000`)
2. API key (Admin → API → New API Key)
3. Theme to sync

Configuration saved in `.discourse-site.json` (gitignored).

### Watch Mode

```bash
discourse_theme watch .
```

Auto-syncs changes to Discourse. Refresh browser to see updates.

### Project Structure

```
my-theme/
├── about.json                   # Theme metadata
├── settings.yml                 # Theme settings
├── package.json                 # Node dependencies
├── javascripts/
│   └── discourse/
│       ├── api-initializers/    # Theme initialization (.gjs)
│       └── components/          # Glimmer components (.gjs)
├── stylesheets/                 # SCSS files
├── locales/                     # Translations (en.yml, etc.)
├── common/                      # Common styles
├── mobile/                      # Mobile-specific styles
└── assets/                      # Images, fonts
```

### Useful Commands

```bash
# Watch for changes
discourse_theme watch .

# Upload theme
discourse_theme upload .

# Download theme
discourse_theme download <theme-id>

# Lint code
pnpm run lint

# Format code
pnpm run format
```

### Debugging

Enable developer toolbar in browser console:
```javascript
enableDevTools()
```

Features:
- 🔌 Plugin outlet inspector
- 📊 Performance metrics
- 🎨 Color scheme switcher

---

## 2. Version Compatibility

### 2025 Breaking Changes

#### ❌ Inline Script Tags (REMOVED - Sept 2025)

**Deprecated**: `<script type="text/discourse-plugin">`

**Migration**:
```javascript
// OLD (removed)
<script type="text/discourse-plugin" version="0.8">
  const api = require("discourse/lib/plugin-api").default;
  api.onPageChange(() => { /* ... */ });
</script>

// NEW (required)
// File: javascripts/discourse/api-initializers/init-theme.gjs
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.onPageChange(() => { /* ... */ });
});
```

**Deprecation ID**: `discourse.inline-script-tags`

---

#### ❌ Template Overrides (REMOVED - June 2025)

**Deprecated**: Overriding core templates

**Migration**: Use wrapper plugin outlets
```javascript
// OLD (removed)
// templates/components/topic-list.hbs

// NEW (required)
api.renderInOutlet("topic-list-wrapper", MyCustomComponent);
```

**Deprecation ID**: `discourse.template-overrides`

---

#### ❌ Widget System (EOL - Q4 2025)

**Deprecated**: All widget APIs

**Affected**:
- `createWidget`
- `decorateWidget`
- `changeWidgetSetting`
- `reopenWidget`
- `attachWidgetAction`
- `MountWidget`

**Migration**:
```javascript
// OLD (deprecated)
api.decorateWidget("post-contents:after-cooked", (helper) => {
  return helper.attach("my-widget", { data });
});

// NEW (required)
api.renderAfterWrapperOutlet("post-content-cooked-html",
  class extends Component {
    <template>
      <div class="my-content">{{@post.data}}</div>
    </template>
  }
);
```

**Testing**: Set `deactivate_widgets_rendering: true` in site settings

**Deprecation ID**: `discourse.widgets-end-of-life`

---

#### ⚠️ Post Stream Modernization (Active - 2025)

**Changed**: Post stream uses Glimmer components

**Migration**:
```javascript
// OLD
api.includePostAttributes("custom_field");

// NEW
api.addTrackedPostProperties("custom_field");
```

**Testing**: Set `glimmer_post_stream_mode: auto`

**Deprecation ID**: `discourse.post-stream-widget-overrides`

---

### Setting Minimum Version

```json
// about.json
{
  "name": "My Theme",
  "component": true,
  "minimum_discourse_version": "3.2.0",
  "theme_version": "2.1.0"
}
```

### Monitoring Deprecations

Check browser console:
```
DEPRECATION: discourse.widgets-end-of-life
  Widget rendering system will be removed in Q4 2025
  See: https://meta.discourse.org/t/375332
```

### Testing with Feature Flags

```
# Admin → Settings
glimmer_post_stream_mode: auto
deactivate_widgets_rendering: true
```

### Migration Checklist

**Inline Scripts → File-Based**
- [ ] Move `<script type="text/discourse-plugin">` to `.gjs` files
- [ ] Update `require()` to ES6 `import`
- [ ] Test all functionality

**Template Overrides → Wrapper Outlets**
- [ ] Identify template overrides
- [ ] Find wrapper outlets
- [ ] Create connector components
- [ ] Test rendering

**Widgets → Glimmer Components**
- [ ] List widget decorations
- [ ] Map to outlets/transformers
- [ ] Create Glimmer components
- [ ] Update `includePostAttributes` to `addTrackedPostProperties`
- [ ] Test with `deactivate_widgets_rendering: true`

**Post Stream Updates**
- [ ] Replace widget decorations
- [ ] Update post attribute tracking
- [ ] Test with `glimmer_post_stream_mode: auto`
- [ ] Verify no console warnings

### Compatibility Matrix

| Feature | Deprecated | Removed | Replacement |
|---------|-----------|---------|-------------|
| Inline `<script>` | May 2025 | Sept 2025 | `.gjs` files |
| Template overrides | Nov 2024 | June 2025 | Wrapper outlets |
| Widget system | July 2025 | Q4 2025 | Glimmer components |
| `includePostAttributes` | Q3 2025 | Q4 2025 | `addTrackedPostProperties` |

---

## Best Practices

### ✅ Do

- Use Theme CLI watch mode for development
- Set `minimum_discourse_version` in about.json
- Monitor deprecation warnings
- Test with feature flags enabled
- Follow dev-news on Meta Discourse
- Use `.gjs` files for components
- Use Glimmer components (not widgets)
- Version control with Git
- Install from Git repository

### ❌ Don't

- Develop directly in Admin panel
- Commit `.discourse-site.json` (contains API key)
- Test on production first
- Ignore deprecation warnings
- Use deprecated APIs in new code
- Skip testing with feature flags

---

## Troubleshooting

### Theme CLI Issues

**Command not found**:
```bash
gem install discourse_theme
```

**API authentication fails**:
```bash
# Regenerate API key in Admin → API
rm .discourse-site.json
discourse_theme watch .
```

**Changes not syncing**:
- Restart watch mode (Ctrl+C, then restart)
- Check internet connection
- Verify API key is valid
- Check Discourse instance is running

### Code Issues

**ESLint errors**:
```bash
pnpm run lint:fix
```

**Component not rendering**:
- Check browser console for errors
- Verify plugin outlet name
- Check component syntax
- Verify initializer is loading

**Changes not visible**:
- Hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
- Clear browser cache
- Check theme is enabled

---

## References

- [Discourse Theme CLI](https://meta.discourse.org/t/82950)
- [Widget System EOL](https://meta.discourse.org/t/375332)
- [Inline Scripts Deprecation](https://meta.discourse.org/t/366482)
- [Template Overrides Removal](https://meta.discourse.org/t/355668)
- [Post Stream Changes](https://meta.discourse.org/t/372063)
- [Dev News Tag](https://meta.discourse.org/tag/dev-news)
- [Theme Developer Tutorial](https://meta.discourse.org/t/357796)

