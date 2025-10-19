import Component from "@glimmer/component";
import { schedule } from "@ember/runloop";
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
    ({ value: additionalClasses, context }) => {
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
        if (
          cardStyle === "grid" &&
          settings.set_card_grid_height &&
          !site.mobileView
        ) {
          itemClasses.push("has-grid-height");
        }

        // Add highlight class if topic has any configured highlight tags
        if (settings.highlight_tags) {
          const highlightTags = settings.highlight_tags
            .split("|")
            .map((tag) => tag.trim())
            .filter(Boolean);

          const topicTags = context.topic?.tags || [];

          const hasHighlightTag = highlightTags.some((highlightTag) =>
            topicTags.includes(highlightTag)
          );

          if (hasHighlightTag) {
            itemClasses.push("topic-card--highlight");
          }
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

  // ============================================================================
  // In-card accents: Tag badge highlighting for matching highlight tags
  // ============================================================================
  let tagObserver = null;

  function setupTagBadgeAccents() {
    // Only run if feature is enabled
    if (!settings.show_highlight_incard_accents || !settings.highlight_tags) {
      return;
    }

    const highlightTags = settings.highlight_tags
      .split("|")
      .map((tag) => tag.trim())
      .filter(Boolean);

    if (highlightTags.length === 0) {
      return;
    }

    // Find topic list containers to observe
    const containers = document.querySelectorAll(
      ".topic-list, .latest-topic-list, #list-area"
    );
    if (!containers.length) {
      return;
    }

    // Process existing tag elements
    containers.forEach((container) => {
      const tagElements = container.querySelectorAll(".discourse-tag");
      tagElements.forEach((tagEl) => {
        const tagName = tagEl.getAttribute("data-tag-name");
        if (tagName && highlightTags.includes(tagName)) {
          tagEl.classList.add("is-highlight-tag");
        }
      });
    });

    // Set up observer for dynamically added tags
    tagObserver = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType !== 1) return;

          // Check if the added node itself is a tag
          if (node.classList?.contains("discourse-tag")) {
            const tagName = node.getAttribute("data-tag-name");
            if (tagName && highlightTags.includes(tagName)) {
              node.classList.add("is-highlight-tag");
            }
          }

          // Check for tags within the added node
          if (node.querySelectorAll) {
            const tagElements = node.querySelectorAll(".discourse-tag");
            tagElements.forEach((tagEl) => {
              const tagName = tagEl.getAttribute("data-tag-name");
              if (tagName && highlightTags.includes(tagName)) {
                tagEl.classList.add("is-highlight-tag");
              }
            });
          }
        });
      });
    });

    // Observe each container
    containers.forEach((container) => {
      tagObserver.observe(container, { childList: true, subtree: true });
    });
  }

  function cleanupTagBadgeAccents() {
    if (tagObserver) {
      tagObserver.disconnect();
      tagObserver = null;
    }

    // Remove all is-highlight-tag classes
    document.querySelectorAll(".is-highlight-tag").forEach((el) => {
      el.classList.remove("is-highlight-tag");
    });
  }

  // Set up on page change
  api.onPageChange(() => {
    // Always clean up previous observer
    cleanupTagBadgeAccents();

    // Set up new observer after render
    schedule("afterRender", () => {
      setupTagBadgeAccents();
    });
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
          "topic-card__byline",
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
