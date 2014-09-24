module GroupsHelper

  def selected_groups
    @selected_groups = []
    selected_group_ids = params[:selected_groups]
    unless selected_group_ids.blank?
      if selected_group_ids.class == String
        selected_group_ids = selected_group_ids.split(",")
      end
      @selected_groups = Group.where(id: selected_group_ids)
      # selected_group_ids.each do |id|
      #   group = Group.find_by(id: id)
      #   unless group.nil? 
      #     @selected_groups.push group
      #   end
      # end
    end
    @selected_groups
  end

  def groups_list(selected_entity)
    if selected_entity.blank?
      groups = Group.index(params[:group_search], group_sort_column, group_sort_direction, params[:groups_page], 10, [], [])
    else
      groups = Group.index(params[:group_search], group_sort_column, group_sort_direction, params[:groups_page], 10, selected_entity.groups, [])
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

  def group_params
    params.require(:group).permit(:name, :default_label)
  end

  def group_sort_column
    Group.column_names.include?(params[:group_sort]) ? params[:group_sort] : "created_at"
  end
    
  def group_sort_direction
    %w[asc desc].include?(params[:group_direction]) ? params[:group_direction] : "desc"
  end

end