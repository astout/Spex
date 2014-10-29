module PropertiesHelper
  def current_property
    @current_property = Property.find(params[:id])
  end

  def current_property=(property)
    @current_property = property
  end

  def current_property?(property)
    property == current_property
  end

  def selected_properties
    @selected_properties = []
    selected_property_ids = params[:selected_properties]
    unless selected_property_ids.nil?
      selected_property_ids.each do |id|
        property = Property.find_by(id: id)
        unless property.nil? 
          @selected_properties.push property
        end
      end
    end
    @selected_properties
  end

  def properties_list(selected_egrs, selected_groups)
    reject_properties = []
    unless selected_groups.blank?
      #store the entity's groups to eliminate repeated queries
      selected_groups.each do |group|
        reject_properties |= group.properties
      end
    end
    unless selected_egrs.blank?
      selected_egrs.each do |relation|
        reject_properties |= relation.entity.properties_via(relation.group)
      end
    end
    # puts reject_properties
    properties = Property.index(params[:search], sort_column("property"), sort_direction, params[:page], 10, reject_properties, [])
  end

  def property_create(prop_params)
    property = { status: -1, msg: "", data: nil }
    property[:data] = Property.find_by(name: prop_params[:name])

    #if property not found, clear to create
    if property[:data].nil?
      #set the role_ids from the params to a property parameter
      prop_params[:role_ids] = params[:role_ids]
      #create a new property from the prop_params
      property[:data] = Property.new(prop_params)

      #attempt to save
      if !property[:data].save
        property[:status] = 0
        property[:msg] = "'#{property[:data].name}' failed to save."
      else #success
        property[:status] = 1
        property[:msg] = "'#{property[:data].name}' was saved."
      end
    else #otherwise, name isn't unique
      property[:status] = 0
      property[:msg] = "Name: '#{property[:data].name}' is already taken."
    end
    return property
  end

  def properties_delete(properties)
    deleted_properties = []
    properties.each do |property|
      deleted_properties.push property ? { data: property.destroy, msg: "" } : { data: nil, msg: "property not found" }
    end
    return deleted_properties
  end

  def property_params
    params.require(:property).permit(:name, :units, :units_short, :default_label, :default_value, role_ids: [])
  end

  def property_sort_column
    Property.column_names.include?(params[:property_sort]) ? params[:property_sort] : "created_at"
  end

  def property_sort_direction
    %w[asc desc].include?(params[:property_direction]) ? params[:property_direction] : "desc"
  end

end
