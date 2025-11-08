/**
 * Topic Cards Carousel - Initializer
 *
 * Renders a carousel of topic cards on the home page (above-main-container outlet).
 * Gated to home page only via router service.
 *
 * Compatibility Notes:
 * - Uses separate plugin outlet (above-main-container) from topic list cards
 * - Does not interfere with topic-list-main-link-bottom outlet
 * - Does not register value transformers (no conflicts with topic-list-class)
 * - Does not register behavior transformers (no click handler conflicts)
 * - Carousel cards use .carousel-topic-card class (distinct from .topic-card)
 * - Compatible with portfolio-topic-cards and discourse-topic-list-cards
 *
 * @see javascripts/discourse/api-initializers/discourse-topic-list-cards.gjs
 * @see javascripts/discourse/api-initializers/portfolio-topic-cards.gjs
 */
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import TopicCardsCarousel from "../components/topic-cards-carousel";

export default apiInitializer((api) => {
  // Use configured outlet with safe fallback
  const outletName = settings.carousel_plugin_outlet || "above-main-container";

  api.renderInOutlet(
    outletName,
    class extends Component {
      @service router;

      /**
       * Determines if carousel should be displayed.
       * Shows on home routes (discovery.latest, discovery.top, discovery.categories) when enabled.
       * @returns {boolean}
       */
      get shouldShow() {
        // Check setting
        if (settings.carousel_display_location !== "home") {
          return false;
        }

        // Check route - show on common home routes
        const name = this.router?.currentRouteName;
        return (
          name === "discovery.latest" ||
          name === "discovery.top" ||
          name === "discovery.categories"
        );
      }

      <template>
        {{#if this.shouldShow}}
          <TopicCardsCarousel />
        {{/if}}
      </template>
    }
  );
});
