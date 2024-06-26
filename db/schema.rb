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

ActiveRecord::Schema[7.1].define(version: 2024_05_31_050708) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "financial_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "institution_name"
    t.bigint "balance"
    t.string "category"
    t.string "subcategory"
    t.string "last4"
    t.string "stripe_financial_connections_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_transaction_refresh"
    t.index ["stripe_financial_connections_account_id"], name: "idx_on_stripe_financial_connections_account_id_c62ed637c6", unique: true
    t.index ["user_id"], name: "index_financial_accounts_on_user_id"
  end

  create_table "spending_category_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "spending_category"
    t.string "pattern", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pattern"], name: "index_spending_category_rules_on_pattern", unique: true
    t.index ["user_id"], name: "index_spending_category_rules_on_user_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "financial_account_id", null: false
    t.bigint "amount"
    t.string "currency"
    t.string "description"
    t.string "status"
    t.string "stripe_transaction_id"
    t.datetime "posted_at"
    t.datetime "void_at"
    t.datetime "transacted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "spending_category"
    t.index ["financial_account_id"], name: "index_transactions_on_financial_account_id"
    t.index ["stripe_transaction_id"], name: "index_transactions_on_stripe_transaction_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.string "stripe_customer_id"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "financial_accounts", "users"
  add_foreign_key "spending_category_rules", "users"
  add_foreign_key "transactions", "financial_accounts"
end
