# frozen_string_literal: true

RSpec.describe "Card style configurations", type: :system do
  fab!(:theme) { upload_theme_component }
  fab!(:category)
  fab!(:topic1) { Fabricate(:topic, category: category) }
  fab!(:topic2) { Fabricate(:topic, category: category) }

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

  shared_examples "cards are disabled" do |viewport|
    it "does not apply card classes on #{viewport}" do
      if viewport == :mobile
        page.driver.browser.manage.window.resize_to(375, 667)
      else
        page.driver.browser.manage.window.resize_to(1280, 800)
      end

      visit "/c/#{category.slug}/#{category.id}"

      expect(page).not_to have_css(".topic-cards-list")
      expect(page).not_to have_css(".topic-card")
    end
  end

  context "when desktop: list, mobile: list" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: ""
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: ""
      YAML
      theme.save!
    end

    include_examples "applies correct card style classes", :desktop, "list"
    include_examples "applies correct card style classes", :mobile, "list"
  end

  context "when desktop: list, mobile: grid" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: ""
        mobile_list_view_categories: ""
        mobile_grid_view_categories: "#{category.id}"
      YAML
      theme.save!
    end

    include_examples "applies correct card style classes", :desktop, "list"
    include_examples "applies correct card style classes", :mobile, "grid"
  end

  context "when desktop: grid, mobile: list" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: ""
      YAML
      theme.save!
    end

    include_examples "applies correct card style classes", :desktop, "grid"
    include_examples "applies correct card style classes", :mobile, "list"
  end

  context "when desktop: grid, mobile: grid" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: ""
        mobile_grid_view_categories: "#{category.id}"
      YAML
      theme.save!
    end

    include_examples "applies correct card style classes", :desktop, "grid"
    include_examples "applies correct card style classes", :mobile, "grid"
  end

  context "card content rendering" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: ""
      YAML
      theme.save!
      page.driver.browser.manage.window.resize_to(1280, 800)
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
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: ""
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: ""
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
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: ""
        mobile_grid_view_categories: "#{category.id}"
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
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: ""
        mobile_grid_view_categories: "#{category.id}"
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
        mobile_list_view_categories: ""
        mobile_grid_view_categories: "#{category.id}"
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
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: ""
      YAML
      theme.save!
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

  context "per-category styling on desktop" do
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
        mobile_list_view_categories: ""
        mobile_grid_view_categories: ""
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

  context "category appears in both settings (list priority)" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{category.id}"
        grid_view_categories: "#{category.id}"
        mobile_list_view_categories: "#{category.id}"
        mobile_grid_view_categories: "#{category.id}"
      YAML
      theme.save!
    end

    it "applies list style when category is in both settings on desktop" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-cards-list--list")
      expect(page).to have_css(".topic-card--list")
      expect(page).not_to have_css(".topic-card--grid")
    end

    it "applies list style when category is in both settings on mobile" do
      page.driver.browser.manage.window.resize_to(375, 667)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".topic-cards-list--list")
      expect(page).to have_css(".topic-card--list")
      expect(page).not_to have_css(".topic-card--grid")
    end
  end

  context "empty category settings (cards disabled)" do
    before do
      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: ""
        grid_view_categories: ""
        mobile_list_view_categories: ""
        mobile_grid_view_categories: ""
      YAML
      theme.save!
    end

    it "disables cards on desktop when both desktop settings are empty" do
      page.driver.browser.manage.window.resize_to(1280, 800)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).not_to have_css(".topic-cards-list")
      expect(page).not_to have_css(".topic-card")
    end

    it "disables cards on mobile when both mobile settings are empty" do
      page.driver.browser.manage.window.resize_to(375, 667)
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).not_to have_css(".topic-cards-list")
      expect(page).not_to have_css(".topic-card")
    end
  end

  context "independent mobile and desktop settings" do
    fab!(:desktop_only_category, :category)
    fab!(:mobile_only_category, :category)

    before do
      Fabricate(:topic, category: desktop_only_category)
      Fabricate(:topic, category: mobile_only_category)

      theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
        list_view_categories: "#{desktop_only_category.id}"
        grid_view_categories: ""
        mobile_list_view_categories: "#{mobile_only_category.id}"
        mobile_grid_view_categories: ""
      YAML
      theme.save!
    end

    it "shows cards on desktop for desktop-configured category only" do
      page.driver.browser.manage.window.resize_to(1280, 800)

      visit "/c/#{desktop_only_category.slug}/#{desktop_only_category.id}"
      expect(page).to have_css(".topic-cards-list--list")

      visit "/c/#{mobile_only_category.slug}/#{mobile_only_category.id}"
      expect(page).not_to have_css(".topic-cards-list")
    end

    it "shows cards on mobile for mobile-configured category only" do
      page.driver.browser.manage.window.resize_to(375, 667)

      visit "/c/#{mobile_only_category.slug}/#{mobile_only_category.id}"
      expect(page).to have_css(".topic-cards-list--list")

      visit "/c/#{desktop_only_category.slug}/#{desktop_only_category.id}"
      expect(page).not_to have_css(".topic-cards-list")
    end
  end
end

