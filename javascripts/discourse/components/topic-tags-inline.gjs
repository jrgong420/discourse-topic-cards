import PluginOutlet from "discourse/components/plugin-outlet";
import categoryLink from "discourse/helpers/category-link";
import discourseTags from "discourse/helpers/discourse-tags";
import { hash } from "@ember/helper";


/**
 * TopicTagsInline Component
 *
 * Renders category badge and tags inline for topic cards.
 * Shows category if present, followed by tags.
 *
 * BEM Structure:
 * - .topic-card__tags (container for category and tags)
 *
 * Plugin Outlets:
 * - topic-list-after-category: Renders after the category badge
 */
const TopicTagsInline = <template>
  {{#if @topic.category}}
    <div class="topic-card__tags">
      {{categoryLink @topic.category}}
      <PluginOutlet
        @name="topic-list-after-category"
        @outletArgs={{hash topic=@topic category=@topic.category}}
      />
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

