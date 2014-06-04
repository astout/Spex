require 'spec_helper'

describe Entity do

  before {
    @entity = Entity.new(name: "entity")    
  }

  subject { @entity }

  #fields
  it { should respond_to(:name) }
  it { should respond_to(:label) }
  it { should respond_to(:id) }
  it { should respond_to(:img) }

  #functions
  it { should respond_to(:properties) }
  it { should respond_to(:properties_via) }
  it { should respond_to(:groups) }
  it { should respond_to(:entity_property_relationships) }
  it { should respond_to(:entity_group_relationships) }
  it { should respond_to(:group_relations) }
  # it { should respond_to(:relation_at) }
  # it { should respond_to(:relation_at_via) }
  it { should respond_to(:relation_for) }
  it { should respond_to(:relation_for_via) }
  it { should respond_to(:own!) }
  # it { should respond_to(:utilize!) }
  it { should respond_to(:owns?) }
  it { should respond_to(:utilizes?) }
  it { should respond_to(:property_relations) }
  it { should respond_to(:property_relations_via) }
  it { should respond_to(:disown!) }
  it { should respond_to(:disown_all!) }
  it { should respond_to(:update_order) }
  it { should respond_to(:first!) }
  it { should respond_to(:first_via!) }
  it { should respond_to(:first) }
  it { should respond_to(:first_via) }
  it { should respond_to(:up!) }
  it { should respond_to(:down!) }
  it { should respond_to(:up_via!) }
  it { should respond_to(:down_via!) }
  it { should respond_to(:last) }
  it { should respond_to(:last_via) }
  it { should respond_to(:last!) }
  it { should respond_to(:last_via!) }

  describe "when name is not present" do
    before { @entity.name = " " }
    it { should_not be_valid }
  end

  describe "Group Relationships" do

    describe "#own!" do
      it "should create an EntityGroupRelationship between the entity and group" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")

        r = @entity.own!(@group)

        @entity.group_relations.include?(r).should eq(true)
      end

      it "should create EntityPropertyRelationships for the group's properties via the group" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")
        @property1 = Property.create!(name: "p")

        @group.own!(@property1)
        @entity.own!(@group)

        r = EntityPropertyRelationship.find_by(property_id: @property1.id, entity_id: @entity.id)
        @entity.property_relations.include?(r).should eq(true)
      end
    end

    describe "#owns?" do
      it "should be true if there exists a EntityGroupRelationship between the Entity and the group" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")

        @entity.own!(@group)

        @entity.owns?(@group).should eq(true)
      end

      it "should be false if no EntityGroupRelationship exists between the Entity and the group" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")

        @entity.owns?(@group).should eq(false)
      end
    end

    describe "#disown!" do
      it "should destroy the EntityGroupRelationship" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")

        @entity.own!(@group)
        @entity.owns?(@group).should eq(true)

        @entity.disown!(@group)
        @entity.owns?(@group).should eq(false)

        EntityGroupRelationship.find_by(entity_id: @entity.id, group_id: @group.id).should eq(nil)
      end

      it "should destroy the EntityPropertyRelationship for properties associated via the group" do
        @entity = Entity.create!(name: "e")
        @group = Group.create!(name: "g")

        @property = Property.create!(name: "p")

        @group.own!(@property)
        @entity.own!(@group)  
        @entity.utilizes?(@property).should eq(true)

        @entity.disown!(@group)
        @entity.utilizes?(@property).should eq(false)

        EntityPropertyRelationship.find_by(entity_id: @entity.id, group_id: @group.id, property_id: @property.id).should eq(nil)
      end
    end

    describe "#disown_all!" do
      it "should remove all EntityGroupRelationships associated with this entity" do
        @entity = Entity.create!(name: "e")
        @g1 = Group.create!(name: "g1")
        @g2 = Group.create!(name: "g2")
        @g3 = Group.create!(name: "g3")

        @entity.own!(@g1)
        @entity.own!(@g2)
        @entity.own!(@g3)

        @entity.groups.empty?.should eq(false)

        @entity.disown_all!

        @entity.groups.empty?.should eq(true)
        @entity.group_relations.empty?.should eq(true)
      end

      it "should remove all EntityPropertyRelationships associated with this entity and the disowned groups" do
        @entity = Entity.create!(name: "e")
        @g1 = Group.create!(name: "g1")
        @g2 = Group.create!(name: "g2")
        @g3 = Group.create!(name: "g3")

        @entity.own!(@g1)
        @entity.own!(@g2)
        @entity.own!(@g3)

        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @g1.own!(@p1)
        @g2.own!(@p2)
        @g3.own!(@p3)

        @entity.properties.empty?.should eq(false)
        @entity.property_relations.empty?.should eq(false)

        @entity.disown_all!

        @entity.properties.empty?.should eq(true)
        @entity.property_relations.empty?.should eq(true)
      end
    end

    # describe "#relation_at" do
    #   it "should return the EntityGroupRelationship at the order index specified" do
    #     @entity = Entity.create!(name: "e")
    #     @g1 = Group.create!(name: "g1")
    #     @g2 = Group.create!(name: "g2")
    #     @g3 = Group.create!(name: "g3")

    #     @entity.own!(@g1)
    #     @entity.own!(@g2)
    #     @entity.own!(@g3)

    #     @entity.relation_at(0).group.should eq(@g1)
    #     @entity.relation_at(1).group.should eq(@g2)
    #     @entity.relation_at(2).group.should eq(@g3)
    #   end
    # end

    # describe "#relation_at_via" do
    #   it "should return the EntityPropertyRelationship at the order index specified via the specified group" do
    #     @entity = Entity.create!(name: "e")
    #     @g1 = Group.create!(name: "g1")
    #     @g2 = Group.create!(name: "g2")
    #     @g3 = Group.create!(name: "g3")

    #     @p1 = Property.create!(name: "p1")
    #     @p2 = Property.create!(name: "p2")
    #     @p3 = Property.create!(name: "p3")

    #     @g1.own! @p1
    #     @g1.own! @p2
    #     @g1.own! @p3

    #     @g2.own! @p1
    #     @g2.own! @p2
    #     @g2.own! @p3

    #     @g3.own! @p1
    #     @g3.own! @p2
    #     @g3.own! @p3

    #     @entity.own!(@g1)
    #     @entity.own!(@g2)
    #     @entity.own!(@g3)

    #     @entity.relation_at_via(0, @g1).property.should eq(@p1)
    #     @entity.relation_at_via(1, @g1).property.should eq(@p2)
    #     @entity.relation_at_via(2, @g2).property.should eq(@p3)
    #   end
    # end

    describe "#relation_for" do
      it "should return the EntityGroupRelationship that associates this entity to the specified group" do
        @entity = Entity.create!(name: "e")
        @g1 = Group.create!(name: "g1")
        @g2 = Group.create!(name: "g2")
        @g3 = Group.create!(name: "g3")

        r1 = @entity.own!(@g1)
        r2 = @entity.own!(@g2)
        r3 = @entity.own!(@g3)

        @entity.relation_for(@g1).should eq(r1)
        @entity.relation_for(@g2).should eq(r2)
        @entity.relation_for(@g3).should eq(r3)
      end
    end

    describe "#relation_for_via" do
      it "should return the EntityPropertyRelationship that associates this entity to the specified property via the specified group" do
        @entity = Entity.create!(name: "e")
        @g1 = Group.create!(name: "g1")
        @g2 = Group.create!(name: "g2")
        @g3 = Group.create!(name: "g3")

        @p1 = Property.create!(name: "p1")
        @p2 = Property.create!(name: "p2")
        @p3 = Property.create!(name: "p3")

        @g1.own!(@p1)
        @g2.own!(@p2)
        @g3.own!(@p3)

        @entity.own!(@g1)
        @entity.own!(@g2)
        @entity.own!(@g3)

        @entity.relation_for_via(@p1, @g1).property.should eq(@p1)
        @entity.relation_for_via(@p2, @g2).property.should eq(@p2)
        @entity.relation_for_via(@p3, @g3).property.should eq(@p3)
      end
    end

    describe "Group Ordering" do

      describe "#first" do
        it "should return the group that is in the first order of this entity's groups" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.first.should eq(@g1)
          @entity.own!(@g2)
          @entity.first.should eq(@g1)
        end
      end

      describe "#first!" do
        it "should make the given property order first" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.first.should eq(@g1)
          @entity.own!(@g2)
          @entity.first.should eq(@g1)

          @entity.first!(@g2)
          @entity.first.should eq(@g2)
        end

        it "should reorder all other groups" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.first.should eq(@g1)
          @entity.own!(@g2)
          @entity.first.should eq(@g1)

          @entity.first!(@g2)

          @entity.group_relations[1].group.should eq(@g1)
        end
      end

      describe "#up!" do
        it "should move the specified group up" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")
          @g3 = Group.create!(name: "g3")

          @entity.own!(@g1)
          @entity.own!(@g2)
          @entity.own!(@g3)

          @entity.up!(@g3)
          @entity.group_relations[1].group.should eq(@g3)
        end

        it "should move the group above the specified group down" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")
          @g3 = Group.create!(name: "g3")

          @entity.own!(@g1)
          @entity.own!(@g2)
          @entity.own!(@g3)

          @entity.up!(@g3)
          @entity.group_relations[2].group.should eq(@g2)
        end
      end

      describe "#down!" do
        it "should move the specified group down" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")
          @g3 = Group.create!(name: "g3")

          @entity.own!(@g1)
          @entity.own!(@g2)
          @entity.own!(@g3)

          @entity.down!(@g1)
          @entity.group_relations[1].group.should eq(@g1)
        end

        it "should move the group below the specified group up" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")
          @g3 = Group.create!(name: "g3")

          @entity.own!(@g1)
          @entity.own!(@g2)
          @entity.own!(@g3)

          @entity.down!(@g1)
          @entity.group_relations[0].group.should eq(@g2)
        end
      end

      describe "#last" do
        it "should return the group that is in the last order position of this entity's groups" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.last.should eq(@g1)
          @entity.own!(@g2)
          @entity.last.should eq(@g2)
        end
      end

      describe "#last!" do
        it "should make the given group order last" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.last.should eq(@g1)
          @entity.own!(@g2)
          @entity.last.should eq(@g2)

          @entity.last!(@g1)
          @entity.last.should eq(@g1)
        end

        it "should reorder all other groups" do
          @entity = Entity.create!(name: "e")
          @g1 = Group.create!(name: "g1")
          @g2 = Group.create!(name: "g2")

          @entity.own!(@g1)
          @entity.last.should eq(@g1)
          @entity.own!(@g2)
          @entity.last.should eq(@g2)

          @entity.last!(@g1)

          @entity.group_relations[0].group.should eq(@g2)
        end
      end
    end

  end

  describe "Property Relationships" do

    # describe "#utilize!" do
    #   it "should not be able to utilize non-Property type" do
    #     @entity = Entity.create!(name: "entity")
    #     @group = Group.create!(name: "group")

    #     @a = [1]
    #     @entity.utilize!(@a, @group).should eq(nil)

    #     @a = 1
    #     @entity.utilize!(@a, @group).should eq(nil)

    #     @a = Entity.create!(name: "test")
    #     @entity.utilize!(@a, @group).should eq(nil)
        
    #   end

    #   it "should create an entity property relationship" do
    #     @entity = Entity.create!(name: "entity")

    #     @property = Property.create!(name: "property")

    #     @group = Group.create!(name: "group")
    #     @group.own!(@property)

    #     @entity.utilize!(@property, @group).class.should eq(EntityPropertyRelationship)
    #   end
    # end

    describe "#utilizes?" do
      it "should return true if a relationship exists" do
        @entity = Entity.create!(name: "entity")

        @property = Property.create!(name: "property")

        @group = Group.create!(name: "group")
        @group.own!(@property)

        @entity.own!(@group)

        @entity.utilizes?(@property).should eq(true)
      end

      it "should return false if a relationship doesn't exist" do
        @entity = Entity.create!(name: "entity")

        @property1 = Property.create!(name: "property1")
        @property2 = Property.create!(name: "property2")

        @group = Group.create!(name: "group")
        @group.own!(@property2)

        @entity.own!(@group)

        @entity.utilizes?(@property1).should eq(false)
      end
    end

    describe "#property_relations" do
      it "should return all the EntityPropertyRelationships" do
        @entity = Entity.create!(name: "entity")

        @entity.property_relations.count.should eq(0)

        @property1 = Property.create!(name: "property1")
        @property2 = Property.create!(name: "property2")

        @group1 = Group.create!(name: "group1")
        @group1.own!(@property1)
        @group1.own!(@property2)
        @group2 = Group.create!(name: "group2")
        @group2.own!(@property1)
        @group2.own!(@property2)

        @entity.own!(@group1)
        @entity.own!(@group2)

        @entity.property_relations.count.should eq(4)

        r1 = @entity.relation_for_via(@property1, @group1)
        r2 = @entity.relation_for_via(@property2, @group2)

        @entity.property_relations.include?(r1).should eq(true)
        @entity.property_relations.include?(r2).should eq(true)
      end
    end

    describe "#property_relations_via" do
      it "should return the EntityPropertyRelationships associated with the given grouop" do
        @entity = Entity.create!(name: "entity")

        @property1 = Property.create!(name: "property1")
        @property2 = Property.create!(name: "property2")

        @group1 = Group.create!(name: "group1")
        @group1.own!(@property1)
        @group2 = Group.create!(name: "group2")
        @group2.own!(@property2)

        @entity.own!(@group1)
        @entity.own!(@group2)

        temp = @entity.property_relations_via(@group1).select{ |r| r[:property_id] == @property1.id }.first
        if temp.nil?
          fail
        else
          temp.property.should eq(@property1)
        end
      end
    end

    describe "#properties" do
      it "should return all properties utilized by the entity" do
        @entity = Entity.create!(name: "entity")
        @group = Group.create!(name: "group")

        @property1 = Property.create!(name: "property1")

        @property2 = Property.create!(name: "property2")

        @group.own!(@property1)
        @group.own!(@property2)

        @entity.own!(@group)

        @entity.properties.include?(@property1).should eq(true)
        @entity.properties.include?(@property2).should eq(true)
      end
    end

    describe "#properties_via" do
      it "should return all the Properties associated via the given group" do
        @entity = Entity.create!(name: "entity")
        @group = Group.create!(name: "group")

        @property1 = Property.create!(name: "property1")

        @property2 = Property.create!(name: "property2")

        @group.own!(@property1)
        @group.own!(@property2)

        @entity.own!(@group)

        @entity.properties_via(@group).include?(@property1).should eq(true)
        @entity.properties_via(@group).include?(@property2).should eq(true)
      end
    end

    describe "#utilizes?" do
      it "should return true when an entity utilizes a property" do
        @entity = Entity.create!(name: "entity")

        @child1 = Property.create!(name: "child1")
        @child2 = Property.create!(name: "child2")
        @group1 = Group.create!(name: "parent1")
        @group1.own!(@child1)
        @group1.own!(@child2)
        @group1.serve!(@entity)


        @entity.utilizes?(@child1).should eq(true)
        @entity.utilizes?(@child2).should eq(true)
      end

      it "should return false when an entity doesn't own a property's group" do
        @entity = Entity.create!(name: "entity")

        @child1 = Property.create!(name: "child1")
        @child2 = Property.create!(name: "child2")
        @group1 = Group.create!(name: "parent1")
        @group1.own!(@child1)
        @group1.serve!(@entity)


        @entity.utilizes?(@child1).should eq(true)
        # @entity.utilizes?(@parent1).should eq(true)
        # @entity.utilizes?(@grand).should eq(true)
      
        @entity.utilizes?(@child2).should eq(false)
      end
    end

    describe "Property Ordering" do

      describe  "#first_via" do
        it "should return the property that is first in order with respect to the given group" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @entity.own!(@group)

          @entity.first_via(@group).should eq(@property1)
          @group.own!(@property2)
          @entity.first_via(@group).should eq(@property1)
        end 
      end

      describe "#first_via!" do
        it "should set the given property to be first in order with respect to the given group" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")

          @property1 = Property.create!(name: "property1")

          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)

          @entity.own!(@group)

          @entity.first_via(@group).should eq(@property1)

          @entity.first_via!(@property2, @group)

          @entity.first_via(@group).should eq(@property2)
        end
      end

      describe "#up_via!" do
        it "should not move up in order if it's already first" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")

          @property1 = Property.create!(name: "property1")

          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)

          @entity.own!(@group)

          @entity.first_via(@group).should eq(@property1)

          @entity.up_via!(@property1, @group)

          @entity.first_via(@group).should eq(@property1)
        end

        it "should move up in order if it's not already first" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")

          @property1 = Property.create!(name: "property1")

          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)

          @entity.own!(@group)

          @entity.first_via(@group).should eq(@property1)

          @entity.up_via!(@property2, @group)

          @entity.first_via(@group).should eq(@property2)
        end

        it "should move the property before it down" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)
          @entity.own!(@group)

          @entity.first_via(@group).should eq(@property1)
          @entity.up_via!(@property2, @group)

          @entity.first_via(@group).should eq(@property2)
          r = @entity.property_relations_via(@group)[1].property.should eq(@property1)
        end
      end

      describe "#down_via!" do
        it "should not move down in order if it's already last" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)

          @entity.own!(@group)

          @entity.last_via(@group).should eq(@property2)

          @entity.down_via!(@property2, @group)

          @entity.last_via(@group).should eq(@property2)
        end

        it "should move down in order if it's not already last" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)
          @entity.own!(@group)

          @entity.last_via(@group).should eq(@property2)
          @entity.down_via!(@property1, @group)
          @entity.last_via(@group).should eq(@property1)
        end

        it "should move the property after it up" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @group.own!(@property2)
          @entity.own!(@group)

          @entity.last_via(@group).should eq(@property2)
          @entity.down_via!(@property1, @group)

          r = @entity.property_relations_via(@group)[0].property.should eq(@property2)
        end
      end

      describe "#last_via" do
        it "should return the property that is last in order with respect to the given group" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @entity.own!(@group)

          @entity.last_via(@group).should eq(@property1)
          @group.own!(@property2)
          @entity.last_via(@group).should eq(@property2)
        end 
      end

      describe "#last_via!" do
        it "should set the given property to be last in order with respect to the given group" do
          @entity = Entity.create!(name: "entity")
          @group = Group.create!(name: "group")
          @property1 = Property.create!(name: "property1")
          @property2 = Property.create!(name: "property2")

          @group.own!(@property1)
          @entity.own!(@group)

          @entity.last_via(@group).should eq(@property1)
          @group.own!(@property2)
          @entity.last_via(@group).should eq(@property2)

          @entity.last_via!(@property1, @group)

          @entity.last_via(@group).should eq(@property1)
        end
      end
    end
  end
end
