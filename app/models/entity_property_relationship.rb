class EntityPropertyRelationship < ActiveRecord::Base
  belongs_to :entity, class_name: "Entity", foreign_key: "entity_id"
  belongs_to :property, class_name: "Property", foreign_key: "property_id"
  validates :entity_id, presence: true
  validates :property_id, presence: true


  def group
    group = Group.find_by id: self.group_id
  end

end
