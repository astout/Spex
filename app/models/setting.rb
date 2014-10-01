class Setting < ActiveRecord::Base

  VALID_NAME_REGEX = /\A[a-z0-9]+[a-z0-9\-\_]*[a-z0-9]+\z/i
  validates :name,  presence: true, format: { with: VALID_NAME_REGEX }, 
    length: { minimum: 2, maximum: 32 },
    uniqueness: { case_sensitive: false }

  before_save do |setting|
    setting.name.downcase!
  end

  def Setting.default_role_id
    setting = Setting.find_by(name: "default_role_id")
    return setting.blank? ? setting : setting['value']
  end

  def Setting.default_role
    Setting.find_by name: "default_role_id"
  end

end

