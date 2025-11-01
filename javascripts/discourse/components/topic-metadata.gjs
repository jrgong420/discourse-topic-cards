import ActivityCell from "discourse/components/topic-list/item/activity-cell";
import avatar from "discourse/helpers/avatar";
import dIcon from "discourse/helpers/d-icon";
import LikeToggle from "./like-toggle";

const TopicMetadata = <template>
  <div class="topic-card__metadata">
    <div class="right-aligned">
      {{#if settings.show_views}}
        <span class="topic-card__views item">
          {{dIcon "eye"}}
          <span class="number">
            {{@topic.views}}
          </span>
        </span>
      {{/if}}

      {{#if settings.show_likes}}
        <span class="topic-card__likes item">
          <LikeToggle @topic={{@topic}} />
        </span>
      {{/if}}

      {{#if settings.show_reply_count}}
        <span class="topic-card__reply_count item">
          {{dIcon "comment"}}
          <span class="number">
            {{@topic.replyCount}}
          </span>
        </span>
      {{/if}}

      {{#if settings.show_activity}}
        <div class="topic-card__activity item">
          <ActivityCell @topic={{@topic}} />
        </div>
      {{/if}}

      {{! Most recent reply - bottom right }}
      {{#if @topic.lastPoster}}
        <span class="topic-card__most-recent item">
          {{avatar @topic.lastPoster imageSize="tiny"}}
          <ActivityCell @topic={{@topic}} />
        </span>
      {{/if}}
    </div>
  </div>
</template>;

export default TopicMetadata;
