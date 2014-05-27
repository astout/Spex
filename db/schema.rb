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

ActiveRecord::Schema.define(version: 20140523150105) do

  create_table "entities", force: true do |t|
    t.string   "name"
    t.string   "label"
    t.string   "img"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["name"], name: "index_entities_on_name", unique: true

  create_table "entity_property_relationships", force: true do |t|
    t.integer  "entity_id"
    t.integer  "property_id"
    t.integer  "order"
    t.string   "label"
    t.string   "value"
    t.integer  "visibility"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_property_relationships", ["entity_id", "property_id"], name: "index_entity_property_unique_pair", unique: true
  add_index "entity_property_relationships", ["entity_id"], name: "index_entity_property_relationships_on_entity_id"
  add_index "entity_property_relationships", ["property_id"], name: "index_entity_property_relationships_on_property_id"

  create_table "properties", force: true do |t|
    t.string   "name"
    t.string   "units"
    t.string   "units_short"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_label"
    t.string   "default_value"
    t.integer  "default_visibility"
  end

  add_index "properties", ["name"], name: "index_properties_on_name", unique: true

  create_table "property_associations", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "property_associations", ["child_id"], name: "index_property_associations_on_child_id"
  add_index "property_associations", ["parent_id", "child_id"], name: "index_property_associations_on_parent_id_and_child_id", unique: true
  add_index "property_associations", ["parent_id"], name: "index_property_associations_on_parent_id"

  create_table "users", force: true do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "login"
    t.integer  "role",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["login"], name: "index_users_on_login", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
