class PropertyAssociationsController < ApplicationController
  before_action do
    redirect_to root_url unless current_user.admin?
  end

  def create
    session[:return_to] ||= request.referer
    @parent = Property.find(params[:parent])
    @child = Property.find(params[:child])
    @relationship = PropertyAssociation.new(parent_id: @parent.id, child_id: @child.id)
    if @relationship.save
      flash[:success] = "Property Association Added"
    else
      flash.now[:danger] = "Property Association Not Added"
    end
    redirect_to session.delete(:return_to)
  end

  def destroy
    # @property = Property.find(params[:parent_id])
    # @child = PropertyAssociation.find(params[:id]).child
    # @property.disown!(@child)
    session[:return_to] ||= request.referer
    @relation = PropertyAssociation.find(params[:id])
    @relation.destroy
    flash[:success] = "Association removed"
    redirect_to session.delete(:return_to)
  end
end