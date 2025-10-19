import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";

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
