# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140929175245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entities", force: true do |t|
    t.string   "name"
    t.string   "label"
    t.string   "img"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["name"], name: "index_entities_on_name", unique: true, using: :btree

  create_table "entity_group_relationships", force: true do |t|
    t.integer  "entity_id"
    t.integer  "group_id"
    t.integer  "position"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_group_relationships", ["entity_id", "group_id"], name: "index_entity_group_relationships_on_entity_id_and_group_id", unique: true, using: :btree

  create_table "entity_property_relationships", force: true do |t|
    t.integer  "entity_id"
    t.integer  "property_id"
    t.integer  "group_id"
    t.integer  "position"
    t.string   "label"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "units"
    t.string   "units_short"
  end

  create_table "eprs_roles", id: false, force: true do |t|
    t.integer "epr_id"
    t.integer "role_id"
  end

  add_index "eprs_roles", ["epr_id", "role_id"], name: "index_eprs_roles_on_epr_id_and_role_id", unique: true, using: :btree

  create_table "group_property_relationships", force: true do |t|
    t.integer  "group_id"
    t.integer  "property_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_property_relationships", ["group_id", "property_id"], name: "index_group_property_relationships_on_group_id_and_property_id", unique: true, using: :btree
  add_index "group_property_relationships", ["group_id"], name: "index_group_property_relationships_on_group_id", using: :btree
  add_index "group_property_relationships", ["property_id"], name: "index_group_property_relationships_on_property_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.string   "default_label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree

  create_table "properties", force: true do |t|
    t.string   "name"
    t.string   "units"
    t.string   "units_short"
    t.string   "default_label"
    t.string   "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["name"], name: "index_properties_on_name", unique: true, using: :btree

  create_table "properties_roles", id: false, force: true do |t|
    t.integer "property_id"
    t.integer "role_id"
  end

  add_index "properties_roles", ["property_id", "role_id"], name: "index_properties_roles_on_property_id_and_role_id", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "change_view"
    t.boolean  "admin"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "role_id"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
