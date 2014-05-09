require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Goal Zero Tech Specs'" do
      visit '/static_pages/home'
      expect(page).to have_content('GZSpex')
    end
  end

  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have the content 'Goal Zero Tech Specs'" do
      visit '/static_pages/home'
      expect(page).to have_content('GZSpex')
    end
  end
end