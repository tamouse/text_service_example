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

ActiveRecord::Schema[7.0].define(version: 2022_11_30_173518) do
  create_table "message_errors", force: :cascade do |t|
    t.integer "message_id", null: false
    t.string "status_code"
    t.text "message"
    t.text "raw_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_errors_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "phone_id", null: false
    t.text "body"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_id"], name: "index_messages_on_phone_id"
  end

  create_table "phone_errors", force: :cascade do |t|
    t.integer "phone_id", null: false
    t.integer "status_code"
    t.text "message"
    t.text "raw_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_id"], name: "index_phone_errors_on_phone_id"
  end

  create_table "phones", force: :cascade do |t|
    t.string "number"
    t.string "status"
    t.boolean "valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_errors", force: :cascade do |t|
    t.string "status"
    t.boolean "active"
    t.text "message"
    t.text "raw_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string "endpoint"
    t.decimal "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "message_errors", "messages"
  add_foreign_key "messages", "phones"
  add_foreign_key "phone_errors", "phones"
end
