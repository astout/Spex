class RolesController < ApplicationController
  include RolesHelper
  include UsersHelper
  include ApplicationHelper


  #must be admin
  before_action do
    unless current_user.nil?
      redirect_to root_url unless admin_user?
    else
      redirect_to root_url
    end
  end

  def index
    @default = Role.default
    @roles = roles_list(params)

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @default = Role.default
    @role = Role.new
  end

  def create 
    role = Role.find_by(name: role_params[:name])
    if role.blank?
      #create new role ignoring default for now
      role = Role.new(name: role_params[:name], admin: role_params[:admin], change_view: role_params[:change_view])
      if role.save
        if params[:default] == "true"
          #change_defaults is a boolean, set_default expects a boolean
          if role.set_default(params[:change_defaults] == "true")
            flash[:success] = "'" + role.name + "' was created and set as the default role."
          else
            flash[:warning] = "'" + role.name + "' was created, but couldn't be set to the default role."
          end
          redirect_to roles_path
          return
        else
          flash[:success] = "'#{role.name}' was created."
        end
        redirect_to roles_path
      else
        flash[:danger] = "'#{role.name}' couldn't be created."
        @default = Role.default
        @role = Role.new
        render 'new'
        return
      end
    else
      flash[:danger] = "The name '" + @role.name + "' is alredy taken."
      @default = Role.default
      @role = Role.new
      render 'new'
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
    role = Role.find_by(id: params[:id])
    new_role = Role.find_by(id: params[:new_id])
    msg = ""
    type = "info"
    if role.blank?
      msg = "There was an error deleting the role."
      type = "danger"
    elsif new_role.blank? && role.users.count > 0
      msg = "This role has users assigned to it, those users must be reassigned to a new role before it can be deleted."
      type = "info"
    elsif role.delete params[:new_id]
      msg = "#{role.name.capitalize} deleted."
      type = "success"
    else
      msg = "There was an error deleting the role."
      type = "danger"
    end
    @default = Role.default
    @roles = roles_list(params)
    @role = {notification: notification(type, msg, []), data: role}
    puts @role
    # redirect_to roles_path
    respond_to do |format|
      format.js
      format.html
    end
  end

  # def confirm_delete
  #   role = Property.find(params[:id])
  #   msg = ""
  #   type = "info"
  #   if role.blank?
  #     msg = "The role couldn't be found."
  #     type = "danger"
  #   elsif role.destroy
  #     msg = "#{role.name} successfully removed."
  #     type = "success"
  #   else
  #     msg = "There was an error destroying the specified role."
  #     type = "danger"
  #   end
  #   @role = {notification: notification(type, msg, []), data: role}
  #   @roles = _list
  #   respond_to do |format|
  #     format.js
  #     format.html
  #   end
  # end

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
