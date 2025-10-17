import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import TopicExcerpt from "../components/topic-excerpt";
import TopicMetadata from "../components/topic-metadata";
import TopicOp from "../components/topic-op";
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

  function enableCards() {
    if (router.currentRouteName === "topic.fromParamsNear") {
      return settings.show_for_suggested_topics;
    }

    if (settings.show_on_categories?.length === 0) {
      return true; // no categories set, so enable cards by default
    }
    const currentCat = router.currentRoute?.attributes?.category?.id;
    if (currentCat === undefined) {
      return false; // not in a category
    }
    const categoryIds = settings.show_on_categories?.split("|").map(Number);
    return categoryIds.includes(currentCat);
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
        <TopicOp @topic={{@outletArgs.topic}} />
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

        // Add card layout modifier based on viewport
        const rawStyle = site.mobileView
          ? settings.card_style_mobile
          : settings.card_style_desktop;
        const cardStyle = normalizeCardStyle(rawStyle);
        additionalClasses.push(`topic-cards-list--${cardStyle}`);
      }
      return additionalClasses;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        // Add card layout modifier based on viewport
        const rawStyle = site.mobileView
          ? settings.card_style_mobile
          : settings.card_style_desktop;
        const cardStyle = normalizeCardStyle(rawStyle);

        const itemClasses = ["topic-card", `topic-card--${cardStyle}`];

        // Add layout-specific max-dimension classes
        if (cardStyle === "list" && settings.set_card_max_height) {
          itemClasses.push("has-max-height");
        }
        if (cardStyle === "grid" && settings.set_card_max_width) {
          itemClasses.push("has-max-width");
        }
        if (cardStyle === "grid" && settings.set_card_grid_height && !site.mobileView) {
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

        const clickTargets = [
          "topic-list-data",
          "link-bottom-line",
          "topic-list-item",
          "topic-card__excerpt",
          "topic-card__excerpt-text",
          "topic-card__metadata",
          "topic-card__likes",
          "topic-card__op",
        ];

        if (site.mobileView) {
          clickTargets.push("topic-item-metadata");
        }

        if (clickTargets.some((t) => targetElement.closest(`.${t}`))) {
          if (wantsNewWindow(event)) {
            return true;
          }
          return context.navigateToTopic(topic, topic.lastUnreadUrl);
        }
      }

      next();
    }
  );
});
