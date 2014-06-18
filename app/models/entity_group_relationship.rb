class EntityGroupRelationship < ActiveRecord::Base
  belongs_to :entity, class_name: "Entity", foreign_key: "entity_id"
  belongs_to :group, class_name: "Group", foreign_key: "group_id"
  validates :entity_id, presence: true
  validates :group_id, presence: true
  validates :order, presence: true

  after_create do |r|
    r.group.properties.each do |property|
      EntityPropertyRelationship.create!(entity_id: r.entity_id, group_id: r.group_id, property_id: property.id, order: r.group.relation_for(property).order, value: property.default_value, visibility: property.default_visibility, label: property.default_label)
    end
  end

  before_destroy { |r| EntityPropertyRelationship.destroy_all group_id: "#{r.group_id}", entity_id: "#{r.entity_id}" }

  ######################################
  # # # ENTITY GROUP RELATIONSHIP SEARCH
  ######################################

  #instance function
  #returns entities that match the given search string
  #It searches the name, label, created, and updated fields for partial matches
  # def self.search(search)
  #   self.group.search(search)
  # end
end
