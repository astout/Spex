class HubController < ApplicationController
  include EntityGroupRelationsHelper
  include EntityPropertyRelationsHelper
  include GroupPropertyRelationsHelper
  include HubHelper
  include EntitiesHelper
  include GroupsHelper
  include PropertiesHelper
  helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction, :egr_sort_column, :egr_sort_direction, :property_sort_column, :property_sort_direction

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

    @entities_all = Entity.all.to_json
    @groups_all = Group.all.to_json
    @properties_all = Property.all.to_json

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
  def delete_egrs

    @deleted_egrs = egr_delete(selected_egrs)

    @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relationships to top
  def top_egrs
    @moved_egrs = egr_top(selected_egrs)

    #response for entity group relations
    @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_egrs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations to bottom
  def bottom_egrs
    @moved_egrs = egr_bottom(selected_entity, selected_egrs)

    #response for entity group relations
    @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_egrs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations up one
  def up_egrs
    @moved_egrs = egr_up(selected_egrs)

    #response for entity group relations
    @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_egrs' }
      format.html { redirect_to hub_path }
    end
  end

  #request to move selected entity group relations down one
  def down_egrs
    @moved_egrs = egr_down(selected_egrs)

    #response for entity group relations
    @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js { render 'move_egrs' }
      format.html { redirect_to hub_path }
    end
  end

  #Gets the group_property_relationships for the selected groups
  def gprs
    #get the group property relationships list
    # groups_property_relations
    @gprs = get_gprs(selected_groups)

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

    @gprs = get_gprs(selected_groups)

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
    @gprs = { status: 1, msg: "", data: gpr_list(selected_groups) }

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
    @gprs = { status: 1, msg: "", data: gpr_list(selected_groups) }

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
    @gprs = { status: 1, msg: "", data: gpr_list(selected_groups) }

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
    @gprs = { status: 1, msg: "", data: gpr_list(selected_groups) }

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
    @moved_eprs = epr_bottom(selected_egrs, selected_eprs)

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
    @moved_eprs = epr_down(selected_eprs)

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
    @epr = epr_update(epr_update_params)

    unless @epr.blank?
      unless @epr[:data].blank?
        egr = @epr[:data].egr
        puts " -- GETTING EGRS -- "
        puts egr
        @eprs = { status: 1, msg: "", data: epr_list(selected_egrs([egr.id])) }
        puts " -- SELECTED EGRS -- "
        puts @selected_egrs
      end
    end

    puts " -- FINAL EPR -- "
    puts @epr

    respond_to do |format|
      format.js
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
      format.js { render 'gprs' }
      format.html { redirect_to hub_path }
    end
  end

  #request list of entity group relationships
  def egrs
    @egrs = get_egrs(selected_entity)

    #update appropriate lists
    selected_groups
    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js #{ render 'main' }
      format.html { redirect_to hub_path }
    end
  end

  #request to add selected groups to selected entity
  def create_egrs
    @created_relations = egr_create(selected_entity, selected_groups)

    #response structure
    @egrs = get_egrs(selected_entity)
    # @egrs = { status: 1, msg: "", data: egr_list(selected_entity) }

    @groups = groups_list(selected_entity)

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #request to add selected properties to selected group
  def create_gprs
    @added_properties = gprs_create(selected_groups, selected_properties)

    #update list of group property relations
    @gprs = { status: 1, msg: "", data: gpr_list(selected_groups) }
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

end