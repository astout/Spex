module HubHelper

  #get the group property relationships for the selected group
  def groups_property_relations

    #get the selected entity's entity group relationships
    selected_egrs

    #get the instances of the selected groups
    selected_groups

    #start a list of properties that are being listed
    used_properties = []

    #start a response hash for group property relationships
    @gprs = { status: -1, msg: "", data: [] }

    #start a response hash for entity property relationships
    @eprs = { status: -1, msg: "", data: [] }
    
    #if there aren't any selected groups
    if @selected_groups.blank?
      #assume there are selected entity group relations

      #for each selected entity group relation
      @selected_egrs.each do |group_relation|

        #get the entity property relations that involve the current entity group relation
        group_relation.eprs.each do |entity_property_relation|

          #unless the current entity property relation's property is already listed
          unless used_properties.include? entity_property_relation.property
            
            #add the entity property relation to the list
            @eprs[:data] |= [entity_property_relation]

            #
            used_properties |= [entity_property_relation.property]

          end #end add to list
        
        end #end each entity property relation
      
      end #end each entity group relation

    else #there exists at least one selected group

      #for each selected group
      @selected_groups.each do |group|

        #get the current group's group property relations
        group.property_relations.each do |property_relation|

          #unless the current group property relation's property is already listed
          unless used_properties.include? property_relation.property

            #add the group property relationship to the data list
            @gprs[:data] |= [property_relation]

            #add the property to the list of listed properties
            used_properties |= [property_relation.property]
          
          end #end add relation to list
        
        end #end each group property relation

      end #end each selected group

    end #end if selected groups

    #now if the group property relations data is blank
    if @gprs[:data].blank?
      #update the status and message
      @gprs[:status] = 2
      @gprs[:msg] = "No properties for the selected groups."
    else
      #if there's data, sort it by group id
      @gprs[:data].sort_by { |r| r[:group_id] }

      #prepare the data for pagination
      @gprs[:data] = @gprs[:data].paginate(page: params[:gprs_page].blank? ? 1 : params[:gprs_page], per_page: 10, order: 'order ASC')

      #success status and no message
      @gprs[:status] = 1
      @gprs[:msg] = ""
    end

    #now if the entity property relations data is blank
    if @eprs[:data].blank?
      #update the status and message
      @eprs[:status] = 2
      @eprs[:msg] = "No properties for the selected groups."
    else
      #if there's data, sort it by group id
      @eprs[:data].sort_by { |r| r[:group_id] }

      #prepare the data for pagination
      @eprs[:data] = @eprs[:data].paginate(page: params[:gprs_page].blank? ? 1 : params[:gprs_page], per_page: 10, order: 'order ASC')

      #success status and no message
      @eprs[:status] = 1
      @eprs[:msg] = ""
    end
  end #end groups_property_relations

end
