class EntityGroupRelationship < ActiveRecord::Base
  belongs_to :entity
  belongs_to :group 
  validates :entity_id, 
    presence: true
  validates :group_id, 
    presence: true
  validates :position, 
    presence: true

  after_create do |r|
    r.group.properties.each do |property|
      EntityPropertyRelationship.create!(entity_id: r.entity_id, group_id: r.group_id, property_id: property.id, position: r.group.relation_for(property).position, value: property.default_value, label: property.default_label)
    end
  end

  before_destroy do |r| 
    EntityPropertyRelationship.destroy_all group_id: "#{r.group_id}", entity_id: "#{r.entity_id}"
  end

  after_destroy do |r|
    r.entity.update_position(r.position)
  end


  def display_name
    return self.label unless self.label.blank?
    return self.group.display_name
  end

  def eprs
    relations = EntityPropertyRelationship.where(entity_id: self.entity.id, group_id: self.group.id)
    relations.sort_by { |r| r[:position] }
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
          elements.concat [e]*7
        end
        #declare the where clause
        clause = ''

        #for each word from the search string
        _elements.each do |element|
          #append to the clause the full query
          clause += '(LOWER(entities.name) LIKE ? OR LOWER(entities.label) LIKE ? OR LOWER(groups.name) LIKE ? OR LOWER(groups.default_label) LIKE ? OR LOWER(entity_group_relationships.label) LIKE ? OR entity_group_relationships.created_at::text LIKE ? OR entity_group_relationships.updated_at::text LIKE ?) AND '
        end
        #remove the trailing 'AND' from the clause
        clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

        full_join = EntityGroupRelationship.joins(:group).joins(:entity)

        full_join.where clause, *elements

        #call the query using the clause and each binding element and return the result
        # where clause, *elements
      else
        all # if _elements.empty?
      end
    end

end
