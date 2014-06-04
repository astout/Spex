require 'spec_helper'

describe Property do
  
  before {
    @property = Property.new(name: "p", units: "Units", units_short: "U", default_label: "Property", default_value: nil, default_visibility: 0)
  }

  subject { @property }

  #fields
  it { should respond_to(:name) }
  it { should respond_to(:units) }
  it { should respond_to(:units_short) }
  it { should respond_to(:default_label) }
  it { should respond_to(:default_value) }
  it { should respond_to(:default_visibility) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  #functions
  it { should respond_to(:entities) }
  it { should respond_to(:groups) }
  it { should respond_to(:entity_property_relationships) }
  it { should respond_to(:entity_relations) }
  it { should respond_to(:group_property_relationships) }
  it { should respond_to(:group_relations) }
  it { should respond_to(:flee!) }
  it { should respond_to(:flee_all!) }
  it { should respond_to(:utilized_by?) }
  it { should respond_to(:serve!) }
  it { should respond_to(:serves?) }

  describe "when name is not present" do
    before { @property.name = " " }
    it { should_not be_valid }
  end

  describe "#serve!" do
    it "should create a GroupPropertyRelationship between the property and the specified group" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      
      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil

      r1 = @property.serve! @g1

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq r1
    end
  end

  describe "#serves?" do
    it "should return true if there exists a relationship between the property and the given group" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      
      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil

      r1 = @property.serve! @g1

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq r1

      @property.serves?(@g1).should eq true
    end

    it "should return false if no relationship between the property and the given group exists" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq nil

      r1 = @property.serve! @g1

      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq nil

      @property.serves?(@g2).should eq false
    end
  end

  

  describe "flee!" do
    it "should destroy the GroupPropertyRelationship between the property and the given group" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      
      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq nil

      r1 = @property.serve! @g1
      r2 = @property.serve! @g2

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq r1
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq r2

      @property.serves?(@g1).should eq true
      @property.serves?(@g2).should eq true

      @property.flee! @g1

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq r2

      @property.serves?(@g1).should eq false
      @property.serves?(@g2).should eq true
    end
  end

  describe "flee_all!" do
    it "should destroy all GroupPropertyRelationships associated with the property" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @g3 = Group.create!(name: "g3")
      
      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g3.id, property_id: @property.id).should eq nil

      r1 = @property.serve! @g1
      r2 = @property.serve! @g2
      r3 = @property.serve! @g3

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq r1
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq r2
      GroupPropertyRelationship.find_by(group_id: @g3.id, property_id: @property.id).should eq r3

      @property.flee_all!

      GroupPropertyRelationship.find_by(group_id: @g1.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g2.id, property_id: @property.id).should eq nil
      GroupPropertyRelationship.find_by(group_id: @g3.id, property_id: @property.id).should eq nil

      @property.serves?(@g1).should eq false
      @property.serves?(@g2).should eq false
      @property.serves?(@g3).should eq false
    end
  end

  describe "#groups" do
    it "should return an array of groups associated with the property" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")

      @property.serve! @g1
      @property.serve! @g2

      @property.groups.include?(@g1).should eq true
      @property.groups.include?(@g2).should eq true
    end

    it "should should not include any groups not associated with the property" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @g3 = Group.create!(name: "g3")

      @property.serve! @g1
      @property.serve! @g2

      @property.groups.include?(@g1).should eq true
      @property.groups.include?(@g2).should eq true
      @property.groups.include?(@g3).should eq false
    end
  end

  describe "#group_relations" do
    it "should return an array of the GroupPropertyRelationships associating the property and its groups" do

      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")

      r1 = @property.serve! @g1
      r2 = @property.serve! @g2

      @property.group_relations.include?(r1).should eq true
      @property.group_relations.include?(r2).should eq true
      @property.group_relations.count.should eq 2
    end
  end  

  describe "#entities" do
    it "should return an array of the entities associated with the property" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")

      @property.serve! @g1
      @property.serve! @g2

      @property.entities.empty?.should eq true

      @g1.serve! @e1
      @g2.serve! @e2

      @property.entities.include?(@e1).should eq true      
      @property.entities.include?(@e2).should eq true      
    end
  end

  describe "#entity_relations" do
    it "should return all the relationships between the property and its entities" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @g3 = Group.create!(name: "g3")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @property.serve! @g1
      @property.serve! @g2
      @property.serve! @g3

      @property.entities.empty?.should eq true

      @g1.serve! @e1
      @g2.serve! @e2

      r1 = @e1.relation_for_via(@property, @g1)
      r2 = @e2.relation_for_via(@property, @g2)
      r3 = @e2.relation_for_via(@property, @g3)

      @property.entity_relations.include?(r1).should eq true
      @property.entity_relations.include?(r2).should eq true
      @property.entity_relations.include?(r3).should eq false
    end
  end

  describe "#utilized_by?" do
    it "should return true if there exists an EntityPropertyRelationship between the property and the given entity" do

      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @property.serve! @g1
      @property.serve! @g2

      @property.entities.empty?.should eq true

      @property.utilized_by?(@e1).should eq false
      @property.utilized_by?(@e2).should eq false
      @property.utilized_by?(@e3).should eq false

      @g1.serve! @e1
      @g2.serve! @e2

      @property.utilized_by?(@e1).should eq true
      @property.utilized_by?(@e2).should eq true
      @property.utilized_by?(@e3).should eq false
    end

    it "should no longer be utilized by entities after group-entity relations are destroyed" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @property.serve! @g1
      @property.serve! @g2

      @property.entities.empty?.should eq true

      @property.utilized_by?(@e1).should eq false
      @property.utilized_by?(@e2).should eq false
      @property.utilized_by?(@e3).should eq false

      @g1.serve! @e1
      @g2.serve! @e2

      @property.utilized_by?(@e1).should eq true
      @property.utilized_by?(@e2).should eq true
      @property.utilized_by?(@e3).should eq false

      @g1.flee! @e1

      @property.utilized_by?(@e1).should eq false
      @property.utilized_by?(@e2).should eq true
      @property.utilized_by?(@e3).should eq false
    end

    it "should no longer be utilized by entities after group-property relations are destroyed" do
      @property = Property.create!(name: "p1")
      @g1 = Group.create!(name: "g1")
      @g2 = Group.create!(name: "g2")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @property.serve! @g1
      @property.serve! @g2

      @property.entities.empty?.should eq true

      @property.utilized_by?(@e1).should eq false
      @property.utilized_by?(@e2).should eq false
      @property.utilized_by?(@e3).should eq false

      @g1.serve! @e1
      @g2.serve! @e2

      @property.utilized_by?(@e1).should eq true
      @property.utilized_by?(@e2).should eq true
      @property.utilized_by?(@e3).should eq false

      @property.flee! @g2

      @property.utilized_by?(@e1).should eq true
      @property.utilized_by?(@e2).should eq false
      @property.utilized_by?(@e3).should eq false
    end
  end
end
