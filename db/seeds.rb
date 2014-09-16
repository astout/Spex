# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.destroy_all
[{name: "default", change_view: false, admin: false}, {name: "enthusiast", change_view: false, admin: false}, {name: "specialist", change_view: true, admin: false}, {name: "engineer", change_view: true, admin: false}, {name: "admin", change_view: true, admin: true}].each do |role|
  Role.find_or_create_by role
end

Setting.destroy_all
def_role = Role.find_by(name: "default") || Role.first || {}

[{name: "default_role_id", value: def_role['id'] || "0" }].each do |setting|
  Setting.find_or_create_by setting
end

User.destroy_all
[{ first: "admin", last: "user", login: "gzadmin", email: "spexadmin@goalzero.com", password: "epsilon", password_confirmation: "epsilon", role_id: Role.admins.first.blank? ? 0 : Role.admins.first['id'] }].each do |user|
  User.find_or_create_by user
end
