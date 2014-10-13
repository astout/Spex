class Property < ActiveRecord::Base
  has_many :group_property_relationships
  has_many :entity_property_relationships
  has_many :entities, 
    through: :entity_property_relationships, 
    inverse_of: :properties
  has_many :groups, 
    through: :group_property_relationships, 
    inverse_of: :properties
  has_and_belongs_to_many :roles
  VALID_NAME_REGEX = /\A[a-z0-9]+[a-z0-9\-\_]*[a-z0-9]+\z/i
  validates :name,  presence: true, format: { with: VALID_NAME_REGEX }, 
    length: { minimum: 2, maximum: 64 },
    uniqueness: { case_sensitive: false }

  before_save do |property|
    property.name.downcase!
  end

  before_destroy do |property|
    GroupPropertyRelationship.destroy_all "property_id = #{property.id}"
    EntityPropertyRelationship.destroy_all "property_id = #{property.id}"
    # self.flee_all!
    # self.entities.each do |e|
    #   self.flee_entity!(e)
    # end
  end

  def label
    self.default_label
  end

  def display_name
    return self.default_label unless self.default_label.blank?
    return self.name unless self.name.blank?
    return self.id
  end

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
    self.entity_relations.each do |epr|
      result |= [epr.entity]
    end
    result
  end

  def entity_relations
    EntityPropertyRelationship.where(property_id: self.id)
  end

  #Breaks the relationship of this property to the given group
  def flee_entity!(e)
    return if e.class != Entity
    e.disown_property!(self)
  end

  ##################
  # # # PROPERTY SEARCH
  ##################

  #class function
  #returns groups that match the given search string
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
        elements.concat [e]*7
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(LOWER(name) LIKE ? OR LOWER(default_label) LIKE ? OR LOWER(units) LIKE ? OR LOWER(units_short) LIKE ? OR LOWER(default_value) LIKE ? OR created_at::text LIKE ? OR updated_at::text LIKE ?) AND '
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
