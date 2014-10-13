class Entity < ActiveRecord::Base
  has_many :entity_property_relationships
  has_many :entity_group_relationships
  has_many :properties, 
    through: :entity_property_relationships, 
    inverse_of: :entities
  has_many :groups, 
    through: :entity_group_relationships, 
    inverse_of: :entities
  VALID_NAME_REGEX = /\A[a-z0-9]+[a-z0-9\-\_]*[a-z0-9]+\z/i
  validates :name,  presence: true, format: { with: VALID_NAME_REGEX }, 
    length: { minimum: 2, maximum: 64 },
    uniqueness: { case_sensitive: false }

  before_save do |entity|
    entity.name.downcase!
  end

  # before_destroy { |entity| EntityPropertyRelationship.destroy_all "entity_id = #{entity.id}" }
  before_destroy do |entity|
    EntityPropertyRelationship.destroy_all :entity_id => entity.id
    groups = entity.groups
    groups.each do |group|
      entity.disown! group
    end
  end

  def display_name
    return self.label unless self.label.blank?
    return self.name unless self.name.blank?
    return self.id
  end
  # before_destroy { |entity| EntityGroupRelationship.destroy_all "entity_id = #{entity.id}" }

  #####################
  # # # ENTITY TO GROUP
  #####################

  #creates an EntityGroupRelationship between this entity and the given group
  def own!(group)
    return if group.class != Group
    group = Group.find_by(id: group.id)
    return if group.nil?
    EntityGroupRelationship.create!(entity_id: self.id, group_id: group.id, position: self.groups.count)
  end

  # returns true if there exists an EntityGroupRelationship between the entity and the given group
  def owns?(group)
    return if group.class != Group
    self.groups.any? {|g| g[:id] == group.id}
  end

  #returns an array of groups associated with this entity through EntityGroupRelationships
  def groups
    groups = []
    relations = self.group_relations
    relations.each do |r|
      groups.push r.group
    end
    groups
  end

  #returns the EntityGroupRelationships associated with this entity sorted
  #by the order field
  def group_relations
    relations = EntityGroupRelationship.where(entity_id: self.id)
    relations.sort_by { |r| r[:position] }
  end

  #gives the EntityGroupRelationship between the entity and the given group
  def relation_for(group)
    return if group.class != Group
    self.group_relations.select { |r| r[:group_id] == group.id }.first
  end

  #gives the EntityPropertyRelationship between the entity and the given property via the
  #given group
  def relation_for_via(property, group)
    return if group.class != Group
    return if property.class != Property
    self.property_relations.select { |r| r[:property_id] == property.id && r[:group_id] == group.id }.first
  end

  #destroys the EntityGroupRelationship between the entity and the given group
  def disown!(group)
    return if group.class != Group
    e = Entity.find_by(id: self.id)
    return if e.nil?
    relationship = EntityGroupRelationship.find_by(entity_id: self.id, group_id: group.id)
    return if relationship.nil?
    if relationship.position.nil?
      return relationship.destroy
    end
    index = relationship.position
    relationship.destroy
    # self.update_position(index)
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

  #returns true if there is a EntityPropertyRelationship between the entity and
  #the given property
  def utilizes?(property)
    return false if property.class != Property
    property = Property.find_by(id: property.id)
    return false if property.nil?
    self.properties.include?(property)
  end

  #Array of all property associations for this entity
  def property_relations
    relations = EntityPropertyRelationship.where(entity_id: self.id)
    relations.sort_by { |r| r[:position] }
  end

  def property_relations_via(group)
    relations = []
    if group.class == Fixnum
      relations = self.property_relations.select { |r| r[:group_id] == group }
    else
      relations = self.property_relations.select { |r| r[:group_id] == group.id }
    end
    relations.sort_by { |r| r[:position] }
  end

  # an array of all employed properties
  def properties
    properties = []
    relations = self.property_relations
    relations.each do |relationship|
      properties.push relationship.property
    end
    properties
  end

  #an array of all employed properties
  def properties_via(group)
    properties = []
    property_relations_via(group).each do |relationship|
      property = relationship.property
      properties.push(property)
    end
    properties
  end

  #destroys the EntityGroupRelationship between the entity and the given group
  def disown_property!(property)
    return false if property.class != Property
    return false if Entity.find_by_id(self.id).nil?
    return false if Property.find_by_id(property.id).nil?
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id)
    return if relationship.nil?
    if relationship.position.nil?
      return relationship.destroy
    end
    index = relationship.position
    relationship.destroy
    # self.p_update_position(index)
  end


  ####################
  # # # PROPERTY ORDER
  ####################

  #updates the position of all the children after the given index
  def p_update_position_via(index, group)
    relationships = self.property_relations
    relationships |= self.property_relations.select { |r| r[:position] != nil && r[:group_id] == group.id }
    last = relationships.count 
    relationships.each do |r|
      if r.position.nil?
        r.position = last -= 1
        r.save
      else
        if r.position > index
          r.position -= 1 
          r.save
        end
      end
    end
  end

  #sets the property to be the first ordered property of this entity
  #updates the positions of all affected entity-property relationships
  #position is the position which properties will be displayed under an
  #entity in ascending order
  def first_via!(property, group)
    return if property.class != Property
    return if group.class != Group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.property_relations.select { |r| r[:group_id] == group.id }
    last = relationships.count 
    return if relationship.position == 0
    if relationship.position.nil?
      line = last - 1
    else
      line = relationship.position
    end
    relationships.each do |r|
      next if r == relationship
      if r.position.nil?
        r.update_attribute(:position, last -= 1)
      else
        if r.position < line
          r.update_attribute(:position, r.position + 1)
        end
      end
    end
    relationship.update_attribute(:position, 0)
  end

  #moves the given property up (decrement position) in order with the associated group
  #also moves the property above it down (increment position)
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
    return if relationship.position == 0
    #relationship after property
    swap = self.property_relations_via(group)[relationship.position - 1]
    #move the property below the passed property up
    swap.update_attribute(:position, swap.position + 1)
    #move the passed property down
    relationship.update_attribute(:position, relationship.position - 1)
  end

  #moves the given property down (increment position) in order with the associated group
  #also moves the property below it up (decrement position)
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
    return if relationship.position == relationships.count - 1
    #relationship after property
    swap = self.property_relations_via(group)[relationship.position + 1]
    #move the property below the passed property up
    swap.update_attribute(:position, swap.position - 1)
    #move the passed property down
    relationship.update_attribute(:position, relationship.position + 1)
  end

  #returns the property that is first in ordering
  def first_via(group)
    relationship = self.property_relations.select { |r| r[:position] == 0 && r[:group_id] == group.id }[0]
    return if relationship.nil?
    Property.find_by(id: relationship.property_id)
  end


  #sets the property to be the last ordered property of this entity
  #updates the positions of all affected entity-property relationships
  #position is the order which properties will be displayed under an
  #entity in ascending order
  def last_via!(property, group)
    return if property.class != Property
    return if group.class != Group
    relationship = EntityPropertyRelationship.find_by(entity_id: self.id, property_id: property.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.property_relations.select { |r| r[:group_id] == relationship.group_id }
    last = relationships.count - 1 # - 1 because child will be set to last at the end
    return if relationship.position == last
    if relationship.position.nil?
      line = 0
    else
      line = relationship.position
    end
    relationships.each do |r|
      next if r == relationship
      if r.position.nil?
        r.update_attribute(:position, last -= 1)
      else
        if r.position > line
          r.update_attribute(:position, r.position - 1)
        end
      end
    end
    relationship.update_attribute(:position, relationships.count - 1)
  end

  #returns the property that is first in ordering
  def last_via(group)
    relationships = self.property_relations_via group
    return if relationships.empty?
    last_index = relationships.count - 1
    last_relationship  = relationships.select { |r| r[:position] == last_index }.first
    return if last_relationship.nil?
    Property.find_by(id: last_relationship.property_id)
  end


  #################
  # # # GROUP ORDER
  #################

  #updates the position of all the children after the given index
  def update_position(index)
    relationships = self.group_relations
    last = relationships.count 
    relationships.each do |r|
      if r.position.nil?
        r.update_attribute(:position, last -= 1)
      else
        if r.position > index
          r.update_attribute(:position, r.position - 1)
        end
      end
    end
  end

  #sets the property to be the first ordered property of this entity
  #updates the positions of all affected entity-property relationships
  #position is the order which properties will be displayed under an
  #entity in ascending order
  def first!(group)
    return if group.class != Group
    relationship = self.group_relations.select { |r| r[:group_id] == group.id }.first
    return if relationship.nil?
    last = self.group_relations.count 
    return if relationship.position == 0
    if relationship.position.nil?
      line = last - 1
    else
      line = relationship.position
    end
    relations = self.group_relations
    relations.each do |r|
      next if r == relationship
      if r.position.nil?
        r.update_attribute(:position, last -= 1)
      else
        if r.position < line
          r.update_attribute(:position, r.position + 1)
        end
      end
    end
    relationship.update_attribute(:position, 0)
  end

  #returns the property that is first in ordering
  def first
    first_relationship = self.group_relations.select { |r| r[:position] == 0 }.first
    return if first_relationship.nil?
    first_relationship.group
  end

  #moves the specified group up in order and moves the group above it down
  def up!(group)
    return if group.class != Group
    relationship = self.relation_for(group)
    return if relationship.nil?
    return if relationship.position == 0
    r = self.group_relations[relationship.position - 1]
    r.update_attribute(:position, relationship.position)
    relationship.update_attribute(:position, relationship.position - 1)
  end

  #moves the specified group down in position and moves the group below it up
  def down!(group)
    return if group.class != Group
    relationship = self.relation_for(group)
    return if relationship.nil?
    last = self.group_relations.count - 1
    return if relationship.position == last
    r = self.group_relations[relationship.position + 1]
    # r = self.relation_at(relationship.position + 1)
    r.update_attribute(:position, relationship.position)
    relationship.update_attribute(:position, relationship.position + 1)
  end

  #sets the property to be the last ordered property of this entity
  #updates the positions of all affected entity-property relationships
  #position is the order which properties will be displayed under an
  #entity in ascending order
  def last!(group)
    return if group.class != Group
    relationship = EntityGroupRelationship.find_by(entity_id: self.id, group_id: group.id)
    return if relationship.nil?
    relationships = self.group_relations
    last = relationships.count - 1 # - 1 because child will be set to last at the end
    return if relationship.position == last
    if relationship.position.nil?
      line = 0
    else
      line = relationship.position
    end
    relationships.reverse.each do |r|
      next if r == relationship
      if r.position.nil?
        r.update_attribute(:position, last -= 1)
      else
        if r.position > line
          r.update_attribute(:position, last -= 1)
        end
      end
    end
    relationship.update_attribute( :position, relationships.count - 1 )
  end

  #returns the property that is last in ordering
  def last
    relationships = self.group_relations
    last_index = relationships.count - 1
    last_relationship = relationships.select { |child| child[:position] == last_index }.first
    return if last_relationship.nil?
    last_relationship.group
  end

  ###################
  # # # ENTITY SEARCH
  ###################

  #class function
  #returns entities that match the given search string
  #It searches the name, label, created, and updated fields for partial matches
  def self.search(search)
    #return all entities if search is nil
    return all if search.nil?

    search.downcase!

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
        clause += '(LOWER(name) LIKE ? OR LOWER(label) LIKE ? OR created_at::text LIKE ? OR updated_at::text LIKE ?) AND '
      end
      #remove the trailing 'AND' from the clause
      clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

      #call the query using the clause and each binding element and return the result
      where clause, *elements
    else
      all # if _elements.empty?
    end
  end

end
