module RolesHelper
  def roles_list(params)
    Role.search(params[:role_search]).order(role_sort_column + ' ' + role_sort_direction).paginate(page: params[:roles_page])
  end

  def role_params
    params.require(:role).permit(:name, :admin, :change_view)
  end

  def role_sort_column
    Role.column_names.include?(params[:role_sort]) ? params[:role_sort] : "created_at"
  end
    
  def role_sort_direction
    %w[asc desc].include?(params[:role_direction]) ? params[:role_direction] : "desc"
  end
end
