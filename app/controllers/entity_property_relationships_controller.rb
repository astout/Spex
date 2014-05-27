class EntityPropertyRelationshipsController < ApplicationController
  before_action do
    redirect_to root_url unless current_user.admin?
  end

  def create
    session[:return_to] ||= request.referer
    @entity = Entity.find(params[:entity])
    @property = Property.find(params[:property])
    @relationship = EntityPropertyRelationship.new(entity_id: @entity.id, property_id: @property.id)
    if @relationship.save
      flash[:success] = "Property Added to " + @entity.name
    else
      flash.now[:danger] = "Property Not Added " + @entity.name 
    end
    redirect_to session.delete(:return_to)
  end

  def destroy
    session[:return_to] ||= request.referer
    @relation = EntityPropertyRelationship.find(params[:id])
    @relation.destroy
    flash[:success] = "'" + @relation.property.name + "' removed from '" + @relation.entity.name + "'"
    redirect_to session.delete(:return_to)
  end
end