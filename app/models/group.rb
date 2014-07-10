class Group < ActiveRecord::Base
  has_many :group_property_relationships, foreign_key: "group_id"
  has_many :entity_group_relationships, foreign_key: "group_id"
  has_many :entities, through: :entity_group_relationships, inverse_of: :groups
  has_many :properties, through: :group_property_relationships, inverse_of: :groups
  validates :name, presence: true

  # before_destroy { |group| GroupPropertyRelationship.destroy_all "group_id = #{group.id}" }
  # before_destroy { |group| EntityGroupRelationship.destroy_all "group_id = #{group.id}" }

  before_destroy do |group| 
    EntityPropertyRelationship.destroy_all "group_id = #{group.id}"
    properties = group.properties
    entities = group.entities
    properties.each do |property|
      group.disown! property
    end
    entities.each do |entity|
      group.flee! entity
    end
  end

  #####################
  # # # GROUP TO ENTITY
  #####################

  #creates EntityGroupRelationship between this group and the given Entity
  def serve!(entity)
    return if entity.class != Entity
    entity.own!(self)
  end

  #returns true if there exists an EntityGroupRelationship between the group and the given entity
  def serves?(entity)
    return if entity.class != Entity
    entity.owns?(self)
  end

  #returns an array of entities associated with the group
  def entities
    entities = []
    relations = self.entity_relations
    relations.each do |relationship|
      entity = Entity.find_by(id: relationship.entity_id)
      entities.push(entity)
    end
    entities
  end

  #returns an array of the EntityGroupRelationships associated with this group
  def entity_relations
    EntityGroupRelationship.where(group_id: self.id)
  end

  #destroys the EntityGroupRelationship between this group and the given entity
  def flee!(entity)
    entity.disown!(self)
  end

  # destroys all EntityGroupRelationships associated with this group
  def flee_all!
    group = Group.find_by(id: self.id)
    return if group.nil?
    self.entities.each do |entity|
      self.flee!(entity)
    end
  end


  #######################
  # # # GROUP TO PROPERTY
  #######################

  # Makes a property a group of the given property
  # Adds a group-to-property association in GroupPropertyRelationships
  def own!(property)
    return if property.class != Property
    property = Property.find_by(id: property.id)
    return if property.nil?
    group = Group.find_by(id: self.id)
    return if group.nil?
    GroupPropertyRelationship.create!(group_id: self.id, property_id: property.id, order: self.property_relations.count)
  end

  #True if group is the direct group of the given property
  #Queries GroupPropertyRelationships for a group_id value of the
  #property's id and a property_id of the given property
  def owns?(property)
    return if property.class != Property
    self.properties.any? { |p| p[:id] == property.id }
  end

  #the IDs of the immediate properties of the group
  def properties
    properties = []
    relations = self.property_relations
    relations.each do |relationship|
      properties.push relationship.property
    end
    properties
  end

  #returns an array of GroupPropertyRelationships associated with this group sorted
  #by the order field
  def property_relations
    relations = GroupPropertyRelationship.where(group_id: self.id)
    relations.sort_by { |r| r[:order] }
  end

  #returns the GroupPropertyRelationship associating this group to the given property
  #or entity
  def relation_for(parameter)
    if parameter.class == Entity
      EntityGroupRelationship.find_by(group_id: self.id, entity_id: parameter.id)
    elsif parameter.class == Property
      GroupPropertyRelationship.find_by(group_id: self.id, property_id: parameter.id)
    else
      nil
    end
  end

  #Break relationship between group and property
  def disown!(property)
    return if property.class != Property
    relationship = GroupPropertyRelationship.find_by(group_id: self.id, property_id: property.id)
    return if relationship.nil?
    if relationship.order.nil?
      return relationship.destroy
    end
    index = relationship.order
    relationship.destroy
    self.update_order(index)
  end

  #Break relationship between group and all its properties
  def disown_all!
    properties = self.properties
    properties.each do |property|
      self.disown!(property)
    end
  end


  ##########################
  # # # GROUP PROPERTY ORDER
  ##########################

  #updats the order for each property after the given index
  def update_order(index)
    relationships = self.property_relations
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

  #sets the given property to be the first in relationship order for this group
  def first!(property)
    return if property.class != Property
    relationship = GroupPropertyRelationship.find_by(group_id: self.id, property_id: property.id)
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

  #returns the property associated by the relationship that is first in order
  def first
    first_order_relationship = self.property_relations.select { |property| property[:order] == 0 }[0]
    return if first_order_relationship.nil?
    Property.find_by(id: first_order_relationship.property_id)
  end

  #moves the specified property up in order and moves the property above it down
  def up!(property)
    return if property.class != Property
    relationship = self.relation_for(property)
    return if relationship.nil?
    return if relationship.order == 0
    r = self.property_relations[relationship.order - 1]
    # r = self.relation_at(relationship.order - 1)
    r.update_attribute(:order, relationship.order)
    relationship.update_attribute(:order, relationship.order - 1)
  end

  #moves the specified property down in order and moves the property below it up
  def down!(property)
    return if property.class != Property
    relationship = self.relation_for(property)
    return if relationship.nil?
    last = self.property_relations.count - 1
    return if relationship.order == last
    r = self.property_relations[relationship.order + 1]
    r.update_attribute(:order, relationship.order)
    relationship.update_attribute(:order, relationship.order + 1)
  end

  #sets the given property to last in relationship order with this group
  def last!(property)
    return if property.class != Property
    relationship = GroupPropertyRelationship.find_by(group_id: self.id, property_id: property.id)
    return if relationship.nil?
    relationships = self.property_relations
    last = relationships.count - 1 # - 1 because property will be set to last at the end
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

  #returns the property associated by the relationship that is last in order
  def last
    relationships = self.property_relations
    last_index = relationships.count - 1
    last_order_relationship = relationships.select { |property| property[:order] == last_index }[0]
    return if last_order_relationship.nil?
    Property.find_by(id: last_order_relationship.property_id)
  end

  ##################
  # # # GROUP SEARCH
  ##################

  #class function
  #returns groups that match the given search string
  #It searches the name, label, created, and updated fields for partial matches
  def self.search(search)
    #return all entities if search is nil
    return all if search.nil?

    #split the search by spaces
    _elements = search.split ' '

    #return all if empty after split
    unless _elements.empty?
      #declare an array to store each binding element
      elements = []

      #for each word from the split search phrase
      _elements.each do |e|
        #wrap each word in '%' to allow partial matches
        e = '%'+e+'%'
        #add the string to the binding elements 4 times (1 for each field)
        elements.concat [e]*4
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(name LIKE ? OR default_label LIKE ? OR created_at::text LIKE ? OR updated_at::text LIKE ?) AND '
      end
      #remove the trailing 'AND' from the clause
      clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

      #call the query using the clause and each binding element
      where clause, *elements
    else
      all # if _elements.empty?
    end
  end

end
