/**
 * Discourse Topic List Cards - Main Initializer
 *
 * Transforms standard Discourse topic lists into card-based layouts (list or grid style).
 * Supports per-category configuration and mobile/desktop responsive behavior.
 *
 * Key Features:
 * - Per-category card style configuration (list/grid/disabled)
 * - Mobile-specific card styles
 * - Custom click behavior for card navigation
 * - BEM-based CSS architecture
 * - Glimmer component-based rendering
 *
 * Component Rendering Order (via topic-list-main-link-bottom outlet):
 * 1. TopicExcerpt - Topic excerpt text
 * 2. TopicTagsInline - Category and tags
 * 3. TopicByline - Author and publish date
 * 4. TopicActionButtons - Details and featured link buttons
 * 5. TopicMetadata - Views, likes, replies, activity
 *
 * CSS Classes Applied:
 * - .topic-cards-list (list container)
 * - .topic-cards-list--list or .topic-cards-list--grid (layout variant)
 * - .topic-card (individual card)
 * - .topic-card--list or .topic-card--grid (card variant)
 */
import Component from "@glimmer/component";
import { schedule } from "@ember/runloop";
import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import TopicActionButtons from "../components/topic-action-buttons";
import TopicByline from "../components/topic-byline";
import TopicExcerpt from "../components/topic-excerpt";
import TopicMetadata from "../components/topic-metadata";
import TopicTagsInline from "../components/topic-tags-inline";
import TopicThumbnail from "../components/topic-thumbnail";

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");
  const router = api.container.lookup("service:router");

  // Backward compatibility: map legacy setting values to new layout names
  function normalizeCardStyle(style) {
    const legacyMap = {
      portrait: "grid",
      landscape: "list",
    };
    return legacyMap[style] || style;
  }

  /**
   * Determines the card style for the current category on desktop.
   * Returns "list", "grid", or null (no cards).
   *
   * Priority:
   * 1. If category is in grid_view_categories -> "grid"
   * 2. If category is in list_view_categories -> "list"
   * 3. If both settings are empty -> "list" (default everywhere)
   * 4. Otherwise -> null (no cards)
   */
  function getCategoryCardStyle() {
    const currentCat = router.currentRoute?.attributes?.category?.id;

    // Parse category settings
    const listCategoryIds = settings.list_view_categories?.length > 0
      ? settings.list_view_categories.split("|").map(Number)
      : [];
    const gridCategoryIds = settings.grid_view_categories?.length > 0
      ? settings.grid_view_categories.split("|").map(Number)
      : [];

    // If both settings are empty, enable list style everywhere
    if (listCategoryIds.length === 0 && gridCategoryIds.length === 0) {
      return "list";
    }

    // If not in a category context, don't show cards
    if (currentCat === undefined) {
      return null;
    }

    // Grid takes priority if category appears in both settings
    if (gridCategoryIds.includes(currentCat)) {
      return "grid";
    }

    if (listCategoryIds.includes(currentCat)) {
      return "list";
    }

    // Category not in either setting
    return null;
  }

  function enableCards() {
    if (router.currentRouteName === "topic.fromParamsNear") {
      return settings.show_for_suggested_topics;
    }

    return getCategoryCardStyle() !== null;
  }

  api.renderInOutlet(
    "topic-list-main-link-bottom",
    class extends Component {
      static shouldRender(args, context) {
        return (
          context.siteSettings.glimmer_topic_list_mode !== "disabled" &&
          enableCards()
        );
      }

      <template>
        <TopicExcerpt @topic={{@outletArgs.topic}} />
        <TopicTagsInline @topic={{@outletArgs.topic}} />
        <TopicByline @topic={{@outletArgs.topic}} />
        <TopicActionButtons @topic={{@outletArgs.topic}} />
        <TopicMetadata @topic={{@outletArgs.topic}} />
      </template>
    }
  );

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        additionalClasses.push("topic-cards-list");

        // Determine card style based on viewport and category
        let cardStyle;
        if (site.mobileView) {
          // Mobile uses the global mobile setting
          cardStyle = normalizeCardStyle(settings.card_style_mobile);
        } else {
          // Desktop uses per-category style
          cardStyle = getCategoryCardStyle() || "list";
        }

        additionalClasses.push(`topic-cards-list--${cardStyle}`);
      }
      return additionalClasses;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        // Determine card style based on viewport and category
        let cardStyle;
        if (site.mobileView) {
          // Mobile uses the global mobile setting
          cardStyle = normalizeCardStyle(settings.card_style_mobile);
        } else {
          // Desktop uses per-category style
          cardStyle = getCategoryCardStyle() || "list";
        }

        const itemClasses = ["topic-card", `topic-card--${cardStyle}`];

        // Add layout-specific max-dimension classes
        if (cardStyle === "list" && settings.set_card_max_height) {
          itemClasses.push("has-max-height");
        }
        if (
          cardStyle === "grid" &&
          settings.set_card_grid_height &&
          !site.mobileView
        ) {
          itemClasses.push("has-grid-height");
        }

        return [...additionalClasses, ...itemClasses];
      } else {
        return additionalClasses;
      }
    }
  );

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (enableCards()) {
      return false;
    }
    return value;
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (enableCards()) {
      columns.add("thumbnail", { item: TopicThumbnail }, { before: "topic" });
      // Tags are now rendered inline within the main content area
    }
    return columns;
  });

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ context, next }) => {
      if (enableCards()) {
        const targetElement = context.event.target;
        const topic = context.topic;

        if (
          targetElement.closest(
            "a[href], button, input, textarea, select, label[for]"
          )
        ) {
          return next();
        }

        const clickTargets = [
          "topic-list-data",
          "link-bottom-line",
          "topic-list-item",
          "topic-card__excerpt",
          "topic-card__excerpt-text",
          "topic-card__metadata",
          "topic-card__likes",
          "topic-card__byline",
          "topic-card__op",
        ];

        if (site.mobileView) {
          clickTargets.push("topic-item-metadata");
        }

        if (clickTargets.some((t) => targetElement.closest(`.${t}`))) {
          if (wantsNewWindow(context.event)) {
            return true;
          }
          return context.navigateToTopic(topic, topic.lastUnreadUrl);
        }


      }

      next();
    }
  );

  // DOM reordering: Move .topic-post-badges before .title to prevent overlap with .topic-statuses
  // This is SPA-safe and scoped to card layouts only
  let observer = null;

  function reorderBadgesAndStatuses() {
    const topicCards = document.querySelectorAll(
      ".topic-cards-list .topic-list-item"
    );

    topicCards.forEach((card) => {
      const linkTopLine = card.querySelector(".link-top-line");
      if (!linkTopLine) return;

      const badges = linkTopLine.querySelector(".topic-post-badges");
      const title = linkTopLine.querySelector(".title");

      // Only reorder if both elements exist and badges is not already before title
      if (badges && title && badges.nextElementSibling !== title) {
        // Move badges to be the first child of link-top-line
        linkTopLine.insertBefore(badges, linkTopLine.firstChild);
      }
    });
  }

  function setupObserver() {
    const containers = document.querySelectorAll(
      ".topic-cards-list .topic-list-body"
    );
    if (!containers.length) return;

    observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType !== 1) return;
          if (
            node.classList?.contains("topic-list-item") ||
            node.classList?.contains("topic-card")
          ) {
            const linkTopLine = node.querySelector(".link-top-line");
            if (!linkTopLine) return;

            const badges = linkTopLine.querySelector(".topic-post-badges");
            const title = linkTopLine.querySelector(".title");

            if (badges && title && badges.nextElementSibling !== title) {
              linkTopLine.insertBefore(badges, linkTopLine.firstChild);
            }
          }
        });
      });
    });

    containers.forEach((container) => {
      observer.observe(container, { childList: true, subtree: true });
    });
  }

  api.onPageChange(() => {
    // Disconnect previous observer
    if (observer) {
      observer.disconnect();
      observer = null;
    }

    // Only process if cards are enabled
    if (!enableCards()) return;

    // Use schedule to ensure DOM is ready
    schedule("afterRender", () => {
      reorderBadgesAndStatuses();
      setupObserver();
    });
  });

});
