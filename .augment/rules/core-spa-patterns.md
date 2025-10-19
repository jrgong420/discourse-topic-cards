# Core SPA Patterns for Discourse Themes

## Intent

Master essential patterns for Discourse's single-page application (SPA) architecture: event binding, navigation guards, and state management. These patterns prevent common bugs like redirect loops, memory leaks, and stale event listeners.

## When This Applies

- Binding event listeners to dynamic content
- Programmatically changing URL parameters or navigating
- Managing component or application state
- Responding to route/page changes

---

## 1. SPA Event Binding

### Problem
Discourse uses Ember.js routing—page content changes without full reloads. Direct event binding breaks when elements are re-rendered.

### ✅ Do: Use Event Delegation

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  let bound = false;

  if (!bound) {
    document.addEventListener("click", (e) => {
      const target = e.target?.closest?.(".my-button");
      if (!target) return;
      console.log("Button clicked:", target);
    }, true); // Use capture phase
    bound = true;
  }
});
```

### ✅ Do: Use Router Service (Modern)

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  router.on("routeDidChange", (transition) => {
    console.log("Route changed to:", transition.to.name);
  });
});
```

### ✅ Do: Use api.onPageChange with Scheduling

```javascript
import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

export default apiInitializer((api) => {
  api.onPageChange((url, title) => {
    schedule("afterRender", () => {
      // DOM is ready
      const container = document.querySelector(".topic-body");
      if (container) {
        // Safe to manipulate
      }
    });
  });
});
```

### ❌ Don't: Bind Directly to Transient Elements

```javascript
// BAD - breaks on re-render
api.onPageChange(() => {
  const btn = document.querySelector(".my-button");
  btn?.addEventListener("click", handler);
});
```

---

## 2. Redirect Loop Avoidance

### Problem
Programmatic navigation in `api.onPageChange` can trigger infinite loops if not guarded properly.

### ✅ Do: Check Current State Before Navigating

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.onPageChange((url, title) => {
    const currentUrl = new URL(window.location.href);
    const currentFilter = currentUrl.searchParams.get("username_filters");

    // Guard: already filtered
    if (currentFilter) {
      return;
    }

    // Safe to navigate
    currentUrl.searchParams.set("username_filters", "someuser");
    window.location.replace(currentUrl.toString());
  });
});
```

### ✅ Do: Use Multiple Guard Conditions

```javascript
import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

export default apiInitializer((api) => {
  api.onPageChange((url, title) => {
    schedule("afterRender", () => {
      const currentUrl = new URL(window.location.href);
      const currentFilter = currentUrl.searchParams.get("username_filters");
      const hasFilteredNotice = !!document.querySelector(".posts-filtered-notice");

      // Guard 1: Already filtered (URL or UI)
      if (currentFilter || hasFilteredNotice) {
        return;
      }

      // Guard 2: Data not ready
      const topic = api.container.lookup("controller:topic")?.model;
      if (!topic?.user?.username) {
        return;
      }

      // Safe to navigate
      currentUrl.searchParams.set("username_filters", topic.user.username);
      window.location.replace(currentUrl.toString());
    });
  });
});
```

### ✅ Do: Use Router Service for SPA Navigation

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  api.onPageChange(() => {
    const currentParams = router.currentRoute.queryParams;

    if (currentParams.username_filters) {
      return;
    }

    router.transitionTo({ queryParams: { username_filters: "someuser" } });
  });
});
```

### ❌ Don't: Navigate Without Guards

```javascript
// BAD - infinite loop
api.onPageChange(() => {
  const url = new URL(window.location.href);
  url.searchParams.set("filter", "active");
  window.location.replace(url.toString()); // Triggers onPageChange again!
});
```

---

## 3. State Scope Management

### Problem
Choosing wrong scope causes bugs: unintended persistence, stale data, or memory leaks.

### State Scopes

1. **Component-Scoped** (Recommended for UI state)
   - Lifetime: Component instance
   - Implementation: `@tracked` properties
   - Use for: Component UI state, form inputs, toggles

2. **Module-Scoped** (View-only)
   - Lifetime: Current route/view; manually reset
   - Implementation: Module-level variables
   - Use for: One-shot suppression flags, temporary guards

3. **Session-Scoped**
   - Lifetime: Browser tab/window
   - Implementation: `sessionStorage`
   - Use for: Per-session preferences

4. **Persisted**
   - Lifetime: Across sessions
   - Implementation: `localStorage` or server settings
   - Use for: Long-term preferences

### ✅ Do: Use @tracked for Component State

```javascript
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class ToggleComponent extends Component {
  @tracked isExpanded = false;

  @action
  toggle() {
    this.isExpanded = !this.isExpanded;
  }

  <template>
    <button {{on "click" this.toggle}}>
      {{if this.isExpanded "Collapse" "Expand"}}
    </button>
    {{#if this.isExpanded}}
      <div>{{yield}}</div>
    {{/if}}
  </template>
}
```

### ✅ Do: Use Module-Level Flags for One-Shot Suppression

```javascript
import { apiInitializer } from "discourse/lib/api";

let suppressNextAction = false;
let suppressedTopicId = null;

export default apiInitializer((api) => {
  document.addEventListener("click", (e) => {
    if (e.target.closest(".dismiss-notice")) {
      const topic = api.container.lookup("controller:topic")?.model;
      suppressNextAction = true;
      suppressedTopicId = topic?.id;
    }
  }, true);

  api.onPageChange(() => {
    const topic = api.container.lookup("controller:topic")?.model;

    if (suppressNextAction && topic?.id === suppressedTopicId) {
      suppressNextAction = false;
      suppressedTopicId = null;
      return; // Consume flag
    }

    // Normal logic
  });
});
```

### ✅ Do: Use sessionStorage for Per-Session Preferences

```javascript
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const STORAGE_KEY = "theme_feature_dismissed";

  api.onPageChange(() => {
    if (sessionStorage.getItem(STORAGE_KEY)) {
      return;
    }

    document.addEventListener("click", (e) => {
      if (e.target.closest(".dismiss-feature")) {
        sessionStorage.setItem(STORAGE_KEY, "true");
      }
    }, { once: true });
  });
});
```

### ❌ Don't: Store View-Only State in sessionStorage

```javascript
// BAD - view-only state shouldn't persist
api.onPageChange(() => {
  if (sessionStorage.getItem("suppress_action")) {
    sessionStorage.removeItem("suppress_action");
    return;
  }
});

// GOOD - use module variable
let suppressAction = false;
api.onPageChange(() => {
  if (suppressAction) {
    suppressAction = false;
    return;
  }
});
```


---

## 4. MutationObserver Lifecycle and Scope

### Problems
- Global observers cause leaks and unnecessary work
- Observers attached before render miss nodes or double-process content
- Not disconnecting observers on navigation leads to duplicated work

### ✅ Do: Connect After Render, Disconnect on Page Change, Scope to Relevant Containers

```javascript
import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

let observer = null;

export default apiInitializer((api) => {
  api.onPageChange(() => {
    // Always disconnect any previous observer
    if (observer) {
      observer.disconnect();
      observer = null;
    }

    // Perform DOM work after render
    schedule("afterRender", () => {
      // Process current items safely here...
      setupObserver();
    });
  });

  function setupObserver() {
    const containers = document.querySelectorAll(
      ".topic-list, .latest-topic-list, #list-area"
    );
    if (!containers.length) return;

    observer = new MutationObserver((mutations) => {
      mutations.forEach((m) => {
        m.addedNodes.forEach((node) => {
          if (node.nodeType !== 1) return;
          // Process newly added topic rows only
          if (
            node.classList?.contains("topic-list-item") ||
            node.classList?.contains("latest-topic-list-item")
          ) {
            // processTopic(node)
          }
        });
      });
    });

    containers.forEach((el) => observer.observe(el, { childList: true, subtree: true }));
  }
});
```

### ✅ Do: Reset UI State When Reprocessing
- Remove any injected controls (e.g., toggles) you added on the previous render
- Unhide elements and related separators you may have hidden (e.g., `.ts-hidden` on tags and separators)
- Recompute hidden/visible elements from a clean state each time

### ❌ Don’t
- Observe `#main-outlet` globally unless absolutely necessary
- Rely on `setTimeout` on initial page load instead of `schedule("afterRender", ...)`
- Leave observers connected across route changes

---

## Debugging Tips

### Logging Navigation Attempts

```javascript
let navigationAttempts = 0;

api.onPageChange((url, title) => {
  navigationAttempts++;
  console.log(`[Navigation] Attempt #${navigationAttempts}`);
  console.log(`[Navigation] URL: ${url}`);

  if (navigationAttempts > 5) {
    console.error("[Navigation] Possible redirect loop!");
    return;
  }

  // Your logic with guards
});
```

### Checking Event Binding

```javascript
let clickCount = 0;

document.addEventListener("click", (e) => {
  const target = e.target?.closest?.(".my-button");
  if (!target) return;

  clickCount++;
  console.log(`[Event] Click #${clickCount}`);
}, true);
```

---

## References

- [Trigger JavaScript on Page Link Clicks](https://meta.discourse.org/t/167970)
- [Ember Router Service](https://api.emberjs.com/ember/5.12/classes/RouterService)
- [Glimmer Component Lifecycle](https://guides.emberjs.com/release/components/)

