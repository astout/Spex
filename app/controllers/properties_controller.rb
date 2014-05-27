class PropertiesController < ApplicationController
  before_action do
    redirect_to root_url unless current_user.admin?
  end

  def index
    @properties = Property.paginate(page: params[:page])
  end

  def show
    @property = Property.find(params[:id])
    @children = @property.children.paginate(page: params[:page])
    @child_relations = @property.child_relations.paginate(page: params[:page])
    @parents = @property.parents.paginate(page: params[:page])
    @parent_relations = PropertyAssociation.where(child_id: @property.id).paginate(page: params[:page])
  end

  def own
    @child = Property.find(params[:id])
    current_property.own!(@child)
  end

  def new
    @property = Property.new
  end

  def create
    @property = Property.new(property_params)
    if @property.save
      flash[:success] = "Property Created."
      redirect_to @property
    else
      render 'new'
    end
  end

  def edit
    @property = Property.find(params[:id])
    @properties = Property.paginate(page: params[:page])
  end

  def update
    @property = Property.find(params[:id])
    if @property.update_attributes(property_params)
      flash[:success] = "Property updated"
      redirect_to @property
    else
      render 'edit'
    end
  end

  def destroy
    @property = Property.find(params[:id])
    @property.destroy
    flash[:success] = "Property deleted."
    redirect_to properties_url
  end

  private

    def property_params
      params.require(:property).permit(:name, :units, :units_short, :default_label,
                                   :default_value)
    end

end
