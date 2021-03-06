class GroupPropertyRelationship < ActiveRecord::Base
  belongs_to :group
  belongs_to :property
  validates :group_id, 
    presence: true
  validates :property_id, 
    presence: true
  validates :position, 
    presence: true

  after_create do |r|
    property = Property.find_by id: r.property_id
    return if property.nil?
    r.group.entities.each do |entity|
      EntityPropertyRelationship.create! entity_id: entity.id, group_id: r.group_id, property_id: property.id, position: r.position, value: property.default_value, role_ids: property.role_ids, label: property.default_label
    end
  end

  after_destroy do |r|
    EntityPropertyRelationship.destroy_all group_id: r.group_id, property_id: r.property_id
    r.group.update_position(r.position)
  end
end
