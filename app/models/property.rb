class Property < ActiveRecord::Base
  has_many :group_property_relationships
  has_many :entity_property_relationships
  has_many :entities, through: :entity_property_relationships, inverse_of: :properties
  has_many :groups, through: :group_property_relationships, inverse_of: :properties
  validates :name, presence: true

  before_destroy { |property| GroupPropertyRelationship.destroy_all "property_id = #{property.id}" }
  before_destroy { |property| EntityPropertyRelationship.destroy_all "property_id = #{property.id}" }

  #######################
  # # # PROPERTY TO GROUP
  #######################

  #Adds the given property as the group of this property
  def serve!(group)
    group.own!(self)
  end

  #True if the given property is an immediate group of this property
  def serves?(group)
    return if group.class != Group
    group.owns?(self)
  end

  #An array of all immediate group properties of this property
  def groups
    groups = []
    self.group_relations.each do |r|
      groups.push r.group
    end
    groups
  end

  def group_relations
    GroupPropertyRelationship.where(property_id: self.id)
  end

  #Breaks the relationship of this property to the given group
  def flee!(group)
    return if group.class != Group
    group.disown!(self)
  end

  #Break relationship between property and all its groups
  def flee_all!
    self.groups.each do |group|
      self.flee!(group)
    end
  end

  ########################
  # # # PROPERTY TO ENTITY
  ########################


  #implies a vicarious relationship between this property and the given entity
  #means that this property or one of its groups is employed by the given entity
  def utilized_by?(entity)
    return if entity.class != Entity
    entity.utilizes?(self)
  end

  #an array of all the entities that utilize this property
  def entities
    result = []
    self.groups.each do |group|
      result |= group.entities
    end
    result
  end

  def entity_relations
    EntityPropertyRelationship.where(property_id: self.id)
  end
  
end
