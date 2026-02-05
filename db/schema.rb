# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_04_155517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bills", force: :cascade do |t|
    t.string "bill_type", null: false
    t.integer "congress", null: false
    t.datetime "created_at", null: false
    t.string "current_status"
    t.date "current_status_date"
    t.date "introduced_on"
    t.integer "number", null: false
    t.string "short_title"
    t.string "source_path"
    t.text "summary"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["congress", "bill_type", "number"], name: "index_bills_on_congress_and_bill_type_and_number", unique: true
    t.index ["introduced_on"], name: "index_bills_on_introduced_on"
  end

  create_table "divisions", force: :cascade do |t|
    t.string "country"
    t.string "county"
    t.datetime "created_at", null: false
    t.string "district"
    t.string "level"
    t.string "name"
    t.string "ocd_id", null: false
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["ocd_id"], name: "index_divisions_on_ocd_id", unique: true
  end

  create_table "office_holdings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "office_id", null: false
    t.bigint "person_id", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_office_holdings_on_office_id"
    t.index ["person_id"], name: "index_office_holdings_on_person_id"
  end

  create_table "offices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.string "google_civic_office_id"
    t.string "name"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_offices_on_division_id"
  end

  create_table "people", force: :cascade do |t|
    t.jsonb "address_json", default: {}
    t.string "bioguide_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "google_civic_person_id"
    t.string "govtrack_id"
    t.string "name", null: false
    t.string "party"
    t.string "phone"
    t.string "photo_url"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["bioguide_id"], name: "index_people_on_bioguide_id"
    t.index ["google_civic_person_id"], name: "index_people_on_google_civic_person_id"
    t.index ["govtrack_id"], name: "index_people_on_govtrack_id"
  end

  add_foreign_key "office_holdings", "offices"
  add_foreign_key "office_holdings", "people"
  add_foreign_key "offices", "divisions"
end
