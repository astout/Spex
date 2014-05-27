class Entity < ActiveRecord::Base
  has_many :entity_property_relationships
  has_many :properties, through: :entity_property_relationships
  validates :name, presence: true

  before_destroy { |entity| EntityPropertyRelationship.destroy_all "entity_id = #{entity.id}" }

  #creates the EntityPropertyRelationship between this entity and the given the property
  def employ!(property)
    return if property.class != Property
    property = Property.find_by(id: property.id)
    return if property.nil?
    last_index = self.properties.count
    EntityPropertyRelationship.create!(entity_id: self.id, property_id: property.id, order: last_index)
  end

  #queries whether there is an EntityPropertyRelationship between this entity and the given property
  def employs?(property)
    return if property.class != Property
    EntityPropertyRelationship.where(entity_id: self.id, property_id: property.id).any?
  end

  #inquires whether there are any EntityPropertyRelationships for this entity
  def employs_any?
    EntityPropertyRelationship.where(entity_id: self.id).any?
  end

  #Array of all property associations for this entity
  def property_relations
    EntityPropertyRelationship.where(entity_id: self.id)
  end

  #an array of all employed properties
  def properties
    properties = []
    property_relations.each do |relationship|
      property = Property.find_by(id: relationship.property_id)
      properties.push(property)
    end
    properties
  end

  #an array of all employed property and its descendants
  def all_properties
    result = []
    result |= self.properties
    self.properties.each do |property|
      result |= property.descendants
    end
    result
  end

  #inquires whether this entity either employs the given property, or that the given
  #property is a descendant of an employed property
  def utilizes?(property)
    return if property.class != Property
    self.all_properties.include?(property)
  end

  #destroys the relationship between this entity and the given property
  #note: if the property is utilized by, but not employed by this entity,
  #there will be no effect
  def fire!(property)
    return if property.class != Property
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id)
    return if relationship.nil?
    if relationship.order.nil?
      return relationship.destroy
    end
    index = relationship.order
    relationship.destroy
    self.update_order(index)
  end

  #removes all relationships between this entity and its properties
  def fire_all!
    self.properties.each do |property|
      self.fire!(property)
    end
  end


  ####################
  # # # PROPERTY ORDER
  ####################

  #updates the order of all the children after the given index
  def update_order(index)
    relationships = self.property_relations
    last = relationships.count 
    relationships.each do |r|
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

  #sets the property to be the first ordered property of this entity
  #updates the orders of all affected entity-property relationships
  #order is the order which properties will be displayed under an
  #entity in ascending order
  def first!(property)
    return if property.class != Property
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id)
    return if relationship.nil?
    relationships = self.property_relations
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

  #returns the property that is first in ordering
  def first
    first_order_relationship = self.property_relations.select { |child| child[:order] == 0 }[0]
    return if first_order_relationship.nil?
    Property.find_by(id: first_order_relationship.property_id)
  end


  #sets the property to be the last ordered property of this entity
  #updates the orders of all affected entity-property relationships
  #order is the order which properties will be displayed under an
  #entity in ascending order
  def last!(property)
    return if property.class != Property
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id)
    return if relationship.nil?
    relationships = self.property_relations
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

  #returns the property that is last in ordering
  def last
    relationships = self.property_relations
    last_index = relationships.count - 1
    last_order_relationship = relationships.select { |child| child[:order] == last_index }[0]
    return if last_order_relationship.nil?
    Property.find_by(id: last_order_relationship.property_id)
  end

end
