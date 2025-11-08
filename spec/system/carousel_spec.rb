# frozen_string_literal: true

RSpec.describe "Topic Cards Carousel", system: true do
  fab!(:category) { Fabricate(:category) }
  fab!(:topic1) { Fabricate(:topic, category: category, title: "Featured Topic 1") }
  fab!(:topic2) { Fabricate(:topic, category: category, title: "Featured Topic 2") }
  fab!(:topic3) { Fabricate(:topic, category: category, title: "Featured Topic 3") }
  let!(:theme) { upload_theme_component }

  before do
    # Enable carousel on home page
    theme.update_setting(:carousel_display_location, "home")
    theme.save!
  end

  context "when carousel is enabled" do
    it "renders the carousel on the home page" do
      visit "/"

      expect(page).to have_css(".topic-cards-carousel", wait: 5)
      expect(page).to have_css(".topic-cards-carousel__title")
    end

    it "displays navigation arrows with correct ARIA labels" do
      visit "/"

      expect(page).to have_css("[data-test-prev]", wait: 5)
      expect(page).to have_css("[data-test-next]")

      prev_button = page.find("[data-test-prev]")
      next_button = page.find("[data-test-next]")

      expect(prev_button["aria-label"]).to be_present
      expect(next_button["aria-label"]).to be_present
    end

    it "displays pagination dots when enabled" do
      theme.update_setting(:carousel_show_dots, true)
      theme.save!

      visit "/"

      expect(page).to have_css("[data-test-dots]", wait: 5)
      expect(page).to have_css("[data-test-dot]")
    end

    it "respects max_items setting" do
      theme.update_setting(:carousel_max_items, 2)
      theme.save!

      visit "/"

      # Wait for carousel to load
      expect(page).to have_css(".carousel-topic-card", wait: 5)

      # Should have at most 2 cards
      cards = page.all(".carousel-topic-card")
      expect(cards.count).to be <= 2
    end
  end

  context "when carousel is disabled" do
    it "does not render the carousel" do
      theme.update_setting(:carousel_display_location, "disabled")
      theme.save!

      visit "/"

      expect(page).not_to have_css(".topic-cards-carousel")
    end
  end

  context "route gating" do
    it "displays on discovery.latest" do
      visit "/latest"

      expect(page).to have_css(".topic-cards-carousel", wait: 5)
    end

    it "displays on discovery.top" do
      visit "/top"

      expect(page).to have_css(".topic-cards-carousel", wait: 5)
    end

    it "displays on discovery.categories" do
      visit "/categories"

      expect(page).to have_css(".topic-cards-carousel", wait: 5)
    end
  end

  context "accessibility" do
    it "has proper ARIA role and label for carousel container" do
      visit "/"

      carousel = page.find(".topic-cards-carousel", wait: 5)
      expect(carousel["role"]).to eq("region")
      expect(carousel["aria-label"]).to be_present
    end

    it "navigation buttons are keyboard accessible" do
      visit "/"

      prev_button = page.find("[data-test-prev]", wait: 5)
      next_button = page.find("[data-test-next]")

      # Buttons should be focusable
      prev_button.send_keys(:tab)
      expect(page.evaluate_script("document.activeElement")).to eq(prev_button.native)

      next_button.send_keys(:tab)
      expect(page.evaluate_script("document.activeElement")).to eq(next_button.native)
    end
  end
end

