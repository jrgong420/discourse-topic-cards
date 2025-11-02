import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";

/**
 * TopicByline Component
 *
 * Renders the topic author (OP) with avatar and optional publish date.
 *
 * BEM Structure:
 * - .topic-card__byline (container)
 *   - .topic-card__op (original poster with avatar)
 *   - .topic-card__meta-sep (separator bullet)
 *   - .topic-card__publish-date (creation date)
 */
const TopicByline = <template>
  <div class="topic-card__byline">
    <div class="topic-card__op">
      <UserLink @user={{@topic.creator}}>
        {{avatar @topic.creator imageSize="tiny"}}
        <span class="username">
          {{@topic.creator.username}}
        </span>
      </UserLink>
    </div>
    {{#if settings.show_publish_date}}
      <span class="topic-card__meta-sep" aria-hidden="true">•</span>
      <span class="topic-card__publish-date">
        {{formatDate @topic.createdAt format="medium-with-ago"}}
      </span>
    {{/if}}
  </div>
</template>;

export default TopicByline;
