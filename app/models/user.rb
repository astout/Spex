class User < ActiveRecord::Base
  before_save do
    self.email = email.downcase unless self.email.blank?
    self.login = login.downcase
  end
  before_create :create_remember_token
  validates :first,  presence: true, length: { maximum: 30 }
  validates :last,  presence: true, length: { maximum: 30 }
  VALID_LOGIN_REGEX = /\A[a-z\d]+[a-z\d\-]*[a-z\d]+\z/i
    validates :login,  presence: true, format: { with: VALID_LOGIN_REGEX }, 
      length: { minimum: 3, maximum: 18 },
      uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, format: { with: VALID_EMAIL_REGEX }, allow_blank: true,
      uniqueness: { case_sensitive: false }
  validates :role,  presence: true
  has_secure_password
  validates :password, length: { minimum: 6 }
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

    def self.search(search)
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
        elements.concat [e]*6
      end
      #declare the where clause
      clause = ''

      #for each word from the search string
      _elements.each do |element|
        #append to the clause the full query
        clause += '(LOWER(first) LIKE ? OR LOWER(last) LIKE ? OR LOWER(email) LIKE ? OR LOWER(login) LIKE ? OR created_at::text LIKE ? OR updated_at::text LIKE ?) AND '
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