class Entity < ActiveRecord::Base
  has_many :entity_property_relationships
  has_many :entity_group_relationships
  has_many :properties, through: :entity_property_relationships, inverse_of: :entities
  has_many :groups, through: :entity_group_relationships, inverse_of: :entities
  validates :name, presence: true

  before_destroy { |entity| EntityPropertyRelationship.destroy_all "entity_id = #{entity.id}" }
  before_destroy { |entity| EntityGroupRelationship.destroy_all "entity_id = #{entity.id}" }

  #####################
  # # # ENTITY TO GROUP
  #####################

  def own!(group)
    return if group.class != Group
    group = Group.find_by(id: group.id)
    return if group.nil?
    EntityGroupRelationship.create!(entity_id: self.id, group_id: group.id, order: self.groups.count)

    # group.properties.each do |property|
    #   self.utilize!(property, group)
    # end
  end

  def owns?(group)
    return if group.class != Group
    self.groups.any? {|g| g[:id] == group.id}
    # EntityGroupRelationship.where(entity_id: self.id, group_id: group.id)
  end

  def groups
    groups = []
    self.group_relations.each do |r|
      groups.push r.group
    end
    groups
  end

  def group_relations
    relations = EntityGroupRelationship.where(entity_id: self.id)
    relations.sort_by { |r| r[:order] }
  end

  def relation_for(group)
    return if group.class != Group
    self.group_relations.select { |r| r[:group_id] == group.id }.first
  end

  def relation_for_via(property, group)
    return if group.class != Group
    return if property.class != Property
    self.property_relations.select { |r| r[:property_id] == property.id && r[:group_id] == group.id }.first
  end

  def disown!(group)
    return if group.class != Group
    e = Entity.find_by(id: self.id)
    return if e.nil?
    relationship = EntityGroupRelationship.find_by(entity_id: self.id, group_id: group.id)
    return if relationship.nil?
    if relationship.order.nil?
      return relationship.destroy
    end
    index = relationship.order
    relationship.destroy
    self.update_order(index)
    EntityPropertyRelationship.destroy_all(group_id: group.id)
  end

  #removes all relationships between this entity and its groups
  def disown_all!
    self.groups.each do |group|
      self.disown!(group)
    end
  end

  ########################
  # # # ENTITY TO PROPERTY
  ########################

  def utilize!(property, group)
    #check classes of parameters, also checks not nil
    return if property.class != Property
    return if group.class != Group
    #obtains the true db copies of the parameters
    property = Property.find_by(id: property.id)
    group = Group.find_by(id: group.id)
    #set order to be the count of properties for this entity via the group
    # order = self.property_relations_via(group).count
    #store the relationship of the property and group
    pr = group.relation_for(property)
    return if pr.nil?
    #set order to be the default order
    order = pr.order
    if self.property_relations.select { |r| r[:group_id] == group.id && r[:order] == order }.any?
      order = self.property_relations_via(group).count    
    end
    EntityPropertyRelationship.create!(entity_id: self.id, group_id: group.id, 
      property_id: property.id, order: order)
  end

  def utilizes?(property)
    return if property.class != Property
    property = Property.find_by(id: property.id)
    return if property.nil?
    self.properties.include?(property)
  end

  #Array of all property associations for this entity
  def property_relations
    relations = EntityPropertyRelationship.where(entity_id: self.id)
    relations.sort_by { |r| r[:order] }
    # self.entity_property_relationships
  end

  def property_relations_via(group)
    # EntityPropertyRelationship.where(entity_id: self.id group_id: group.id)
    relations = self.property_relations.select { |r| r[:group_id] == group.id }
    relations.sort_by { |r| r[:order] }
  end

  # def toss_via!(property, group)
  #   return if property.class != Property
  #   return if group.class != Group
  #   e = Entity.find_by(id: self.id)
  #   return if e.nil?
  #   relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
  #   return if relationship.nil?
  #   if relationship.order.nil?
  #     return relationship.destroy
  #   end
  #   index = relationship.order
  #   relationship.destroy
  #   self.update_group_order(index)
  #   # EntityPropertyRelationship.destroy_all(property_id: property.id)
  # end

  # an array of all employed properties
  def properties
    properties = []
    property_relations.each do |relationship|
      properties.push relationship.property
    end
    properties
  end

  #an array of all employed properties
  def properties_via(group)
    properties = []
    property_relations_via(group).each do |relationship|
      # property = Property.find_by(id: relationship.property_id)
      property = relationship.property
      properties.push(property)
    end
    properties
  end


  ####################
  # # # PROPERTY ORDER
  ####################

  #updates the order of all the children after the given index
  def p_update_order(index)
    relationships = self.property_relations
    relationships |= self.property_relations.select { |r| r[:order] != nil }
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
  def first_via!(property, group)
    return if property.class != Property
    return if group.class != Group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.property_relations.select { |r| r[:group_id] == group.id }
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
        r.update_attribute(:order, last -= 1)
        # r.order = last -= 1
        # r.save
      else
        if r.order < line
          r.update_attribute(:order, r.order + 1)
          # r.order += 1 
          # r.save
        end
      end
    end
    relationship.update_attribute(:order, 0)
    # relationship.order = 0
    # relationship.save
  end

  def up_via!(property, group)
    #parameter passed a property type?
    return if property.class != Property
    return if group.class != Group
    #get all relationships for this entity via the given group
    relationships = property_relations_via group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    #relationship exist?
    return if relationship.nil?
    #already last?
    return if relationship.order == 0
    #relationship after property
    swap = self.property_relations_via(group)[relationship.order - 1]
    # swap = self.relation_at_via(relationship.order - 1, group)
    # swap = relationships.select { |r| r[:order] == relationship.order + 1 }
    #move the property below the passed property up
    swap.update_attribute(:order, swap.order + 1)
    #move the passed property down
    relationship.update_attribute(:order, relationship.order - 1)
  end

  def down_via!(property, group)
    #parameter passed a property type?
    return if property.class != Property
    return if group.class != Group
    #get all relationships for this entity via the given group
    relationships = property_relations_via group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    #relationship exist?
    return if relationship.nil?
    #already last?
    return if relationship.order == relationships.count - 1
    #relationship after property
    swap = self.property_relations_via(group)[relationship.order + 1]
    # swap = self.relation_at_via(relationship.order + 1, group)
    # swap = relationships.select { |r| r[:order] == relationship.order + 1 }
    #move the property below the passed property up
    swap.update_attribute(:order, swap.order - 1)
    #move the passed property down
    relationship.update_attribute(:order, relationship.order + 1)
  end

  #returns the property that is first in ordering
  def first_via(group)
    relationship = self.property_relations.select { |r| r[:order] == 0 && r[:group_id] == group.id }[0]
    return if relationship.nil?
    Property.find_by(id: relationship.property_id)
  end


  #sets the property to be the last ordered property of this entity
  #updates the orders of all affected entity-property relationships
  #order is the order which properties will be displayed under an
  #entity in ascending order
  def last_via!(property, group)
    return if property.class != Property
    return if group.class != Group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.property_relations.select { |r| r[:group_id] == relationship.group_id }
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
        r.update_attribute(:order, last -= 1)
        # r.order = last -= 1
        # r.save
      else
        if r.order > line
          r.update_attribute(:order, r.order - 1)
          # r.order -= 1
          # r.save
        end
      end
    end
    relationship.update_attribute(:order, relationships.count - 1)
    # relationship.order = relationships.count - 1
    # relationship.save
  end

  #returns the property that is first in ordering
  def last_via(group)
    relationships = self.property_relations_via group
    return if relationships.empty?
    last_index = relationships.count - 1
    last_relationship  = relationships.select { |r| r[:order] == last_index }.first
    return if last_relationship.nil?
    Property.find_by(id: last_relationship.property_id)
  end

  #returns the property that is last in ordering
  # def last
  #   relationships = self.property_relations
  #   last_index = relationships.count - 1
  #   last_order_relationship = relationships.select { |child| child[:order] == last_index }[0]
  #   return if last_order_relationship.nil?
  #   Property.find_by(id: last_order_relationship.property_id)
  # end

  #################
  # # # GROUP ORDER
  #################

  #updates the order of all the children after the given index
  def update_order(index)
    relationships = self.group_relations
    last = relationships.count 
    relationships.each do |r|
      if r.order.nil?
        r.update_attribute(:order, last -= 1)
      else
        if r.order > index
          r.update_attribute(:order, r.order - 1)
        end
      end
    end
  end

  #sets the property to be the first ordered property of this entity
  #updates the orders of all affected entity-property relationships
  #order is the order which properties will be displayed under an
  #entity in ascending order
  def first!(group)
    return if group.class != Group
    relationship = self.group_relations.select { |r| r[:group_id] == group.id }.first
    return if relationship.nil?
    last = self.group_relations.count 
    return if relationship.order == 0
    if relationship.order.nil?
      line = last - 1
    else
      line = relationship.order
    end
    self.group_relations.each do |r|
      next if r == relationship
      if r.order.nil?
        r.update_attribute(:order, last -= 1)
        # r.order = last -= 1
        # r.save
      else
        if r.order < line
          r.update_attribute(:order, r.order + 1)
          # r.order += 1 
          # r.save
        end
      end
    end
    relationship.update_attribute(:order, 0)
    # relationship.order = 0
    # relationship.save
  end

  #returns the property that is first in ordering
  def first
    first_relationship = self.group_relations.select { |r| r[:order] == 0 }.first
    return if first_relationship.nil?
    first_relationship.group
    # Group.find_by(id: first_relationship.group_id)
  end

  #moves the specified group up in order and moves the group above it down
  def up!(group)
    return if group.class != Group
    relationship = self.relation_for(group)
    return if relationship.nil?
    return if relationship.order == 0
    r = self.group_relations[relationship.order - 1]
    # r = self.relation_at(relationship.order - 1)
    r.update_attribute(:order, relationship.order)
    relationship.update_attribute(:order, relationship.order - 1)
  end

  #moves the specified group down in order and moves the group below it up
  def down!(group)
    return if group.class != Group
    relationship = self.relation_for(group)
    return if relationship.nil?
    last = self.group_relations.count - 1
    return if relationship.order == last
    r = self.group_relations[relationship.order + 1]
    # r = self.relation_at(relationship.order + 1)
    r.update_attribute(:order, relationship.order)
    relationship.update_attribute(:order, relationship.order + 1)
  end

  #sets the property to be the last ordered property of this entity
  #updates the orders of all affected entity-property relationships
  #order is the order which properties will be displayed under an
  #entity in ascending order
  def last!(group)
    return if group.class != Group
    relationship = EntityGroupRelationship.find_by(entity_id: self.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.group_relations
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
        r.update_attribute(:order, last -= 1)
        # r.order = last -= 1
        # r.save
      else
        if r.order > line
          r.update_attribute(:order, last - 1)
          # r.order -= 1
          # r.save
        end
      end
    end
    relationship.update_attribute( :order, relationships.count - 1 )
    # relationship.order = relationships.count - 1
    # relationship.save
  end

  #returns the property that is last in ordering
  def last
    relationships = self.group_relations
    last_index = relationships.count - 1
    last_relationship = relationships.select { |child| child[:order] == last_index }.first
    return if last_relationship.nil?
    last_relationship.group
    # Group.find_by(id: last_relationship.property_id)
  end

end
