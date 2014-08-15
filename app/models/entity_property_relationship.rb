class EntityPropertyRelationship < ActiveRecord::Base
  attr_accessor :evaluation
  attr_reader :evaluation
  belongs_to :entity
  belongs_to :property
  belongs_to :group
  validates :entity_id, 
    presence: true
  validates :property_id, 
    presence: true
  validates :order, 
    presence: :true

  after_destroy do |r|
    r.entity.p_update_order_via(r.order, r.group)
  end

  after_create do |r|
    r.value = r.property.default_value
    r.label = r.property.default_label
    r.visibility = r.property.default_visibility
  end

  def egr
    egr = EntityGroupRelationship.find_by entity_id: self.entity_id, group_id: self.group_id
  end

  def evaluation=(value)

  end

end
