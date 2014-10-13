class EntityPropertyRelationship < ActiveRecord::Base
  attr_accessor :evaluation
  attr_reader :evaluation
  belongs_to :entity
  belongs_to :property
  belongs_to :group
  has_and_belongs_to_many :roles, join_table: "eprs_roles", foreign_key: "epr_id"
  validates :entity_id, 
    presence: true
  validates :property_id, 
    presence: true
  validates :position, 
    presence: :true

  after_destroy do |r|
    r.entity.p_update_position_via(r.position, r.group)
  end

  after_create do |r|
    r.value = r.property.default_value
    r.label = r.property.default_label
    r.roles = r.property.roles
    r.units = r.property.units
    r.units_short = r.property.units_short
    r.save
  end

  def display_name
    return self.label unless self.label.blank?
    return self.property.display_name
  end

  def egr
    egr = EntityGroupRelationship.find_by entity_id: self.entity_id, group_id: self.group_id
  end

  ################
  # # # EPR SEARCH
  ################

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
        elements.concat [e]*15
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(LOWER(entities.name) LIKE ? OR LOWER(entities.label) LIKE ? OR LOWER(groups.name) LIKE ? OR LOWER(groups.default_label) LIKE ? OR LOWER(properties.name) LIKE ? OR LOWER(properties.default_label) LIKE ? OR LOWER(properties.units) LIKE ? OR LOWER(properties.units_short) LIKE ? OR LOWER(properties.default_value) LIKE ? OR LOWER(entity_property_relationships.label) LIKE ? OR LOWER(entity_property_relationships.value) LIKE ? OR LOWER(entity_property_relationships.units) LIKE ? OR LOWER(entity_property_relationships.units_short) LIKE ? OR entity_property_relationships.created_at::text LIKE ? OR entity_property_relationships.updated_at::text LIKE ?) AND '
      end
      #remove the trailing 'AND' from the clause
      clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

      full_join = EntityPropertyRelationship.joins(:property).joins(:group).joins(:entity)

      full_join.where clause, *elements

      #call the query using the clause and each binding element and return the result
      # where clause, *elements
    else
      all # if _elements.empty?
    end
  end

end
