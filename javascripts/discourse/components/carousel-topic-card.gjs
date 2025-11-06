/**
 * Carousel Topic Card Component
 *
 * Renders a single topic card for the carousel using the existing
 * topic card components (thumbnail, excerpt, byline, metadata, tags).
 *
 * Phase 4: Integrate existing card rendering (no slider yet)
 *
 * BEM Structure:
 * - .carousel-topic-card (wrapper)
 *   - .carousel-topic-card__thumbnail
 *   - .carousel-topic-card__content
 *     - .carousel-topic-card__title
 *     - (existing topic card components)
 */
import Component from "@glimmer/component";
import { service } from "@ember/service";
import dIcon from "discourse/helpers/d-icon";

export default class CarouselTopicCard extends Component {
  @service site;

  responsiveRatios = [1, 1.5, 2];

  get topic() {
    return this.args.topic;
  }

  get hasThumbnail() {
    return !!this.topic.thumbnails;
  }

  get displayWidth() {
    // Default display width for carousel cards
    return this.site.mobileView ? 300 : 400;
  }

  get srcSet() {
    if (!this.hasThumbnail) {
      return "";
    }

    const srcSetArray = [];

    this.responsiveRatios.forEach((ratio) => {
      const target = ratio * this.displayWidth;
      const match = this.topic.thumbnails.find(
        (t) => t.url && t.max_width === target
      );
      if (match) {
        srcSetArray.push(`${match.url} ${ratio}x`);
      }
    });

    if (srcSetArray.length === 0 && this.original) {
      srcSetArray.push(`${this.original.url} 1x`);
    }

    return srcSetArray.join(",");
  }

  get original() {
    return this.topic.thumbnails?.[0];
  }

  get fallbackSrc() {
    if (!this.hasThumbnail) {
      return "";
    }

    const largeEnough = this.topic.thumbnails.filter((t) => {
      if (!t.url) {
        return false;
      }
      return (
        t.max_width >
        this.displayWidth *
          this.responsiveRatios[this.responsiveRatios.length - 1]
      );
    });

    if (largeEnough.length > 0) {
      return largeEnough[largeEnough.length - 1].url;
    }

    return this.original?.url || "";
  }

  get topicUrl() {
    return this.topic.linked_post_number
      ? this.topic.urlForPostNumber?.(this.topic.linked_post_number) ||
          this.topic.url
      : this.topic.lastUnreadUrl || this.topic.url;
  }

  get placeholderIconName() {
    const raw = settings?.thumbnail_placeholder_icon || "fa-image";
    return raw.replace?.(/^fa-/, "") || "image";
  }

  <template>
    <div class="carousel-topic-card">
      <a href={{this.topicUrl}} class="carousel-topic-card__link">
        <div class="carousel-topic-card__thumbnail">
          {{#if this.hasThumbnail}}
            <img
              class="main-thumbnail"
              src={{this.fallbackSrc}}
              srcset={{this.srcSet}}
              width={{this.original.width}}
              height={{this.original.height}}
              loading="lazy"
              alt={{this.topic.title}}
            />
          {{else}}
            <div class="thumbnail-placeholder" aria-hidden="true">
              {{dIcon this.placeholderIconName}}
            </div>
          {{/if}}
        </div>

        <div class="carousel-topic-card__content">
          <h3 class="carousel-topic-card__title">{{this.topic.title}}</h3>
        </div>
      </a>
    </div>
  </template>
}
