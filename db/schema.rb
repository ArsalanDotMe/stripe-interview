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

ActiveRecord::Schema.define(version: 2021_09_29_123057) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "country_code"
    t.string "locale"
    t.string "name"
    t.jsonb "payment_credentials"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.string "secret"
    t.integer "subscription_price"
    t.jsonb "appearance_data"
    t.integer "article_price"
    t.string "subscription_name"
    t.boolean "live_mode", default: false
    t.integer "test_subscription_price"
    t.integer "test_article_price"
    t.string "test_subscription_name"
    t.string "currency", default: "eur"
    t.boolean "phone_payments_enabled", default: false
    t.string "contact_person_name"
    t.string "company_registration_number"
    t.string "phone_number"
    t.string "plugin_version"
    t.string "domain"
    t.boolean "applepay_enabled", default: true
    t.boolean "googlepay_enabled", default: true
    t.integer "sendgrid_domain_id"
    t.string "sendgrid_domain"
    t.jsonb "email_data"
    t.string "sendgrid_contact_list_id"
    t.string "address_line1"
    t.string "city"
    t.string "business_type"
    t.boolean "subscription_notifications", default: false
    t.bigint "live_active_price_plan_id"
    t.bigint "test_active_price_plan_id"
    t.index ["live_active_price_plan_id"], name: "index_clients_on_live_active_price_plan_id"
    t.index ["test_active_price_plan_id"], name: "index_clients_on_test_active_price_plan_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "phone"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "client_id", null: false
    t.index ["client_id"], name: "index_customers_on_client_id"
    t.index ["phone", "email", "client_id"], name: "index_customers_on_phone_and_email_and_client_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.datetime "expires_at"
    t.string "payment_provider"
    t.string "provider_subscription_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state", default: "initial", null: false
    t.string "order_reference"
    t.jsonb "provider_response"
    t.bigint "client_id", null: false
    t.boolean "live_mode", default: false
    t.string "article_title"
    t.string "content_id"
    t.integer "price"
    t.datetime "invoiced_at"
    t.string "wallet"
    t.string "last_payment_error"
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "subscription_id"
    t.bigint "customer_id"
    t.bigint "client_id", null: false
    t.string "purpose"
    t.string "status"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.bigint "purchase_id"
    t.jsonb "provider_response"
    t.boolean "live_mode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "payment_provider", default: "undefined", null: false
    t.index ["client_id"], name: "index_transactions_on_client_id"
    t.index ["customer_id"], name: "index_transactions_on_customer_id"
    t.index ["purchase_id"], name: "index_transactions_on_purchase_id"
    t.index ["subscription_id"], name: "index_transactions_on_subscription_id"
  end
  
  add_foreign_key "customers", "clients"
  add_foreign_key "subscriptions", "clients"
  add_foreign_key "subscriptions", "customers"
  add_foreign_key "transactions", "clients"
  add_foreign_key "transactions", "customers"
  add_foreign_key "transactions", "purchases"
  add_foreign_key "transactions", "subscriptions"
end
