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

ActiveRecord::Schema[8.1].define(version: 2026_06_22_020000) do
  create_table "budget_targets", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "month", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["category_id", "year", "month"], name: "index_budget_targets_on_category_id_and_year_and_month", unique: true
    t.index ["category_id"], name: "index_budget_targets_on_category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "household_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "name"], name: "index_categories_on_household_id_and_name", unique: true
    t.index ["household_id"], name: "index_categories_on_household_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "household_id", null: false
    t.date "paid_on", null: false
    t.boolean "shared", default: true, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["household_id", "paid_on"], name: "index_expenses_on_household_id_and_paid_on"
    t.index ["household_id"], name: "index_expenses_on_household_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "household_id", null: false
    t.integer "invited_by_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_invitations_on_household_id"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "settlements", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "creditor_id", null: false
    t.integer "debtor_id", null: false
    t.integer "household_id", null: false
    t.integer "month", null: false
    t.datetime "settled_at"
    t.integer "settled_by_id"
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["creditor_id"], name: "index_settlements_on_creditor_id"
    t.index ["debtor_id"], name: "index_settlements_on_debtor_id"
    t.index ["household_id", "year", "month"], name: "index_settlements_on_household_id_and_year_and_month", unique: true
    t.index ["household_id"], name: "index_settlements_on_household_id"
    t.index ["settled_by_id"], name: "index_settlements_on_settled_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "household_id"
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["household_id"], name: "index_users_on_household_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "budget_targets", "categories"
  add_foreign_key "categories", "households"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "households"
  add_foreign_key "expenses", "users"
  add_foreign_key "invitations", "households"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "settlements", "households"
  add_foreign_key "settlements", "users", column: "creditor_id"
  add_foreign_key "settlements", "users", column: "debtor_id"
  add_foreign_key "settlements", "users", column: "settled_by_id"
  add_foreign_key "users", "households"
end
