require 'spec_helper'

describe HubController do

  describe "GET 'main'" do
    it "returns http success" do
      get 'main'
      response.should be_success
    end
  end

  describe "GET 'create_entity'" do
    it "returns http success" do
      get 'create_entity'
      response.should be_success
    end
  end

  describe "GET 'create_group'" do
    it "returns http success" do
      get 'create_group'
      response.should be_success
    end
  end

  describe "GET 'create_property'" do
    it "returns http success" do
      get 'create_property'
      response.should be_success
    end
  end

  describe "GET 'create_entity_group_relation'" do
    it "returns http success" do
      get 'create_entity_group_relation'
      response.should be_success
    end
  end

  describe "GET 'create_group_property_relation'" do
    it "returns http success" do
      get 'create_group_property_relation'
      response.should be_success
    end
  end

end
