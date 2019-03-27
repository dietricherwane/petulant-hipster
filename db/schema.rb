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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190327055332) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "custom_logs", force: true do |t|
    t.text     "sender_service"
    t.text     "message"
    t.text     "msisdn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.string   "label"
    t.string   "uuid"
    t.string   "login"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "service_id"
    t.string   "encrypted_password"
    t.string   "iv"
    t.string   "key"
    t.binary   "bytea_password"
    t.integer  "user_id"
    t.string   "sender"
    t.boolean  "status"
    t.string   "md5_password"
    t.integer  "sms_provider_id"
    t.integer  "bulk"
    t.integer  "bulk_email"
    t.boolean  "sms_allowed"
    t.boolean  "email_allowed"
    t.string   "email"
    t.string   "clear_password"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_logs", force: true do |t|
    t.integer  "subscriber_id"
    t.string   "email"
    t.integer  "profile_id"
    t.text     "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_transaction_id"
    t.string   "subject"
    t.string   "sender"
  end

  create_table "email_transactions", force: true do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "profile_id"
    t.text     "description"
    t.integer  "send_messages"
    t.integer  "failed_messages"
    t.integer  "number_of_messages"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  create_table "message_logs", force: true do |t|
    t.integer  "subscriber_id"
    t.integer  "profile_id"
    t.integer  "period_id"
    t.integer  "sms_transaction_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",             limit: 200
    t.string   "message_id",         limit: 200
    t.string   "msisdn"
    t.integer  "customer_id"
    t.integer  "user_id"
  end

  add_index "message_logs", ["period_id"], name: "index_message_logs_on_period_id", using: :btree
  add_index "message_logs", ["profile_id"], name: "index_message_logs_on_profile_id", using: :btree
  add_index "message_logs", ["sms_transaction_id"], name: "index_message_logs_on_sms_transaction_id", using: :btree
  add_index "message_logs", ["subscriber_id"], name: "index_message_logs_on_subscriber_id", using: :btree

  create_table "parameters", force: true do |t|
    t.string   "sms_provider_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sms_provider_token"
    t.text     "sms_provider_token_ext"
    t.string   "routesms_provider_url"
    t.string   "routesms_provider_username"
    t.string   "routesms_provider_password"
    t.string   "infobip_provider_url"
    t.string   "infobip_provider_username"
    t.string   "infobip_provider_password"
    t.string   "profile_separator"
  end

  create_table "periods", force: true do |t|
    t.string   "name",           limit: 100
    t.integer  "number_of_days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_data", force: true do |t|
    t.integer  "profile_id"
    t.boolean  "published"
    t.string   "col1"
    t.string   "col2"
    t.string   "col3"
    t.string   "col4"
    t.string   "col5"
    t.string   "col6"
    t.string   "col7"
    t.string   "col8"
    t.string   "col9"
    t.string   "col10"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "row_content"
  end

  create_table "profiles", force: true do |t|
    t.string   "name",              limit: 100
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "customer_id"
    t.string   "col1a"
    t.string   "col2a"
    t.string   "col3a"
    t.string   "col4a"
    t.string   "col5a"
    t.string   "col6a"
    t.string   "col7a"
    t.string   "col8a"
    t.string   "col9a"
    t.string   "col10a"
    t.integer  "number_of_columns"
    t.text     "aliases"
    t.integer  "msisdn_column"
    t.boolean  "email"
    t.integer  "email_column"
  end

  create_table "registration_logs", force: true do |t|
    t.integer  "subscriber_id"
    t.integer  "profile_id"
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registration_logs", ["period_id"], name: "index_registration_logs_on_period_id", using: :btree
  add_index "registration_logs", ["profile_id"], name: "index_registration_logs_on_profile_id", using: :btree
  add_index "registration_logs", ["subscriber_id"], name: "index_registration_logs_on_subscriber_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sms_providers", force: true do |t|
    t.string   "name",       limit: 100
    t.string   "url",        limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_transactions", force: true do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "profile_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "send_messages",      limit: 8
    t.integer  "failed_messages",    limit: 8
    t.integer  "number_of_messages", limit: 8
    t.string   "sender_service"
    t.integer  "user_id"
    t.string   "service_id"
    t.integer  "customer_id"
  end

  add_index "sms_transactions", ["profile_id"], name: "index_sms_transactions_on_profile_id", using: :btree

  create_table "subscribers", force: true do |t|
    t.string   "name",                     limit: 100
    t.integer  "profile_id"
    t.integer  "period_id"
    t.datetime "last_registration_date"
    t.integer  "last_registration_period"
    t.integer  "registrations_times"
    t.integer  "received_messages"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "msisdn"
  end

  add_index "subscribers", ["period_id"], name: "index_subscribers_on_period_id", using: :btree
  add_index "subscribers", ["profile_id"], name: "index_subscribers_on_profile_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
