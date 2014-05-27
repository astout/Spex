require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'GZ Spex'" do
      visit root_url
      expect(page).to have_content('GZ Spex')
    end
  end

  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/help'
      expect(page).to have_content('Help')
    end

  end
end