class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login: params[:session][:login].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or root_url     
    else
      flash.now[:danger] = 'Invalid login/password combination' # Not quite right!
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
