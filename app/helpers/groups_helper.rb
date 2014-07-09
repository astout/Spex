module GroupsHelper

  def selected_groups
    @selected_groups = []
    selected_group_ids = params[:selected_groups]
    unless selected_group_ids.nil?
      selected_group_ids.each do |id|
        group = Group.find_by(id: id)
        unless group.nil? 
          @selected_groups.push group
        end
      end
    end
    @selected_groups
  end

  def groups_list(selected_entity)
    if selected_entity.nil?
      groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page].blank? ? 1 : params[:groups_page], per_page: 10)
    else
      #store the entity's groups to eliminate repeated queries
      reject_groups = selected_entity.groups
      groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).reject { |group| reject_groups.any? { |e_group| e_group[:id] == group[:id] } }.paginate(page: params[:groups_page].blank? ? 1 : params[:groups_page], per_page: 10)
    end
    return groups
  end

  def group_create(params)
    group = { status: -1, msg: "", data: nil }

    #check that a Group doesn't exist in the DB with the given name
    #nil if not found
    group[:data] = Group.find_by(name: params[:name])

    #if nil, clear to create
    if group[:data].nil?
      group[:data] = Group.new(params)
      if !group[:data].save
        group[:status] = 0
        group[:msg] = "'#{group[:data].name}' failed to save."
      else
        group[:status] = 1
        group[:msg] = "'#{group[:data].name}' was saved."
      end
    else #otherwise name is taken, status is fail
      group[:status] = 0
      group[:msg] = "Name: '#{group[:data].name}' is already taken."
    end
    return group
  end

  def groups_delete(groups)
    deleted_groups = []
    groups.each do |group|
      deleted_groups.push group ? { data: group.destroy, msg: "deleted" } : { data: nil, msg: "group was nil" }
    end
    return deleted_groups
  end

  def add_properties_to_group(selected_groups, selected_properties)
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


end
