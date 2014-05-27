class Property < ActiveRecord::Base
  has_many :property_associations
  has_many :entity_property_relationships
  has_many :parents, through: :property_associations, source: :parent
  has_many :children, through: :property_associations, source: :child
  has_many :entities, through: :entity_property_relationships
  validates :name, presence: true

  before_destroy { |property| PropertyAssociation.destroy_all "child_id = #{property.id}" }
  before_destroy { |property| PropertyAssociation.destroy_all "parent_id = #{property.id}" }
  before_destroy { |property| EntityPropertyRelationship.destroy_all "property_id = #{property.id}" }

  #####################
  # # # PARENT TO CHILD
  #####################

  # Makes a property a parent of the given child
  # Adds a parent-to-child association in PropertyAssociations
  def own!(child)
    return if child.class != Property
    return if child == self
    property = Property.find_by(id: child.id)
    return if property.nil?
    property = Property.find_by(id: self.id)
    return if property.nil?
    return if self.descendant_of?(child)
    PropertyAssociation.create!(parent_id: self.id, child_id: child.id, order: self.child_relations.count)
  end

  #True if property is the direct parent of the given child
  #Queries PropertyAssociations for a parent_id value of the
  #property's id and a child_id of the given child
  def owns?(child)
    return if child.class != Property
    PropertyAssociation.where(parent_id: self.id, child_id: child.id).any?
  end

  #True if the property has any children
  #Queries PropertyAssociations for any records of the property's ID
  #under parent_id
  def owns_any?
    PropertyAssociation.where(parent_id: self.id).any?
  end

  #the IDs of the immediate children of the property
  def children
    children = []
    child_relations.each do |relationship|
      child = Property.find(relationship.child_id)
      children.push(child)
    end
    children
  end

  def child_relations
    PropertyAssociation.where(parent_id: self.id)
  end

  #An array of all descendants of the property
  def descendants
    result = []
    children = self.children
    result |= children
    children.each do |child|
      result |= child.descendants
    end
    result
  end

  #true if property is ancestor (parent or beyond) of given child
  def ancestor_of?(descendant)
    return if descendant.class != Property
    self.descendants.include?(descendant)
  end

  #Break relationship between parent and child
  def disown!(child)
    return if child.class != Property
    relationship = PropertyAssociation.find_by(parent_id: self.id, child_id: child.id)
    return if relationship.nil?
    if relationship.order.nil?
      return relationship.destroy
    end
    index = relationship.order
    relationship.destroy
    self.update_order(nil, index)
  end

  #Break relationship between parent and all its children
  def disown_all!
    children = self.children
    children.each do |child|
      self.disown!(child)
    end
  end

  #####################
  # # # CHILD TO PARENT
  #####################

  #Adds the given property as the parent of this property
  def serve!(parent)
    return if parent.class != Property
    return if parent == self
    property = Property.find_by(id: parent.id)
    return if property.nil?
    property = Property.find_by(id: self.id)
    return if property.nil?
    return if self.ancestor_of?(parent)
    PropertyAssociation.create!(parent_id: parent.id, child_id: self.id, order: parent.child_relations.count)
  end

  #True if the given property is an immediate parent of this property
  def serves?(parent)
    return if parent.class != Property
    PropertyAssociation.where(parent_id: parent.id, child_id: self.id).any?
  end

  #True if this property has any parent properties
  def serves_any?
    PropertyAssociation.where(child_id: self.id).any?
  end

  #An array of all immediate parent properties of this property
  def parents
    parents = []
    parent_relations.each do |relationship|
      parent = Property.find(relationship.parent_id)
      parents.push(parent)
    end
    parents
  end

  def parent_relations
    PropertyAssociation.where(child_id: self.id)
  end

  #An array of all ancestors (parent and beyond) of this property
  def ancestors
    result = []
    parents = self.parents
    result |= parents
    parents.each do |parent|
      result |= parent.ancestors
    end
    result
  end

  #True if this property is the child of a property that either
  #is the given ancestor property of is also a descendant of
  #the given ancestor property
  def descendant_of?(ancestor)
    return if ancestor.class != Property
    self.ancestors.include?(ancestor)
  end

  #Breaks the relationship of this property to the given
  #parent property
  def flee!(parent)
    return if parent.class != Property
    relationship = PropertyAssociation.find_by(parent_id: parent.id, child_id: self.id)
    return if relationship.nil?
    if relationship.order.nil?
      return relationship.destroy
    end
    index = relationship.order
    relationship.destroy
    self.update_order(nil, index)
  end

  #Break relationship between child and all its parents
  def flee_all!
    self.parents.each do |parent|
      self.flee!(parent)
    end
  end

  ########################
  # # # PROPERTY TO ENTITY
  ########################


  #will also create an indirect relationship between the descendants
  #of this property and the given the entity
  def serve_entity!(entity)
    return if entity.class != Entity
    entity = Entity.find_by(id: entity.id)
    return if entity.nil?
    last_index = entity.properties.count - 1
    EntityPropertyRelationship.create!(entity_id: entity.id, property_id: self.id, order: last_index)
  end

  #implies a direct relationship between this property and the given entity
  def employed_by?(entity)
    return if entity.class != Entity
    entity.employs?(self)
  end

  #implies a vicarious relationship between this property and the given entity
  #means that this property or one of its ancestors is employed by the given entity
  def utilized_by?(entity)
    return if entity.class != Entity
    entity.utilizes?(self)
  end

  #an array of all the entities that utilize this property
  def all_entities
    result = []
    result |= self.entities
    self.ancestors.each do |ancestor|
      result |= ancestor.entities
    end
    result
  end

  #breaks the direct relationship from this property and the given entity
  def flee_entity!(entity)
    return if entity.class != Entity
    relationship = EntityPropertyRelationship.find_by(entity_id: entity.id, property_id: self.id)
    return if relationship.nil?
    index = relationship.order
    relationship.destroy
    entity.update_order(index)
  end

  #breaks all direct relationships from this property and the entities it serves
  def flee_all_entities!
    self.entities.each do |entity|
      self.flee_entity!(entity)
    end
  end

  ##########################
  # # # PROPERTY CHILD ORDER
  ##########################

  def update_order(relationship, index)
    relationships = self.child_relations
    last = relationships.count 
    relationships.each do |r|
      next if r == relationship
      if r.order.nil?
        r.order = last -= 1
        r.save
      else
        if r.order > index
          r.order -= 1 
          r.save
        end
      end
    end
  end

  def first!(child)
    return if child.class != Property
    relationship = PropertyAssociation.find_by(parent_id: self.id, child_id: child.id)
    return if relationship.nil?
    relationships = self.child_relations
    last = relationships.count 
    return if relationship.order == 0
    if relationship.order.nil?
      line = last - 1
    else
      line = relationship.order
    end
    relationships.each do |r|
      next if r == relationship
      if r.order.nil?
        r.order = last -= 1
        r.save
      else
        if r.order < line
          r.order += 1 
          r.save
        end
      end
    end
    relationship.order = 0
    relationship.save
  end

  def first
    first_order_relationship = self.child_relations.select { |child| child[:order] == 0 }[0]
    return if first_order_relationship.nil?
    Property.find_by(id: first_order_relationship.child_id)
  end

  def last!(child)
    return if child.class != Property
    relationship = PropertyAssociation.find_by(parent_id: self.id, child_id: child.id)
    return if relationship.nil?
    relationships = self.child_relations
    last = relationships.count - 1 # - 1 because child will be set to last at the end
    return if relationship.order == last
    if relationship.order.nil?
      line = 0
    else
      line = relationship.order
    end
    relationships.each do |r|
      next if r == relationship
      if r.order.nil?
        r.order = last -= 1
        r.save
      else
        if r.order > line
          r.order -= 1
          r.save
        end
      end
    end
    relationship.order = relationships.count - 1
    relationship.save
  end

  def last
    relationships = self.child_relations
    last_index = relationships.count - 1
    last_order_relationship = relationships.select { |child| child[:order] == last_index }[0]
    return if last_order_relationship.nil?
    Property.find_by(id: last_order_relationship.child_id)
  end

end
