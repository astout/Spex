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

  #Get the list of entities based on pagination page, search field, and sort it
  def entities_list
    Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page].blank? ? 1 : params[:entities_page], per_page: 10)
  end

  #retrieve the DB instance of the selected entity
  def selected_entity
    @selected_entity = Entity.find_by(id: params[:selected_entity])
  end

  #create entity and provide response structure given the entity params
  def entity_create(params)
    entity = { status: -1, msg: "", data: nil }
    #check that an item with that name doesn't already exist
    entity[:data] = Entity.find_by(name: params[:name])
    if entity[:data].nil? #if it doesn't already exist
      #create the entity using all the submitted params
      entity[:data] = Entity.new(params)
      if !entity[:data].save #if not successful
        entity[:status] = 0
        entity[:msg] = "'#{entity[:data].name}' failed to save."
      else
        entity[:status] = 1
        entity[:msg] = "'#{entity[:data].name}' was saved."
      end
    else
      #if data is nil, the name is already taken
      entity[:status] = 0
      entity[:msg] = "Name: '#{entity[:data].name}' is already taken."
    end
    entity
  end

  def entity_delete(id)
    entity = { status: -1, msg: "", data: nil }

    #find the instance in the DB from the id parameter
    entity[:data] = Entity.find_by(id: id)

    #success if the entity is destroyed, failure otherwise
    success = entity[:data] ? entity[:data].destroy : false

    #status is 1 if successful, 0 otherwise
    entity[:status] = success ? 1 : 0

    #update msg based on success
    entity[:msg] = success ? "'#{entity[:data].name}' deleted." : "Unable to delete '#{entity[:data].name}'."

    entity
  end

  # def link_to_add_property(entity, property)
  #   link_to "Add Property", controller: :entity_property_relationships, 
  #     action: :create,  method: :post, entity_id: entity.id, property_id: property.id
  # end  
end
