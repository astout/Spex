module GroupPropertyRelationsHelper

  #retrieve the DB instances of the selected group property relations
  def selected_gprs
    @selected_gprs = []
    selected_relation_ids = params[:selected_gprs]
    unless selected_relation_ids.nil?
      selected_relation_ids.each do |id|
        relation = GroupPropertyRelationship.find_by id: id
        unless relation.nil?
          @selected_gprs.push relation
        end
      end
    end
    @selected_gprs
  end

  #get the group property relations for the selected group
  def gpr_list(selected_groups)
    #start a list of properties that are being listed
    used_properties = []

    gprs = []

    #for each selected group
    selected_groups.each do |group|

      #get the current group's group property relations
      group.property_relations.each do |property_relation|

        #unless the current group property relation's property is already listed
        unless used_properties.include? property_relation.property

          #add the group property relationship to the data list
          gprs |= [property_relation]

          #add the property to the list of listed properties
          used_properties |= [property_relation.property]
        
        end #end add relation to list
      
      end #end each group property relation

    end #end each selected group

    gprs = gprs.paginate(page: params[:gprs_page], per_page: 10, order: 'order ASC')
  end

  def get_gprs(selected_groups)
    gprs = { status: -1, msg: "", data: [] }
    #if nothing selected
    if selected_groups.blank?
      gprs[:status] = 1
      gprs[:msg] = ""
    else #otherwise get the data
      gprs[:data] = gpr_list(selected_groups)

      #if the data is empty
      if gprs[:data].empty?
        gprs[:status] = 2
        gprs[:msg] = "No groups for '#{selected_groups.first.name}'"
      else #otherwise success
        gprs[:status] = 1
        gprs[:msg] = ""
      end
    end
    return gprs
  end

  def gprs_create(selected_groups, selected_properties)
    added_properties = []
    #there should only be one group selected, this is enforced client-side
    unless selected_groups.blank?
      group = selected_groups.first #get the first group of the selected groups (should be only one)
      unless group.nil?
        #for each selected property
        selected_properties.each do |property|

          #create the relatioships between the group and the current property
          added_properties.push property ? { relation: group.own!(property), property: property, msg: "added to #{group.name}" } : { relation: "", property: "", msg: "property was nil" }
        end
      end
    else
      added_properties.push({ relation: "", group: "", msg: "group was nil" })
    end
    return added_properties
  end

  def gpr_delete(selected_gprs)
    #destroy the selected group property relationships
    deleted_gprs = []
    selected_gprs.each do |relation|
      success = relation.property.flee! relation.group
      deleted_gprs.push success ? { data: relation, msg: "deleted" } : { data: relation, msg: "not deleted" }
    end
    return deleted_gprs
  end

  def gpr_top(selected_gprs)

    #set the count to one more than actual for iterative reduction
    count = selected_gprs.count + 1

    #move each selected relation to the top in reverse order
    moved_gprs = []
    selected_gprs.reverse.each do |relation|
      success = relation.group.first! relation.property
      moved_gprs.push success ? { data: relation, msg: "moved to top", idx: count -= 1 } : { data: relation, msg: "not moved", idx: count -= 1 }
    end
    return moved_gprs
  end

  def gpr_bottom(selected_groups, selected_gprs)
    #index is the total group property relationships for the selected group minus what is selected

    return if selected_groups.count > 1

    selected_group = selected_groups.first

    _index = selected_group.properties.count - selected_gprs.count

    #store the status of what is moved
    moved_gprs = []

    #sort the relations by order
    relations = selected_gprs.sort_by { |r| r[:order] }

    #enumerate over the relations, get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      #success true if the move is successful
      success = relation.group.last! relation.property
      moved_gprs.push success ? { data: relation, msg: "moved to bottom", idx: _index += 1 } : { data: relation, msg: "not moved", idx: _index += 1 }
    end

    #reverse the order of what was moved for reporting to user
    moved_gprs.reverse!
  end

  def gpr_up(selected_gprs)
    #data for what is moved
    moved_gprs = []

    #sort the relations by order
    relations = selected_gprs.sort_by { |r| r[:order] }

    #enumerate the relations and get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      if relation.order == i #if order is the current index, doesn't need to move
        moved_gprs.push({ data: relation, msg: "not moved", idx: i+1 })
      else #move it
        success = relation.group.up! relation.property
        moved_gprs.push success ? { data: relation, msg: "moved", idx: relation.order } : { data: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end

    #reverse for reporting
    moved_gprs.reverse!
  end

  def gpr_down(selected_gprs)
    #data for moved relations
    moved_gprs = []

    #sort the relations by order
    relations = selected_gprs.sort_by { |r| r[:order] }

    #reverse the order, enumerate with 0-based index i
    relations.reverse.to_enum.with_index(0).each do |relation, i|
      #if the order is the inverse of the current index (indexing from high to low)
      if relation.order == relation.group.properties.count - 1 - i 
        moved_gprs.push({ data: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.group.down! relation.property
        moved_gprs.push success ? { data: relation, msg: "moved", idx: relation.order + 2 } : { data: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end
    return moved_gprs
  end

end