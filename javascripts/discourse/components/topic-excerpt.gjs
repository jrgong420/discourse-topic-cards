import dirSpan from "discourse/helpers/dir-span";

/**
 * TopicExcerpt Component
 *
 * Renders the topic excerpt with proper text direction handling.
 *
 * BEM Structure:
 * - .topic-card__excerpt (container)
 *   - .topic-card__excerpt-text (text content with line clamping)
 */
const TopicExcerpt = <template>
  <div class="topic-card__excerpt">
    <div class="topic-card__excerpt-text">
      {{dirSpan @topic.escapedExcerpt htmlSafe="true"}}
    </div>
  </div>
</template>;

export default TopicExcerpt;
