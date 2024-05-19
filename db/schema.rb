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

ActiveRecord::Schema[7.1].define(version: 2024_05_19_025634) do
  create_table "transactions", force: :cascade do |t|
    t.date "posted_on"
    t.string "description"
    t.string "category"
    t.string "direction"
    t.string "transaction_type"
    t.bigint "amount"
    t.bigint "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
