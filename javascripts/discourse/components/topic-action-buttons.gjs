import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

/**
 * TopicActionButtons Component
 *
 * Renders action buttons for topic cards when a featured link is present.
 * Provides "Details" button (navigate to topic) and "Featured Link" button (external link).
 *
 * BEM Structure:
 * - .topic-card__actions (container)
 *   - .topic-card__details-btn (secondary button)
 *   - .topic-card__featured-link-btn (primary button)
 *
 * Accessibility:
 * - Both buttons have aria-label attributes
 * - Featured link opens in new tab with noopener/noreferrer
 */
export default class TopicActionButtons extends Component {
  get featuredLink() {
    return this.args.topic?.featuredLink || this.args.topic?.featured_link;
  }

  get detailsUrl() {
    return this.args.topic?.lastUnreadUrl;
  }

  get detailsAriaLabel() {
    return i18n(themePrefix("js.topic_cards.details_button_aria"), {
      title: this.args.topic?.title || "",
    });
  }

  get featuredLinkAriaLabel() {
    if (!this.featuredLink) {
      return "";
    }

    try {
      const url = new URL(this.featuredLink);
      return i18n(themePrefix("js.topic_cards.featured_link_button_aria"), {
        domain: url.hostname,
      });
    } catch {
      return i18n(themePrefix("js.topic_cards.featured_link_button"));
    }
  }

  <template>
    {{#if this.featuredLink}}
      <div class="topic-card__actions">
        <a
          href={{this.detailsUrl}}
          class="btn topic-card__details-btn"
          aria-label={{this.detailsAriaLabel}}
        >
          {{i18n (themePrefix "js.topic_cards.details_button")}}
        </a>
        <a
          href={{this.featuredLink}}
          class="btn btn-primary topic-card__featured-link-btn"
          aria-label={{this.featuredLinkAriaLabel}}
          target="_blank"
          rel="noopener noreferrer"
        >
          {{i18n (themePrefix "js.topic_cards.featured_link_button")}}
        </a>
      </div>
    {{/if}}
  </template>
}

