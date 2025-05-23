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

ActiveRecord::Schema[8.0].define(version: 2025_04_10_054114) do
  create_table "answers", force: :cascade do |t|
    t.integer "problem_id", null: false
    t.text "user_code"
    t.string "result"
    t.text "output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error_log"
    t.index ["problem_id"], name: "index_answers_on_problem_id"
  end

  create_table "problems", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "initial_code"
    t.text "test_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "expected_output"
  end

  add_foreign_key "answers", "problems"
end
