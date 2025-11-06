import categoryLink from "discourse/helpers/category-link";
import discourseTags from "discourse/helpers/discourse-tags";

/**
 * TopicTagsInline Component
 *
 * Renders category badge and tags inline for topic cards.
 * Shows category if present, followed by tags.
 *
 * BEM Structure:
 * - .topic-card__tags (container for category and tags)
 */
const TopicTagsInline = <template>
  {{#if @topic.category}}
    <div class="topic-card__tags">
      {{categoryLink @topic.category}}
      {{#if @topic.tags}}
        {{discourseTags @topic mode="list"}}
      {{/if}}
    </div>
  {{else if @topic.tags}}
    <div class="topic-card__tags">
      {{discourseTags @topic mode="list"}}
    </div>
  {{/if}}
</template>;

export default TopicTagsInline;
