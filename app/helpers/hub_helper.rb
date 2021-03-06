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

  def parse_value(value, epr=nil, epr_list=[])

    if epr_list.include? epr
      puts "- - - - - -CIRCULAR DEPENDENCY- - - - - - -"
      return value
    else
      epr_list.push epr
    end

    return unless value.class == String
    result = value
    #split the string by variable references
    # rx = /([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.][\*][.]\w*\s*\w+[}])/
    rx = /([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.][\*][.]\w*\s*\w+[}])|
      ([{]\w*\s*\w+[.]\w*\s*\w+[}])|([{][\*][.]\w*\s*\w+[}])|([{]\w*\s*\w+[}])/
    # pieces = value.split(/([{]\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+[}])/)
    pieces = value.split(rx)
    puts "--pieces--"
    puts pieces
    pieces.each do |piece|
      #each sub-part, if it's a variable, get just the variable w/o curly braces
      # scan = piece.scan(/[{](\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+)[}]/).flatten
      rx = /[{](\w*\s*\w+[.]\w*\s*\w+[.]\w*\s*\w+)[}]|[{]([\*][.]\w*\s*\w+[.]\w*\s*\w+)[}]|[{]([\*][.][\*][.]\w*\s*\w+)[}]|
        [{](\w*\s*\w+[.]\w*\s*\w+)[}]|[{]([\*][.]\w*\s*\w+)[}]|[{](\w*\s*\w+)[}]/
      scan = piece.scan(rx).flatten.compact
      unless scan.empty?
        puts "GETTING VALUE FOR: "
        puts scan.first
        #parse the reference, get the value
        val = parse_reference(scan.first, epr, epr_list)
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
        puts "PIECE BEFORE EVALUATE: #{scan.first}" #the equation will be the first element
        _scan = evaluate_value(scan.first)
        val = _scan.blank? ? piece : _scan #if the result is empty, default to input
        puts "PIECE AFTER EVALUATE: #{val}"
        puts "REPLACING #{piece} WITH #{val}"
        result.sub!(piece, val)
        puts "RESULT CHANGED: "
        puts result
      end
    end
    result
  end

  def replace_converters(string)
    result = string
    # rx = /(\s|^)(?<converter>([\d]+([.]\d+)?){1}([.][a-zA-Z]+){1,3})/
    rx = /(\s|^)(?<number>([\d]+([.]\d+)?){1})(?<converter>(([.](?!round)(?!floor)(?!ceil)[a-zA-Z]+){1,3}))(?<rounder>([.]?((round)|(ceil)|(floor))(\({1}[-]?\w*\){1})?))?/ 

    m = result.match(rx)

    if !m.blank? && !m['converter'].blank?
      result.sub!( m['converter'].to_s, m['converter'].to_s + ".value" )
    end

    puts "result: '#{result}'"
    return result

    # _scan = string.scan(rx).flatten.compact
    # return string if _scan.empty?
    # puts "-- - - - -- - SCAN - - -- - - -"
    # puts _scan
    # _scan.each do |part|

    #   #match round, ceil, and floor with or without parameters
    #   rx = /[.]?((round)|(ceil)|(floor))(\({1}[-]?\w*\){1})?/

    #   puts "adding .value to: '#{part}'"
    #   # replace = part
    #   # replace += ".value"
    #   temp = part.gsub(rx, '')  #chop off match
    #   temp += ".value"          #append .value
    #   temp += part[rx].to_s     #append match
    #   result.sub!(part, temp)   #replace
    # end
    # puts "result: '#{result}'"
    # return result
  end

  def evaluate_value(value)
    return value if value.blank?
    # result = value
    result = replace_converters(value)
    # rx = /(\s|^)(([\d]+([.]\d+)?)[.][a-zA-Z]+([.][a-zA-Z]+){0,2})/
    rx = /(\s|^)(?<converter>([\d]+([.]\d+)?){1}([.][a-zA-Z]+){1,3})/
    # rx = /(\s|^)(([\d]+([.]\d+)?){1}([.][a-zA-Z]+){1,3})/
    if result.scan(rx).flatten.compact.count > 0 || ["round", "ceil", "floor"].any? { |word| value.include?(word) }
      begin result = eval(result).to_s
      rescue Exception => e
        puts "error caught:"
        puts e.message
        result = value
      end
    end
    begin result = Dentaku.evaluate(result)
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

  def parse_reference(ref, epr=nil, epr_list=[])
    return ref unless ref.class == String
    pieces = ref.split "."
    return ref if pieces.empty?

    if pieces.length == 1
      return ref if epr.blank?
      entity = epr.entity
      group = epr.group
      pname = pieces.last.strip
    elsif pieces.length == 2
      return ref if epr.blank?
      entity = epr.entity
      gname = pieces.first.strip
      pname = pieces.last.strip
      if gname == "*"
        group = epr.group
      else
        group = Group.find_by_name gname
      end
    elsif pieces.length == 3
      ename = pieces.first.strip
      gname = pieces[1].strip
      pname = pieces.last.strip

      if ename == "*"
        return ref if epr.blank?
        entity = epr.entity
      else
        entity = Entity.find_by_name ename
      end
      
      if gname == "*"
        return ref if epr.blank?
        group = epr.group
      else
        group = Group.find_by_name gname
      end
    else
      return ref
    end

    property = Property.find_by_name pname

    return ref if entity.nil? || group.nil? || property.nil?

    relationship = EntityPropertyRelationship.find_by entity_id: entity.id, group_id: group.id, property_id: property.id

    return ref if relationship.nil?

    value = parse_value(relationship.value.to_s, relationship, epr_list)
    return value.to_s
  end

end
