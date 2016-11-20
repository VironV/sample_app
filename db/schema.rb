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

ActiveRecord::Schema.define(version: 20161109122938) do

  create_table "films", force: :cascade do |t|
    t.string   "title"
    t.string   "director"
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "films", ["director"], name: "index_films_on_director"
  add_index "films", ["title", "director", "year"], name: "index_films_on_title_and_director_and_year", unique: true
  add_index "films", ["title"], name: "index_films_on_title"
  add_index "films", ["year"], name: "index_films_on_year"

  create_table "films_tags", force: :cascade do |t|
    t.integer  "film_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "films_tags", ["film_id"], name: "index_films_tags_on_film_id"
  add_index "films_tags", ["tag_id"], name: "index_films_tags_on_tag_id"

  create_table "preferences", force: :cascade do |t|
    t.integer  "favfilm_id"
    t.integer  "fan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["fan_id"], name: "index_preferences_on_fan_id"
  add_index "preferences", ["favfilm_id"], name: "index_preferences_on_favfilm_id"

  create_table "ratings", force: :cascade do |t|
    t.integer  "film_id"
    t.integer  "user_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["film_id"], name: "index_ratings_on_film_id"
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "tags", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "users_tags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_tags", ["tag_id"], name: "index_users_tags_on_tag_id"
  add_index "users_tags", ["user_id"], name: "index_users_tags_on_user_id"

end
