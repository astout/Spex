module EntitiesHelper
  def current_entity
    @current_entity = Entity.find(params[:id])
  end

  def current_entity=(entity)
    @current_entity = entity
  end

  def current_entity?(entity)
    entity == current_entity
  end

  # def link_to_add_property(entity, property)
  #   link_to "Add Property", controller: :entity_property_relationships, 
  #     action: :create,  method: :post, entity_id: entity.id, property_id: property.id
  # end  
end
