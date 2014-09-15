module UsersHelper
  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.first + " " + user.last, class: "gravatar")
  end

  def user_params
    params.require(:user).permit(:first, :last, :login, :email, :role_id, :password, :password_confirmation)
  end

  def user_sort_column
    User.column_names.include?(params[:user_sort]) ? params[:user_sort] : "created_at"
  end

  def user_sort_direction
    %w[asc desc].include?(params[:user_direction]) ? params[:user_direction] : "desc"
  end

  def require_admin
    unless current_user.nil?
      redirect_to root_url unless current_user.admin?
    else
      redirect_to root_url
    end
  end
end
