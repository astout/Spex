module EntityGroupRelationsHelper

  #retrieve the DB instances of the selected entity group relations
  def selected_egrs
    @selected_egrs = []
    selected_relation_ids = params[:selected_entity_group_relations]
    unless selected_relation_ids.nil?
      selected_relation_ids.each do |id|
        relation = EntityGroupRelationship.find_by id: id
        unless relation.nil?
          @selected_egrs.push relation
        end
      end
    end
    @selected_egrs
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
    egrs = selected_entity.group_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
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

    #move each selected relation to the top in reverse order
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

    #sort the relations by order
    relations = selected_egrs.sort_by { |r| r[:order] }

    #enumerate over the relations, get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      #success true if the move is successful
      success = relation.entity.last! relation.group
      moved_egrs.push success ? { data: relation, msg: "moved to bottom", idx: _index += 1 } : { data: relation, msg: "not moved", idx: _index += 1 }
    end

    #reverse the order of what was moved for reporting to user
    moved_egrs.reverse!
  end

  def egr_up(selected_egrs)
    #data for what is moved
    moved_egrs = []

    #sort the relations by order
    relations = selected_egrs.sort_by { |r| r[:order] }

    #enumerate the relations and get a 0-based index
    relations.to_enum.with_index(0).each do |relation, i|
      if relation.order == i #if order is the current index, doesn't need to move
        moved_egrs.push({ data: relation, msg: "not moved", idx: i+1 })
      else #move it
        success = relation.entity.up! relation.group
        moved_egrs.push success ? { data: relation, msg: "moved", idx: relation.order } : { data: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end

    #reverse for reporting
    moved_egrs.reverse!
  end

  def egr_down(selected_egrs)
    #data for moved relations
    moved_egrs = []

    #sort the relations by order
    relations = selected_egrs.sort_by { |r| r[:order] }

    #reverse the order, enumerate with 0-based index i
    relations.reverse.to_enum.with_index(0).each do |relation, i|
      #if the order is the inverse of the current index (indexing from high to low)
      if relation.order == relation.entity.groups.count - 1 - i 
        moved_egrs.push({ data: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.entity.down! relation.group
        moved_egrs.push success ? { data: relation, msg: "moved", idx: relation.order + 2 } : { data: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end
    return moved_egrs
  end

end