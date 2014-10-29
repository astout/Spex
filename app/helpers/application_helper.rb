module ApplicationHelper

  def sortable(model, column, title = nil)
    puts "sortable :: model: #{model}, column: #{column}, title: #{title}"
    title ||= column.titleize 
    css_class = (column == sort_column(model)) ? "current #{sort_direction()}" : nil  
    direction = (column == sort_column(model) && sort_direction() == "asc") ? "desc" : "asc"  
    link_to title, params.merge(column: column, direction: direction, event: "entity", page: nil), class: css_class.to_s + " table_header #{column} #{model}", data: {column: column, direction: direction, model: model}
  end

  # #provides column sortability for tables
  # def entity_sortable(column, title = nil)  
  #   title ||= column.titleize 
  #   css_class = (column == entity_sort_column) ? "current #{entity_sort_direction}" : nil  
  #   direction = (column == entity_sort_column && entity_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(entity_sort: column, entity_direction: direction, event: "entity", page: nil), class: css_class.to_s + " table_header #{column} entity", data: {direction: direction} 
  # end

  # def group_sortable(column, title = nil)
  #   title ||= column.titleize 
  #   css_class = (column == group_sort_column) ? "current #{group_sort_direction}" : nil  
  #   direction = (column == group_sort_column && group_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(group_sort: column, group_direction: direction, event: "group", page: nil), class: css_class.to_S + " table_header #{column} group"  
  # end

  # def property_sortable(column, title = nil)
  #   title ||= column.titleize 
  #   css_class = (column == property_sort_column) ? "current #{property_sort_direction}" : nil  
  #   direction = (column == property_sort_column && property_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(property_sort: column, property_direction: direction, event: "property", page: nil), {class: css_class}  
  # end

  # def epr_sortable(column, title = nil)  
  #   title ||= column.titleize 
  #   css_class = (column == epr_sort_column) ? "current #{epr_sort_direction}" : nil  
  #   direction = (column == epr_sort_column && epr_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(epr_sort: column, epr_direction: direction, event: "epr", page: nil), {class: css_class}  
  # end

  # def user_sortable(column, title = nil)
  #   title ||= column.titleize 
  #   css_class = (column == user_sort_column) ? "current #{user_sort_direction}" : nil  
  #   direction = (column == user_sort_column && user_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(user_sort: column, user_direction: direction, event: "user", page: nil), {class: css_class}  
  # end

  # def egr_sortable(column, title = nil)
  #   title ||= column.titleize 
  #   css_class = (column == egr_sort_column) ? "current #{egr_sort_direction}" : nil  
  #   direction = (column == egr_sort_column && egr_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(egr_sort: column, egr_direction: direction, entitys_group_event: true, page: nil), {class: css_class}  
  # end

  # def role_sortable(column, title = nil)
  #   title ||= column.titleize 
  #   css_class = (column == role_sort_column) ? "current #{role_sort_direction}" : nil  
  #   direction = (column == role_sort_column && role_sort_direction == "asc") ? "desc" : "asc"  
  #   link_to title, params.merge(role_sort: column, role_direction: direction, event: "role", page: nil), {class: css_class}  
  # end

  #TODO: verify
  def sort_column(model)
    puts "model: #{model}"
    if model.blank? || model.class != String
      return "created_at"
    elsif model == "entity"
      return Entity.column_names.include?(params[:column]) ? params[:column] : "created_at"
    elsif model == "group"
      return Group.column_names.include?(params[:column]) ? params[:column] : "created_at"
    elsif model == "property"
      return Property.column_names.include?(params[:column]) ? params[:column] : "created_at"
    elsif model == "epr"
      return EntityPropertyRelationship.column_names.include?(params[:column]) ? params[:column] : "created_at"
    elsif model == "gpr"
      return GroupPropertyRelationship.column_names.include?(params[:column]) ? params[:column] : "created_at"
    elsif model == "egr"
      return EntityGroupRelationship.column_names.include?(params[:column]) ? params[:column] : "created_at"
    else
      return "created_at"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "GZSpex"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def notification(type, msg, classes)
    html = "<div class='alert notice alert-#{type} #{classes.join(' ')}'>"
    html += msg
    html += "</div>"
  end

  # File actionpack/lib/action_view/helpers/asset_tag_helper.rb, line 166
  # def favicon_link_tag(source='favicon.ico', options={})
  #   tag('link', {
  #     :rel  => 'shortcut icon',
  #     :type => 'image/vnd.microsoft.icon',
  #     :href => path_to_image(source)
  #   }.merge!(options.symbolize_keys))
  # end
  
end