class Role < ActiveRecord::Base
  has_and_belongs_to_many :properties
  has_and_belongs_to_many :entity_property_relationships, join_table: "eprs_roles", association_foreign_key: "epr_id"
  has_many :users

  before_save do
    self.name = name.downcase
  end

  VALID_ROLE_NAME = /([a-z0-9]+\s?[a-z0-9\-\_]*\s?[a-z0-9]+\z)/i
  validates :name, presence: true, format: { with: VALID_ROLE_NAME },
    length: { minimum: 2, maximum: 20 },
    uniqueness: { case_sensitive: false }


  #gets the default role
  def Role.default
    default = Setting.default_role_id
    if default.blank?
      return {}
    else
      return Role.find_by(id: default) || {}
    end
    # r = r.blank? ? {} : r.serializable_hash
  end

  #returns list of all roles with admin rights
  def Role.admins
    Role.where(admin: true)
  end 

  def Role.non_admins
    Role.where(admin: false)
  end

  def default?
    self == Role.default ? true : false 
  end

  def caps_name
    if name.blank?
      ""
    else
      name.capitalize
    end
  end

  def viewables
    if self.admin?
      EntityPropertyRelationship.all
    else
      EntityPropertyRelationship.includes(:roles).where('roles.id = ?', self.id).references(:roles)
    end
  end

  def egr_viewables(entity_id, group_id)
    return 0 if group_id.blank? || entity_id.blank?
    self.viewables.select { |v| v[:group_id] == group_id.to_i && v[:entity_id] == entity_id.to_i }.count
  end

  def entity_viewables(entity)
    return 0 if entity.blank?
    puts "entity param"
    puts entity
    puts "entity class"
    puts entity.class.name
    if entity.class.name == "String" || entity.class.name == "Fixnum"
      return self.viewables.select { |v| v[:entity_id] == entity.to_i }.count
    elsif entity.class.name == "Entity"
      return self.viewables.select { |v| v[:entity_id] == entity.id }.count
    else
      return 0
    end
  end

  def delete(new_role_id = nil)
    return false if new_role_id.blank? && self.users.count > 0
    if self.default?
      new_role = Role.find_by(id: new_role_id)
      return false if new_role.blank?
      new_role.set_default(true)
    else
      User.where(role_id: self.id).update_all(role_id: new_role_id) 
    end

    return self.destroy
  end

  #sets the instance to be the new default role
  #unsets the original default as default
  #if change_user_roles == true, changes all users where
  #role_id is current default role id
  def set_default(change_user_roles=false)
    original_default = Role.default
    return true if self == original_default
    def_role_setting = Setting.default_role
    if def_role_setting.update_attribute('value', self.id)
      if change_user_roles && !original_default.blank?
        User.where(role_id: original_default.id).update_all(role_id: self.id) 
      end
      return true
    else
      return false
    end
  end


  ##################
  # # # ROLE SEARCH
  ##################

  #class function
  #returns roles that match the given search string
  #It searches the name, label, created, and updated fields for partial matches
  def Role.search(search)
    #return all entities if search is nil
    return all if search.nil?

    search.downcase!

    #split the search by spaces
    _elements = search.split ' '

    #return all if empty after split
    unless _elements.empty?
      #declare an array to store each binding element
      elements = []

      #for each word from the split search phrase
      _elements.each do |e|
        #wrap each word in '%' to allow partial matches
        e = '%'+e+'%'
        #add the string to the binding elements 4 times (1 for each field)
        elements.concat [e]*1
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(LOWER(name) LIKE ?) AND '
      end
      #remove the trailing 'AND' from the clause
      clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

      #call the query using the clause and each binding element
      where clause, *elements
    else
      all # if _elements.empty?
    end
  end
end
