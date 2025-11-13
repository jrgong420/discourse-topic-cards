/**
 * Subcategory Carousel - Initializer
 *
 * Transforms the native subcategory list on category pages into an Embla carousel
 * when enabled via settings and when the category has multiple visible subcategories.
 *
 * Features:
 * - In-place DOM transformation (preserves native subcategory markup)
 * - Permission-aware subcategory detection
 * - Inherits sizing/behavior from main carousel settings
 * - Idempotent wrapping with cleanup on navigation
 * - Scoped MutationObserver for dynamic subcategory changes
 * - Full keyboard navigation and ARIA support
 *
 * Settings:
 * - subcategory_carousel_categories: List of enabled categories
 * - subcategory_carousel_min_children: Minimum subcategories required (default 2)
 * - Inherits: carousel_* settings for sizing, behavior, and animation
 *
 * @see javascripts/discourse/components/topic-cards-carousel.gjs
 */
import { schedule } from "@ember/runloop";
import { apiInitializer } from "discourse/lib/api";
import loadScript from "discourse/lib/load-script";
import { i18n } from "discourse-i18n";

// Module-scoped state (reset on navigation)
let emblaInstance = null;
let mutationObserver = null;
let isTransformed = false;

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");
  const site = api.container.lookup("service:site");

  /**
   * Cleanup function - destroys Embla, removes wrappers, disconnects observer
   */
  function cleanup() {
    if (emblaInstance) {
      try {
        emblaInstance.destroy();
      } catch {
        // Ignore errors during cleanup
      }
      emblaInstance = null;
    }

    if (mutationObserver) {
      mutationObserver.disconnect();
      mutationObserver = null;
    }

    // Remove carousel wrappers and restore original structure
    const wrapper = document.querySelector(".subcategory-carousel");
    if (wrapper) {
      const container = wrapper.querySelector(
        ".subcategory-carousel__container"
      );
      if (container) {
        // Move slides back to original parent
        const slides = container.querySelectorAll(
          ".subcategory-carousel__slide"
        );
        slides.forEach((slide) => {
          const originalItem = slide.firstElementChild;
          if (originalItem && wrapper.parentElement) {
            wrapper.parentElement.insertBefore(originalItem, wrapper);
          }
        });
      }
      wrapper.remove();
    }

    isTransformed = false;
  }

  /**
   * Get visible subcategories for current category (permission-aware)
   */
  function getVisibleSubcategories(categoryId) {
    if (!site?.categories) {
      return [];
    }
    const categories = Array.isArray(site.categories)
      ? site.categories
      : [];
    return categories.filter((c) => c.parent_category_id === categoryId);
  }

  /**
   * Check if feature is enabled for current category
   */
  function isEnabledForCategory(categoryId) {
    if (!settings.subcategory_carousel_categories) {
      return false;
    }
    const enabledIds = settings.subcategory_carousel_categories
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter((id) => !isNaN(id));
    return enabledIds.includes(categoryId);
  }

  /**
   * Load Embla script if not already loaded
   */
  async function ensureEmblaLoaded() {
    if (window.EmblaCarousel) {
      return;
    }
    const cdnUrl = api.container.lookup("service:site-settings").cdn_url || "";
    const themeId = document
      .querySelector('meta[name="discourse-theme-id"]')
      ?.getAttribute("content");
    const url = `${cdnUrl}/theme-javascripts/embla-carousel.umd.min.js?__ws=${themeId}`;
    await loadScript(url);
  }

  /**
   * Transform native subcategory list into Embla carousel
   */
  async function transformSubcategoryList() {
    // Guard: already transformed
    if (isTransformed) {
      return;
    }

    // Find native subcategory container
    const subcategoryContainer = document.querySelector(
      ".subcategories, .subcategory-list"
    );
    if (!subcategoryContainer) {
      return;
    }

    // Find all subcategory items
    const subcategoryItems = subcategoryContainer.querySelectorAll(
      ".subcategory-list-item, .subcategory"
    );
    if (subcategoryItems.length === 0) {
      return;
    }

    // Load Embla
    await ensureEmblaLoaded();

    // Create carousel structure
    const carouselWrapper = document.createElement("div");
    carouselWrapper.className = "subcategory-carousel";
    carouselWrapper.setAttribute("role", "region");
    carouselWrapper.setAttribute(
      "aria-label",
      i18n(themePrefix("js.subcategory_carousel.carousel_label"))
    );

    const viewport = document.createElement("div");
    viewport.className = "subcategory-carousel__viewport";

    const container = document.createElement("div");
    container.className = "subcategory-carousel__container";

    // Wrap each subcategory item as a slide
    subcategoryItems.forEach((item) => {
      const slide = document.createElement("div");
      slide.className = "subcategory-carousel__slide";
      slide.appendChild(item.cloneNode(true));
      container.appendChild(slide);
    });

    viewport.appendChild(container);
    carouselWrapper.appendChild(viewport);

    // Create navigation controls
    const controls = createControls();
    carouselWrapper.appendChild(controls);

    // Replace original container with carousel
    subcategoryContainer.parentElement.insertBefore(
      carouselWrapper,
      subcategoryContainer
    );
    subcategoryContainer.style.display = "none";

    // Initialize Embla
    await initializeEmbla(viewport);

    isTransformed = true;
  }

  /**
   * Create navigation controls (arrows and dots)
   */
  function createControls() {
    const controls = document.createElement("div");
    controls.className = "subcategory-carousel__controls";

    // Previous button
    const prevBtn = document.createElement("button");
    prevBtn.className = "subcategory-carousel__arrow subcategory-carousel__arrow--prev";
    prevBtn.setAttribute("type", "button");
    prevBtn.setAttribute(
      "aria-label",
      i18n(themePrefix("js.subcategory_carousel.previous_slide"))
    );
    prevBtn.innerHTML = '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z" fill="currentColor"/></svg>';
    prevBtn.addEventListener("click", () => emblaInstance?.scrollPrev());

    // Next button
    const nextBtn = document.createElement("button");
    nextBtn.className = "subcategory-carousel__arrow subcategory-carousel__arrow--next";
    nextBtn.setAttribute("type", "button");
    nextBtn.setAttribute(
      "aria-label",
      i18n(themePrefix("js.subcategory_carousel.next_slide"))
    );
    nextBtn.innerHTML = '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z" fill="currentColor"/></svg>';
    nextBtn.addEventListener("click", () => emblaInstance?.scrollNext());

    // Dots container
    const dotsContainer = document.createElement("div");
    dotsContainer.className = "subcategory-carousel__dots";
    dotsContainer.setAttribute("role", "tablist");

    controls.appendChild(prevBtn);
    controls.appendChild(dotsContainer);
    controls.appendChild(nextBtn);

    return controls;
  }

  /**
   * Initialize Embla carousel instance
   */
  async function initializeEmbla(viewport) {
    if (!window.EmblaCarousel) {
      return;
    }

    // Map speed setting to duration
    const speedMap = { slow: 35, normal: 25, fast: 15 };
    const duration = speedMap[settings.carousel_speed] || 25;

    // Compute slides per view from CSS
    const computeSlidesPerView = () => {
      const cap = settings.carousel_slides_per_view || 3;
      const minWidth = settings.carousel_min_slide_width_px || 320;
      const gap = settings.carousel_slide_gap_px || 16;
      const viewportWidth = viewport.offsetWidth;
      const spv = Math.floor((viewportWidth + gap) / (minWidth + gap));
      return Math.max(1, Math.min(spv, cap));
    };

    const slidesPerView = computeSlidesPerView();

    emblaInstance = window.EmblaCarousel(viewport, {
      align: settings.carousel_align || "start",
      containScroll: "trimSnaps",
      loop: settings.carousel_loop !== false,
      dragFree: settings.carousel_drag_free || false,
      duration,
      skipSnaps: false,
      slidesToScroll: settings.carousel_scroll_by === "1" ? 1 : slidesPerView,
    });

    // Update dots and button states
    const updateUI = () => {
      updateDots();
      updateArrows();
    };

    emblaInstance.on("select", updateUI);
    emblaInstance.on("reInit", updateUI);
    updateUI();
  }

  /**
   * Update pagination dots
   */
  function updateDots() {
    if (!emblaInstance) {
      return;
    }

    const dotsContainer = document.querySelector(
      ".subcategory-carousel__dots"
    );
    if (!dotsContainer) {
      return;
    }

    const scrollSnaps = emblaInstance.scrollSnapList();
    const selectedIndex = emblaInstance.selectedScrollSnap();

    dotsContainer.innerHTML = "";
    scrollSnaps.forEach((_, index) => {
      const dot = document.createElement("button");
      dot.className = "subcategory-carousel__dot";
      dot.setAttribute("type", "button");
      dot.setAttribute("role", "tab");
      dot.setAttribute(
        "aria-label",
        i18n(themePrefix("js.subcategory_carousel.go_to_slide"), {
          number: index + 1,
        })
      );

      if (index === selectedIndex) {
        dot.classList.add("is-active");
        dot.setAttribute("aria-current", "true");
      }

      dot.addEventListener("click", () => emblaInstance.scrollTo(index));
      dotsContainer.appendChild(dot);
    });
  }

  /**
   * Update arrow button states
   */
  function updateArrows() {
    if (!emblaInstance) {
      return;
    }

    const prevBtn = document.querySelector(
      ".subcategory-carousel__arrow--prev"
    );
    const nextBtn = document.querySelector(
      ".subcategory-carousel__arrow--next"
    );

    if (prevBtn) {
      prevBtn.disabled = !emblaInstance.canScrollPrev();
    }
    if (nextBtn) {
      nextBtn.disabled = !emblaInstance.canScrollNext();
    }
  }

  /**
   * Main page change handler
   */
  api.onPageChange(() => {
    // Always cleanup previous state
    cleanup();

    // Guard: only on category route
    const routeName = router.currentRouteName;
    if (!routeName?.startsWith("discovery.category")) {
      return;
    }

    // Get current category
    const category = router.currentRoute?.attributes?.category;
    if (!category?.id) {
      return;
    }

    // Guard: feature not enabled for this category
    if (!isEnabledForCategory(category.id)) {
      return;
    }

    // Get visible subcategories
    const subcategories = getVisibleSubcategories(category.id);
    const minChildren = settings.subcategory_carousel_min_children || 2;

    // Guard: not enough subcategories
    if (subcategories.length < minChildren) {
      return;
    }

    // Transform after render
    schedule("afterRender", () => {
      transformSubcategoryList();
    });
  });
});

