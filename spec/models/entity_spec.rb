require 'spec_helper'

describe Entity do

  before {
    @entity = Entity.new(name: "entity")    
  }

  subject { @entity }

  it { should respond_to(:name) }
  it { should respond_to(:label) }
  it { should respond_to(:id) }
  it { should respond_to(:img) }
  it { should respond_to(:properties) }
  it { should respond_to(:entity_property_relationships) }
  it { should respond_to(:employ!) }
  it { should respond_to(:employs?) }
  it { should respond_to(:employs_any?) }
  it { should respond_to(:property_relations) }
  it { should respond_to(:all_properties) }
  it { should respond_to(:utilizes?) }
  it { should respond_to(:fire!) }
  it { should respond_to(:fire_all!) }
  it { should respond_to(:update_order) }
  it { should respond_to(:first!) }
  it { should respond_to(:first) }
  it { should respond_to(:last) }
  it { should respond_to(:last!) }

  describe "when name is not present" do
    before { @entity.name = " " }
    it { should_not be_valid }
  end

  describe "Entity Property Relationships" do

    describe Entity, "#employ!" do
      it "should not be able to employ non-Property type" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @a = [1]
        @entity.employ!(@a).should eq(nil)

        @a = 1
        @entity.employ!(@a).should eq(nil)

        @a = 1
        @entity.employ!(@a).should eq(nil)

        @a = Entity.new(name: "test")
        @a.save
        @entity.employ!(@a).should eq(nil)
        
        @a = 1
        @entity.employ!(@a).should eq(nil)
        
      end

      it "should create an entity property relationship" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        @entity.employ!(@property).class.should eq(EntityPropertyRelationship)
      end
    end

    describe Entity, "#employs?" do
      it "should return true if a relationship exists" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        @entity.employ!(@property)

        @entity.employs?(@property).should eq(true)
      end

      it "should return false if a relationship doesn't exist" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        @entity.employs?(@property).should eq(false)
      end
    end

    describe Entity, "#employs_any?" do
      it "should return true if any relationship exists" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        @entity.employ!(@property)

        @entity.employs_any?.should eq(true)
      end

      it "should return false if no relationship exists" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        @entity.employs_any?.should eq(false)
      end
    end

    describe Entity, "#property_relations" do
      it "should return all the EntityPropertyRelationships" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property = Property.new(name: "property")
        @property.save

        test = @entity.employ!(@property)

        @entity.property_relations.include?(test).should eq(true)
      end
    end

    describe Entity, "#properties" do
      it "should return all properties employed by the entity" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property1 = Property.new(name: "property1")
        @property1.save

        @property2 = Property.new(name: "property2")
        @property2.save

        @entity.employ!(@property1)
        @entity.employ!(@property2)

        @entity.properties.include?(@property1).should eq(true)
        @entity.properties.include?(@property2).should eq(true)
      end
    end

    describe Entity, "#all_properties" do
      it "should return all properties and their descendants employed by the entity" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @parent1.own!(@child2)
        @parent1.serve!(@grand)

        @entity.employ!(@grand)

        @entity.all_properties.include?(@child1).should eq(true)
        @entity.all_properties.include?(@child2).should eq(true)
        @entity.all_properties.include?(@parent1).should eq(true)
        @entity.all_properties.include?(@grand).should eq(true)
      end

      it "should return false for properties that aren't descendants of employed properties" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @parent1.serve!(@grand)

        @entity.employ!(@grand)

        @entity.all_properties.include?(@child1).should eq(true)
        @entity.all_properties.include?(@parent1).should eq(true)
        @entity.all_properties.include?(@grand).should eq(true)

        @entity.all_properties.include?(@child2).should eq(false)
      end
    end

    describe Entity, "#utilizes?" do
      it "should return true when an entity employs a property's ancestor" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @parent1.own!(@child2)
        @parent1.serve!(@grand)

        @entity.employ!(@grand)

        @entity.utilizes?(@child1).should eq(true)
        @entity.utilizes?(@child2).should eq(true)
        @entity.utilizes?(@parent1).should eq(true)
        @entity.utilizes?(@grand).should eq(true)
      end

      it "should return false when an entity doesn't employ a property's ancestor" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @parent1.serve!(@grand)

        @entity.employ!(@grand)

        @entity.utilizes?(@child1).should eq(true)
        @entity.utilizes?(@parent1).should eq(true)
        @entity.utilizes?(@grand).should eq(true)
      
        @entity.utilizes?(@child2).should eq(false)
      end
    end

    describe Entity, "#fire!" do
      it "should destroy the relationship between an entity and property" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property1 = Property.new(name: "property1")
        @property1.save

        @property2 = Property.new(name: "property2")
        @property2.save

        @entity.employ!(@property1)
        @entity.employ!(@property2)

        @entity.employs?(@property1).should eq(true)
        @entity.employs?(@property2).should eq(true)

        @entity.fire!(@property1)

        @entity.employs?(@property2).should eq(true)
        @entity.employs?(@property1).should eq(false)
      end

      it "should not change when firing property that isn't employed" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property1 = Property.new(name: "property1")
        @property1.save

        @property2 = Property.new(name: "property2")
        @property2.save

        @entity.employ!(@property1)

        @entity.employs?(@property1).should eq(true)
        @entity.employs?(@property2).should eq(false)

        @entity.properties.count.should eq(1)
        @entity.fire!(@property2).should eq(nil)
        @entity.properties.count.should eq(1)
      end
    end

    describe Entity, "#fire_all!" do
      it "should destroy all relationships between an entity and its properties" do
        @entity = Entity.new(name: "entity")
        @entity.save

        @property1 = Property.new(name: "property1")
        @property1.save

        @property2 = Property.new(name: "property2")
        @property2.save

        @entity.employ!(@property1)
        @entity.employ!(@property2)

        @entity.employs?(@property1).should eq(true)
        @entity.employs?(@property2).should eq(true)

        @entity.fire_all!

        @entity.employs?(@property1).should eq(false)
        @entity.employs?(@property2).should eq(false)
      end
    end

    describe "Child Ordering" do

      describe Entity, "#first!" do
        it "should make the given property order first and reorder all other employed properties" do
          @entity = Entity.new(name: "entity")
          @property1 = Property.new(name: "property1")
          @property2 = Property.new(name: "property2")
          @entity.save
          @property1.save
          @property2.save
          @entity.employ!(@property1)
          @entity.first.should eq(@property1)
          @entity.last.should eq(@property1)
          @entity.employ!(@property2)
          @entity.first.should eq(@property1)
          @entity.last.should eq(@property2)

          @entity.first!(@property2)
          @entity.first.should eq(@property2)
          @entity.last.should eq(@property1)
        end
      end

      describe Entity, "#last!" do
        it "should make the given property order lsat and reorder all other employed properties" do
          @entity = Entity.new(name: "entity")
          @property1 = Property.new(name: "property1")
          @property2 = Property.new(name: "property2")
          @entity.save
          @property1.save
          @property2.save
          @entity.employ!(@property1)
          @entity.first.should eq(@property1)
          @entity.last.should eq(@property1)
          @entity.employ!(@property2)
          @entity.first.should eq(@property1)
          @entity.last.should eq(@property2)

          @entity.last!(@property1)
          @entity.first.should eq(@property2)
          @entity.last.should eq(@property1)
        end
      end
    end

  end

end
