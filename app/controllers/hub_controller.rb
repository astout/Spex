class HubController < ApplicationController
  helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction, :entitys_group_sort_column, :entitys_group_sort_direction

  before_action do
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end

  def main
    @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10)
    @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page], per_page: 10)
    @entity = Entity.new
    @group = Group.new
  end

  def create_entity
    @entity = Entity.find_by(name: entity_params[:name])
    @result = {msg: "", r: -1}
    @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10)

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
          @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10)
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@entity.name}' is already taken."
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def create_group
    @group = Group.find_by(name: group_params[:name])
    @result = {msg: "", r: -1}
    @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page], per_page: 10)

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
          @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page], per_page: 10)
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@group.name}' is already taken."
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def entitys_groups
    @fetched_entity = Entity.find_by(id: params[:entity_id])
    @result = {msg: "", r: -1}
    @entitys_group_relations = []

    respond_to do |format|
      if @fetched_entity.nil?
        @result[:r] = 0
        @result[:msg] = "The fetched entity couldn't be found."
      else
        @entitys_group_relations = @fetched_entity.group_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
        if @entitys_group_relations.empty?
          @result[:r] = 2
          @result[:msg] = "No groups for '#{@fetched_entity.name}'"
        else
          @result[:r] = 1
          @result[:msg] = ""
        end
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def create_property
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
