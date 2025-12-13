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

ActiveRecord::Schema[7.2].define(version: 2025_12_13_020653) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "business_hours", force: :cascade do |t|
    t.bigint "roaster_id", null: false
    t.integer "day_of_week", null: false
    t.time "opens_at"
    t.time "closes_at"
    t.boolean "is_closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roaster_id", "day_of_week"], name: "index_business_hours_on_roaster_id_and_day_of_week"
    t.index ["roaster_id"], name: "index_business_hours_on_roaster_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "coffee_variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["coffee_variant_id"], name: "index_cart_items_on_coffee_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "roaster_id", null: false
    t.string "name", limit: 50, null: false
    t.text "description"
    t.string "color", limit: 7
    t.string "icon", limit: 50
    t.boolean "is_active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_categories_on_is_active"
    t.index ["position"], name: "index_categories_on_position"
    t.index ["roaster_id", "name"], name: "index_categories_on_roaster_id_and_name", unique: true
    t.index ["roaster_id"], name: "index_categories_on_roaster_id"
  end

  create_table "coffee_categories", force: :cascade do |t|
    t.bigint "coffee_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_coffee_categories_on_category_id"
    t.index ["coffee_id", "category_id"], name: "index_coffee_categories_on_coffee_id_and_category_id", unique: true
    t.index ["coffee_id"], name: "index_coffee_categories_on_coffee_id"
  end

  create_table "coffee_variants", force: :cascade do |t|
    t.bigint "coffee_id", null: false
    t.string "grind_type", limit: 50
    t.string "bag_size", limit: 20
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bag_size"], name: "index_coffee_variants_on_bag_size"
    t.index ["coffee_id"], name: "index_coffee_variants_on_coffee_id"
    t.index ["grind_type"], name: "index_coffee_variants_on_grind_type"
    t.index ["price"], name: "index_coffee_variants_on_price"
    t.index ["stock"], name: "index_coffee_variants_on_stock"
  end

  create_table "coffees", force: :cascade do |t|
    t.bigint "roaster_id", null: false
    t.string "name", limit: 100, null: false
    t.text "description"
    t.string "origin_country", limit: 100
    t.string "varietal", limit: 100
    t.string "process_method", limit: 50
    t.string "roast_level", limit: 50
    t.text "flavor_notes"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "featured", default: false, null: false
    t.string "slug"
    t.index ["featured"], name: "index_coffees_on_featured"
    t.index ["is_active"], name: "index_coffees_on_is_active"
    t.index ["name"], name: "index_coffees_on_name"
    t.index ["origin_country"], name: "index_coffees_on_origin_country"
    t.index ["roast_level"], name: "index_coffees_on_roast_level"
    t.index ["roaster_id"], name: "index_coffees_on_roaster_id"
    t.index ["slug"], name: "index_coffees_on_slug", unique: true
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "favoritable_type", null: false
    t.bigint "favoritable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable"
    t.index ["user_id", "favoritable_type", "favoritable_id"], name: "index_favorites_on_user_and_favoritable", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "coffee_variant_id", null: false
    t.integer "quantity"
    t.decimal "unit_price", precision: 10, scale: 2
    t.index ["coffee_variant_id"], name: "index_order_items_on_coffee_variant_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "roaster_id", null: false
    t.string "status", limit: 30, default: "pending", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.string "pickup_or_delivery", limit: 20
    t.text "qr_code_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["roaster_id"], name: "index_orders_on_roaster_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "roaster_id", null: false
    t.decimal "rating", precision: 3, scale: 2, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["roaster_id"], name: "index_reviews_on_roaster_id"
    t.index ["user_id", "roaster_id"], name: "index_reviews_on_user_id_and_roaster_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "roaster_applications", force: :cascade do |t|
    t.string "email", null: false
    t.string "roaster_name", null: false
    t.string "full_name", null: false
    t.text "comment"
    t.string "website_url"
    t.string "phone_number"
    t.string "type_of_business", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.decimal "average_rating", default: "0.0", null: false
    t.boolean "delivery_available", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "tags"
    t.index ["active"], name: "index_roasters_on_active"
    t.index ["delivery_available"], name: "index_roasters_on_delivery_available"
    t.index ["name"], name: "index_roasters_on_name"
    t.index ["slug"], name: "index_roasters_on_slug", unique: true
  end

  create_table "subscription_items", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.bigint "coffee_variant_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coffee_variant_id"], name: "index_subscription_items_on_coffee_variant_id"
    t.index ["subscription_id"], name: "index_subscription_items_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "day_of_month"
    t.boolean "active"
    t.datetime "last_order_created_at"
    t.string "name"
    t.string "pickup_or_delivery", default: "delivery"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_hours", "roasters"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "coffee_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "roasters"
  add_foreign_key "coffee_categories", "categories"
  add_foreign_key "coffee_categories", "coffees"
  add_foreign_key "coffee_variants", "coffees"
  add_foreign_key "coffees", "roasters"
  add_foreign_key "favorites", "users"
  add_foreign_key "order_items", "coffee_variants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "roasters"
  add_foreign_key "orders", "users"
  add_foreign_key "reviews", "roasters"
  add_foreign_key "reviews", "users"
  add_foreign_key "roaster_memberships", "roasters"
  add_foreign_key "roaster_memberships", "users"
  add_foreign_key "subscription_items", "coffee_variants"
  add_foreign_key "subscription_items", "subscriptions"
  add_foreign_key "subscriptions", "users"
end
