module PropertiesHelper
  def current_property
    @current_property = Property.find(params[:id])
  end

  def current_property=(property)
    @current_property = property
  end

  def current_property?(property)
    property == current_property
  end

  # def link_to_add_parent(parent, child)
  #   link_to "Add as Parent", controller: :property_associations, 
  #     action: :create,  method: :post, parent_id: parent.id, child_id: child.id
  # end  
end
