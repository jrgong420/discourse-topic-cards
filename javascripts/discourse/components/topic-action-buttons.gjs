import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

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
    <div class="topic-card__actions">
      {{! Details button - always shown }}
      <a
        href={{this.detailsUrl}}
        class="btn topic-card__details-btn"
        aria-label={{this.detailsAriaLabel}}
      >
        {{i18n (themePrefix "js.topic_cards.details_button")}}
      </a>

      {{! Featured link CTA - only when featured link exists }}
      {{#if this.featuredLink}}
        <a
          href={{this.featuredLink}}
          class="btn btn-primary topic-card__featured-link-btn"
          aria-label={{this.featuredLinkAriaLabel}}
          target="_blank"
          rel="noopener noreferrer"
        >
          {{i18n (themePrefix "js.topic_cards.featured_link_button")}}
        </a>
      {{/if}}
    </div>
  </template>
}

