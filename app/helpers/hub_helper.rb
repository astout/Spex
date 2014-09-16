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
      @gprs[:data] = @gprs[:data].paginate(page: params[:gprs_page].blank? ? 1 : params[:gprs_page], per_page: 10, order: 'position ASC')

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
      @eprs[:data] = @eprs[:data].paginate(page: params[:gprs_page].blank? ? 1 : params[:gprs_page], per_page: 10, order: 'position ASC')

      #success status and no message
      @eprs[:status] = 1
      @eprs[:msg] = ""
    end
  end #end groups_property_relations

  #regex matches ThreeVariables.separatedBy.oneDecimal 
  #((?<![.])\b+\w+[.]\w+[.]\w+\b+(?![.]))

  #regex matches {ThreeVariables.separatedBy.oneDecimal} (surrounded by curly braces).
  #([{]\w+[.]\w+[.]\w+[}])

  #same as above but allows spaces in names
  #([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])
  #remember only what's inside the brackets
  #[{](\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+)[}]

  #get any int or decimal number
  #\d+[.]?(?!\d)*

  #match anything between square brackets
  #(\[.*\])

  #match each occurrence of enclosures of double brackets
  #\[\[([^]]+)\]\]

  def parse_value(value, epr=nil)
    return unless value.class == String
    result = value
    vars = []
    #split the string by variable references
    rx = /([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.][\*][.]\w*\s*\w+[}])/
    # pieces = value.split(/([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])/)
    pieces = value.split(rx)
    puts "--pieces--"
    puts pieces
    pieces.each do |piece|
      #each sub-part, if it's a variable, get just the variable w/o curly braces
      # scan = piece.scan(/[{](\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+)[}]/).flatten
      rx = /[{](\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+)[}]|[{]([\*][.]\w*\s*\w+[.]\w*\s*\w+)[}]|[{]([\*][.][\*][.]\w*\s*\w+)[}]/
      scan = piece.scan(rx).flatten.compact
      unless scan.empty?
        puts "GETTING VALUE FOR: "
        puts scan.first
        #parse the reference, get the value
        val = parse_reference(scan.first, epr)
        puts "VALUE RETRIEVED: "
        puts val
        val = piece if val == scan.first
        puts "REPLACING #{piece} WITH #{val}"
        result.sub!(piece, val)
        puts "RESULT CHANGED: "
        puts result
      end
    end

    #split the result by equations
    pieces = result.split(/(\[\[[^\]]+\]\])/)
    pieces.each do |piece|
      scan = piece.scan(/\[\[([^\]]+)\]\]/).flatten
      unless scan.empty?
        puts "PIECE BEFORE EVALUATE: #{scan.first}"
        _scan = evaluate_value(scan.first)
        val = _scan.blank? ? piece : _scan
        puts "PIECE AFTER EVALUATE: #{val}"
        puts "REPLACING #{piece} WITH #{val}"
        result.sub!(piece, val)
        puts "RESULT CHANGED: "
        puts result
      end
    end
    result
  end

  def evaluate_value(value)
    return value if value.blank?
    result = value
    begin result = Dentaku.evaluate(value)
    rescue Exception => e
      puts "error caught:"
      puts e.message
      return value
    end
    puts "EVAL RESULT: #{result}"
    result.to_s
  end

  def parse_formula(formula)
    return unless formula.class == String
    pieces = formula.scan(/\{(.*?)\}/)
  end

  def parse_reference(ref, epr=nil)
    return ref unless ref.class == String
    pieces = ref.split "."
    return ref if pieces.empty?

    ename = pieces.first.strip
    gname = pieces[1].strip
    pname = pieces.last.strip

    if ename == "*" && !epr.blank?
      entity = epr.entity
    else
      entity = Entity.find_by_name ename
    end
    
    if gname == "*" && !epr.blank?
      group = epr.group
    else
      group = Group.find_by_name gname
    end

    property = Property.find_by_name pname

    return ref if entity.nil? || group.nil? || property.nil?

    relationship = EntityPropertyRelationship.find_by entity_id: entity.id, group_id: group.id, property_id: property.id

    relationship.value
  end

end
