class EntityGroupRelationshipsController < ApplicationController
  include EntityGroupRelationsHelper
  include EntitiesHelper
  before_action do
    redirect_to root_path unless admin_user?
  end

  def index
  	@egrs = egrs_index()

  	puts @egrs

    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    @egr = EntityGroupRelationship.find(params[:id])
    if @egr.update_attributes(egr_params)
      flash[:success] = "'" + @egr.label + "' updated"
    else
      flash[:danger] = "The relationship couldn't be updated"
    end
  	render 'edit'
  end

  def edit
    @egr = EntityGroupRelationship.find(params[:id])
  end

end