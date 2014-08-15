module ApplicationHelper

  #provides column sortability for tables
  def entity_sortable(column, title = nil)  
    title ||= column.titleize 
    css_class = (column == entity_sort_column) ? "current #{entity_sort_direction}" : nil  
    direction = (column == entity_sort_column && entity_sort_direction == "asc") ? "desc" : "asc"  
    link_to title, params.merge(entity_sort: column, entity_direction: direction, event: "entity", page: nil), {class: css_class}  
  end

  def group_sortable(column, title = nil)
    title ||= column.titleize 
    css_class = (column == group_sort_column) ? "current #{group_sort_direction}" : nil  
    direction = (column == group_sort_column && group_sort_direction == "asc") ? "desc" : "asc"  
    link_to title, params.merge(group_sort: column, group_direction: direction, event: "group", page: nil), {class: css_class}  
  end

  def property_sortable(column, title = nil)
    title ||= column.titleize 
    css_class = (column == property_sort_column) ? "current #{property_sort_direction}" : nil  
    direction = (column == property_sort_column && property_sort_direction == "asc") ? "desc" : "asc"  
    link_to title, params.merge(property_sort: column, property_direction: direction, event: "property", page: nil), {class: css_class}  
  end

  def user_sortable(column, title = nil)
    title ||= column.titleize 
    css_class = (column == user_sort_column) ? "current #{user_sort_direction}" : nil  
    direction = (column == user_sort_column && user_sort_direction == "asc") ? "desc" : "asc"  
    link_to title, params.merge(user_sort: column, user_direction: direction, event: "user", page: nil), {class: css_class}  
  end

  def egr_sortable(column, title = nil)
    title ||= column.titleize 
    css_class = (column == egr_sort_column) ? "current #{egr_sort_direction}" : nil  
    direction = (column == egr_sort_column && egr_sort_direction == "asc") ? "desc" : "asc"  
    link_to title, params.merge(egr_sort: column, egr_direction: direction, entitys_group_event: true, page: nil), {class: css_class}  
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

  
end