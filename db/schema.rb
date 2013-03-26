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

ActiveRecord::Schema.define(version: 20130323024617) do

  create_table "callers", force: true do |t|
    t.integer  "situation_id",            null: false
    t.string   "revision",     limit: 30, null: false
    t.string   "gvdate",       limit: 10, null: false
    t.string   "fort_group",   limit: 10, null: false
    t.string   "fort_code",    limit: 10, null: false
    t.string   "guild_name",   limit: 50, null: false
    t.string   "reject_name",  limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "callers", ["fort_code"], name: "index_callers_on_fort_code"
  add_index "callers", ["fort_group"], name: "index_callers_on_fort_group"
  add_index "callers", ["guild_name"], name: "index_callers_on_guild_name"
  add_index "callers", ["gvdate", "fort_code"], name: "index_callers_on_gvdate_and_fort_code"
  add_index "callers", ["gvdate", "fort_group"], name: "index_callers_on_gvdate_and_fort_group"
  add_index "callers", ["gvdate", "guild_name"], name: "index_callers_on_gvdate_and_guild_name"
  add_index "callers", ["gvdate", "reject_name"], name: "index_callers_on_gvdate_and_reject_name"
  add_index "callers", ["gvdate"], name: "index_callers_on_gvdate"
  add_index "callers", ["reject_name"], name: "index_callers_on_reject_name"
  add_index "callers", ["revision", "fort_code"], name: "index_callers_on_revision_and_fort_code", unique: true

  create_table "forts", force: true do |t|
    t.integer  "situation_id",             null: false
    t.string   "revision",     limit: 30,  null: false
    t.string   "gvdate",       limit: 10,  null: false
    t.string   "fort_group",   limit: 10,  null: false
    t.string   "fort_code",    limit: 10,  null: false
    t.string   "fort_name",    limit: 100
    t.string   "formal_name",  limit: 100
    t.string   "guild_name",   limit: 50,  null: false
    t.datetime "update_time",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forts", ["fort_group"], name: "index_forts_on_fort_group"
  add_index "forts", ["guild_name"], name: "index_forts_on_guild_name"
  add_index "forts", ["gvdate", "fort_group"], name: "index_forts_on_gvdate_and_fort_group"
  add_index "forts", ["gvdate", "guild_name"], name: "index_forts_on_gvdate_and_guild_name"
  add_index "forts", ["gvdate"], name: "index_forts_on_gvdate"
  add_index "forts", ["revision", "fort_code"], name: "index_forts_on_revision_and_fort_code", unique: true
  add_index "forts", ["situation_id"], name: "index_forts_on_situation_id"

  create_table "guild_results", force: true do |t|
    t.string   "gvdate",     limit: 10, null: false
    t.string   "guild_name", limit: 50, null: false
    t.text     "data",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guild_results", ["guild_name"], name: "index_guild_results_on_guild_name"
  add_index "guild_results", ["gvdate", "guild_name"], name: "index_guild_results_on_gvdate_and_guild_name", unique: true
  add_index "guild_results", ["gvdate"], name: "index_guild_results_on_gvdate"

  create_table "posted_situations", force: true do |t|
    t.datetime "posted_time",                 null: false
    t.text     "posted_data",                 null: false
    t.boolean  "locked",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posted_situations", ["posted_time"], name: "index_posted_situations_on_posted_time"

  create_table "rulers", force: true do |t|
    t.string   "gvdate",       limit: 10,                  null: false
    t.string   "fort_group",   limit: 10,                  null: false
    t.string   "fort_code",    limit: 10,                  null: false
    t.string   "fort_name",    limit: 100
    t.string   "formal_name",  limit: 100
    t.string   "guild_name",   limit: 50,                  null: false
    t.string   "source",       limit: 50,                  null: false
    t.boolean  "full_defense",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rulers", ["fort_group"], name: "index_rulers_on_fort_group"
  add_index "rulers", ["guild_name"], name: "index_rulers_on_guild_name"
  add_index "rulers", ["gvdate", "fort_code"], name: "index_rulers_on_gvdate_and_fort_code", unique: true
  add_index "rulers", ["gvdate", "fort_group"], name: "index_rulers_on_gvdate_and_fort_group"
  add_index "rulers", ["gvdate", "guild_name"], name: "index_rulers_on_gvdate_and_guild_name"
  add_index "rulers", ["gvdate"], name: "index_rulers_on_gvdate"
  add_index "rulers", ["source"], name: "index_rulers_on_source"

  create_table "situations", force: true do |t|
    t.string   "revision",    limit: 30, null: false
    t.string   "gvdate",      limit: 10, null: false
    t.datetime "update_time",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "situations", ["gvdate"], name: "index_situations_on_gvdate"
  add_index "situations", ["revision"], name: "index_situations_on_revision", unique: true

end
