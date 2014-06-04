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
      child_results = create_child_eprs(@entity, @property)
      result = !child_results.any? {|item| item[:result] == false}
      if result
        flash[:success] = "'" + @property.name + "' added to '" + @entity.name + "'"
      else
        message = ""
        child_results.each do |item|
          if item[:result] == false
            message += "'" + item[:property].name + "' not able to be added.\n"
          end
        end
        flash.now[:danger] = message
      end
    else
      flash.now[:danger] = "'" + @property.name + "' not Added " + @entity.name 
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

  private

    def create_child_eprs(entity, property)
      results = []
      result = nil
      property.descendants.each do |descendant|
        relationship = EntityPropertyRelationship.new(entity_id: entity.id, property_id: descendant.id)
        if relationship.save
          result = true
        else
          result = false
        end
        r = {property: descendant, result: result}
        results ||= r
      end
    end

end