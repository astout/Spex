class EntitiesController < ApplicationController
  # helper_method :entity_sort_column, :entity_sort_direction, :group_sort_column, :group_sort_direction
  helper_method :egr_sort_column, :egr_sort_direction

  before_action do
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end
 

  def index
    # @entities = Entity.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(page: params[:entities_page])
    @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page])
  end

  def new
    @entity = Entity.new
  end

  def create
    @entity = Entity.find_by(name: entity_params[:name])
    @result = {msg: "", r: -1}
    @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10, order: 'created_at DESC')

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
          @entities = Entity.search(params[:entity_search]).order(entity_sort_column + ' ' + entity_sort_direction).paginate(page: params[:entities_page], per_page: 10, order: 'created_at DESC')
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@entity.name}' is already taken."
      end
      format.js
      format.html { redirect_to hub_path }
    end


    # @entity = Entity.new(entity_params)
    # @result = {msg: "", r: -1}

    # respond_to do |format|
    #   if !@entity.save
    #     @result[:r] = 0
    #     @result[:msg] = "'#{@entity.name}' failed to save."
    #   else
    #     @result[:r] = 1
    #     @result[:msg] = "'#{@entity.name}' was saved."
    #   end
    #   format.js
    # end
    # if @entity.save
    #   flash[:success] = "'" + @entity.name + "' created."
    #   redirect_to @entity
    # else
    #   render 'new'
    # end
  end

  def edit
    @back ||= request.referer
    @entity = Entity.find(params[:id])
    @relationships = EntityPropertyRelationship.where(entity_id: @entity.id).paginate(page: params[:page])
    @all_properties = Property.paginate(page: params[:page])
  end

  def show
    @entity = Entity.find(params[:id])
    @properties = @entity.properties.paginate(page: params[:page])
    @relationships = EntityPropertyRelationship.where(entity_id: @entity.id).paginate(page: params[:page])
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
        @egrs = @fetched_entity.group_relations.paginate(page: params[:egrs_page], per_page: 10, order: 'order ASC')
      end
      format.js
      format.html { redirect_to hub_path }
    end
  end

  private

    def entity_params
      params.require(:entity).permit(:name, :label, :img)
    end

    def egr_sort_column
      EntityGroupRelationship.column_names.include?(params[:egr_sort]) || Group.column_names.include?(params[:egr_sort]) ? params[:egr_sort] : "order"
    end

    def egr_sort_direction
      %w[asc desc].include?(params[:egr_direction]) ? params[:egr_direction] : "desc"
    end

end
