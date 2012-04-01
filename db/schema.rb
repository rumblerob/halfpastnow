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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120401054254) do

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "venue_id"
  end

  add_index "events", ["venue_id"], :name => "index_events_on_venue_id"

  create_table "events_tags", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "tag_id"
  end

  create_table "occurrences", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recurrence_id"
    t.integer  "day_of_week"
  end

  add_index "occurrences", ["event_id"], :name => "index_occurrences_on_event_id"
  add_index "occurrences", ["recurrence_id"], :name => "index_occurrences_on_recurrence_id"

  create_table "raw_events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start"
    t.datetime "end"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "venue_name"
    t.string   "venue_address"
    t.string   "venue_city"
    t.string   "venue_state"
    t.string   "venue_zip"
    t.string   "url"
    t.string   "raw_id"
    t.string   "from"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted"
    t.boolean  "submitted"
  end

  create_table "raw_venues", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.integer  "zip"
    t.string   "state_code"
    t.string   "phone"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "rating"
    t.integer  "review_count"
    t.text     "categories"
    t.text     "neighborhoods"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name2"
  end

  create_table "recurrences", :force => true do |t|
    t.integer  "interval"
    t.integer  "every_other"
    t.integer  "day_of_week"
    t.integer  "day_of_month"
    t.integer  "week_of_month"
    t.date     "range_start"
    t.date     "range_end"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  add_index "recurrences", ["event_id"], :name => "index_recurrences_on_event_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "parent_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phonenumber"
  end

end
