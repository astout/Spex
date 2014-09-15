class Setting < ActiveRecord::Base
end

def Setting.default_role_id
  setting = Setting.find_by(name: "default_role_id")
  return setting.blank? ? setting : setting['value']
end

def Setting.default_role
  Setting.find_by name: "default_role_id"
end