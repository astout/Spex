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
end