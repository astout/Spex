class User < ActiveRecord::Base
  belongs_to :role
  before_save do
    self.email = email.downcase unless self.email.blank?
    self.login = login.downcase
    if self.role_id.blank?
      self.role_id = Role.default['id']
    end
  end
  before_create do
    :create_remember_token
  end
  before_destroy do
    if User.admins.count < 2 && self.admin?
      puts "\n - - - Can't delete the last admin user. - - - \n"
      return false
    end
  end
  validates :first,  presence: true, length: { maximum: 32 }
  validates :last,  presence: true, length: { maximum: 32 }
  VALID_LOGIN_REGEX = /\A[a-z0-9]+[a-z0-9\-\_]*[a-z0-9]+\z/i
    validates :login,  presence: true, format: { with: VALID_LOGIN_REGEX }, 
      length: { minimum: 3, maximum: 32 },
      uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, format: { with: VALID_EMAIL_REGEX }, allow_blank: true
  has_secure_password
  validates :password, 
    length: { minimum: 6 },
    if: :password #only validate if changed    
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  #returns list of users with admin rights?
  def User.admins
    User.where(role_id: Role.admins.pluck(:id))
  end

  def User.non_admins
    User.where("id not in (?)", User.admins.pluck(:id))
  end

  def display_name
    return self.first.to_s.capitalize + " " + self.last.to_s.capitalize unless self.first.blank? && self.last.blank?
    return self.login
  end

  #true if user role has admin rights
  def admin?
    return false if self.role.nil?
    return true if self.role.admin?
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

    def User.search(search)
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
        elements.concat [e]*7
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(LOWER(first) LIKE ? OR LOWER(last) LIKE ? OR LOWER(email) LIKE ? OR LOWER(login) LIKE ? OR LOWER(roles.name) LIKE ? OR users.created_at::text LIKE ? OR users.updated_at::text LIKE ?) AND '
      end
      #remove the trailing 'AND' from the clause
      clause = clause.gsub(/(.*)( AND )(.*)/, '\1')

      full_join = User.joins(:role)

      full_join.where clause, *elements

      #call the query using the clause and each binding element
      # where clause, *elements
    else
      all # if _elements.empty?
    end
  end
end