import CategoryLink from "discourse/components/category-link";
import DiscourseTag from "discourse/components/discourse-tag";

const TopicTagsInline = <template>
  {{#if @topic.category}}
    <div class="topic-card__tags">
      <CategoryLink @category={{@topic.category}} />
      {{#each @topic.tags as |tag|}}
        <DiscourseTag @tag={{tag}} />
      {{/each}}
    </div>
  {{else if @topic.tags}}
    <div class="topic-card__tags">
      {{#each @topic.tags as |tag|}}
        <DiscourseTag @tag={{tag}} />
      {{/each}}
    </div>
  {{/if}}
</template>;

export default TopicTagsInline;

