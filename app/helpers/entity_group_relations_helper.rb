module EntityGroupRelationsHelper

  #retrieve the DB instances of the selected entity group relations
  def selected_egrs(ids = nil)
    @selected_egrs = []
    selected_relation_ids = ids || params[:selected_egrs]
    unless selected_relation_ids.blank?
      selected_relation_ids.each do |id|
        relation = EntityGroupRelationship.find_by id: id
        unless relation.blank?
          @selected_egrs.push relation
        end
      end
    end
    @selected_egrs
  end

  def egr_create(selected_entity, selected_groups)
    created_relations = []

    #unless there's no selected entity
    unless selected_entity.nil?

      #for each selected group
      selected_groups.each do |group|

        #create the relationship and push the data
        created_relations.push group ? { relation: selected_entity.own!(group), group: group, msg: "added to #{selected_entity.name}" } : { relation: "", group: "", msg: "group not found" }

      end
    else #there's no entity
      created_relations.push({ relation: "", group: "", msg: "entity not found" })
    end
    return created_relations
  end

  def egrs_index
    inclusion = []
    e = selected_entity()
    unless e.blank?
      inclusion = e.group_relations
    end
    EntityGroupRelationship.index(params[:egr_search], egr_sort_column, egr_sort_direction, params[:egr_page], 10, [], inclusion)
  end

  def get_egrs(selected_entity)
    entitys_group_relations = { status: -1, msg: "", data: [] }
    #if nothing selected
    if selected_entity.nil?
      entitys_group_relations[:status] = 1
      entitys_group_relations[:msg] = ""
    else #otherwise get the data
      entitys_group_relations[:data] = egr_list(selected_entity)

      #if the data is empty
      if entitys_group_relations[:data].empty?
        entitys_group_relations[:status] = 2
        entitys_group_relations[:msg] = "No groups for '#{selected_entity.name}'"
      else #otherwise success
        entitys_group_relations[:status] = 1
        entitys_group_relations[:msg] = ""
      end
    end
    return entitys_group_relations
  end

  #get the entity group relations for the selected entity
  def egr_list(selected_entity)
    # egrs = EntityGroupRelationship.index("", "position", "ASC", params[:egrs_page], 10, [], selected_entity.group_relations)
    egrs = selected_entity.group_relations.paginate(page: params[:egrs_page], per_page: 10, position: 'position ASC')
    return egrs
  end

  def egr_delete(selected_egrs)
    #destroy the selected entity group relationships
    deleted_egrs = []
    selected_egrs.each do |relation|
      success = relation.group.flee! relation.entity
      deleted_egrs.push success ? { data: relation, msg: "deleted" } : { data: relation, msg: "not deleted" }
    end
    return deleted_egrs
  end

  def egr_top(selected_egrs)

    #set the count to one more than actual for iterative reduction
    count = selected_egrs.count + 1

    #move each selected relation to the top in reverse position
    moved_egrs = []
    selected_egrs.reverse.each do |relation|
      success = relation.entity.first! relation.group
      moved_egrs.push success ? { data: relation, msg: "moved to top", idx: count -= 1 } : { data: relation, msg: "not moved", idx: count -= 1 }
    end
    return moved_egrs
  end

  def egr_bottom(selected_entity, selected_egrs)
    #index is the total entity group relationships for the selected entity minus what is selected
    _index = selected_entity.groups.count - selected_egrs.count

    #store the status of what is moved
    moved_egrs = []

    #sort the relations by position
    relations = selected_egrs.sort_by { |r| r[:position] }

    #enumerate over the relations, get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      #success true if the move is successful
      success = relation.entity.last! relation.group
      moved_egrs.push success ? { data: relation, msg: "moved to bottom", idx: _index += 1 } : { data: relation, msg: "not moved", idx: _index += 1 }
    end

    #reverse the position of what was moved for reporting to user
    moved_egrs.reverse!
  end

  def egr_up(selected_egrs)
    #data for what is moved
    moved_egrs = []

    #sort the relations by position
    relations = selected_egrs.sort_by { |r| r[:position] }

    #enumerate the relations and get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      if relation.position == i #if position is the current index, doesn't need to move
        moved_egrs.push({ data: relation, msg: "not moved", idx: i+1 })
      else #move it
        success = relation.entity.up! relation.group
        moved_egrs.push success ? { data: relation, msg: "moved", idx: relation.position } : { data: relation, msg: "not moved", idx: relation.position + 1 }
      end
    end

    #reverse for reporting
    moved_egrs.reverse!
  end

  def egr_down(selected_egrs)
    #data for moved relations
    moved_egrs = []

    #sort the relations by position
    relations = selected_egrs.sort_by { |r| r[:position] }

    #reverse the position, enumerate with 0-based index i
    relations.reverse.to_enum.with_index(0).each do |relation, i|
      #if the position is the inverse of the current index (indexing from high to low)
      if relation.position == relation.entity.groups.count - 1 - i 
        moved_egrs.push({ data: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.entity.down! relation.group
        moved_egrs.push success ? { data: relation, msg: "moved", idx: relation.position + 2 } : { data: relation, msg: "not moved", idx: relation.position + 1 }
      end
    end
    return moved_egrs
  end

  def egr_params
    params.require(:entity_group_relationship).permit(:label)
  end

  def egr_sort_column
    EntityGroupRelationship.column_names.include?(params[:egr_sort]) || Group.column_names.include?(params[:egr_sort]) ? params[:egr_sort] : "position"
  end

  def egr_sort_direction
    %w[asc desc].include?(params[:egr_direction]) ? params[:egr_direction] : "desc"
  end

end