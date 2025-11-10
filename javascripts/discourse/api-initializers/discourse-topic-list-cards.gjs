/**
 * Discourse Topic List Cards - Main Initializer
 *
 * Transforms standard Discourse topic lists into card-based layouts (list or grid style).
 * Supports per-category configuration with independent mobile/desktop settings.
 *
 * Key Features:
 * - Per-category card style configuration (list/grid/disabled) for desktop and mobile independently
 * - Custom click behavior for card navigation
 * - BEM-based CSS architecture
 * - Glimmer component-based rendering
 *
 * Component Rendering Order (via topic-list-main-link-bottom outlet):
 * 1. TopicTagsInline - Category and tags
 * 2. TopicExcerpt - Topic excerpt text
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

  /**
   * Determines the card style for the current category and viewport.
   * Returns "list", "grid", or null (no cards).
   *
   * Logic:
   * 1. Parse the appropriate settings based on viewport (mobile vs desktop)
   * 2. If both settings for the platform are empty -> null (cards disabled)
   * 3. If category is in both list and grid settings -> "list" (list takes precedence)
   * 4. If category is in list settings -> "list"
   * 5. If category is in grid settings -> "grid"
   * 6. Otherwise -> null (category not assigned, cards disabled)
   */
  function cardStyleFor({ categoryId, isMobile }) {
    // Parse category settings based on viewport
    const listSetting = isMobile
      ? settings.mobile_list_view_categories
      : settings.list_view_categories;
    const gridSetting = isMobile
      ? settings.mobile_grid_view_categories
      : settings.grid_view_categories;

    const listCategoryIds =
      listSetting?.length > 0 ? listSetting.split("|").map(Number) : [];
    const gridCategoryIds =
      gridSetting?.length > 0 ? gridSetting.split("|").map(Number) : [];

    // If both settings are empty for this platform, cards are disabled
    if (listCategoryIds.length === 0 && gridCategoryIds.length === 0) {
      return null;
    }

    // If not in a category context, don't show cards
    if (categoryId === undefined) {
      return null;
    }

    const inList = listCategoryIds.includes(categoryId);
    const inGrid = gridCategoryIds.includes(categoryId);

    // List takes precedence over grid when category is in both
    if (inList && inGrid) {
      return "list";
    }

    if (inList) {
      return "list";
    }

    if (inGrid) {
      return "grid";
    }

    // Category not assigned to either setting
    return null;
  }

  function getCardStyle() {
    const currentCat = router.currentRoute?.attributes?.category?.id;
    return cardStyleFor({
      categoryId: currentCat,
      isMobile: site.mobileView,
    });
  }

  function enableCards() {
    return getCardStyle() !== null;
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
        <TopicTagsInline @topic={{@outletArgs.topic}} />
        <TopicExcerpt @topic={{@outletArgs.topic}} />
        <TopicByline @topic={{@outletArgs.topic}} />
        <TopicActionButtons @topic={{@outletArgs.topic}} />
        <TopicMetadata @topic={{@outletArgs.topic}} />
      </template>
    }
  );

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      const cardStyle = getCardStyle();
      if (cardStyle) {
        additionalClasses.push("topic-cards-list");
        additionalClasses.push(`topic-cards-list--${cardStyle}`);
      }
      return additionalClasses;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      const cardStyle = getCardStyle();
      if (cardStyle) {
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
      ".topic-cards-list .topic-list-item, .topic-cards-list .topic-card"
    );

    topicCards.forEach((card) => {
      const linkTopLine = card.querySelector(".link-top-line");
      if (!linkTopLine) {
        return;
      }

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
    if (!containers.length) {
      return;
    }

    observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType !== 1) {
            return;
          }
          if (
            node.classList?.contains("topic-list-item") ||
            node.classList?.contains("topic-card")
          ) {
            const linkTopLine = node.querySelector(".link-top-line");
            if (!linkTopLine) {
              return;
            }

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
    if (!enableCards()) {
      return;
    }

    // Use schedule to ensure DOM is ready
    schedule("afterRender", () => {
      reorderBadgesAndStatuses();
      setupObserver();
    });
  });
});
