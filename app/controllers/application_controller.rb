class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  config.relative_url_root = ""

  def delete_request
    if params[:model] == "entity"
      @deletions = Entity.where(id: params[:selected])
    elsif params[:model] == "group"
      @deletions = Group.where(id: params[:selected])
    elsif params[:model] == "property"
      @deletions = Property.where(id: params[:selected])
    elsif params[:model] == "egr"
      @deletions = EntityGroupRelationships.where(id: params[:selected])
    elsif params[:model] == "epr"
      @deletions = EntityPropertyRelationships.where(id: params[:selected])
    elsif params[:model] == "gpr"
      @deletions = GroupPropertyRelationships.where(id: params[:selected])
    elsif params[:model] == "role"
      @deletions = Role.where(id: params[:selected])
    elsif params[:model] == "user"
      @deletions = User.where(id: params[:selected])
    end
      
    respond_to do |format|
      format.js 
    end
  end

end
