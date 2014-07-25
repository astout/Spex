class EntityGroupRelationship < ActiveRecord::Base
  belongs_to :entity
  belongs_to :group 
  validates :entity_id, 
    presence: true
  validates :group_id, 
    presence: true
  validates :order, 
    presence: true

  after_create do |r|
    r.group.properties.each do |property|
      EntityPropertyRelationship.create!(entity_id: r.entity_id, group_id: r.group_id, property_id: property.id, order: r.group.relation_for(property).order, value: property.default_value, visibility: property.default_visibility, label: property.default_label)
    end
  end

  before_destroy do |r| 
    EntityPropertyRelationship.destroy_all group_id: "#{r.group_id}", entity_id: "#{r.entity_id}"
  end

  after_destroy do |r|
    r.entity.update_order(r.order)
  end

  def eprs
    relations = EntityPropertyRelationship.where(entity_id: self.entity.id, group_id: self.group.id)
    relations.sort_by { |r| r[:order] }
  end
end
