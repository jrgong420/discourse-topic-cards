# frozen_string_literal: true

RSpec.describe "Card style configurations", type: :system do
  fab!(:theme) { upload_theme_component }
  fab!(:category)
  fab!(:topic1) { Fabricate(:topic, category: category) }
  fab!(:topic2) { Fabricate(:topic, category: category) }

  before do
    # Set up category-based styling
    # For desktop: use list_view_categories or grid_view_categories based on desktop_style
    # For mobile: use card_style_mobile setting
    list_categories = desktop_style == "list" ? category.id.to_s : ""
    grid_categories = desktop_style == "grid" ? category.id.to_s : ""

    theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
      list_view_categories: "#{list_categories}"
      grid_view_categories: "#{grid_categories}"
      card_style_mobile: #{mobile_style}
    YAML
    theme.save!
  end

  shared_examples "applies correct card style classes" do |viewport, expected_style|
    it "applies #{expected_style} style classes on #{viewport}" do
      if viewport == :mobile
        page.driver.browser.manage.window.resize_to(375, 667)
      else
        page.driver.browser.manage.window.resize_to(1280, 800)
      end

      visit "/c/#{category.slug}/#{category.id}"
      
      expect(page).to have_css(".topic-cards-list--#{expected_style}")
      expect(page).to have_css(".topic-card--#{expected_style}")
    end
  end

  context "when desktop: list, mobile: list" do
    let(:desktop_style) { "list" }
    let(:mobile_style) { "list" }

    include_examples "applies correct card style classes", :desktop, "list"
    include_examples "applies correct card style classes", :mobile, "list"
  end

  context "when desktop: list, mobile: grid" do
    let(:desktop_style) { "list" }
    let(:mobile_style) { "grid" }

    include_examples "applies correct card style classes", :desktop, "list"
    include_examples "applies correct card style classes", :mobile, "grid"
  end

  context "when desktop: grid, mobile: list" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "list" }

    include_examples "applies correct card style classes", :desktop, "grid"
    include_examples "applies correct card style classes", :mobile, "list"
  end

  context "when desktop: grid, mobile: grid" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "grid" }

    include_examples "applies correct card style classes", :desktop, "grid"
    include_examples "applies correct card style classes", :mobile, "grid"
  end

  context "card content rendering" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "list" }

    before do
      visit "/c/#{category.slug}/#{category.id}"
    end

    it "renders thumbnail component" do
      expect(page).to have_css(".topic-card__thumbnail")
    end

    it "renders topic metadata" do
      expect(page).to have_css(".topic-card__metadata")
    end

    it "renders topic title" do
      expect(page).to have_css(".link-top-line")
    end
  end

  context "max-height for list cards" do
    let(:desktop_style) { "list" }
    let(:mobile_style) { "list" }

    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: ""
        card_style_mobile: list
        set_card_max_height: true
        card_max_height: 275
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
    end

    it "applies has-max-height class to list cards" do
      expect(page).to have_css(".topic-card--list.has-max-height")
    end

    it "does not apply has-max-height to grid cards" do
      expect(page).not_to have_css(".topic-card--grid.has-max-height")
    end
  end

  context "max-width for grid cards" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "grid" }

    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        card_style_mobile: grid
        set_grid_card_max_width: true
        grid_card_max_width: 360
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
    end

    it "applies has-max-width class to grid cards" do
      expect(page).to have_css(".topic-card--grid.has-max-width")
    end

    it "does not apply has-max-width to list cards" do
      expect(page).not_to have_css(".topic-card--list.has-max-width")
    end
  end

  context "grid height for grid cards on desktop" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "grid" }

    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        card_style_mobile: grid
        set_card_grid_height: true
        card_grid_height: 420
      YAML
      theme.save!
    end

    it "applies has-grid-height class to grid cards on desktop" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-card--grid.has-grid-height")
    end

    it "does not apply has-grid-height to grid cards on mobile" do
      page.driver.browser.manage.window.resize_to(375, 667)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).not_to have_css(".topic-card--grid.has-grid-height")
    end
  end

  context "independent max-dimension settings" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: ""
        card_style_mobile: grid
        set_card_max_height: true
        card_max_height: 275
        set_grid_card_max_width: true
        grid_card_max_width: 360
      YAML
      theme.save!
    end

    it "applies max-height to list cards on desktop" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-card--list.has-max-height")
      expect(page).not_to have_css(".topic-card--list.has-max-width")
    end

    it "applies max-width to grid cards on mobile" do
      page.driver.browser.manage.window.resize_to(375, 667)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-card--grid.has-max-width")
      expect(page).not_to have_css(".topic-card--grid.has-max-height")
    end
  end

  context "separator visibility across routes" do
    let(:desktop_style) { "grid" }
    let(:mobile_style) { "list" }

    before do
      # Create a pinned topic to trigger separator
      Fabricate(:topic, category: category, pinned_at: Time.zone.now)
    end

    it "maintains separator visibility in grid layout" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"

      # Check separator is present and visible
      expect(page).to have_css(".topic-list-item-separator")
      expect(page).to have_css(".topic-list-item-separator td.topic-list-data")
    end

    it "maintains separator visibility in list layout after navigation" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"

      # Navigate to latest and back
      visit "/latest"
      visit "/c/#{category.slug}/#{category.id}"

      # Separator should still be visible
      expect(page).to have_css(".topic-list-item-separator")
    end
  end

  context "per-category styling" do
    fab!(:list_category, :category)
    fab!(:grid_category, :category)
    fab!(:unconfigured_category, :category)

    before do
      Fabricate(:topic, category: list_category)
      Fabricate(:topic, category: grid_category)
      Fabricate(:topic, category: unconfigured_category)

      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{list_category.id}"
        grid_view_categories: "#{grid_category.id}"
        card_style_mobile: grid
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
    end

    it "applies list style to categories in list_view_categories" do
      visit "/c/#{list_category.slug}/#{list_category.id}"
      expect(page).to have_css(".topic-cards-list--list")
      expect(page).to have_css(".topic-card--list")
    end

    it "applies grid style to categories in grid_view_categories" do
      visit "/c/#{grid_category.slug}/#{grid_category.id}"
      expect(page).to have_css(".topic-cards-list--grid")
      expect(page).to have_css(".topic-card--grid")
    end

    it "does not apply topic cards to unconfigured categories" do
      visit "/c/#{unconfigured_category.slug}/#{unconfigured_category.id}"
      expect(page).not_to have_css(".topic-cards-list")
      expect(page).not_to have_css(".topic-card")
    end
  end

  context "category appears in both settings (grid priority)" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: "#{category.id}"
        card_style_mobile: grid
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
    end

    it "applies grid style when category is in both settings" do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-cards-list--grid")
      expect(page).to have_css(".topic-card--grid")
      expect(page).not_to have_css(".topic-card--list")
    end
  end

  context "empty category settings (default behavior)" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: ""
        card_style_mobile: grid
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
    end

    it "applies list style everywhere when both settings are empty" do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-cards-list--list")
      expect(page).to have_css(".topic-card--list")
    end
  end
end

