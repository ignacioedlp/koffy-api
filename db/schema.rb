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

ActiveRecord::Schema[7.2].define(version: 2025_11_23_224646) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "roaster_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "roaster_id", null: false
    t.string "role", default: "member", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "salary", precision: 10, scale: 2
    t.string "currency", default: "USD", null: false
    t.string "salary_period", default: "monthly", null: false
    t.index ["active"], name: "index_roaster_memberships_on_active"
    t.index ["roaster_id", "role"], name: "index_roaster_memberships_on_roaster_and_role"
    t.index ["roaster_id", "role"], name: "index_roaster_memberships_on_roaster_id_and_role"
    t.index ["roaster_id"], name: "index_roaster_memberships_on_roaster_id"
    t.index ["salary"], name: "index_roaster_memberships_on_salary"
    t.index ["salary_period"], name: "index_roaster_memberships_on_salary_period"
    t.index ["user_id", "roaster_id"], name: "index_roaster_memberships_on_user_and_roaster", unique: true
    t.index ["user_id", "roaster_id"], name: "index_roaster_memberships_on_user_id_and_roaster_id", unique: true
    t.index ["user_id"], name: "index_roaster_memberships_on_user_id"
  end

  create_table "roasters", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.text "description"
    t.text "logo_url"
    t.decimal "average_rating", default: "0.0", null: false
    t.boolean "delivery_available", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_roasters_on_active"
    t.index ["delivery_available"], name: "index_roasters_on_delivery_available"
    t.index ["name"], name: "index_roasters_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.text "profile_picture_url"
    t.text "preferred_grind_method"
    t.text "preferred_roast_level"
    t.text "preferred_bag_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "roaster_memberships", "roasters"
  add_foreign_key "roaster_memberships", "users"
end
