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

ActiveRecord::Schema.define(version: 20161215165348) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "factors", force: :cascade do |t|
    t.string "name"
  end

  create_table "film_factors", force: :cascade do |t|
    t.integer "film_id"
    t.integer "factor_id"
    t.decimal "value",     precision: 20, scale: 10
  end

  add_index "film_factors", ["factor_id"], name: "index_film_factors_on_factor_id", using: :btree
  add_index "film_factors", ["film_id"], name: "index_film_factors_on_film_id", using: :btree

  create_table "films", force: :cascade do |t|
    t.string   "title"
    t.string   "director"
    t.integer  "year"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.decimal  "base_predictor", precision: 20, scale: 10, default: 0.0
  end

  add_index "films", ["director"], name: "index_films_on_director", using: :btree
  add_index "films", ["title", "director", "year"], name: "index_films_on_title_and_director_and_year", unique: true, using: :btree
  add_index "films", ["title"], name: "index_films_on_title", using: :btree
  add_index "films", ["year"], name: "index_films_on_year", using: :btree

  create_table "films_tags", force: :cascade do |t|
    t.integer  "film_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "films_tags", ["film_id"], name: "index_films_tags_on_film_id", using: :btree
  add_index "films_tags", ["tag_id"], name: "index_films_tags_on_tag_id", using: :btree

  create_table "preferences", force: :cascade do |t|
    t.integer  "favfilm_id"
    t.integer  "fan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["fan_id"], name: "index_preferences_on_fan_id", using: :btree
  add_index "preferences", ["favfilm_id"], name: "index_preferences_on_favfilm_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "film_id"
    t.integer  "user_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["film_id"], name: "index_ratings_on_film_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "svd_params", force: :cascade do |t|
    t.string  "name"
    t.decimal "value", precision: 20, scale: 10
  end

  add_index "svd_params", ["name"], name: "index_svd_params_on_name", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["title"], name: "index_tags_on_title", using: :btree

  create_table "user_factors", force: :cascade do |t|
    t.integer "user_id"
    t.integer "factor_id"
    t.decimal "value",     precision: 20, scale: 10
  end

  add_index "user_factors", ["factor_id"], name: "index_user_factors_on_factor_id", using: :btree
  add_index "user_factors", ["user_id"], name: "index_user_factors_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.decimal  "base_predictor",  precision: 20, scale: 10, default: 0.0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "users_tags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_tags", ["tag_id"], name: "index_users_tags_on_tag_id", using: :btree
  add_index "users_tags", ["user_id"], name: "index_users_tags_on_user_id", using: :btree

end
