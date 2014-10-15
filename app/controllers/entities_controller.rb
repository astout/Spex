class EntitiesController < ApplicationController
  include EntitiesHelper
  include UsersHelper
  include ApplicationHelper
  # helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction
  helper_method :egr_sort_column, :egr_sort_direction

  def index
    @entities = entities_list

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    require_admin
    @entity = Entity.new
  end

  def create
    @entity = Entity.new entity_params
    if @entity.save
      flash[:success] = "Entity created"
      redirect_to entities_path
    else
      flash[:danger] = "The entity couldn't be created"
      render 'new'
    end
  end

  # def create
  #   # @property = Property.new(property_params)

  #   e = Entity.find_by name: entity_params[:name]
  #   if e.blank?
  #     @entity = entity_create(entity_params)
  #     # if @property.save
  #     success = @entity[:status] == 1 ? true : false
  #     @entity = @entity[:data]
  #     @entities = entities_list()
  #     puts @entity.attributes
  #     if success
  #       flash[:success] = "Entity Created."
  #       redirect_to entities_path
  #     else
  #       render 'new'
  #     end
  #   else
  #     @entity = e
  #     flash[:info] = "An entity with that name already exists"
  #     pre_show(e)
  #     render 'show'
  #   end
  # end

  # def create
  #   require_admin
  #   @entity = Entity.find_by(name: entity_params[:name])
  #   @result = {msg: "", r: -1}

  #   r = -1
  #   msg = ""
  #   entity = Entity.find_by name: entity_params[:name]

  #   if entity.blank?

  #   else
  #     r = 0
  #   end
  #   respond_to do |format|
  #     if @entity.nil?
  #       @entity = Entity.new(entity_params)
  #       if !@entity.save
  #         @result[:r] = 0
  #         @result[:msg] = "'#{@entity.name}' failed to save."
  #       else
  #         @result[:r] = 1
  #         @result[:msg] = "'#{@entity.name}' was saved."
  #         #entities needs to be updated to get the latest addition
  #         @entities = entities_list
  #       end
  #     else
  #       @result[:r] = 0
  #       @result[:msg] = "Name: '#{@entity.name}' is already taken."
  #     end
  #     format.js
  #     format.html {redirect_to entities_path }
  #   end
  # end

  def edit
    require_admin
    @back ||= request.referer
    @entity = Entity.find(params[:id])
  end

  def pre_show(e=nil)
    if e.blank?
      @entity = Entity.find_by(id: params[:id])
    end
    @role = Role.find_by(id: params[:view_id] || current_user.role_id).attributes

    unless @entity.blank?
      @groups_all = @entity.groups
      @properties_all = @entity.properties_via(@entity.groups.first)
    end
    @updated_property = params[:property]
  end

  def show
    # if @entity.blank?
    #   @entity = Entity.find_by(id: params[:id])
    # end
    # @role = Role.find_by(id: params[:view_id] || current_user.role_id).attributes

    # @groups_all = @entity.groups
    # @properties_all = @entity.properties_via(@entity.groups.first)
    # @updated_property = params[:property]
    pre_show(nil)
    # @view = { id: nil, name: nil }
    # role = Role.find_by(id: params[:view_id] || current_user.role_id)
    # unless role.blank?
    #   @view[:id] = role.id
    #   @view[:name] = role.name
    # end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    require_admin
    @entity = Entity.find(params[:id])
    if @entity.update_attributes(entity_params)
      flash[:success] = "'" + @entity.name + "' updated"
      redirect_to @entity
    else
      flash[:danger] = "The entity couldn't be updated"
      render 'edit'
    end
  end

  def delete_request
    @entity = Entity.find_by(id: params[:id])
    respond_to do |format|
      format.js 
    end
  end

  # def confirm_delete
  #   @entity = Entity.find_by(id: params[:id])
  #   if @entity.blank?
  #     flash[:danger] = "The specified relationship couldn't be found."
  #   elsif @entity.destroy
  #     flash[:success] = "The entity '#{@entity.name}' was successfully destroyed."
  #   else
  #     flash[:danger] = "There was an error destroying the specified entity."
  #   end
  #   respond_to do |format|
  #     format.js { render :js => "window.location.href='"+entities_path+"'" }
  #   end
  # end

  def confirm_delete
    entity = Entity.find(params[:id])
    msg = ""
    type = "info"
    if entity.blank?
      msg = "The entity couldn't be found."
      type = "danger"
    elsif entity.destroy
      msg = "#{entity.name} successfully removed."
      type = "success"
    else
      msg = "There was an error destroying the specified entity."
      type = "danger"
    end
    @entity = {notification: notification(type, msg, []), data: entity}
    puts @entity
    @entities = entities_list
    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    require_admin
    respond_to do |format|
      format.js { 
        redirect_to "/hub/delete_entity?id=#{params[:id]}"
      }
      format.html { 
        @entity = Entity.find(params[:id])
        result = @entity.destroy
        if result
          flash[:success] = "'" + @entity.name + "' deleted"
        else
          flash[:danger] = "Unable to delete '" + @entity.name + "'"
        end
        redirect_to entities_url 
      }
    end
  end

  def groups
    require_admin
    @fetched_entity = Entity.find(params[:id])
    @result = {msg: "", r: -1}
    @egrs = []

    respond_to do |format|
      if @fetched_entity.nil?
        @result[:r] = 0
        @result[:msg] = "The fetched entity couldn't be found."
      else
        @result[:r] = 1
        @result[:msg] = ""
        @egrs = @fetched_entity.group_relations.paginate(page: params[:egrs_page], per_page: 10, order: 'position ASC')
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  def print_request
    puts params
    @entity = Entity.find_by(id: params[:id])
    @role = Role.find_by(id: params[:id])
    @role = Role.default if @role.blank?

    respond_to do |format|
      format.js { redirect_to print }
    end
  end

  def print
    @entity = Entity.find_by(id: params[:e])
    @role = Role.find_by(id: params[:v])
    # @role = Role.default if @role.blank?
    @role = Role.default if (!signed_in? || @role.blank?)

    if signed_in?
      if !@current_user.role.change_view?
        @role = Role.default
      end
    end

    @label = ''
    unless @entity.label.blank?
      @label = @entity.label.dup
    else
      unless @entity.name.blank?
        @label = @entity.name.dup.capitalize
      else
        @label = "Entity id: #{@entity.id.to_s}"
      end
    end

    puts @entity
    puts @label
    render layout: false
    puts params
  end

  private

    # def entity_params
    #   params.require(:entity).permit(:name, :label, :img)
    # end

    # def egr_sort_column
    #   EntityGroupRelationship.column_names.include?(params[:egr_sort]) || Group.column_names.include?(params[:egr_sort]) ? params[:egr_sort] : "position"
    # end

    # def egr_sort_direction
    #   %w[asc desc].include?(params[:egr_direction]) ? params[:egr_direction] : "desc"
    # end

end
