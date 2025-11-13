# frozen_string_literal: true

RSpec.describe "Subcategory Carousel", system: true do
  fab!(:parent_category) { Fabricate(:category, name: "Parent Category") }
  fab!(:subcategory1) { Fabricate(:category, parent_category: parent_category, name: "Subcategory 1") }
  fab!(:subcategory2) { Fabricate(:category, parent_category: parent_category, name: "Subcategory 2") }
  fab!(:subcategory3) { Fabricate(:category, parent_category: parent_category, name: "Subcategory 3") }
  let!(:theme) { upload_theme_component }

  before do
    # Enable subcategory carousel for parent category
    theme.update_setting(:subcategory_carousel_categories, parent_category.id.to_s)
    theme.update_setting(:subcategory_carousel_min_children, 2)
    theme.save!
  end

  context "when subcategory carousel is enabled" do
    it "renders the carousel on category page with multiple subcategories" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel", wait: 5)
      expect(page).to have_css(".subcategory-carousel__viewport")
      expect(page).to have_css(".subcategory-carousel__container")
    end

    it "displays navigation arrows" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel__arrow--prev", wait: 5)
      expect(page).to have_css(".subcategory-carousel__arrow--next")
    end

    it "displays pagination dots" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel__dots", wait: 5)
      expect(page).to have_css(".subcategory-carousel__dot")
    end

    it "wraps subcategory items as slides" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel__slide", wait: 5)
      slides = page.all(".subcategory-carousel__slide")
      expect(slides.count).to be >= 2
    end
  end

  context "when category has fewer than minimum subcategories" do
    fab!(:single_parent) { Fabricate(:category, name: "Single Parent") }
    fab!(:single_sub) { Fabricate(:category, parent_category: single_parent, name: "Only Sub") }

    before do
      theme.update_setting(:subcategory_carousel_categories, single_parent.id.to_s)
      theme.save!
    end

    it "does not render the carousel" do
      visit "/c/#{single_parent.slug}/#{single_parent.id}"

      expect(page).not_to have_css(".subcategory-carousel")
    end
  end

  context "when subcategory carousel is not enabled for category" do
    fab!(:other_category) { Fabricate(:category, name: "Other Category") }
    fab!(:other_sub1) { Fabricate(:category, parent_category: other_category) }
    fab!(:other_sub2) { Fabricate(:category, parent_category: other_category) }

    it "does not render the carousel" do
      visit "/c/#{other_category.slug}/#{other_category.id}"

      expect(page).not_to have_css(".subcategory-carousel")
    end
  end

  context "route gating" do
    it "only displays on discovery.category route" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel", wait: 5)
    end

    it "does not display on home page" do
      visit "/"

      expect(page).not_to have_css(".subcategory-carousel")
    end

    it "does not display on latest page" do
      visit "/latest"

      expect(page).not_to have_css(".subcategory-carousel")
    end
  end

  context "accessibility" do
    it "has proper ARIA role and label for carousel container" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      carousel = page.find(".subcategory-carousel", wait: 5)
      expect(carousel["role"]).to eq("region")
      expect(carousel["aria-label"]).to be_present
    end

    it "navigation arrows have ARIA labels" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      prev_button = page.find(".subcategory-carousel__arrow--prev", wait: 5)
      next_button = page.find(".subcategory-carousel__arrow--next")

      expect(prev_button["aria-label"]).to be_present
      expect(next_button["aria-label"]).to be_present
    end

    it "pagination dots have proper ARIA attributes" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      dots_container = page.find(".subcategory-carousel__dots", wait: 5)
      expect(dots_container["role"]).to eq("tablist")

      active_dot = page.find(".subcategory-carousel__dot.is-active")
      expect(active_dot["aria-current"]).to eq("true")
    end

    it "navigation buttons are keyboard accessible" do
      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      prev_button = page.find(".subcategory-carousel__arrow--prev", wait: 5)
      next_button = page.find(".subcategory-carousel__arrow--next")

      # Buttons should be focusable (type="button")
      expect(prev_button["type"]).to eq("button")
      expect(next_button["type"]).to eq("button")
    end
  end

  context "respects minimum children setting" do
    it "renders when subcategories >= min_children" do
      theme.update_setting(:subcategory_carousel_min_children, 3)
      theme.save!

      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).to have_css(".subcategory-carousel", wait: 5)
    end

    it "does not render when subcategories < min_children" do
      theme.update_setting(:subcategory_carousel_min_children, 4)
      theme.save!

      visit "/c/#{parent_category.slug}/#{parent_category.id}"

      expect(page).not_to have_css(".subcategory-carousel")
    end
  end
end

