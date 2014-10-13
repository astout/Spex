module EntityPropertyRelationsHelper
  include EntityGroupRelationsHelper

  #retrieve the DB instances of the selected entity property relations
  def selected_eprs
    @selected_eprs = []
    selected_relation_ids = params[:selected_eprs]
    unless selected_relation_ids.nil?
      selected_relation_ids.each do |id|
        relation = EntityPropertyRelationship.find_by id: id
        unless relation.nil?
          @selected_eprs.push relation
        end
      end
    end
    @selected_eprs
  end

  def epr_update(epr_params)
    puts " -- EPR PARAMS -- "
    puts epr_params

    epr = { status: -1, msg: "", data: nil }
    epr[:data] = EntityPropertyRelationship.find_by id: epr_params[:id]
    if epr[:data].blank?
      puts " -- EPR NOT FOUND -- "
      epr[:status] = 0
      epr[:msg] = "EntityPropertyRelationship with id: #{epr_params[:id]} not found."
    else
      puts " -- SAVING EPR PARAMETERS -- "
      success = epr[:data].update(epr_params)
      puts " -- SUCCESS -- "
      puts " -- ADDING ROLES TO EPR --"
      puts " ROLE PARAM"
      puts params[:role_ids]
      # puts " -- EPR --"
      # puts epr[:data]
      epr[:data].role_ids = params[:role_ids]
      puts " -- EPR ROLES -- "
      puts epr[:data].roles      
      epr[:status] = success ? 1 : 0
      epr[:msg] = success ? "" : "the relation couldn't be updated"
      puts " -- EPR --"
      puts epr
    end
    return epr
  end

  def eprs_index
    inclusion = epr_prioritize(selected_egrs())
    EntityPropertyRelationship.index(params[:epr_search], epr_sort_column, epr_sort_direction, params[:epr_page], 10, [], inclusion)
  end

  #get the entity property relations for the selected group
  def epr_list(selected_egrs)
    #start a list of properties that are being listed
    used_properties = []

    eprs = []

    #for each selected entity group relation
    selected_egrs.each do |group_relation|

      #get the entity property relations that involve the current entity group relation
      group_relation.eprs.each do |epr|

        #unless the current entity property relation's property is already listed
        unless used_properties.include? epr.property
          
          #add the entity property relation to the list
          eprs |= [epr]

          #
          used_properties |= [epr.property]

        end #end add to list
      
      end #end each entity property relation
    
    end #end each entity group relation

    eprs = eprs.paginate(page: params[:epr_page], per_page: 10, position: 'position ASC')
  end

  def epr_prioritize(selected_egrs)
    #start a list of properties that are being listed
    used_properties = []

    eprs = []

    #for each selected entity group relation
    selected_egrs.each do |group_relation|

      #get the entity property relations that involve the current entity group relation
      group_relation.eprs.each do |epr|

        #unless the current entity property relation's property is already listed
        unless used_properties.include? epr.property
          
          #add the entity property relation to the list
          eprs |= [epr]

          #
          used_properties |= [epr.property]

        end #end add to list
      
      end #end each entity property relation
    
    end #end each entity group relation

    return eprs
  end

  def get_eprs(selected_egrs)
    eprs = { status: -1, msg: "", data: [] }
    #if nothing selected
    if selected_egrs.blank?
      eprs[:status] = 1
      eprs[:msg] = ""
    else #otherwise get the data
      eprs[:data] = epr_list(selected_egrs)

      #if the data is empty
      if eprs[:data].empty?
        eprs[:status] = 2
        eprs[:msg] = "No properties for '#{selected_egrs.first.group.name}'"
      else #otherwise success
        eprs[:status] = 1
        eprs[:msg] = ""
      end
    end
    return eprs
  end

  def epr_top(selected_eprs)

    #set the count to one more than actual for iterative reduction
    count = selected_eprs.count + 1

    #move each selected relation to the top in reverse position
    moved_eprs = []
    selected_eprs.reverse.each do |relation|
      success = relation.entity.first_via! relation.property, relation.group
      moved_eprs.push success ? { data: relation, msg: "moved to top", idx: count -= 1 } : { data: relation, msg: "not moved", idx: count -= 1 }
    end
    return moved_eprs
  end

  def epr_bottom(selected_egrs, selected_eprs)
    #index is the total entity property relationships for the selected group minus what is selected

    return if selected_egrs.count != 1

    selected_egr = selected_egrs.first

    _index = selected_egr.group.properties.count - selected_eprs.count

    #store the status of what is moved
    moved_eprs = []

    #sort the relations by position
    relations = selected_eprs.sort_by { |r| r[:position] }

    #enumerate over the relations, get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      #success true if the move is successful
      success = relation.entity.last_via! relation.property, relation.group
      moved_eprs.push success ? { data: relation, msg: "moved to bottom", idx: _index += 1 } : { data: relation, msg: "not moved", idx: _index += 1 }
    end

    #reverse the order of what was moved for reporting to user
    moved_eprs.reverse!
  end

  def epr_up(selected_eprs)
    #data for what is moved
    moved_eprs = []

    #sort the relations by position
    relations = selected_eprs.sort_by { |r| r[:position] }

    #enumerate the relations and get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      if relation.position == i #if position is the current index, doesn't need to move
        moved_eprs.push({ data: relation, msg: "not moved", idx: i+1 })
      else #move it
        success = relation.entity.up_via! relation.property, relation.group
        moved_eprs.push success ? { data: relation, msg: "moved", idx: relation.position } : { data: relation, msg: "not moved", idx: relation.position + 1 }
      end
    end

    #reverse for reporting
    moved_eprs.reverse!
  end

  def epr_down(selected_eprs)
    #data for moved relations
    moved_eprs = []

    #sort the relations by position
    relations = selected_eprs.sort_by { |r| r[:position] }

    #reverse the order, enumerate with 0-based index i
    relations.reverse.to_enum.with_index(0).each do |relation, i|
      #if the position is the inverse of the current index (indexing from high to low)
      if relation.position == relation.group.properties.count - 1 - i 
        moved_eprs.push({ data: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.entity.down_via! relation.property, relation.group
        moved_eprs.push success ? { data: relation, msg: "moved", idx: relation.position + 2 } : { data: relation, msg: "not moved", idx: relation.position + 1 }
      end
    end
    return moved_eprs
  end

  def epr_sort_column
    columns = EntityPropertyRelationship.column_names
    # columns |= ["entity", "group", "property"]
    columns.include?(params[:epr_sort]) ? params[:epr_sort] : "created_at"
  end
    
  def epr_sort_direction
    %w[asc desc].include?(params[:epr_direction]) ? params[:epr_direction] : "desc"
  end

  def epr_params
    params.require(:entity_property_relationship).permit(:entity_id, :group_id, :property_id, :position, :label, :value, :units, :units_short)
  end
  
  def epr_update_params
    params.require(:entity_property_relationship).permit(:id, :label, :value, :role_ids, :units, :units_short)
  end

end