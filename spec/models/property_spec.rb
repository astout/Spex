require 'spec_helper'

describe Property do
  
  before {
    @child1 = Property.new(name: "child1", units: "Units", units_short: "U", default_label: "Child 1", default_value: nil, default_visibility: 0)
  }

  subject { @child1 }

  it { should respond_to(:name) }
  it { should respond_to(:units) }
  it { should respond_to(:units_short) }
  it { should respond_to(:default_label) }
  it { should respond_to(:default_value) }
  it { should respond_to(:default_visibility) }
  it { should respond_to(:entities) }
  it { should respond_to(:children) }
  it { should respond_to(:parents) }
  it { should respond_to(:first) }
  it { should respond_to(:first!) }
  it { should respond_to(:last) }
  it { should respond_to(:last!) }
  it { should respond_to(:child_relations) }
  it { should respond_to(:parent_relations) }
  it { should respond_to(:property_associations) }
  it { should respond_to(:descendants) }
  it { should respond_to(:ancestors) }
  it { should respond_to(:update_order) }
  it { should respond_to(:flee!) }
  it { should respond_to(:flee_all!) }
  it { should respond_to(:flee_entity!) }
  it { should respond_to(:flee_all_entities!) }
  it { should respond_to(:utilized_by?) }
  it { should respond_to(:descendant_of?) }
  it { should respond_to(:ancestor_of?) }
  it { should respond_to(:serve!) }
  it { should respond_to(:serves?) }
  it { should respond_to(:serves_any?) }
  it { should respond_to(:own!) }
  it { should respond_to(:disown!) }
  it { should respond_to(:disown_all!) }
  it { should respond_to(:owns?) }
  it { should respond_to(:owns_any?) }
  it { should respond_to(:entity_property_relationships) }

  describe "when name is not present" do
    before { @child1.name = " " }
    it { should_not be_valid }
  end

  describe "Property Assocations" do

    describe Property, "#serve!" do
      it "should not be able to serve/own itself" do
        @child1 = Property.new(name: "child1")
        @child1.save
        @child1.serve!(@child1).should eq(nil)
        @child1.serves?(@child1).should eq(false)
        @child1.owns?(@child1).should eq(false)
        @child1.serves_any?.should eq(false)
        @child1.owns_any?.should eq(false)
      end

      it "should serve parent" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @child1.save
        @parent1.save
        @child1.serve!(@parent1)
        @child1.serves?(@parent1).should eq(true)
        @child1.serves_any?.should eq(true)
        @parent1.owns?(@child1).should eq(true)
        @parent1.owns_any?.should eq(true)
      end
    end

    describe Property, "#flee!" do
      it "should flee parent" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @parent2 = Property.new(name: "parent2")
        @child1.save
        @parent1.save
        @parent2.save
        @child1.serve!(@parent1)
        @child1.serve!(@parent2)
        @child1.serves_any?.should eq(true)
        @child1.serves?(@parent1).should eq(true)
        @child1.serves?(@parent2).should eq(true)
        @parent1.owns?(@child1).should eq(true)
        @parent2.owns?(@child1).should eq(true)
        @parent1.owns_any?.should eq(true)
        @parent2.owns_any?.should eq(true)
        @child1.flee!(@parent1)

        @child1.serves_any?.should eq(true)
        @child1.serves?(@parent1).should eq(false)
        @child1.serves?(@parent2).should eq(true)
        @parent1.owns?(@child1).should eq(false)
        @parent2.owns?(@child1).should eq(true)
        @parent1.owns_any?.should eq(false)
      end
    end

    describe Property, "#flee_all!" do
      it "should not have anymore parents" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @parent2 = Property.new(name: "parent2")
        @child1.save
        @parent1.save
        @parent2.save
        @parent1.own!(@child1)
        @parent2.own!(@child1)
        @parent1.owns?(@child1).should eq(true)
        @parent2.owns?(@child1).should eq(true)

        @child1.parents.count.should eq(2)
        @child1.flee_all!
        @child1.parents.count.should eq(0)
      end
    end

    describe Property, "#own!" do
      it "should own child" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @child1.save
        @parent1.save
        @parent1.own!(@child1)
        @child1.serves_any?.should eq(true)
        @child1.serves?(@parent1).should eq(true)
        @parent1.owns?(@child1).should eq(true)
        @parent1.owns_any?.should eq(true)
      end
    end

    describe Property, "#disown!" do
      it "should disown child" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @child1.save
        @child2.save
        @parent1.save
        @parent1.own!(@child1)
        @parent1.own!(@child2)
        @child1.serves_any?.should eq(true)
        @child1.serves?(@parent1).should eq(true)
        @child2.serves?(@parent1).should eq(true)
        @parent1.owns?(@child1).should eq(true)
        @parent1.owns?(@child2).should eq(true)
        @parent1.disown!(@child1)

        @child1.serves_any?.should eq(false)
        @parent1.owns?(@child1).should eq(false)
        @parent1.owns_any?.should eq(true)
        @parent1.owns?(@child2).should eq(true)
      end
    end

    describe Property, "#disown_all!" do
      it "should not have anymore children" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @child1.save
        @child2.save
        @parent1.save
        @parent1.own!(@child1)
        @parent1.own!(@child2)
        @parent1.owns?(@child1).should eq(true)
        @parent1.owns?(@child2).should eq(true)

        @parent1.children.count.should eq(2)
        @parent1.disown_all!
        @parent1.children.count.should eq(0)
      end
    end

    describe Property, "#descendants" do
      it "descendants count should change" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @parent1.descendants.count.should eq(1)
        @parent1.own!(@child2)
        @parent1.descendants.count.should eq(2)
        @parent1.serve!(@grand)
        @grand.descendants.count.should eq(3)
        @parent1.disown!(@child1)

        @parent1.descendants.count.should eq(1)
        @grand.descendants.count.should eq(2)
      end
    end

    describe Property, "#descendant_of" do
      it "should be descendant of parent" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @child1.save
        @parent1.save
        @parent1.own!(@child1)
        @child1.descendant_of?(@parent1).should eq(true)
      end

      it "should not be descendant of other parents" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @parent2 = Property.new(name: "parent2")
        @child1.save
        @child2.save
        @parent1.save
        @parent2.save
        @parent1.own!(@child1)
        @parent2.own!(@child2)
        @child1.descendant_of?(@parent2).should eq(false)
      end

      it "should not be descendant of other children" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @parent2 = Property.new(name: "parent2")
        @child1.save
        @child2.save
        @parent1.save
        @parent2.save
        @parent1.own!(@child1)
        @parent2.own!(@child2)
        @child1.descendant_of?(@child2).should eq(false)
      end

      it "should be descendant of parents' parents" do
        @child1 = Property.new(name: "child1")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @grand.own!(@parent1)
        @child1.descendant_of?(@grand).should eq(true)
      end

      it "should be descendant of parents' parents' parents" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @great = Property.new(name: "great")
        @child.save
        @parent.save
        @grand.save
        @great.save
        @parent.own!(@child)
        @grand.own!(@parent)
        @great.own!(@grand)
        @child.descendant_of?(@great).should eq(true)
      end

      it "should not be descendant of great grandparent if chain broken" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @great = Property.new(name: "great")
        @child.save
        @parent.save
        @grand.save
        @great.save
        @parent.own!(@child)
        @grand.own!(@parent)
        @great.own!(@grand)
        @child.descendant_of?(@great).should eq(true)
        @great.disown!(@grand)
        @child.descendant_of?(@great).should eq(false)
        @child.descendant_of?(@grand).should eq(true)
      end
    end

    describe Property, "#ancestors" do
      it "ancestors count should change" do
        @child1 = Property.new(name: "child1")
        @child2 = Property.new(name: "child2")
        @parent1 = Property.new(name: "parent1")
        @grand = Property.new(name: "grand")
        @child1.save
        @child2.save
        @parent1.save
        @grand.save
        @parent1.own!(@child1)
        @child1.ancestors.count.should eq(1)
        @parent1.own!(@child2)
        @parent1.serve!(@grand)
        @child1.ancestors.count.should eq(2)
        @child2.ancestors.count.should eq(2)
        @parent1.ancestors.count.should eq(1)
        @parent1.disown!(@child1)

        @child1.ancestors.count.should eq(0)
        @child2.ancestors.count.should eq(2)
      end
    end

    describe "Child Ordering" do

      describe Property, "#first!" do
        it "should make the given child order first" do
          @parent = Property.new(name: "parent")
          @child1 = Property.new(name: "child1")
          @child2 = Property.new(name: "child2")
          @parent.save
          @child1.save
          @child2.save
          @parent.own!(@child1)
          @parent.last.should eq(@child1)
          @parent.own!(@child2)
          @parent.last.should eq(@child2)

          @parent.first.should eq(@child1)
          @parent.first!(@child2)
          @parent.first.should eq(@child2)
        end
      end

      describe Property, "#last!" do
        it "should make the given child order last" do
          @parent = Property.new(name: "parent")
          @child1 = Property.new(name: "child1")
          @child2 = Property.new(name: "child2")
          @parent.save
          @child1.save
          @child2.save
          @parent.own!(@child1)
          @parent.last.should eq(@child1)
          @parent.own!(@child2)
          @parent.last.should eq(@child2)

          @parent.last!(@child1)
          @parent.last.should eq(@child1)
        end
      end
    end
  end

  describe "Entity Property Relationships" do

    describe Property, "#serve_entity!" do
      it "should be employed by the entity" do
        @property = Property.new(name: "property")
        @entity = Entity.new(name: "entity")
        @property.save
        @entity.save
        @property.employed_by?(@entity).should eq(false)
        @property.serve_entity!(@entity)
        @property.employed_by?(@entity).should eq(true)
      end

      it "should be utilized by the entity" do
        @property = Property.new(name: "property")
        @entity = Entity.new(name: "entity")
        @property.save
        @entity.save
        @property.utilized_by?(@entity).should eq(false)
        @property.serve_entity!(@entity)
        @property.utilized_by?(@entity).should eq(true)
      end

      it "should be utilized by parent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @entity.save
        @child.serve!(@parent)
        @child.utilized_by?(@entity).should eq(false)
        @parent.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)
      end

      it "should be utilized by grandparent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @grand.save
        @entity.save
        @child.serve!(@parent)
        @parent.serve!(@grand)
        @child.utilized_by?(@entity).should eq(false)
        @grand.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)
      end

      it "should be utilized by great grandparent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @great = Property.new(name: "great")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @grand.save
        @great.save
        @entity.save
        @child.serve!(@parent)
        @parent.serve!(@grand)
        @grand.serve!(@great)
        @child.utilized_by?(@entity).should eq(false)
        @parent.utilized_by?(@entity).should eq(false)
        @grand.utilized_by?(@entity).should eq(false)
        @great.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)
        @parent.utilized_by?(@entity).should eq(true)
        @grand.utilized_by?(@entity).should eq(true)
      end
    end

    describe Property, "#flee_entity!" do
      it "should no longer be employed by entity" do
        @property = Property.new(name: "property")
        @entity = Entity.new(name: "entity")
        @property.save
        @entity.save
        @property.employed_by?(@entity).should eq(false)
        @property.serve_entity!(@entity)
        @property.employed_by?(@entity).should eq(true)

        @property.flee_entity!(@entity)
        @property.employed_by?(@entity).should eq(false)
      end

      it "should no longer be employed by given entity, but still employed by others" do
        @property = Property.new(name: "property")
        @entity1 = Entity.new(name: "entity1")
        @entity2 = Entity.new(name: "entity2")
        @property.save
        @entity1.save
        @entity2.save
        @property.employed_by?(@entity1).should eq(false)
        @property.employed_by?(@entity2).should eq(false)
        @property.serve_entity!(@entity1)
        @property.serve_entity!(@entity2)
        @property.employed_by?(@entity1).should eq(true)
        @property.employed_by?(@entity2).should eq(true)

        @property.flee_entity!(@entity1)
        @property.employed_by?(@entity1).should eq(false)
        @property.employed_by?(@entity2).should eq(true)
      end

      it "should no longer be utilized by the entity" do
        @property = Property.new(name: "property")
        @entity = Entity.new(name: "entity")
        @property.save
        @entity.save
        @property.utilized_by?(@entity).should eq(false)
        @property.serve_entity!(@entity)
        @property.utilized_by?(@entity).should eq(true)

        @property.flee_entity!(@entity)
        @property.utilized_by?(@entity).should eq(false)
      end

      it "should no longer be utilized by parent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @entity.save
        @child.serve!(@parent)
        @child.utilized_by?(@entity).should eq(false)
        @parent.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)

        @parent.flee_entity!(@entity)
        @child.utilized_by?(@entity).should eq(false)
      end

      it "should no longer be utilized by grandparent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @grand.save
        @entity.save
        @child.serve!(@parent)
        @parent.serve!(@grand)
        @child.utilized_by?(@entity).should eq(false)
        @grand.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)

        @grand.flee_entity!(@entity)
        @child.utilized_by?(@entity).should eq(false)
      end

      it "should no longer be utilized by great grandparent's entity" do
        @child = Property.new(name: "child")
        @parent = Property.new(name: "parent")
        @grand = Property.new(name: "grand")
        @great = Property.new(name: "great")
        @entity = Entity.new(name: "entity")
        @child.save
        @parent.save
        @grand.save
        @great.save
        @entity.save
        @child.serve!(@parent)
        @parent.serve!(@grand)
        @grand.serve!(@great)
        @child.utilized_by?(@entity).should eq(false)
        @parent.utilized_by?(@entity).should eq(false)
        @grand.utilized_by?(@entity).should eq(false)
        @great.serve_entity!(@entity)
        @child.utilized_by?(@entity).should eq(true)
        @parent.utilized_by?(@entity).should eq(true)
        @grand.utilized_by?(@entity).should eq(true)

        @great.flee_entity!(@entity)
        @child.utilized_by?(@entity).should eq(false)
        @parent.utilized_by?(@entity).should eq(false)
        @grand.utilized_by?(@entity).should eq(false)
      end
    end

    describe Property, "#flee_all_entities!" do
      it "should no longer be employed by any entities" do
        @property = Property.new(name: "property")
        @entity1 = Entity.new(name: "entity1")
        @entity2 = Entity.new(name: "entity2")
        @property.save
        @entity1.save
        @entity2.save
        @property.employed_by?(@entity1).should eq(false)
        @property.employed_by?(@entity2).should eq(false)
        @property.serve_entity!(@entity1)
        @property.serve_entity!(@entity2)
        @property.employed_by?(@entity1).should eq(true)
        @property.employed_by?(@entity2).should eq(true)

        @property.flee_all_entities!
        @property.employed_by?(@entity1).should eq(false)
        @property.employed_by?(@entity2).should eq(false)
      end
    end
  end
end
