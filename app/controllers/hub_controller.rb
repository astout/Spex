class HubController < ApplicationController
  helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction, :entitys_group_sort_column, :entitys_group_sort_direction

  before_action do
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end

  def entities
    @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10)
  end

  def selected_entity
    @selected_entity = Entity.find_by(id: params[:selected_entity])
  end

  def selected_groups
    count = 0
    @selected_groups = []
    selected_group_ids = params[:selected_groups]
    unless selected_group_ids.nil?
      puts "THERE ARE SELECTED_GROUPS"
      selected_group_ids.each do |id|
        count += 1
        puts "QUERY: #{count}"
        _group = Group.find_by(id: id)
        unless _group.nil? 
          @selected_groups.push _group
        end
      end
    end
    @selected_groups
  end

  def groups
    self.selected_entity
    if @selected_entity.nil?
    @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page], per_page: 10)
    else
      #store the entity's groups to eliminate repeated queries
      reject_groups = @selected_entity.groups
      @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).reject { |group| reject_groups.any? { |e_group| e_group[:id] == group[:id] } }.paginate(page: params[:groups_page], per_page: 10)
    end
  end

  def main
    self.entities
    self.groups
    @entity = Entity.new
    @group = Group.new
  end

  def create_entity
    @entity = Entity.find_by(name: entity_params[:name])
    @result = {msg: "", r: -1}
    respond_to do |format|
      if @entity.nil?
        @entity = Entity.new(entity_params)
        if !@entity.save
          @result[:r] = 0
          @result[:msg] = "'#{@entity.name}' failed to save."
        else
          @result[:r] = 1
          @result[:msg] = "'#{@entity.name}' was saved."
          #entities needs to be updated to get the latest addition
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@entity.name}' is already taken."
      end
      self.entities
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def delete_entity
    @entity = Entity.find_by(id: params[:selected_entity])
    success = @entity ? @entity.destroy : false

    self.entities
    self.groups
    # self.selected_entity
    # self.selected_groups

    respond_to do |format|
      format.js {  
        @result = {msg: "", r: -1}
        @result[:r] = success ? 1 : 0
        @result[:msg] = success ? "'#{@entity.name}' deleted." : "Unable to delete '#{@entity.name}'."
      }
      format.html { redirect_to hub_path }
    end
  end

  def create_group
    @group = Group.find_by(name: group_params[:name])
    @result = {msg: "", r: -1}

    respond_to do |format|
      if @group.nil?
        @group = Group.new(group_params)
        if !@group.save
          @result[:r] = 0
          @result[:msg] = "'#{@group.name}' failed to save."
        else
          @result[:r] = 1
          @result[:msg] = "'#{@group.name}' was saved."
          #groups needs to be updated to get the latest addition
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@group.name}' is already taken."
      end
      self.groups
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the groups passed as :selected_groups param
  #:selected_groups is expeced to be an array
  def delete_groups
    #get the valid set of selected group ids
    self.selected_groups

    @results = []
    @selected_groups.each do |group|
      @results.push group ? { group: group.destroy, msg: "deleted" } : { group: nil, msg: "group was nil" }
    end

    self.entities
    self.groups

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def entitys_groups
    @result = {msg: "", r: -1}
    @entitys_group_relations = []
    self.selected_groups
    self.groups

    if @selected_entity.nil?
      @result[:r] = 0
      @result[:msg] = "The fetched entity couldn't be found."
    else
      @entitys_group_relations = @selected_entity.group_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
      if @entitys_group_relations.empty?
        @result[:r] = 2
        @result[:msg] = "No groups for '#{@selected_entity.name}'"
      else
        @result[:r] = 1
        @result[:msg] = ""
      end
    end
    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def entity_add_groups
    self.entities
    self.groups

    @result = {msg: "", r: -1}
    self.selected_entity
    @selected_groups = params[:selected_groups]
    matched_groups = []

    respond_to do |format|
      if @selected_entity.nil?
        @result[:r] = 0
        @result[:msg] = "The entity couldn't be found."
      elsif @selected_groups.empty?
        @result[:r] = 0
        @result[:msg] = "There are no groups to add."
      else
        @selected_groups.each do |group_id|
          group = Group.find_by(id: group_id)
          if group.nil?
            @result[:r] = 2
            @result[:msg] += "\nGroup id: '#{group_id}' couldn't be found."
          else
            matched_groups.push group
            @selected_entity.own! group
          end
        end
        @selected_groups = matched_groups
        @entitys_group_relations = @selected_entity.group_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
        if @result[:r] < 0
          @result[:r] = 1
          @result[:msg] = "The groups were added to '#{@selected_entity.name}'"
        end
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def create_property
    puts "CALLED THIS"
    #not yet implemented
  end

  def create_entity_group_relation
    #not yet implemented
  end

  def create_group_property_relation
    #not yet implemented
  end

  private

    def entity_params
      params.require(:entity).permit(:name, :label, :img)
    end

    def group_params
      params.require(:group).permit(:name, :default_label)
    end

    def entity_sort_column
      Entity.column_names.include?(params[:entity_sort]) ? params[:entity_sort] : "created_at"
    end
      
    def entity_sort_direction
      %w[asc desc].include?(params[:entity_direction]) ? params[:entity_direction] : "desc"
    end

    def group_sort_column
      Group.column_names.include?(params[:group_sort]) ? params[:group_sort] : "created_at"
    end
      
    def group_sort_direction
      %w[asc desc].include?(params[:group_direction]) ? params[:group_direction] : "desc"
    end

    def entitys_group_sort_column
      EntityGroupRelationship.column_names.include?(params[:entitys_group_sort]) || Group.column_names.include?(params[:entitys_group_sort]) ? params[:entitys_group_sort] : "order"
    end

    def entitys_group_sort_direction
      %w[asc desc].include?(params[:entitys_group_direction]) ? params[:entitys_group_direction] : "desc"
    end

end
