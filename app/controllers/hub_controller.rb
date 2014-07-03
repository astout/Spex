class HubController < ApplicationController
  helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction, :entitys_group_sort_column, :entitys_group_sort_direction, :property_sort_column, :property_sort_direction

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

  def selected_entity_group_relations
    @selected_entity_group_relations = []
    selected_relation_ids = params[:selected_entity_group_relations]
    unless selected_relation_ids.nil?
      selected_relation_ids.each do |id|
        relation = EntityGroupRelationship.find_by id: id
        unless relation.nil?
          @selected_entity_group_relations.push relation
        end
      end
    end
    @selected_entity_group_relations
  end

  def entitys_group_relations
    @entitys_group_relations = @selected_entity.group_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
  end

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

  def selected_properties
    @selected_properties = []
    selected_property_ids = params[:selected_properties]
    unless selected_property_ids.nil?
      selected_property_ids.each do |id|
        property = Property.find_by(id: id)
        unless property.nil? 
          @selected_properties.push property
        end
      end
    end
    @selected_properties
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

  def properties
    self.selected_entity_group_relations
    self.selected_groups
    reject_properties = []
    if @selected_groups.blank?
      #store the entity's groups to eliminate repeated queries
      @selected_groups.each do |group|
        reject_properties |= group.properties
      end
    elsif @selected_entity_group_relations.blank?
      @selected_entity_group_relations.each do |relation|
        reject_properties |= relation.group.properties
      end
    end
    @properties = Property.search(params[:property_search]).order(property_sort_column + ' ' + property_sort_direction).reject { |property| reject_properties.any? { |g_property| g_property[:id] == property[:id] } }.paginate(page: params[:properties_page], per_page: 10)
  end

  def main
    self.entities
    self.groups
    self.properties
    @entity = Entity.new
    @group = Group.new
    @property = Property.new

    respond_to do |format|
      format.js
      format.html
    end
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
    @result = {msg: "", r: -1}
    @result[:r] = success ? 1 : 0
    @result[:msg] = success ? "'#{@entity.name}' deleted." : "Unable to delete '#{@entity.name}'."

    respond_to do |format|
      format.js
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

  #deletes the groups passed as :selected_groups param
  #:selected_groups is expeced to be an array
  def delete_entity_group_relations
    #get the valid set of selected group ids
    self.selected_entity_group_relations

    @results = []
    @selected_entity_group_relations.each do |relation|
      success = relation.group.flee! relation.entity
      @results.push success ? { relation: relation, msg: "deleted" } : { relation: relation, msg: "not deleted" }
    end

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #top entity group relations
  def top_entity_group_relations
    #get the valid set of selected group relation ids
    self.selected_entity_group_relations
    count = @selected_entity_group_relations.count + 1

    @results = []
    @selected_entity_group_relations.reverse.each do |relation|
      success = relation.entity.first! relation.group
      @results.push success ? { relation: relation, msg: "moved to top", idx: count -= 1 } : { relation: relation, msg: "not moved", idx: count -= 1 }
    end

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #top entity group relations
  def bottom_entity_group_relations
    #get the valid set of selected group relation ids
    self.selected_entity_group_relations
    _index = @selected_entity_group_relations.first.entity.groups.count - @selected_entity_group_relations.count

    @results = []
    relations = @selected_entity_group_relations.sort_by { |r| r[:order] }
    relations.to_enum.with_index(0).each do |relation, i|
      success = relation.entity.last! relation.group
      @results.push success ? { relation: relation, msg: "moved to bottom", idx: _index += 1 } : { relation: relation, msg: "not moved", idx: _index += 1 }
    end

    @results.reverse!

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js { render 'top_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #up entity group relations
  def up_entity_group_relations
    #get the valid set of selected group relation ids
    self.selected_entity_group_relations

    @results = []
    relations = @selected_entity_group_relations.sort_by { |r| r[:order] }
    relations.to_enum.with_index(0).each do |relation, i|
      if relation.order == i
        @results.push({ relation: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.entity.up! relation.group
        @results.push success ? { relation: relation, msg: "moved", idx: relation.order } : { relation: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end

    @results.reverse!

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js { render 'top_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #down entity group relations
  def down_entity_group_relations
    #get the valid set of selected group relation ids
    self.selected_entity_group_relations

    @results = []
    relations = @selected_entity_group_relations.sort_by { |r| r[:order] }
    relations.reverse.to_enum.with_index(0).each do |relation, i|
      puts "Relation"
      puts "#{relation.group.name}"
      puts "Order"
      puts "#{relation.order}"
      puts "Index"
      puts i
      if relation.order == relation.entity.groups.count - 1 - i 
        @results.push({ relation: relation, msg: "not moved", idx: i+1 })
      else
        success = relation.entity.down! relation.group
        @results.push success ? { relation: relation, msg: "moved", idx: relation.order + 2 } : { relation: relation, msg: "not moved", idx: relation.order + 1 }
      end
    end

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js { render 'top_entity_group_relations' }
      format.html { redirect_to hub_path }
    end
  end

  #Gets the group_property_relationships for the selected groups
  def groups_properties
    @result = { msg: "", r: -1 }
    @groups_property_relations = []
    self.selected_groups
    self.properties

    #assume nothing's selected
    if @selected_groups.blank?
      @result[:r] = 2
      @result[:msg] = "No groups selected."
    else
      @selected_groups.each do |group|
        @groups_property_relations |= group.property_relations
      end
      if @groups_property_relations.blank?
        @result[:r] = 2
        @result[:msg] = "No properties for '#{@selected_groups.first.name}'"
      else
        @groups_property_relations = @groups_property_relations.paginate(page: params[:entitys_groups_page], per_page: 10, order: 'order ASC')
        @result[:r] = 1
        @result[:msg] = ""
      end
    end
    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def entitys_groups
    @result = { msg: "", r: -1 }
    @entitys_group_relations = []
    self.selected_groups
    self.groups
    @fetched_entitys_groups = true

    #assume nothing's selected
    if @selected_entity.nil?
      @result[:r] = 1
      @result[:msg] = ""
    else
      self.entitys_group_relations
      if @entitys_group_relations.empty?
        @result[:r] = 2
        @result[:msg] = "No groups for '#{@selected_entity.name}'"
      else
        @result[:r] = 1
        @result[:msg] = ""
      end
    end
    respond_to do |format|
      format.js #{ render 'main' }
      format.html { redirect_to hub_path }
    end
  end

  def entity_add_groups
    self.selected_entity
    self.selected_groups

    @results = []
    unless @selected_entity.nil?
      @selected_groups.each do |group|
        @results.push group ? { relation: @selected_entity.own!(group), group: group, msg: "added to #{@selected_entity.name}" } : { relation: "", group: "", msg: "group was nil" }
      end
    else
      @results.push({ relation: "", group: "", msg: "entity was nil" })
    end

    self.entities
    self.groups
    self.entitys_group_relations

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def group_add_properties
    self.selected_groups
    self.selected_properties

    @results = []
    #there should only be one group selected, this is enforced client-side
    unless @selected_groups.blank?
      group = @selected_groups.first
      unless group.nil?
        @selected_properties.each do |property|
          @results.push property ? { relation: group.own!(property), property: property, msg: "added to #{group.name}" } : { relation: "", property: "", msg: "property was nil" }
        end
      end
    else
      @results.push({ relation: "", group: "", msg: "group was nil" })
    end

    self.groups
    self.properties

    respond_to do |format|
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def create_property
    @property = Property.find_by(name: property_params[:name])
    @result = {msg: "", r: -1}

    respond_to do |format|
      if @property.nil?
        @property = Property.new(property_params)
        if !@property.save
          @result[:r] = 0
          @result[:msg] = "'#{@property.name}' failed to save."
        else
          @result[:r] = 1
          @result[:msg] = "'#{@property.name}' was saved."
          #groups needs to be updated to get the latest addition
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@property.name}' is already taken."
      end
      self.properties
      format.js
      format.html { redirect_to hub_path }
    end
  end

  #deletes the properties passed as :selected_properties param
  #:selected_properties is expected to be an array
  def delete_properties
    #get the valid set of selected property ids
    self.selected_properties

    @results = []
    @selected_properties.each do |property|
      @results.push property ? { property: property.destroy, msg: "deleted" } : { property: nil, msg: "property was nil" }
    end

    self.entities
    self.groups
    self.properties

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
