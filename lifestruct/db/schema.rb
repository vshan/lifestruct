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

ActiveRecord::Schema.define(version: 20150703072047) do

  create_table "goal_logs", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "goal_id"
    t.datetime "start"
    t.datetime "end"
    t.text     "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goal_maps", force: true do |t|
    t.integer  "goal_id"
    t.integer  "status_id"
    t.integer  "in_week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goals", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "parent_id"
    t.float    "progress"
    t.float    "timetaken"
    t.datetime "deadline"
    t.integer  "repeatable"
    t.integer  "priority"
    t.datetime "start"
    t.datetime "end"
    t.integer  "has_child"
    t.integer  "prop"
  end

  add_index "goals", ["parent_id"], name: "index_goals_on_parent_id", using: :btree

  create_table "time_tiles", force: true do |t|
    t.time     "start"
    t.time     "end"
    t.integer  "status"
    t.integer  "goal_id"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
