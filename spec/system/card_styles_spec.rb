# frozen_string_literal: true

RSpec.describe "Card style configurations", type: :system do
  fab!(:theme) { upload_theme_component }
  fab!(:category) { Fabricate(:category) }
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

  context "when desktop: landscape, mobile: landscape" do
    let(:desktop_style) { "landscape" }
    let(:mobile_style) { "landscape" }

    include_examples "applies correct card style classes", :desktop, "landscape"
    include_examples "applies correct card style classes", :mobile, "landscape"
  end

  context "when desktop: landscape, mobile: portrait" do
    let(:desktop_style) { "landscape" }
    let(:mobile_style) { "portrait" }

    include_examples "applies correct card style classes", :desktop, "landscape"
    include_examples "applies correct card style classes", :mobile, "portrait"
  end

  context "when desktop: portrait, mobile: landscape" do
    let(:desktop_style) { "portrait" }
    let(:mobile_style) { "landscape" }

    include_examples "applies correct card style classes", :desktop, "portrait"
    include_examples "applies correct card style classes", :mobile, "landscape"
  end

  context "when desktop: portrait, mobile: portrait" do
    let(:desktop_style) { "portrait" }
    let(:mobile_style) { "portrait" }

    include_examples "applies correct card style classes", :desktop, "portrait"
    include_examples "applies correct card style classes", :mobile, "portrait"
  end

  context "card content rendering" do
    let(:desktop_style) { "portrait" }
    let(:mobile_style) { "landscape" }

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
end

