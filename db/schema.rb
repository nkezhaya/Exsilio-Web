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

ActiveRecord::Schema.define(version: 20160620173017) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tours", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.jsonb    "directions"
    t.integer  "waypoints_count"
    t.integer  "total_time_in_seconds",                         default: 0
    t.decimal  "latitude",              precision: 9, scale: 6
    t.decimal  "longitude",             precision: 9, scale: 6
    t.boolean  "published",                                     default: false
  end

  add_index "tours", ["latitude"], name: "index_tours_on_latitude", using: :btree
  add_index "tours", ["longitude"], name: "index_tours_on_longitude", using: :btree
  add_index "tours", ["published"], name: "index_tours_on_published", using: :btree
  add_index "tours", ["user_id"], name: "index_tours_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "facebook_uid"
    t.string   "token"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "waypoints", force: :cascade do |t|
    t.integer  "tour_id"
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "latitude",           precision: 9, scale: 6
    t.decimal  "longitude",          precision: 9, scale: 6
    t.string   "address"
    t.string   "city"
    t.string   "state"
  end

  add_index "waypoints", ["position"], name: "index_waypoints_on_position", using: :btree
  add_index "waypoints", ["tour_id"], name: "index_waypoints_on_tour_id", using: :btree

end
