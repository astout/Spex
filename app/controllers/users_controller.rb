class UsersController < ApplicationController
  include UsersHelper
  include ApplicationHelper
  before_action :signed_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :index]

  def index
    # @users = User.paginate(page: params[:page])
    # @users = User.search(params[:user_search]).order(user_sort_column + ' ' + user_sort_direction).paginate(page: params[:users_page])
    @users = User.index(params[:user_search], user_sort_column, user_sort_direction, params[:users_page], 10, [], [])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role_id: params[:role_id]))
    if @user.save
      unless admin_user?
        sign_in @user
      end
      if admin_user?
        flash[:success] = "#{@user.login} created successfully."
      else
        flash[:success] = "Welcome to Goal Zero Tech Specs!"
      end
      redirect_to @user
    else
      flash[:danger] = "There was an error creating the account.  The login you tried might be taken."
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(user_params.merge(role_id: params[:role_id]))
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def delete_request
    @user = User.find_by(id: params[:id])
    respond_to do |format|
      format.js 
    end
  end

  def confirm_delete
    user = User.find(params[:id])
    msg = ""
    type = "info"
    if user.blank?
      msg = "The user couldn't be found."
      type = "danger"
    elsif user.destroy
      msg = "#{user.login} successfully removed."
      type = "success"
    else
      msg = "There was an error destroying the specified user."
      type = "danger"
    end
    @user = {notification: notification(type, msg, []), data: user}
    @users = User.index(params[:user_search], user_sort_column, user_sort_direction, params[:users_page], 10, [], [])
    puts "finishing"
    puts @user
    respond_to do |format|
      format.js
      format.html
      # format.js { render :js => "window.location.href='"+users_path+"'" }
    end
  end

  def destroy
    User.find(params[:id]).destroy if admin_user?
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  private

    # def user_params
    #   params.require(:user).permit(:first, :last, :login, :email, :password,
    #                                :password_confirmation)
    # end

    # Before filters

    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user) || admin_user?
        redirect_to(root_url) 
      end
    end

    def admin_user
      redirect_to(root_url) unless admin_user?
    end
end
