class HubController < ApplicationController
  include EntityGroupRelationsHelper
  include EntityPropertyRelationsHelper
  include GroupPropertyRelationsHelper
  include HubHelper
  include EntitiesHelper
  include GroupsHelper
  include PropertiesHelper
  helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction, :entitys_group_sort_column, :entitys_group_sort_direction, :property_sort_column, :property_sort_direction

  #users of the hub must be admin
  before_action do
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end

  #controller request for main
  def main
    #get entities list
    @entities = entities_list

    #get groups list
    @groups = groups_list(selected_entity)
    
    #get properties list
    @properties = properties_list(selected_egrs, selected_groups)

    #instantiate each type
    @entity = Entity.new
    @group = Group.new
    @property = Property.new

    #respond to js and html
    respond_to do |format|
      format.js
      format.html
    end
  end

  #request to create entity
  def create_entity
    #call entities_helper to create entity
    @entity = entity_create(entity_params)

    #update the entities list
    @entities = entities_list

    #respond to js and HTML
    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to delete entity
  def delete_entity
    #call the helper method
    @entity = entity_delete(params[:selected_entity])

    #update the list of entities
    @entities = entities_list

    #respond to js and html
    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to create a group
  def create_group
    @group = group_create(group_params)

    #update list of groups
    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the groups passed as :selected_groups param
  #:selected_groups is expeced to be an array
  def delete_groups
    @deleted_groups = groups_delete(selected_groups)

    #update the groups list
    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the groups passed as :selected_groups param
  #:selected_groups is expeced to be an array
  def delete_entity_group_relations

    @deleted_entity_group_relations = egr_delete(selected_egrs)

    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relationships to top
  def top_entity_group_relations
    @moved_egrs = egr_top(selected_egrs)

    #response for entity group relations
    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations to bottom
  def bottom_entity_group_relations
    @moved_egrs = egr_bottom(selected_entity, selected_egrs)

    #response for entity group relations
    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations up one
  def up_entity_group_relations
    @moved_egrs = egr_up(selected_egrs)

    #response for entity group relations
    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations down one
  def down_entity_group_relations
    @moved_egrs = egr_down(selected_egrs)

    #response for entity group relations
    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #Gets the group_property_relationships for the selected groups
  def groups_properties
    #get the group property relationships list
    # groups_property_relations
    @groups_property_relations = get_gprs(selected_groups)

    #update the properties list
    @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the groups passed as :selected_groups param
  #:selected_groups is expeced to be an array
  def delete_gprs

    @deleted_gprs = gpr_delete(selected_gprs)

    @groups_property_relations = get_gprs(selected_groups)

    @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relationships to top
  def top_gprs
    @moved_gprs = gpr_top(selected_gprs)

    #response for entity group relations
    @groups_property_relations = { status: 1, msg: "", data: gpr_list(selected_groups) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_gprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations to bottom
  def bottom_gprs
    @moved_gprs = gpr_bottom(selected_groups, selected_gprs)

    #response for entity group relations
    @groups_property_relations = { status: 1, msg: "", data: gpr_list(selected_groups) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_gprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations up one
  def up_gprs
    @moved_gprs = gpr_up(selected_gprs)

    #response for entity group relations
    @groups_property_relations = { status: 1, msg: "", data: gpr_list(selected_groups) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_gprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations down one
  def down_gprs
    @moved_gprs = gpr_down(selected_gprs)

    #response for entity group relations
    @groups_property_relations = { status: 1, msg: "", data: gpr_list(selected_groups) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_gprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relationships to top
  def top_eprs
    @moved_eprs = epr_top(selected_eprs)

    #response for entity group relations
    @eprs = { status: 1, msg: "", data: epr_list(selected_egrs) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_eprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations to bottom
  def bottom_eprs
    @moved_eprs = epr_bottom(selected_groups, selected_eprs)

    #response for entity group relations
    @eprs = { status: 1, msg: "", data: epr_list(selected_egrs) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_eprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations up one
  def up_eprs
    @moved_eprs = epr_up(selected_eprs)

    #response for entity group relations
    @eprs = { status: 1, msg: "", data: epr_list(selected_egrs) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_eprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations down one
  def down_eprs
    @moved_eprs = gpr_down(selected_eprs)

    #response for entity group relations
    @eprs = { status: 1, msg: "", data: epr_list(selected_egrs) }

    # @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'move_eprs' }
      format.html { redirect_to hub_path }
    end
  end

  #update entity property relationship with submitted params
  def update_epr
    puts "got here"

    respond_to do |format|
      format.js { render 'main' }
      format.html { redirect_to hub_path }
    end
  end

  #request list of entity group relationships
  def eprs
    @eprs = get_eprs(selected_egrs)

    #update appropriate lists
    selected_properties
    @properties = properties_list(@selected_egrs, selected_groups)

    respond_to do |format|
      format.js { render 'groups_properties' }
      format.html { redirect_to hub_path }
    end
  end

  #request list of entity group relationships
  def entitys_groups
    @entitys_group_relations = get_egrs(selected_entity)

    #update appropriate lists
    selected_groups
    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js #{ render 'main' }
      format.html { redirect_to hub_path }
    end
  end

  #request to add selected groups to selected entity
  def entity_add_groups
    @created_relations = create_egrs(selected_entity, selected_groups)

    #response structure
    @entitys_group_relations = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to add selected properties to selected group
  def group_add_properties
    @added_properties = create_gprs(selected_groups, selected_properties)

    #update list of group property relations
    @groups_property_relations = { status: 1, msg: "", data: gpr_list(selected_groups) }
    # groups_property_relations #HubHelper

    #update list of properties
    @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to create property
  def create_property
    #call properties_helper to create property
    @property = property_create(property_params)

    #update the properties list
    @properties = properties_list(selected_egrs, selected_groups)

    #respond to js and HTML
    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the properties passed as :selected_properties param
  #:selected_properties is expected to be an array
  def delete_properties
    @deleted_properties = properties_delete(selected_properties)

    #update the properties list
    @properties = properties_list(selected_egrs, selected_groups)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  private

    def entity_params
      params.require(:entity).permit(:name, :label, :img)
    end

    def group_params
      params.require(:group).permit(:name, :default_label)
    end

    def property_params
      params.require(:property).permit(:name, :units, :units_short, :default_label, :default_value)
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

    def property_sort_column
      Property.column_names.include?(params[:property_sort]) ? params[:property_sort] : "created_at"
    end

    def property_sort_direction
      %w[asc desc].include?(params[:property_direction]) ? params[:property_direction] : "desc"
    end
end
