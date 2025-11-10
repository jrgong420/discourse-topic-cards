// @ts-nocheck

/**
 * Portfolio Topic Cards Initializer
 *
 * Enables card-based topic list rendering on user portfolio routes.
 * Applies the same card styles as the main topic list cards but scoped
 * to the user.portfolio route only.
 *
 * Configuration:
 * - settings.portfolio_topic_cards_style: "list" | "grid" | "disabled"
 *
 * CSS Classes Applied:
 * - .topic-cards-list (when enabled)
 * - .topic-cards-list--list or .topic-cards-list--grid (layout variant)
 * - .topic-card (individual card)
 * - .topic-card--list or .topic-card--grid (card variant)
 */
import { apiInitializer } from "discourse/lib/api";

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

  // No post-render DOM surgery needed - inline featured link is suppressed via CSS in card mode

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
