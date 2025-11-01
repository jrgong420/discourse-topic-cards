import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import TopicByline from "../components/topic-byline";
import TopicExcerpt from "../components/topic-excerpt";
import TopicMetadata from "../components/topic-metadata";
import TopicTagsMobile from "../components/topic-tags-mobile";
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
        <TopicByline @topic={{@outletArgs.topic}} />
        <TopicExcerpt @topic={{@outletArgs.topic}} />
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

      if (site.mobileView) {
        columns.add(
          "tags-mobile",
          { item: TopicTagsMobile },
          { before: "thumbnail" }
        );
      }
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
});
