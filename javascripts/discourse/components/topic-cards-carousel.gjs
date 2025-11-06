/**
 * Topic Cards Carousel Component
 *
 * A fully accessible, responsive carousel component that displays featured topics
 * on the Discourse home page. Supports both list and grid layouts, tag filtering,
 * and multiple ordering options.
 *
 * Features:
 * - Lazy loading with IntersectionObserver for performance
 * - Responsive layout switching (list/grid) based on viewport
 * - Embla Carousel integration for smooth navigation
 * - Full keyboard navigation (Left/Right arrows)
 * - ARIA roles and labels for screen readers
 * - Pagination dots with active state indicators
 * - Tag-based filtering and multiple ordering modes
 * - Smooth animations and transitions
 *
 * Settings (configured in settings.yml):
 * - carousel_display_location: Where to show carousel (home/disabled)
 * - carousel_desktop_layout: Desktop layout mode (list/grid)
 * - carousel_mobile_layout: Mobile layout mode (list/grid)
 * - carousel_filter_tags: Pipe-separated tag list for filtering
 * - carousel_max_items: Maximum topics to display (1-20)
 * - carousel_order: Topic ordering (latest/random/popular)
 *
 * @class TopicCardsCarousel
 * @extends Component
 */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { schedule } from "@ember/runloop";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { not } from "truth-helpers";
import { ajax } from "discourse/lib/ajax";
import loadScript from "discourse/lib/load-script";
import { i18n } from "discourse-i18n";
import CarouselTopicCard from "./carousel-topic-card";

/**
 * @class TopicCardsCarousel
 * @extends Component
 */
export default class TopicCardsCarousel extends Component {
  /** @type {Service} Ember Data store for creating Topic model instances */
  @service store;

  /** @type {Array<Topic>} Array of topic model instances to display */
  @tracked topics = [];

  /** @type {boolean} Loading state for initial data fetch */
  @tracked isLoading = true;

  /** @type {string|null} Error message if fetch fails */
  @tracked error = null;

  /** @type {boolean} True if viewport is mobile (≤767px) */
  @tracked isMobile = false;

  /** @type {Array<Array<Topic>>} Topics chunked into slides based on layout */
  @tracked chunkedSlides = [];

  /** @type {number} Currently selected slide index (0-based) */
  @tracked selectedIndex = 0;

  /** @type {Array<Object>} Pagination dots with metadata (idx, label, isActive) */
  @tracked dots = [];

  /** @type {boolean} True if carousel can scroll to previous slide */
  @tracked canScrollPrev = false;

  /** @type {boolean} True if carousel can scroll to next slide */
  @tracked canScrollNext = false;

  /** @type {boolean} True if carousel is visible in viewport (for lazy loading) */
  @tracked isVisible = false;

  /** @type {number} Number of grid columns computed dynamically based on viewport width */
  @tracked gridColumns = 3;

  /** @type {MediaQueryList|null} Media query listener for responsive behavior */
  mediaQueryList = null;

  /** @type {EmblaCarousel|null} Embla carousel instance */
  embla = null;

  /** @type {Promise|null} Promise for lazy-loading Embla script */
  emblaScriptPromise = null;

  /** @type {IntersectionObserver|null} Observer for lazy loading */
  intersectionObserver = null;

  /** @type {ResizeObserver|null} Observer for responsive grid columns */
  resizeObserver = null;

  /** @type {HTMLElement|null} Reference to carousel root element */
  carouselElement = null;

  /** @type {HTMLElement|null} Reference to carousel viewport element */
  viewportElement = null;

  /**
   * Modifier to capture carousel root element reference.
   * Sets up IntersectionObserver when element is inserted.
   */
  captureElement = modifier((element) => {
    this.setupCarousel(element);
  });

  /**
   * Component constructor.
   * Sets up media query listener.
   */
  constructor() {
    super(...arguments);
    this.setupMediaQuery();
  }

  /**
   * Component cleanup lifecycle hook.
   * Removes event listeners and destroys carousel instance.
   */
  willDestroy() {
    super.willDestroy(...arguments);
    if (this.mediaQueryList) {
      this.mediaQueryList.removeEventListener("change", this.handleMediaChange);
    }
    this.destroyEmbla();
    this.destroyIntersectionObserver();
    this.destroyResizeObserver();
  }

  /**
   * Captures reference to carousel root element and sets up IntersectionObserver.
   * Called via {{on "load"}} modifier in template.
   * @param {HTMLElement} element - The carousel root element
   */
  @action
  setupCarousel(element) {
    this.carouselElement = element;

    // Set up IntersectionObserver for lazy loading
    this.intersectionObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !this.isVisible) {
            this.isVisible = true;
            this.fetchTopics();
          }
        });
      },
      {
        rootMargin: "50px",
        threshold: 0.1,
      }
    );

    this.intersectionObserver.observe(element);

    // Set up ResizeObserver for dynamic grid columns (after render)
    schedule("afterRender", () => this.setupResizeObserver());
  }

  /**
   * Cleans up IntersectionObserver to prevent memory leaks.
   */
  destroyIntersectionObserver() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
      this.intersectionObserver = null;
    }
  }

  /**
   * Cleans up Embla carousel instance.
   */
  destroyEmbla() {
    if (this.embla) {
      try {
        this.embla.destroy();
      } catch {}
      this.embla = null;
    }
  }

  /**
   * Lazy loads Embla Carousel library from theme uploads.
   * Uses cached promise to prevent duplicate loads.
   * @returns {Promise<void>}
   */
  async ensureEmblaLoaded() {
    if (window.EmblaCarousel) {
      return;
    }
    if (!this.emblaScriptPromise) {
      const url = settings?.theme_uploads?.embla_carousel;
      if (!url) {
        // eslint-disable-next-line no-console
        console.warn(
          "[Carousel] Missing embla_carousel theme asset. Carousel will not initialize."
        );
        return;
      }
      this.emblaScriptPromise = loadScript(url);
    }
    await this.emblaScriptPromise;
  }

  /**
   * Initializes Embla carousel with configuration.
   * Sets up event listeners for slide changes and navigation state.
   */
  async setupEmbla() {
    await this.ensureEmblaLoaded();
    // Initialize after render to ensure DOM is ready
    schedule("afterRender", () => {
      if (!this.carouselElement) {
        return;
      }
      const viewport = this.carouselElement.querySelector(
        ".topic-cards-carousel__viewport"
      );
      if (!viewport) {
        return;
      }
      this.destroyEmbla();
      try {
        // Enable loop only if there are multiple slides
        const enableLoop = this.chunkedSlides.length > 1;

        this.embla = window.EmblaCarousel(viewport, {
          align: "start",
          containScroll: "trimSnaps",
          loop: enableLoop, // Infinite loop for multiple slides
          dragFree: false,
          duration: 25, // Smooth scroll animation (25 frames)
          skipSnaps: false,
        });
        const onSelect = () => {
          try {
            this.selectedIndex = this.embla.selectedScrollSnap();
            this.canScrollPrev = this.embla.canScrollPrev();
            this.canScrollNext = this.embla.canScrollNext();
            this.updateDotsActive();
            this.updatePeekClasses();
          } catch {}
        };
        this.embla.on("select", onSelect);
        this.embla.on("reInit", onSelect);
        onSelect();
      } catch {}
    });
  }

  /**
   * Navigates to the previous slide.
   */
  @action
  prev() {
    this.embla?.scrollPrev();
  }

  /**
   * Navigates to the next slide.
   */
  @action
  next() {
    this.embla?.scrollNext();
  }

  /**
   * Updates the active state of pagination dots.
   * Called when slide selection changes.
   */
  updateDotsActive() {
    this.dots = (this.dots || []).map((d, i) => ({
      ...d,
      isActive: i === this.selectedIndex,
    }));
  }

  /**
   * Updates peek effect classes (has-prev, has-next) on container.
   * Shows gradient fades when there are slides to navigate to.
   */
  updatePeekClasses() {
    if (!this.carouselElement) {
      return;
    }

    const container = this.carouselElement.querySelector(
      ".topic-cards-carousel__container"
    );
    if (!container) {
      return;
    }

    // Add/remove has-prev class
    if (this.canScrollPrev) {
      container.classList.add("has-prev");
    } else {
      container.classList.remove("has-prev");
    }

    // Add/remove has-next class
    if (this.canScrollNext) {
      container.classList.add("has-next");
    } else {
      container.classList.remove("has-next");
    }
  }

  /**
   * Handles pagination dot clicks.
   * Navigates to the clicked slide.
   * @param {Event} e - Click event
   */
  @action
  onDotClick(e) {
    const idx = parseInt(e.currentTarget?.dataset?.index, 10);
    if (Number.isInteger(idx)) {
      this.embla?.scrollTo(idx);
    }
  }

  /**
   * Handles keyboard navigation (Left/Right arrow keys).
   * @param {KeyboardEvent} e - Keyboard event
   */
  @action
  handleKeyDown(e) {
    // Arrow key navigation when carousel is focused
    if (e.key === "ArrowLeft") {
      e.preventDefault();
      this.prev();
    } else if (e.key === "ArrowRight") {
      e.preventDefault();
      this.next();
    }
  }

  setupMediaQuery() {
    // Use Discourse's mobile breakpoint (768px)
    this.mediaQueryList = window.matchMedia("(max-width: 767px)");
    this.isMobile = this.mediaQueryList.matches;
    this.mediaQueryList.addEventListener("change", this.handleMediaChange);
  }

  /**
   * Sets up ResizeObserver to dynamically compute grid columns based on viewport width.
   * Only active in grid mode.
   */
  setupResizeObserver() {
    if (!this.carouselElement) {
      return;
    }

    const viewport = this.carouselElement.querySelector(
      ".topic-cards-carousel__viewport"
    );
    if (!viewport) {
      return;
    }

    this.viewportElement = viewport;
    this.destroyResizeObserver();

    this.resizeObserver = new ResizeObserver((entries) => {
      for (const entry of entries) {
        this.computeGridColumns(entry.contentRect.width);
      }
    });

    this.resizeObserver.observe(viewport);
    // Initial computation
    this.computeGridColumns(viewport.clientWidth);
  }

  /**
   * Computes the number of grid columns based on viewport width.
   * Formula: min(max_cards_visible, floor((viewportWidth + gap) / (minCardWidth + gap)))
   * @param {number} viewportWidth - Current viewport width in pixels
   */
  computeGridColumns(viewportWidth) {
    if (this.currentLayout !== "grid") {
      this.gridColumns = 1;
      return;
    }

    const maxCards = settings.carousel_max_cards_visible || 3;
    const minCardWidth = settings.carousel_grid_min_card_width || 320;
    const gap = 16; // var(--space-4) ≈ 16px

    // Calculate how many cards fit
    const columns = Math.floor((viewportWidth + gap) / (minCardWidth + gap));
    const cappedColumns = Math.max(1, Math.min(maxCards, columns));

    if (this.gridColumns !== cappedColumns) {
      this.gridColumns = cappedColumns;
      // Re-chunk topics with new column count
      this.rechunkTopics();
    }
  }

  /**
   * Re-chunks topics and guards selectedIndex after column changes.
   */
  rechunkTopics() {
    const previousSlideCount = this.chunkedSlides.length;
    this.chunkTopics();

    // Guard selectedIndex to prevent out-of-bounds
    if (this.selectedIndex >= this.chunkedSlides.length) {
      this.selectedIndex = Math.max(0, this.chunkedSlides.length - 1);
    }

    // Reinitialize Embla if slide count changed
    if (previousSlideCount !== this.chunkedSlides.length) {
      schedule("afterRender", () => this.setupEmbla());
    }
  }

  /**
   * Destroys ResizeObserver instance.
   */
  destroyResizeObserver() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
  }

  @action
  handleMediaChange(e) {
    this.isMobile = e.matches;
    // Recompute grid columns for new viewport
    if (this.viewportElement) {
      this.computeGridColumns(this.viewportElement.clientWidth);
    } else {
      this.chunkTopics();
    }
  }

  /**
   * Returns the current layout mode based on viewport size.
   * Validates layout setting and falls back to 'list' if invalid.
   * @returns {string} 'list' or 'grid'
   */
  get currentLayout() {
    const layout = this.isMobile
      ? settings.carousel_mobile_layout || "list"
      : settings.carousel_desktop_layout || "list";

    // Validate layout value
    const validLayouts = ["list", "grid"];
    if (!validLayouts.includes(layout)) {
      // eslint-disable-next-line no-console
      console.warn(
        `[Carousel] Invalid layout setting: ${layout}. Using default: list`
      );
      return "list";
    }

    return layout;
  }

  /**
   * Returns the number of cards to display per slide based on layout.
   * List mode: 1 card per slide
   * Grid mode: Uses dynamically computed gridColumns
   * @returns {number} Cards per slide
   */
  get cardsPerSlide() {
    if (this.currentLayout === "list") {
      return 1;
    }
    // Grid mode: use dynamically computed columns
    return this.gridColumns;
  }

  /**
   * Helper for slide labels (1-based index for accessibility).
   * @param {number} idx - Zero-based slide index
   * @returns {number} One-based slide number
   */
  slideNumber(idx) {
    return idx + 1;
  }

  /**
   * Chunks topics array into slides based on current layout.
   * Reinitializes Embla carousel after chunking.
   */
  chunkTopics() {
    const perSlide = this.cardsPerSlide;
    const chunks = [];

    for (let i = 0; i < this.topics.length; i += perSlide) {
      chunks.push(this.topics.slice(i, i + perSlide));
    }

    this.chunkedSlides = chunks;

    // Create dots with pre-computed metadata for pagination
    this.dots = this.chunkedSlides.map((_, i) => ({
      idx: i,
      label: i + 1,
      isActive: i === this.selectedIndex,
    }));

    // Reinitialize Embla when slides change
    schedule("afterRender", () => this.setupEmbla());
  }

  /**
   * Validates carousel settings and returns sanitized values.
   * @returns {Object} Validated settings with defaults
   */
  validateSettings() {
    const order = settings.carousel_order || "latest";
    const filterTags = settings.carousel_filter_tags || "";

    // Validate and clamp max_items to safe range (1-20)
    let maxItems = parseInt(settings.carousel_max_items, 10);
    if (isNaN(maxItems) || maxItems < 1) {
      // eslint-disable-next-line no-console
      console.warn(
        `[Carousel] Invalid carousel_max_items: ${settings.carousel_max_items}. Using default: 5`
      );
      maxItems = 5;
    } else if (maxItems > 20) {
      // eslint-disable-next-line no-console
      console.warn(
        `[Carousel] carousel_max_items (${maxItems}) exceeds maximum (20). Clamping to 20.`
      );
      maxItems = 20;
    }

    // Validate order
    const validOrders = ["latest", "random", "popular"];
    if (!validOrders.includes(order)) {
      // eslint-disable-next-line no-console
      console.warn(
        `[Carousel] Invalid carousel_order: ${order}. Using default: latest`
      );
    }

    return { order, maxItems, filterTags };
  }

  async fetchTopics() {
    // Don't fetch if already loaded or not visible yet
    if (this.topics.length > 0 || !this.isVisible) {
      return;
    }

    this.isLoading = true;
    this.error = null;

    try {
      // Validate settings before using them
      const { order, maxItems, filterTags } = this.validateSettings();

      let endpoint = "/latest.json";
      let params = {};

      // Parse tags if specified
      const tags = filterTags
        ? filterTags.split("|").filter((t) => t.trim())
        : [];

      // Determine endpoint based on tag filtering
      if (tags.length > 1) {
        // Multiple tags: use intersection endpoint
        endpoint = `/tags/intersection/${tags.join("/")}.json`;
      } else if (tags.length === 1) {
        // Single tag: use tag-specific endpoint
        endpoint = `/tag/${tags[0]}.json`;
      } else {
        // No tags: use order-based endpoint
        if (order === "popular") {
          endpoint = "/top.json";
          params.period = "weekly"; // Default to weekly for popular
        } else if (order === "latest") {
          endpoint = "/latest.json";
        }
        // For "random", we'll fetch latest and shuffle client-side
      }

      const response = await ajax(endpoint, { data: params });
      let fetchedTopics = response.topic_list?.topics || [];

      // Transform plain JS objects into Discourse Topic model instances
      fetchedTopics = fetchedTopics.map((topicData) => {
        // Create Topic model instance from plain object
        return this.store.createRecord("topic", topicData);
      });

      // Shuffle if random order
      if (order === "random") {
        fetchedTopics = this.shuffleArray([...fetchedTopics]);
      }

      // Limit to max items
      this.topics = fetchedTopics.slice(0, maxItems);

      // Chunk topics based on current layout
      this.chunkTopics();
    } catch (err) {
      this.error =
        err.jqXHR?.responseJSON?.errors?.[0] ||
        "Failed to load topics. Please check your tag filters and try again.";
      // eslint-disable-next-line no-console
      console.error("Carousel fetch error:", err);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Shuffles an array using Fisher-Yates algorithm.
   * Used for random topic ordering.
   * @param {Array} array - Array to shuffle
   * @returns {Array} Shuffled copy of the array
   */
  shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  <template>
    <div class="topic-cards-carousel" {{this.captureElement}}>
      <div class="topic-cards-carousel__header">
        <h2 class="topic-cards-carousel__title">{{i18n
            (themePrefix "js.carousel.featured_topics")
          }}</h2>
      </div>

      {{#if this.isLoading}}
        <div class="topic-cards-carousel__loading">
          <p>{{i18n (themePrefix "js.carousel.loading")}}</p>
        </div>
      {{else if this.error}}
        <div class="topic-cards-carousel__error">
          <p>{{i18n (themePrefix "js.carousel.error") message=this.error}}</p>
        </div>
      {{else if this.topics.length}}
        <div
          class="topic-cards-carousel__container topic-cards-carousel__container--{{this.currentLayout}}"
          role="region"
          aria-label={{i18n (themePrefix "js.carousel.carousel_label")}}
          aria-roledescription="carousel"
          tabindex="0"
          {{on "keydown" this.handleKeyDown}}
        >
          <div class="topic-cards-carousel__viewport">
            <div
              class="topic-cards-carousel__slides"
              role="group"
              aria-live="polite"
            >
              {{#each this.chunkedSlides as |slideTopics idx|}}
                <div
                  class="topic-cards-carousel__slide"
                  role="group"
                  aria-roledescription="slide"
                  aria-label={{i18n
                    (themePrefix "js.carousel.slide_label")
                    current=(this.slideNumber idx)
                    total=this.chunkedSlides.length
                  }}
                >
                  <div
                    class="topic-cards-carousel__slide-grid
                      topic-cards-carousel__slide-grid--cols-{{this.gridColumns}}"
                  >
                    {{#each slideTopics as |topic|}}
                      <div class="topic-cards-carousel__card-wrapper">
                        <CarouselTopicCard @topic={{topic}} />
                      </div>
                    {{/each}}
                  </div>
                </div>
              {{/each}}
            </div>
          </div>

          {{! Navigation arrows - positioned at viewport sides }}
          <button
            type="button"
            class="topic-cards-carousel__arrow topic-cards-carousel__arrow--prev"
            aria-label={{i18n (themePrefix "js.carousel.previous_slide")}}
            disabled={{not this.canScrollPrev}}
            {{on "click" this.prev}}
          >
            ‹
          </button>
          <button
            type="button"
            class="topic-cards-carousel__arrow topic-cards-carousel__arrow--next"
            aria-label={{i18n (themePrefix "js.carousel.next_slide")}}
            disabled={{not this.canScrollNext}}
            {{on "click" this.next}}
          >
            ›
          </button>
        </div>

        {{! Pagination dots - centered below carousel }}
        <div class="topic-cards-carousel__dots">
          {{#each this.dots as |dot|}}
            <button
              type="button"
              class="topic-cards-carousel__dot
                {{if dot.isActive 'is-active'}}"
              data-index={{dot.idx}}
              aria-label={{i18n
                (themePrefix "js.carousel.go_to_slide")
                number=dot.label
              }}
              aria-current={{if dot.isActive "true"}}
              {{on "click" this.onDotClick}}
            ></button>
          {{/each}}
        </div>
      {{else}}
        <div class="topic-cards-carousel__empty">
          <p>{{i18n (themePrefix "js.carousel.empty_state")}}</p>
        </div>
      {{/if}}
    </div>
  </template>
}
