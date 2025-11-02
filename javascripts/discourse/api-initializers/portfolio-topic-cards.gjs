/* global settings */
// @ts-nocheck

import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

/** @type {MutationObserver|null} */
let portfolioFeaturedObserver = null;

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  function enablePortfolioCards() {
    if (router.currentRouteName !== "user.portfolio") {
      return false;
    }
    // Activate topic cards when a concrete style is chosen
    return ["list", "grid"].includes(settings.portfolio_topic_cards_style);
  }

  function portfolioCardStyle() {
    const style = settings.portfolio_topic_cards_style;
    return style === "grid" ? "grid" : "list";
  }

  // Remove redundant \u00A0 (non-breaking space) inserted between title and featured link
  // Only remove it when the title is a single line to avoid unwanted spacing in cards
  function processLinkTopLines(root = document) {
    /** @type {Document|Element} */
    // @ts-ignore - root is Document|Element
    const scope = root;
    const containers = scope.querySelectorAll(
      ".topic-list .link-top-line, .latest-topic-list .link-top-line, .topic-cards-list .link-top-line"
    );

    containers.forEach((container) => {
      const title = container.querySelector("a.title");
      const featured = container.querySelector("a.topic-featured-link");
      if (!title || !featured) return;

      const prev = featured.previousSibling;
      if (!prev || prev.nodeType !== 3) return; // not a text node

      const text = prev.nodeValue || "";
      if (!/(\u00A0|\s+)/.test(text)) return; // no nbsp/whitespace to remove

      const cs = getComputedStyle(title);
      const lineHeight = parseFloat(cs.lineHeight);
      const height = title.getBoundingClientRect().height;
      const lines = lineHeight ? Math.round(height / lineHeight) : 1;

      if (lines <= 1) {
        prev.remove();
      }
    });
  }

  function setupObserver() {
    const lists = document.querySelectorAll(
      ".topic-list, .latest-topic-list, .topic-cards-list"
    );
    if (!lists.length) return;

    portfolioFeaturedObserver = new MutationObserver((mutations) => {
      mutations.forEach((m) => {
        m.addedNodes.forEach((node) => {
          if (!(node instanceof Element)) return;
          if (node.matches(".link-top-line")) {
            processLinkTopLines(node.parentElement || node);
          } else {
            const inners = node.querySelectorAll(".link-top-line");
            if (inners && inners.length) {
              processLinkTopLines(node);
            }
          }
        });
      });
    });

    lists.forEach((el) =>
      portfolioFeaturedObserver.observe(el, { childList: true, subtree: true })
    );
  }

  api.onPageChange(() => {
    // Always disconnect any existing observer
    if (portfolioFeaturedObserver) {
      portfolioFeaturedObserver.disconnect();
      portfolioFeaturedObserver = null;
    }

    if (!enablePortfolioCards()) {
      return;
    }

    schedule("afterRender", () => {
      processLinkTopLines();
      setupObserver();
    });
  });

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      if (enablePortfolioCards()) {
        additionalClasses.push("topic-cards-list");
        additionalClasses.push(`topic-cards-list--${portfolioCardStyle()}`);
      }
      return additionalClasses;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enablePortfolioCards()) {
        const style = portfolioCardStyle();
        additionalClasses.push("topic-card");
        additionalClasses.push(`topic-card--${style}`);
      }
      return additionalClasses;
    }
  );
});
