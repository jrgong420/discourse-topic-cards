# Theme Configuration: Settings, Metadata, and Localization

## Intent

Configure themes with settings, metadata (about.json), and multi-language support. Make themes customizable without code changes.

---

## 1. Theme Settings (settings.yml)

### Supported Types

- `bool` - Checkbox
- `integer` - Whole number
- `float` - Decimal number
- `string` - Text input
- `list` - Pipe-separated values
- `enum` - Dropdown selection
- `upload` - File upload
- `objects` - Structured JSON data

### Example settings.yml

```yaml
feature_enabled:
  type: bool
  default: false
  description: "Enable the custom feature"

banner_text:
  type: string
  default: "Welcome!"
  description: "Banner message"

max_items:
  type: integer
  default: 10
  min: 1
  max: 100
  description: "Maximum items to display"

display_mode:
  type: enum
  default: "compact"
  choices:
    - compact
    - expanded
    - minimal
  description: "Display mode"

featured_tags:
  type: list
  list_type: tag
  default: "featured"
  description: "Tags to feature (pipe-separated)"

banner_image:
  type: upload
  default: ""
  description: "Upload banner image"
```

### Accessing Settings

**JavaScript:**
```javascript
if (settings.feature_enabled) {
  console.log(settings.banner_text);
  console.log(settings.max_items);
}

// Parse list settings
const tags = settings.featured_tags.split("|");
```

**Templates:**
```handlebars
{{#if settings.feature_enabled}}
  <div style="background: {{settings.banner_color}}">
    {{settings.banner_text}}
  </div>
{{/if}}
```

**SCSS (kebab-case):**
```scss
.banner {
  padding: #{$banner-padding}px;

  @if $enable-shadows {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
}
```

### Localized Descriptions

```yaml
# locales/en.yml
en:
  theme_metadata:
    settings:
      feature_enabled: "Enable the custom feature"
      banner_text: "Customize the welcome message"
```

---

## 1a. Site Settings vs Theme Settings (important)

- Theme settings live under `settings` and are defined in your theme's `settings.yml`.
- Site settings and other core services live in Discourse and are accessed via the plugin API container; do not shadow site settings with theme settings of the same name.
- Retrieve services in JS with `api.container.lookup("service:…")`. Common examples: `service:site-settings`, `service:router`, `service:store`.

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const siteSettings = api.container.lookup("service:site-settings");

  // Example: combine a theme-configured limit with a site-wide limit
  const limit = Math.min(settings.theme_limit, siteSettings.some_site_limit);

  // Example: branch logic on a site toggle
  if (siteSettings.some_feature_enabled) {
    // feature-specific logic
  }
});
```

Best practices:
- Prefer combining constraints rather than duplicating site settings as theme settings (e.g., `Math.min(themeLimit, siteLimit)` for caps, `Math.max` for minimums).
- Avoid shadowing: don’t define a theme setting with the same name as a site setting.
- Keep theme settings focused on presentation/per-theme behavior; defer global policy and limits to site settings.
- Use services as sources of truth (e.g., `site-settings`, `router`) and favor them over hard-coded assumptions.


## 2. Theme Metadata (about.json)

### Required Fields

```json
{
  "name": "My Theme Component",
  "component": true,
  "authors": "Your Name"
}
```

### Recommended Fields

```json
{
  "name": "My Awesome Theme",
  "component": true,
  "authors": "John Doe",
  "about_url": "https://github.com/username/my-theme",
  "license_url": "https://github.com/username/my-theme/blob/main/LICENSE",
  "theme_version": "1.2.0",
  "minimum_discourse_version": "3.2.0",
  "maximum_discourse_version": null
}
```

### Assets

```json
{
  "name": "My Theme",
  "component": true,
  "authors": "John Doe",
  "assets": {
    "hero-image": "assets/hero.png",
    "custom-font": "assets/fonts/custom.woff2",
    "icon": "assets/icon.svg"
  }
}
```

**Access in SCSS:**
```scss
.hero {
  background-image: url($hero-image);
}

@font-face {
  font-family: "CustomFont";
  src: url($custom-font);
}
```

### Screenshots

```json
{
  "screenshots": [
    "screenshots/light-mode.png",
    "screenshots/dark-mode.png"
  ]
}
```

Requirements:
- Max 2 screenshots
- Max 1MB each
- Max 3840×2160
- Formats: JPEG, GIF, PNG

### Color Schemes

```json
{
  "color_schemes": {
    "Custom Dark": {
      "primary": "dddddd",
      "secondary": "222222",
      "tertiary": "3498db",
      "quaternary": "34495e",
      "header_background": "1a1a1a",
      "header_primary": "ffffff",
      "highlight": "e67e22",
      "danger": "e74c3c",
      "success": "27ae60",
      "love": "e91e63"
    }
  }
}
```

### Complete Example

```json
{
  "name": "Featured Topics Extended",
  "component": true,
  "authors": "Jane Smith",
  "about_url": "https://github.com/janesmith/featured-topics",
  "license_url": "https://github.com/janesmith/featured-topics/blob/main/LICENSE",
  "theme_version": "2.0.0",
  "minimum_discourse_version": "3.2.0",
  "assets": {
    "logo": "assets/logo.svg",
    "banner": "assets/banner.jpg"
  },
  "screenshots": [
    "screenshots/desktop.png",
    "screenshots/mobile.png"
  ],
  "modifiers": {
    "topic_thumbnail_sizes": [
      [375, 375],
      [500, 500],
      [750, 750]
    ],
    "serialize_topic_excerpts": true
  }
}
```

---

## 3. Localization (locales/)

### Structure

```yaml
# locales/en.yml
en:
  js:
    my_theme:
      welcome_message: "Welcome to our community!"
      button_label: "Click Here"
      post_count:
        one: "%{count} post"
        other: "%{count} posts"

  theme_metadata:
    description: "A custom theme for our community"
    settings:
      feature_enabled: "Enable the custom feature"
      banner_text: "Customize the banner text"
```

### Using Translations

**JavaScript:**
```javascript
import { i18n } from "discourse-i18n";

const message = i18n(themePrefix("js.my_theme.welcome_message"));
const count = i18n(themePrefix("js.my_theme.post_count"), { count: 5 });
```

**Templates:**
```handlebars
<h3>{{i18n (themePrefix "js.my_theme.welcome_message")}}</h3>
<button>{{i18n (themePrefix "js.my_theme.button_label")}}</button>
```

**With DButton:**
```javascript
import DButton from "discourse/components/d-button";

<template>
  <DButton
    @label={{themePrefix "js.my_theme.button_label"}}
    @action={{@onClick}}
  />
</template>
```

### Theme translations in JavaScript (critical)

- Always wrap translation keys with `themePrefix()` when calling the i18n function in JS. This ensures keys resolve under the theme-specific namespace (`theme_translation.{theme_id}...`).
- Do NOT call `I18n.t("js.some.key")` (or `i18n("js.some.key")`) directly without `themePrefix` — this commonly yields placeholders like `[en.js.some.key]`.

Examples:

```javascript
// Using the built-in I18n (global)
I18n.t(themePrefix("js.my_theme.welcome_message"));
I18n.t(themePrefix("js.my_theme.post_count"), { count: 5 });

// Or using discourse-i18n helper
import { i18n } from "discourse-i18n";
i18n(themePrefix("js.my_theme.welcome_message"));
i18n(themePrefix("js.my_theme.post_count"), { count: 5 });
```

Troubleshooting:
- Symptom: You see `[en.js.my_theme.welcome_message]` in the UI.
- Fix: Ensure you call `I18n.t(themePrefix("js.my_theme.welcome_message"))` (or `i18n(themePrefix(...))`) and that your locales file nests strings under `en: js: my_theme:`.


### Interpolation

```yaml
# locales/en.yml
en:
  js:
    my_theme:
      user_greeting: "Welcome, %{username}!"
      items_count: "Showing %{current} of %{total}"
```

```javascript
const greeting = i18n(themePrefix("js.my_theme.user_greeting"), {
  username: currentUser.username
});
```

### Pluralization

```yaml
# locales/en.yml
en:
  js:
    my_theme:
      likes:
        zero: "No likes"
        one: "1 like"
        other: "%{count} likes"
```

```javascript
i18n(themePrefix("js.my_theme.likes"), { count: 0 }); // "No likes"
i18n(themePrefix("js.my_theme.likes"), { count: 1 }); // "1 like"
i18n(themePrefix("js.my_theme.likes"), { count: 5 }); // "5 likes"
```

### Multiple Languages

```yaml
# locales/en.yml
en:
  js:
    my_theme:
      greeting: "Hello"

# locales/fr.yml
fr:
  js:
    my_theme:
      greeting: "Bonjour"

# locales/es.yml
es:
  js:
    my_theme:
      greeting: "Hola"
```

---

## Best Practices

### ✅ Do

- Define default values for all settings
- Use validation constraints (min/max)
- Localize setting descriptions
- Include theme_version in about.json
- Set minimum_discourse_version
- Use themePrefix() for translations
- Support pluralization
- Provide multiple language files

### ❌ Don't

- Store sensitive data in settings (visible to admins)
- Hardcode user-facing text
- Forget default values
- Use invalid JSON in about.json
- Include theme_translations prefix manually (themePrefix adds it)
- Hardcode values that should be settings

---

## Complete Example

**settings.yml:**
```yaml
show_banner:
  type: bool
  default: true

banner_message:
  type: string
  default: "Welcome!"

max_topics:
  type: integer
  default: 5
  min: 1
  max: 20

featured_tags:
  type: list
  list_type: tag
  default: "featured"
```

**about.json:**
```json
{
  "name": "Featured Topics",
  "component": true,
  "authors": "Your Name",
  "theme_version": "1.0.0",
  "minimum_discourse_version": "3.2.0"
}
```

**locales/en.yml:**
```yaml
en:
  js:
    featured_topics:
      heading: "Featured Topics"
      no_topics: "No featured topics found"

  theme_metadata:
    description: "Display featured topics"
    settings:
      show_banner: "Show the featured topics banner"
      banner_message: "Customize the banner message"
```

**Usage:**
```javascript
import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

export default class FeaturedTopics extends Component {
  <template>
    {{#if settings.show_banner}}
      <div class="banner">
        <h2>{{i18n (themePrefix "js.featured_topics.heading")}}</h2>
        <p>{{settings.banner_message}}</p>
      </div>
    {{/if}}
  </template>
}
```

---

## References

- [Theme Settings](https://meta.discourse.org/t/82557)
- [Theme Metadata](https://meta.discourse.org/t/119205)
- [Localization](https://meta.discourse.org/t/109867)
- [Theme Developer Quick Reference](https://meta.discourse.org/t/110448)

