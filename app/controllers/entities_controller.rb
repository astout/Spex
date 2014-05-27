class EntitiesController < ApplicationController
  before_action do
    redirect_to root_url unless current_user.admin?
  end

  def index
    @entities = Entity.paginate(page: params[:page])
  end

  def new
    @entity = Entity.new
  end

  def create
    @entity = Entity.new(entity_params)
    if @entity.save
      flash[:success] = "'" + @entity.name + "' created."
      redirect_to @entity
    else
      render 'new'
    end
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def show
    @entity = Entity.find(params[:id])
    @properties = @entity.properties.paginate(page: params[:page])
    @relationships = EntityPropertyRelationship.where(entity_id: @entity.id).paginate(page: params[:page])
    @all_properties = Property.paginate(page: params[:page])
  end

  def employ
    @property = Property.find(params[:id])
    current_entity.employ!(@property)
  end

  def update
    @entity = Entity.find(params[:id])
    if @entity.update_attributes(entity_params)
      flash[:success] = "'" + @entity.name + "' updated"
      redirect_to @entity
    else
      render 'edit'
    end
  end

  def destroy
    @entity = Entity.find(params[:id])
    @entity.destroy
    flash[:success] = "'" + @entity.name + "' deleted"
    redirect_to entities_url
  end

  private

    def entity_params
      params.require(:entity).permit(:name, :label, :img)
    end

end
