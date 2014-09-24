class EntityPropertyRelationshipsController < ApplicationController
  include EntityPropertyRelationsHelper
  before_action :admin_user,  only: [:new, :create]
     # redirect_to root_url unless current_user.admin?
  # end

  def index
    @entities_all = Entity.search(params[:q])
    @groups_all = Group.search(params[:q])
    @properties_all = Property.search(params[:q])

    @all = @entities_all + @groups_all + @properties_all

    respond_to do |format|
      format.html
      format.json { render json: @all.map { |a| a.attributes.merge 'class' => a.class.name } }
    end
  end

  def query
    if signed_in?
      @eprs = eprs_index

      @role = Role.find_by(id: params[:view_id] || current_user.role_id)
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    # require_admin
    @epr = EntityPropertyRelationship.new
  end

  def create
    # require_admin
    match_params = {entity_id: epr_params[:entity_id], group_id: epr_params[:group_id], property_id: epr_params[:property_id]}
    @epr = EntityPropertyRelationship.find_by(match_params)
    @result = {msg: "", r: -1}
    # @eprs = EntityPropertyRelationship.search(params[:epr_search]).order(epr_sort_column + ' ' + epr_sort_direction).paginate(page: params[:eprs_page], per_page: 10, order: 'created_at DESC')

    if @epr.nil?
      @epr = EntityPropertyRelationship.new(epr_params)
      if !@epr.save
        @result[:r] = 0
        @result[:msg] = "'#{@epr.entity.name @epr.property.name}' failed to save."
      else
        @result[:r] = 1
        @result[:msg] = "'#{@epr.entity.name @epr.property.name}' was saved."
        #entities needs to be updated to get the latest addition
        # @eprs = EntityPropertyRelationship.search(params[:epr_search]).order(epr_sort_column + ' ' + epr_sort_direction).paginate(page: params[:eprs_page], per_page: 10, order: 'created_at DESC')
      end
    else
      @result[:r] = 0
      @result[:msg] = "Name: '#{@epr.entity.name @epr.property.name}' is already declared."
    end

    respond_to do |format|
      format.js
      format.html {redirect_to entity_property_relationships_path }
    end
  end

end