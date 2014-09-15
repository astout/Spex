class RolesController < ApplicationController
  include RolesHelper
  include UsersHelper

  #must be admin
  before_action do
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end

  def index
    @default = Role.default
    get_collection(params)
  end

  def new
    @default = Role.default
    @role = Role.new
  end

  def create 
    @role = Role.find_by(name: role_params[:name])
    if @role.blank?
      #create new role ignoring default for now
      @role = Role.new(name: role_params[:name], admin: role_params[:admin], change_view: role_params[:change_view])
      if @role.save
        if params[:default] == "true"
          #change_defaults is a boolean, set_default expects a boolean
          if @role.set_default(params[:change_defaults] == "true")
            flash[:success] = "'" + @role.name + "' was created and set as the default role."
          else
            flash[:warning] = "'" + @role.name + "' was created, but couldn't be set to the default role."
          end
          redirect_to roles_path
          return
        else
          flash[:success] = "'#{@role.name}' was created."
        end
        redirect_to roles_path
      else
        flash[:danger] = "'#{@role.name}' couldn't be created."
        redirect_to roles_path
        return
      end
    else
      flash[:danger] = "The name '" + @role.name + "' is alredy taken."
      redirect_to roles_path
      return
    end
  end

  def show
    @role = Role.find(params[:id])
  end

  def edit
    @default = Role.default
    @role = Role.find(params[:id])  
    @users = User.index(params['user_search'], user_sort_column, user_sort_direction, params[:users_page], 10, nil, @role.users)
  end

  def update
    @role = Role.find_by(id: params[:id])
    if @role.blank?
      flash[:danger] = "'" + role_params['name'] + "' couldn't be found."
      render 'edit'
      return
    end
    if params[:default] == "true"
      #change_defaults is a boolean, set_default expects a boolean
      @role.set_default(params[:change_defaults] == "true")
    end
    if @role.update_attributes(role_params)
      flash[:success] = "'" + @role.name + "' updated"
      redirect_to roles_path
    else
      flash[:danger] = "'" + @role.name + "' couldn't be updated."
      render 'edit'
    end

    # original_default = Role.find_by(default: true)
    
    # if @role == original_default
    #   if !params[:role][:default]
    #     flash[:danger] = "To change the default role, go to the role you want to make default and set it to default."
    #     render 'edit'
    #     return
    #   else
    #     if @role.update_attributes(role_params)
    #       flash[:success] = "'" + @role.name + "' updated"
    #       redirect_to roles_path
    #     else
    #       render 'edit'
    #     end
    #   end
    # else
    #   if @role.update_attributes(role_params)
    #     if params[:role][:default]
    #       original_default.update_attributes(default: false)
    #       if params[:role][:change_defaults]
    #         User.update(User.where(role_id: original_default.id), role_id: @role.id) 
    #       end
    #     end
    #     flash[:success] = "'" + @role.name + "' updated"
    #     redirect_to roles_path
    #   else
    #     render 'edit'
    #   end
    # end
  end

  def delete_request
    @default = Role.default
    @role = Role.find_by(id: params[:id])
    @other_roles = Role.all.reject { |r| r.id == @role['id'] }
    respond_to do |format|
      format.js
    end
  end

  def confirm_delete
    @role = Role.find_by(id: params[:id])
    @new_role = Role.find_by(id: params[:new_id])
    if @role.blank? || @new_role.blank?
      flash[:danger] = "There was an error deleting the role."
    elsif @role.delete params[:new_id]
      flash[:success] = "'#{@role.name}' deleted."
    else
      flash[:danger] = "There was an error deleting the role."
    end
    # redirect_to roles_path
    respond_to do |format|
      format.js { render :js => "window.location.href='"+roles_path+"'" }
    end
  end

  def destroy
    respond_to do |format|
      format.html { 
        @role = Role.find(params[:id])
        result = @role.destroy
        if result
          flash[:success] = "'" + @role.name + "' deleted"
        else
          flash[:danger] = "Unable to delete '" + @role.name + "'"
        end
        redirect_to roles_url 
      }
    end
  end
end
