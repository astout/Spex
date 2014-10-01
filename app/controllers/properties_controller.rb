class PropertiesController < ApplicationController
  include PropertiesHelper
  include ApplicationHelper
  before_action do
    redirect_to root_url unless admin_user?
  end

  def index
    @properties = properties_list(nil, nil)
    # @properties = Property.search(params[:property_search]).order(property_sort_column + ' ' + property_sort_direction).paginate(page: params[:properties_page])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @property = Property.find(params[:id])
    # @children = @property.children.paginate(page: params[:page])
    # @child_relations = @property.child_relations.paginate(page: params[:page])
    # @parents = @property.parents.paginate(page: params[:page])
    # @parent_relations = PropertyAssociation.where(child_id: @property.id).paginate(page: params[:page])
  end

  def own
    @child = Property.find(params[:id])
    current_property.own!(@child)
  end

  def new
    @property = Property.new
  end

  # def create
  #   # @property = Property.new(property_params)

  #   p = Property.find_by name: property_params[:name]
  #   if p.blank?
  #     @property = property_create(property_params)
  #     # if @property.save
  #     success = @property[:status] == 1 ? true : false
  #     @property = @property[:data]
  #     puts @property.attributes
  #     if success
  #       flash[:success] = "Property Created."
  #       redirect_to properties_path
  #     else
  #       render 'new'
  #     end
  #   else
  #     @property = p
  #     flash[:info] = "A property with that name already exists"
  #     render 'show'
  #   end
  # end

  def create
    @property = Property.new property_params
    if @property.save
      flash[:success] = "Property created"
      redirect_to properties_path
    else
      flash[:danger] = "The property couldn't be created"
      render 'new'
    end
  end

  def edit
    @property = Property.find(params[:id])
    # @properties = Property.paginate(page: params[:page])
  end

  # def update
  #   @property = Property.find(params[:id])
  #   if @property.blank?
  #     flash[:danger] = "Property not found"
  #     render 'edit'
  #     return
  #   end
  #   params[:property][:role_ids] = params[:role_ids]
  #   if @property.update_attributes(property_params)
  #     flash[:success] = "Property updated"
  #     redirect_to @property
  #   else
  #     render 'edit'
  #   end
  # end

  def update
    @property = Property.find(params[:id])
    if @property.update_attributes(property_params)
      flash[:success] = "'" + @property.name + "' updated"
      redirect_to @property
    else
      flash[:danger] = "The property couldn't be updated"
      render 'edit'
    end
  end

  def delete_request
    @property = Property.find_by(id: params[:id])
    respond_to do |format|
      format.js 
    end
  end

  def confirm_delete
    property = Property.find(params[:id])
    msg = ""
    type = "info"
    if property.blank?
      msg = "The property couldn't be found."
      type = "danger"
    elsif property.destroy
      msg = "#{property.name} successfully removed."
      type = "success"
    else
      msg = "There was an error destroying the specified property."
      type = "danger"
    end
    @property = {notification: notification(type, msg, []), data: property}
    @properties = properties_list(nil, nil)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    @property = Property.find(params[:id])
    result = @property.destroy
    if result[:status] == 0
      flash[:danger] = result[:msg]
    else
      flash[:success] = result[:msg]
    end
    redirect_to properties_url
  end

  

  private

    # def property_params
    #   params.require(:property).permit(:name, :units, :units_short, :default_label,
    #                                :default_value, :role)
    # end

end
