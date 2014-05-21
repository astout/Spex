class Property < ActiveRecord::Base
  # has_many :children, class_name: "Property", foriegn_key: "parent_id", dependent: :destroy
  # belongs_to_many :parents, foreign_key
  # has_many :property_associations, foreign_key: "parent_id", dependent: :destroy
  has_many :property_associations
  # has_many :children, ->(child) { where child_id: child.id }, class_name: 'PropertyAssociation'
  # has_many :children, through: :property_associations, foreign_key: :child_id, dependent: :destroy
  # has_many :property_associations, foreign_key: :child_id, dependent: :destroy
  # has_many :parents, through: :property_associations, foreign_key: :parent_id, dependent: :destroy
  # has_many :property_associations, foreign_key: :parent_id, dependent: :destroy
  has_many :parents, through: :property_associations, source: :parent
  has_many :children, through: :property_associations, source: :child
  validates :name, presence: true

  before_destroy { |property| PropertyAssociation.destroy_all "child_id = #{property.id}" }
  before_destroy { |property| PropertyAssociation.destroy_all "parent_id = #{property.id}" }

  #####################
  # # # PARENT TO CHILD
  #####################

  # Makes a property a parent of the given child
  # Adds a parent-to-child association in PropertyAssociations
  def own!(child)
    return if child == self
    property = Property.find_by(id: child.id)
    return if property.nil?
    property = Property.find_by(id: self.id)
    return if property.nil?
    return if self.descendant_of?(child)
    PropertyAssociation.create!(parent_id: self.id, child_id: child.id) #unless self.descendant_of?(child)
  end

  #True if property is the direct parent of the given child
  #Queries PropertyAssociations for a parent_id value of the
  #property's id and a child_id of the given child
  def owns?(child)
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
    # PropertyAssociation.where(parent_id: self.id)
    set = PropertyAssociation.where(parent_id: self.id)
    children = []
    set.each do |relationship|
      child = Property.find(relationship.child_id)
      children.push(child)
    end
    children
  end

  def child_relations
    PropertyAssociation.where(parent_id: self.id)
  end

  #An array of the IDs of all descendants of the property
  def descendants
    result = []
    children = self.children
    result |= children
    children.each do |child|
      result |= child.descendants
    end
    # while children.any?
    #   child = children.pop
    #   # _child = Property.find(child.id)
    #   result |= child.descendants
    # end
    result
  end

  #true if property is ancestor (parent or beyond) of given child
  def ancestor_of?(descendant)
    self.descendants.include?(descendant)
  end

  #Break relationship between parent and child
  def disown!(child)
    relationship = PropertyAssociation.find_by(parent_id: self.id, child_id: child.id)
    return if relationship.nil?
    relationship.destroy
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
    return if parent == self
    property = Property.find_by(id: parent.id)
    return if property.nil?
    property = Property.find_by(id: self.id)
    return if property.nil?
    return if self.ancestor_of?(parent)
    PropertyAssociation.create!(parent_id: parent.id, child_id: self.id)
  end

  #True if the given property is an immediate parent of this property
  def serves?(parent)
    PropertyAssociation.where(parent_id: parent.id, child_id: self.id).any?
  end

  #True if this property has any parent properties
  def serves_any?
    PropertyAssociation.where(child_id: self.id).any?
  end

  #An array of all immediate parent properties of this property
  def parents
    # PropertyAssociation.where(child_id: self.id)
    set = PropertyAssociation.where(child_id: self.id)
    parents = []
    set.each do |relationship|
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
    # while parents.any?
    #   parent = parents.pop
    #   # _child = Property.find(child.id)
    #   result |= parent.ancestors
    # end
    # result
    # result = []
    # child = self
    # parents = child.parents
    # result.concat(parents)
    # while parents.any?
    #   parent_id = parents.pop
    #   parent = Property.find(parent_id)
    #   result.concat(parent.ancestors)
    # end
    result
  end

  #True if this property is the child of a property that either
  #is the given ancestor property of is also a descendant of
  #the given ancestor property
  def descendant_of?(ancestor)
    self.ancestors.include?(ancestor)
  end

  #Breaks the relationship of this property to the given
  #parent property
  def flee!(parent)
    relationship = PropertyAssociation.find_by(parent_id: parent.id, child_id: self.id)
    return if relationship.nil?
    relationship.destroy
  end

  #Break relationship between child and all its parents
  def flee_all!
    parents = self.parents
    parents.each do |parent|
      self.flee!(parent)
    end
  end
end
