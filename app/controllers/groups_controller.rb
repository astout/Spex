class GroupsController < ApplicationController
  helper_method :group_sort_column, :group_sort_direction

  def index
    @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page])
    # @groups = Group.paginate(page: params[:groups_page], order: 'created_at DESC')
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.find_by(name: group_params[:name])
    @result = {msg: "", r: -1}
    @groups = Group.paginate(page: params[:groups_page], per_page: 10, order: 'created_at DESC')

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
          @groups = Group.paginate(page: params[:groups_page], per_page: 10, order: 'created_at DESC')
        end
      else
        @result[:r] = 0
        @result[:msg] = "Name: '#{@group.name}' is already taken."
      end
      format.js
      format.html { redirect_to groups_path }
    end
  end

  def edit
  end

  def show
  end

  def destroy
    respond_to do |format|
      format.js { 
        redirect_to "/hub/delete_group?id=#{params[:id]}"
      }
      format.html { 
        @group = Group.find(params[:id])
        result = @group.destroy
        if result
          flash[:success] = "'" + @group.name + "' deleted"
        else
          flash[:danger] = "Unable to delete '" + @group.name + "'"
        end
        redirect_to groups_url 
      }
    end
  end

  private

    def group_params
      params.require(:group).permit(:name, :default_label)
    end

    def group_sort_column
      Group.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
      
    def group_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
