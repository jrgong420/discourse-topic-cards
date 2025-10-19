# Modern JavaScript for Discourse Themes (2025)

## Intent

Use modern Discourse JavaScript patterns: Glimmer components, plugin outlets, API initializers, and value transformers. Avoid deprecated widget system (EOL Q4 2025).

## When This Applies

- Creating custom UI components
- Inserting content into Discourse UI
- Customizing values or behavior
- Initializing theme functionality

---

## 1. Glimmer Components

### Modern Component Pattern (.gjs files)

```javascript
// javascripts/discourse/components/custom-banner.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class CustomBanner extends Component {
  @service router;
  @tracked isVisible = true;

  @action
  dismiss() {
    this.isVisible = false;
  }

  <template>
    {{#if this.isVisible}}
      <div class="custom-banner">
        <p>{{@message}}</p>
        <button {{on "click" this.dismiss}}>Dismiss</button>
      </div>
    {{/if}}
  </template>
}
```

### Key Features

- **Template-tag format**: Template and logic in one `.gjs` file
- **Reactive state**: `@tracked` properties auto-update UI
- **Services**: Inject with `@service` decorator
- **Actions**: Use `@action` decorator and `{{on}}` modifier
- **Arguments**: Access via `@argName` in template, `this.args.argName` in class

### Component Lifecycle

```javascript
import Component from "@glimmer/component";

export default class MyComponent extends Component {
  constructor() {
    super(...arguments);
    // Setup logic
  }

  willDestroy() {
    super.willDestroy(...arguments);
    // Cleanup: remove listeners, cancel timers
  }
}
```

---

## 2. Plugin Outlets

### Rendering in Outlets

```javascript
// javascripts/discourse/api-initializers/init-theme.gjs
import { apiInitializer } from "discourse/lib/api";
import CustomBanner from "../components/custom-banner";

export default apiInitializer("1.14.0", (api) => {
  api.renderInOutlet("above-main-container", CustomBanner);
});
```

### Conditional Rendering

```javascript
import { apiInitializer } from "discourse/lib/api";
import CustomWidget from "../components/custom-widget";

export default apiInitializer("1.14.0", (api) => {
  api.renderInOutlet("topic-above-post-stream", <template>
    {{#if @outletArgs.model.custom_field}}
      <CustomWidget @topic={{@outletArgs.model}} />
    {{/if}}
  </template>);
});
```

### Wrapper Outlets (Replacing Template Overrides)

```javascript
api.renderAfterWrapperOutlet("post-content-cooked-html",
  class extends Component {
    static shouldRender(args) {
      return args.post.someCondition;
    }

    <template>
      <div class="custom-content">{{@post.data}}</div>
    </template>
  }
);
```

### Finding Outlets

Enable developer toolbar in browser console:
```javascript
enableDevTools()
```
Click 🔌 icon to inspect available outlets.

---

## 3. API Initializers

### Basic Structure

```javascript
// javascripts/discourse/api-initializers/init-my-theme.gjs
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.14.0", (api) => {
  // Your initialization code
  console.log("Theme initialized");
});
```

### Common Patterns

```javascript
import { apiInitializer } from "discourse/lib/api";
import MyComponent from "../components/my-component";

export default apiInitializer("1.14.0", (api) => {
  // Render in outlet
  api.renderInOutlet("discovery-list-container-top", MyComponent);

  // Add tracked post properties
  api.addTrackedPostProperties("custom_field", "custom_status");

  // Register value transformer
  api.registerValueTransformer("topic-list-item-class", ({ value, context }) => {
    if (context.topic.pinned) {
      return `${value} custom-pinned`;
    }
    return value;
  });

  // Page change handler
  api.onPageChange((url, title) => {
    console.log("Page changed:", url);
  });
});
```

### Accessing Services

```javascript
export default apiInitializer("1.14.0", (api) => {
  const router = api.container.lookup("service:router");
  const currentUser = api.getCurrentUser();
  const siteSettings = api.container.lookup("service:site-settings");

  console.log("Current route:", router.currentRouteName);
  console.log("User:", currentUser?.username);
  console.log("Site setting:", siteSettings.title);
});
```

---

### 3b. Initializer Hygiene & Lint Harmony

- Follow repository linting conventions for initializers. Some repos disallow passing a version string to `apiInitializer`; omit it unless required by that codebase.
- Keep imports sorted consistently (e.g., via `simple-import-sort`).
- Prefer plugin outlets over global DOM observers when inserting UI; only observe as a fallback and keep observers scoped and disconnected on page change (see SPA patterns).
- Access site-wide settings via `api.container.lookup("service:site-settings")` and combine with theme settings where appropriate, e.g.:

```javascript
export default apiInitializer((api) => {
  const siteSettings = api.container.lookup("service:site-settings");
  const limit = Math.min(settings.max_items, siteSettings.max_tags_per_topic);
});
```


---

## 3a. Translations in JavaScript (theme components)

Always use `themePrefix()` with the i18n function so keys resolve under the theme-specific namespace.

```javascript
// Good: resolves to theme_translation.{theme_id}.js.tag_shortener.more_tags
I18n.t(themePrefix("js.tag_shortener.more_tags"), { count: 3 });

// Also valid with discourse-i18n helper
import { i18n } from "discourse-i18n";
i18n(themePrefix("js.tag_shortener.hide"));
```

Do not call `I18n.t("js.some.key")` directly in themes. That bypasses the theme namespace and usually renders placeholders like `[en.js.some.key]`.


## 4. Value Transformers

### Customizing Values

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.14.0", (api) => {
  // Modify topic list item classes
  api.registerValueTransformer("topic-list-item-class", ({ value, context }) => {
    const classes = [value];

    if (context.topic.custom_field) {
      classes.push("has-custom-field");
    }

    return classes.join(" ");
  });

  // Modify home logo URL
  api.registerValueTransformer("home-logo-href", ({ value }) => {
    return settings.custom_home_url || value;
  });
});
```

### Available Transformers

Common transformers (see [official list](https://meta.discourse.org/t/371140)):
- `topic-list-item-class` - Topic list item CSS classes
- `home-logo-href` - Home logo link URL
- `header-notifications-avatar-size` - Avatar size in header
- `post-menu-buttons` - Post action buttons

---

## 5. Widget System (DEPRECATED - EOL Q4 2025)

### ⚠️ Do Not Use

The widget system is being removed in Q4 2025. Migrate to Glimmer components.

**Deprecated APIs:**
- `createWidget`
- `decorateWidget`
- `changeWidgetSetting`
- `reopenWidget`
- `attachWidgetAction`
- `MountWidget` component

### Migration Path

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

### Testing Without Widgets

Enable in site settings:
```
deactivate_widgets_rendering: true
```

---

## Complete Example

```javascript
// javascripts/discourse/api-initializers/init-featured-topics.gjs
import { apiInitializer } from "discourse/lib/api";
import FeaturedTopics from "../components/featured-topics";

export default apiInitializer("1.14.0", (api) => {
  // Only show on specific routes
  const router = api.container.lookup("service:router");

  api.onPageChange(() => {
    const currentRoute = router.currentRouteName;
    const shouldShow = currentRoute === "discovery.latest";

    if (shouldShow) {
      api.renderInOutlet("above-main-container", FeaturedTopics);
    }
  });

  // Add custom post tracking
  api.addTrackedPostProperties("featured_score");

  // Customize topic classes
  api.registerValueTransformer("topic-list-item-class", ({ value, context }) => {
    if (context.topic.tags?.includes("featured")) {
      return `${value} featured-topic`;
    }
    return value;
  });
});
```

```javascript
// javascripts/discourse/components/featured-topics.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { action } from "@ember/object";

export default class FeaturedTopics extends Component {
  @service store;
  @tracked topics = null;

  constructor() {
    super(...arguments);
    this.loadTopics();
  }

  @action
  async loadTopics() {
    const topicList = await this.store.findFiltered("topicList", {
      filter: "latest",
      params: { tags: settings.featured_tags.split("|") }
    });
    this.topics = topicList.topics.slice(0, settings.max_topic_count);
  }

  <template>
    <div class="featured-topics">
      <h2>Featured Topics</h2>
      {{#each this.topics as |topic|}}
        <div class="featured-topic">
          <a href={{topic.url}}>{{topic.title}}</a>
        </div>
      {{/each}}
    </div>
  </template>
}
```

---

## Best Practices

### ✅ Do

- Use `.gjs` files for components (template-tag format)
- Use `@tracked` for reactive state
- Use `apiInitializer` for theme initialization
- Use plugin outlets instead of template overrides
- Use value transformers for customization
- Clean up in `willDestroy()` lifecycle hook

### ❌ Don't

- Use widget system (deprecated Q4 2025)
- Use inline `<script>` tags (removed Sept 2025)
- Use template overrides (removed June 2025)
- Use jQuery (being phased out)
- Mutate component args (read-only)
- Forget to clean up event listeners

---

## References

- [Glimmer Components Guide](https://guides.emberjs.com/release/components/)
- [Plugin Outlets List](https://meta.discourse.org/t/354612)
- [Value Transformers](https://meta.discourse.org/t/371140)
- [Widget System EOL](https://meta.discourse.org/t/375332)
- [Plugin API Source](https://github.com/discourse/discourse/blob/main/app/assets/javascripts/discourse/app/lib/plugin-api.gjs)

