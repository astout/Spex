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

ActiveRecord::Schema.define(version: 20140516152928) do

  create_table "properties", force: true do |t|
    t.string   "name"
    t.string   "units"
    t.string   "units_short"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_label"
    t.string   "default_value"
  end

  add_index "properties", ["name"], name: "index_properties_on_name"

  create_table "property_associations", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "property_associations", ["child_id"], name: "index_property_associations_on_child_id"
  add_index "property_associations", ["order"], name: "index_property_associations_on_order", unique: true
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
