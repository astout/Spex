class PropertyAssociation < ActiveRecord::Base
  belongs_to :parent, class_name: "Property", foreign_key: "parent_id"
  belongs_to :child, class_name: "Property", foreign_key: "child_id"
  validates :parent_id, presence: true 
  validates :child_id, presence: true 

  # def parent
  #   Property.find(self.parent)
  # end

  # def child
  #   Property.find(self.child)
  # end

  # def parent_name
    
  # end

end
