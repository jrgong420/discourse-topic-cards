# frozen_string_literal: true

RSpec.describe "Card style configurations", type: :system do
  fab!(:theme) { upload_theme_component }
  fab!(:category)
  fab!(:topic1) { Fabricate(:topic, category: category) }
  fab!(:topic2) { Fabricate(:topic, category: category) }

  before do
    theme.set_field(target: :settings, name: :yaml, value: <<~YAML)
      show_on_categories: ""
      card_style_desktop: #{desktop_style}
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
        show_on_categories: ""
        card_style_desktop: list
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
        show_on_categories: ""
        card_style_desktop: grid
        card_style_mobile: grid
        set_card_max_width: true
        card_max_width: 360
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
        show_on_categories: ""
        card_style_desktop: grid
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
        show_on_categories: ""
        card_style_desktop: list
        card_style_mobile: grid
        set_card_max_height: true
        card_max_height: 275
        set_card_max_width: true
        card_max_width: 360
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
end

