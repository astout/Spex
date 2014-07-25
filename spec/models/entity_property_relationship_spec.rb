require 'spec_helper'

describe EntityPropertyRelationship do

  before {
    @epr = EntityPropertyRelationship.new(entity_id: 1, property_id: 1)    
  }

  subject { @epr }

  #fields
  it { should respond_to(:entity) }
  it { should respond_to(:entity_id) }
  it { should respond_to(:property) }
  it { should respond_to(:property_id) }
  it { should respond_to(:group) }
  it { should respond_to(:group_id) }
  it { should respond_to(:egr) }
  it { should respond_to(:id) }
  it { should respond_to(:order) }
  it { should respond_to(:label) }
  it { should respond_to(:value) }
  it { should respond_to(:visibility) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  describe "when entity_id is not present" do
    before { @epr.entity_id = nil }
    it { should_not be_valid }
  end

  describe "when property_id is not present" do
    before { @epr.property_id = nil }
    it { should_not be_valid }
  end

end
