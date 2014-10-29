class GroupsController < ApplicationController
  include GroupsHelper
  include ApplicationHelper
  helper_method :group_sort_column, :group_sort_direction
  before_action do
    redirect_to root_path unless admin_user?
  end

  def index
    puts "groups controller: index"
    @groups = groups_list(nil)

    respond_to do |format|
      format.js
      format.html
    end
    # @groups = Group.search(params[:group_search]).order(group_sort_column + ' ' + group_sort_direction).paginate(page: params[:groups_page])
    # @groups = Group.paginate(page: params[:groups_page], order: 'created_at DESC')
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new group_params
    if @group.save
      flash[:success] = "Group created"
      redirect_to groups_path
    else
      flash[:danger] = "The group couldn't be created"
      render 'new'
    end
  end

  # def create
  #   @group = Group.find_by(name: group_params[:name])
  #   @result = {msg: "", r: -1}
  #   @groups = Group.paginate(page: params[:groups_page], per_page: 10, order: 'created_at DESC')

  #   respond_to do |format|
  #     if @group.nil?
  #       @group = Group.new(group_params)
  #       if !@group.save
  #         @result[:r] = 0
  #         @result[:msg] = "'#{@group.name}' failed to save."
  #       else
  #         @result[:r] = 1
  #         @result[:msg] = "'#{@group.name}' was saved."
  #         #groups needs to be updated to get the latest addition
  #         @groups = Group.paginate(page: params[:groups_page], per_page: 10, order: 'created_at DESC')
  #       end
  #     else
  #       @result[:r] = 0
  #       @result[:msg] = "Name: '#{@group.name}' is already taken."
  #     end
  #     format.js
  #     format.html { redirect_to groups_path }
  #   end
  # end

  def edit
    @group = Group.find(params[:id])
  end

  def show
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      flash[:success] = "'" + @group.name + "' updated"
      redirect_to @group
    else
      flash[:danger] = "The group couldn't be updated"
      render 'edit'
    end
  end

  def delete_request
    @group = Group.find_by(id: params[:id])
    respond_to do |format|
      format.js 
    end
  end

  # def confirm_delete
  #   @group = Group.find(params[:id])
  #   if @group.blank?
  #     flash[:danger] = "The group couldn't be found."
  #   elsif @group.destroy
  #     flash[:success] = "#{@group.name} successfully destroyed."
  #   else
  #     flash[:danger] = "There was an error destroying the specified group. Notify the administrator."
  #   end
  #   respond_to do |format|
  #     format.js { render :js => "window.location.href='"+groups_path+"'" }
  #   end
  # end

  def confirm_delete
    groups = Group.where(id: params[:selected])
    msg = ""
    type = "info"
    if groups.blank?
      msg = "The groups couldn't be found."
      type = "danger"
    else 
      groups.each do |group|
        if group.destroy
          msg += "<p>#{group.display_name} deleted</p>"
        else
          msg += "<p>#{group.display_name} not deleted.</p>"
        end
      end
    end
    
    @result = {notification: notification(type, msg, []), data: groups}
    puts @result
    @groups = groups_list(nil)
    respond_to do |format|
      format.js
      format.html
    end
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

    # def group_params
    #   params.require(:group).permit(:name, :default_label)
    # end

end
