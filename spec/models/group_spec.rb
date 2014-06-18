require 'spec_helper'

describe Group do

  before {
    @group = Group.new(name: "group")    
  }

  subject { @group }

  #fields
  it { should respond_to(:name) }
  it { should respond_to(:default_label) }
  it { should respond_to(:id) }

  #functions
  it { should respond_to(:properties) }
  it { should respond_to(:entities) }
  it { should respond_to(:group_property_relationships) }
  it { should respond_to(:entity_group_relationships) }
  it { should respond_to(:entity_relations) }
  it { should respond_to(:property_relations) }
  it { should respond_to(:relation_for) }
  it { should respond_to(:own!) }
  it { should respond_to(:serve!) }
  it { should respond_to(:flee!) }
  it { should respond_to(:flee_all!) }
  it { should respond_to(:owns?) }
  it { should respond_to(:serves?) }
  it { should respond_to(:property_relations) }
  it { should respond_to(:disown!) }
  it { should respond_to(:disown_all!) }
  it { should respond_to(:update_order) }
  it { should respond_to(:first!) }
  it { should respond_to(:first) }
  it { should respond_to(:up!) }
  it { should respond_to(:down!) }
  it { should respond_to(:last) }
  it { should respond_to(:last!) }

  describe "when name is not present" do
    before { @group.name = " " }
    it { should_not be_valid }
  end

  describe "#own!" do
    it "should create a GroupPropertyRelationship between the group and the given property" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")

      @group.own! @p1

      GroupPropertyRelationship.find_by(group_id: @group.id, property_id: @p1.id).property.should eq @p1
    end
  end

  describe "#serve!" do
    it "should create an EntityGroupRelationship between the group and the given entity" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e")

      @group.serve! @e1

      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).entity.should eq @e1
    end
  end

  describe "#serves?" do
    it "should return true if there exists an EntityGroupRelationship between the group and the given entity" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e")

      @group.serve! @e1

      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).entity.should eq @e1

      @group.serves?(@e1).should eq(true)
    end
  end

  describe "#owns?" do
    it "should return true if there exists a GroupPropertyRelationship between the group and the property" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")

      @group.own!(@p1)
      GroupPropertyRelationship.find_by(group_id: @group.id, property_id: @p1.id).should_not eq(nil)

      @group.owns?(@p1).should eq(true)
    end
  end

  describe "#disown!" do
    it "should destroy the GroupPropertyRelationship between the group and the given property" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")

      @group.own!(@p1)

      GroupPropertyRelationship.find_by(group_id: @group.id, property_id: @p1.id).should_not eq(nil)

      @group.disown!(@p1)

      GroupPropertyRelationship.find_by(group_id: @group.id, property_id: @p1.id).should eq(nil)
    end
  end

  describe "#disown_all!" do
    it "should destroy all GroupPropertyRelationships associated with the group" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")
      @p2 = Property.create!(name: "p2")
      @p3 = Property.create!(name: "p3")

      @group.own!(@p1)
      @group.own!(@p2)
      @group.own!(@p3)

      @group.properties.include?(@p1).should eq(true)
      @group.properties.include?(@p2).should eq(true)
      @group.properties.include?(@p3).should eq(true)

      @group.disown_all!

      @group.properties.include?(@p1).should eq(false)
      @group.properties.include?(@p2).should eq(false)
      @group.properties.include?(@p3).should eq(false)
    end
  end

  describe "#flee!" do
    it "should destroy the EntityGroupRelationship between the group and the given entity" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e")

      @group.serve! @e1
      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).should_not eq nil

      @group.flee! @e1
      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).should eq nil
    end
  end

  describe "#flee_all!" do
    it "should destroy all EntityGroupRelationships associated with the group" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @group.serve! @e1
      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).should_not eq nil
      @group.serve! @e2
      EntityGroupRelationship.find_by(entity_id: @e2.id, group_id: @group.id).should_not eq nil
      @group.serve! @e2
      EntityGroupRelationship.find_by(entity_id: @e2.id, group_id: @group.id).should_not eq nil

      @group.flee_all!
      EntityGroupRelationship.find_by(entity_id: @e1.id, group_id: @group.id).should eq nil
      EntityGroupRelationship.find_by(entity_id: @e2.id, group_id: @group.id).should eq nil
      EntityGroupRelationship.find_by(entity_id: @e3.id, group_id: @group.id).should eq nil
    end
  end

  describe "#properties" do
    it "should return the properties associated to this group" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")
      @p2 = Property.create!(name: "p2")
      @p3 = Property.create!(name: "p3")

      @group.own!(@p1)
      @group.own!(@p2)

      @group.properties.include?(@p1).should eq(true)
      @group.properties.include?(@p2).should eq(true)
      @group.properties.include?(@p3).should eq(false)
    end
  end

  describe "#entities" do
    it "should return the entities associated to the group" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      @group.serve! @e1
      @group.serve! @e2
      @group.serve! @e3

      @group.entities.include?(@e1).should eq true
      @group.entities.include?(@e2).should eq true
      @group.entities.include?(@e3).should eq true
    end
  end

  describe "#entity_relations" do
    it "should return the EntityGroupRelationships associated with the group" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      r1 = @group.serve! @e1
      r2 = @group.serve! @e2
      r3 = @group.serve! @e3

      @group.entity_relations.include?(r1).should eq true
      @group.entity_relations.include?(r2).should eq true
      @group.entity_relations.include?(r3).should eq true
    end
  end

  describe "#property_relations" do
    it "should return the GroupPropertyRelationships associated with the group" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")
      @p2 = Property.create!(name: "p2")
      @p3 = Property.create!(name: "p3")

      r1 = @group.own!(@p1)
      r2 = @group.own!(@p2)

      @group.property_relations.include?(r1).should eq(true)
      @group.property_relations.include?(r2).should eq(true)
    end
  end

  describe "#relation_for" do
    it "should return the relationship for the given property" do
      @group = Group.create!(name: "g")
      @p1 = Property.create!(name: "p1")
      @p2 = Property.create!(name: "p2")
      @p3 = Property.create!(name: "p3")

      r1 = @group.own! @p1
      r2 = @group.own! @p2
      r3 = @group.own! @p3

      @group.relation_for(@p2).should eq(r2) 
    end

    it "should return the relationship for the given entity" do
      @group = Group.create!(name: "g")
      @e1 = Entity.create!(name: "e1")
      @e2 = Entity.create!(name: "e2")
      @e3 = Entity.create!(name: "e3")

      r1 = @group.serve! @e1
      r2 = @group.serve! @e2
      r3 = @group.serve! @e3

      @group.relation_for(@e2).should eq(r2) 
    end
  end

  

  describe "Property Relation Ordering" do

    describe "#first" do
      it "should return the property which comes first in ordering for the group" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.first.should eq @p1
        @group.own! @p2
        @group.first.should eq @p1
        @group.own! @p3
        @group.first.should eq @p1
      end
    end

    describe "#last" do
      it "should return the property which comes last in ordering for the group" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.last.should eq @p1
        @group.own! @p2
        @group.last.should eq @p2
        @group.own! @p3
        @group.last.should eq @p3
      end
    end

    describe "#first!" do
      it "should not move any property ordering if the given property is already first" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.first.should eq @p1
        @group.property_relations[1].property.should eq @p2
        @group.property_relations[2].property.should eq @p3

        @group.first!(@p1).should eq nil

        @group.first.should eq @p1
        @group.property_relations[1].property.should eq @p2
        @group.property_relations[2].property.should eq @p3
      end

      it "should set the given property to be first in ordering for the group" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.first.should eq @p1

        @group.first! @p3

        @group.first.should eq @p3
      end

      it "should move all other properties down in order" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.first.should eq @p1

        @group.property_relations[1].property.should eq @p2
        @group.property_relations[2].property.should eq @p3

        @group.first! @p3

        @group.property_relations[1].property.should eq @p1
        @group.property_relations[2].property.should eq @p2
      end
    end

    describe "#last!" do
      it "should not move any property ordering if the given property is already last" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.last.should eq @p3
        @group.property_relations[0].property.should eq @p1
        @group.property_relations[1].property.should eq @p2

        @group.last!(@p3).should eq nil

        @group.last.should eq @p3
        @group.property_relations[0].property.should eq @p1
        @group.property_relations[1].property.should eq @p2
      end

      it "should set the given property to be last in ordering for the group" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.last.should eq @p3

        @group.last! @p1

        @group.last.should eq @p1
      end

      it "should move all other properties up in order" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.last.should eq @p3

        @group.property_relations[0].property.should eq @p1
        @group.property_relations[1].property.should eq @p2

        @group.last! @p1

        @group.property_relations[0].property.should eq @p2
        @group.property_relations[1].property.should eq @p3
      end
    end

    describe "#up!" do
      it "should shouldn't make any changes if the property is already first" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p1).order.should eq 0
        @group.relation_for(@p2).order.should eq 1
        @group.relation_for(@p3).order.should eq 2

        @group.up! @p1
        
        @group.relation_for(@p1).order.should eq 0
        @group.relation_for(@p2).order.should eq 1
        @group.relation_for(@p3).order.should eq 2
      end

      it "should move the given property up in ordering for the group (decrement its order)" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p3).order.should eq 2

        @group.up! @p3

        @group.relation_for(@p3).order.should eq 1
      end

      it "should move the property above it down (increment its order)" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p2).order.should eq 1

        @group.up! @p3

        @group.relation_for(@p2).order.should eq 2
      end
    end

    describe "#down!" do
      it "should shouldn't make any changes if the property is already last" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p1).order.should eq 0
        @group.relation_for(@p2).order.should eq 1
        @group.relation_for(@p3).order.should eq 2

        @group.down! @p3

        @group.relation_for(@p1).order.should eq 0
        @group.relation_for(@p2).order.should eq 1
        @group.relation_for(@p3).order.should eq 2
      end

      it "should move the given property down in ordering for the group (increment its order)" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p1).order.should eq 0

        @group.down! @p1

        @group.relation_for(@p1).order.should eq 1
      end

      it "should move the property below it up (decrement its order)" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @group.own! @p1
        @group.own! @p2
        @group.own! @p3
        @group.relation_for(@p2).order.should eq 1

        @group.down! @p1

        @group.relation_for(@p2).order.should eq 0
      end
    end

    describe "Property order indexing" do
      it "should return the relationship for the property at the given order index" do
        @group = Group.create!(name: "g")
        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        r1 = @group.own! @p1
        r2 = @group.own! @p2
        r3 = @group.own! @p3

        @group.first! @p3

        @group.property_relations[0].property.should eq @p3
        @group.property_relations[1].property.should eq @p1
        @group.property_relations[2].property.should eq @p2
      end
    end
  end
end