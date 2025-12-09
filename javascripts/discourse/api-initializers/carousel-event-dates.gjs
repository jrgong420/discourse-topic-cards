import { computed } from "@ember/object";
import { apiInitializer } from "discourse/lib/api";

// Normalize and expose event timing for carousel filtering.
//
// Discourse Calendar / Discourse Post Event serializes event dates on topic-list
// items as `event_starts_at` and `event_ends_at` (see plugin.rb). We derive a
// simple `{ start: Date|null, end: Date|null }` window from those fields so the
// carousel can decide whether an event is upcoming, active, or expired.

export default apiInitializer((api) => {
  api.modifyClass(
    "model:topic",
    (Superclass) =>
      class extends Superclass {
        @computed("event_starts_at", "event_ends_at")
        get carouselEventWindow() {
          const rawStart = this.event_starts_at;
          const rawEnd = this.event_ends_at;

          const start = this._parseEventDate(rawStart, "starts_at");
          const end = this._parseEventDate(rawEnd, "ends_at");

          if (!start && !end) {
            return { start: null, end: null };
          }

          return { start, end };
        }

        _parseEventDate(raw, kind) {
          if (!raw) {
            return null;
          }

          const timestamp = Date.parse(raw);

          if (Number.isNaN(timestamp)) {
            // eslint-disable-next-line no-console
            console.warn(
              `[TopicCardsCarousel] Invalid event ${kind} date for topic ${this.id}:`,
              raw
            );
            return null;
          }

          return new Date(timestamp);
        }

        @computed("carouselEventWindow")
        get hasCarouselEvent() {
          const window = this.carouselEventWindow || { start: null, end: null };
          return Boolean(window.start || window.end);
        }

        @computed("carouselEventWindow")
        get isCarouselEventExpired() {
          const window = this.carouselEventWindow;

          if (!window) {
            return false;
          }

          const { start, end } = window;

          if (!start && !end) {
            return false;
          }

          // Without an end date we treat the event as ongoing and never expired
          if (!end) {
            return false;
          }

          const now = Date.now();
          return end.getTime() < now;
        }

        @computed("carouselEventWindow")
        get isCarouselEventUpcoming() {
          const window = this.carouselEventWindow;

          if (!window) {
            return false;
          }

          const { start, end } = window;

          if (!start && !end) {
            return false;
          }

          // Without a start date we treat the event as already started
          if (!start) {
            return false;
          }

          const now = Date.now();
          return start.getTime() > now;
        }
      }
  );
});
